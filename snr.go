package main

import (
	"database/sql"
	"flag"
	"fmt"
	"log"
	"os"
	"regexp"
	"strings"
	"sync"
	"time"
)

// Define the regular expression pattern for email addresses
var emailRegex = regexp.MustCompile(`(?i)\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b`)

func main() {
	// Parse command line arguments
	host := flag.String("host", "localhost", "Database host")
	port := flag.Int("port", 3306, "Database port")
	user := flag.String("user", "", "Database user")
	password := flag.String("password", "", "Database password")
	dbName := flag.String("dbname", "", "Database name")
	replaceDomain := flag.String("replace-domain", "", "Domain name to be replaced")
	withDomain := flag.String("with-domain", "", "Domain name to replace with")
	concurrency := flag.Int("concurrency", 4, "Number of goroutines to use for concurrency")
	logFile := flag.String("logfile", "", "Name of the log file to write")
	flag.Parse()
	startTime := time.Now()

	// Check if required flags are provided
	if *user == "" || *password == "" || *dbName == "" || *replaceDomain == "" || *withDomain == "" || *logFile == "" {
		flag.Usage()
		os.Exit(1)
	}

	// Define the regular expression pattern for the domain name to be replaced
	replaceRegex := regexp.MustCompile(fmt.Sprintf(`(?i)(?<=https?://)(?:www\.)?%s\.com`, regexp.QuoteMeta(*replaceDomain)))

	// Create database connection
	db, err := sql.Open("mysql", fmt.Sprintf("%s:%s@tcp(%s:%d)/%s", *user, *password, *host, *port, *dbName))
	if err != nil {
		log.Fatalf("Error connecting to database: %s", err)
	}
	defer db.Close()

	// Get a list of tables in the database
	tables, err := db.Query("SHOW TABLES")
	if err != nil {
		log.Fatalf("Error getting list of tables: %s", err)
	}
	defer tables.Close()

	// Create log file
	logFileHandle, err := os.Create(*logFile)
	if err != nil {
		log.Fatalf("Error creating log file: %s", err)
	}
	defer logFileHandle.Close()

	// Loop through each table and process them concurrently
	var wg sync.WaitGroup
	for tables.Next() {
		var tableName string
		err := tables.Scan(&tableName)
		if err != nil {
			log.Fatalf("Error scanning table name: %s", err)
		}

		// Query the table for all columns
		columns, err := db.Query(fmt.Sprintf("SELECT * FROM `%s`", tableName))
		if err != nil {
			log.Fatalf("Error querying table %s: %s", tableName, err)
		}

		// Get column names
		columnNames, err := columns.Columns()
		if err != nil {
			log.Fatalf("Error getting column names for table %s: %s", tableName, err)
		}
		columnValues := make([]interface{}, len(columnNames))
		columnValuePointers := make([]interface{}, len(columnNames))
		// Process rows in the table concurrently
		for i := 0; i < *concurrency; i++ {
			wg.Add(1)
			go func() {
				defer wg.Done()

				replacements := 0
				for columns.Next() {
					// Scan row data into columnValues slice
					if err := columns.Scan(columnValuePointers...); err != nil {
						log.Fatalf("Error scanning row data for table %s: %s", tableName, err)
					}

					// Loop through each column and replace domain name in text
					for i, columnValue := range columnValues {
						// Check if column value is nil, skip if nil
						if columnValue == nil {
							continue
						}

						// Convert column value to string
						columnValueString := fmt.Sprintf("%s", columnValue)

						// Check if column value contains email address, skip if it does
						if emailRegex.MatchString(columnValueString) {
							continue
						}

						// Replace domain name in column value using regular expression
						newColumnValueString := replaceRegex.ReplaceAllStringFunc(columnValueString, func(match string) string {
							// Check if the matched string is within an HTML tag or attribute
							if strings.HasPrefix(match, "<") && strings.HasSuffix(match, ">") {
								return match
							} else if strings.Contains(match, "=\"") || strings.Contains(match, "='") {
								return match
							}

							// Replace domain name in the matched string
							return strings.Replace(match, *replaceDomain+".com", *withDomain+".com", -1)
						})

						// Update column value in database if it has changed
						if newColumnValueString != columnValueString {
							_, err := db.Exec(fmt.Sprintf("UPDATE `%s` SET `%s` = ? WHERE `%s` = ?", tableName, columnNames[i], columnNames[i]), newColumnValueString, columnValueString)
							if err != nil {
								log.Fatalf("Error updating row data for table %s: %s", tableName, err)
							}
							replacements++
						}
					}
				}

				// Write to log file the number of replacements done for the table
				if replacements > 0 {
					logFileHandle.WriteString(fmt.Sprintf("%s: %d replacements\n", tableName, replacements))
				}
			}()
		}

		// Wait for all goroutines to finish
		wg.Wait()
	}
	// Log total time taken to complete the program
	log.Printf("Total time taken: %v", time.Since(startTime))
}

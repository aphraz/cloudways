#!/bin/bash

# Set the MySQL root password
MYSQL_ROOT_PASSWORD="your_password_here"

# Exclude the mysql database from the dump
EXCLUDE_DATABASES="mysql"

# Get a list of all MySQL databases
DATABASES=$(mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "SHOW DATABASES;" | grep -Ev "(Database|${EXCLUDE_DATABASES})")

# Drop and recreate each database from the dump file
for DATABASE in ${DATABASES}; do
  echo "Dropping database ${DATABASE}..."
  mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "DROP DATABASE IF EXISTS ${DATABASE};"
  echo "Creating database ${DATABASE}..."
  mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE ${DATABASE};"
  echo "Importing data into database ${DATABASE}..."
  mysql -u root -p"${MYSQL_ROOT_PASSWORD}" ${DATABASE} < "/path/to/dump/${DATABASE}.sql"
done


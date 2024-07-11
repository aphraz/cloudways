#!/bin/bash

# Directory to search
SEARCH_DIR=$1

# Output file
OUTPUT_FILE="output.txt"

if [ -z "$SEARCH_DIR" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Clear the output file if it exists
> $OUTPUT_FILE

# Find all files recursively and process them
find "$SEARCH_DIR" -type f | while read -r file; do
    # Write the full path of the file to the output file
    echo "File: $file" >> "$OUTPUT_FILE"
    # Append the content of the file to the output file
    cat "$file" >> "$OUTPUT_FILE"
    # Add a separator for readability
    echo -e "\n---- End of $file ----\n" >> "$OUTPUT_FILE"
done

echo "All files have been processed. Output saved to $OUTPUT_FILE."


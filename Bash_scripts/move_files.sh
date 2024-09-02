#!/bin/bash

# Define the source and destination directories
SOURCE_DIR="source_dir"  # Path to the source directory
DEST_DIR="json_and_CSV"  # Path to the destination directory

# Create destination directory if it does not exist
mkdir -p "$DEST_DIR"

# Print the contents of the source directory for debugging
echo "Contents of the source directory ($SOURCE_DIR):"
ls "$SOURCE_DIR"

# Move all CSV and JSON files to the destination directory
echo "Moving CSV and JSON files from $SOURCE_DIR to $DEST_DIR..."
mv "$SOURCE_DIR"/*.csv "$SOURCE_DIR"/*.json "$DEST_DIR"

# Check if the files were moved successfully
if [ $? -eq 0 ]; then
    echo "CSV and JSON files moved successfully to $DEST_DIR"
else
    echo "No CSV or JSON files found to move, or an error occurred."
fi


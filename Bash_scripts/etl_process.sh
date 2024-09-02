#!/bin/bash

# Define environment variables
export CSV_URL="https://www.stats.govt.nz/assets/Uploads/Annual-enterprise-survey/Annual-enterprise-survey-2023-financial-year-provisional/Download-data/annual-enterprise-survey-2023-financial-year-provisional.csv"  # Replace this with the actual URL of the CSV file
export RAW_DIR="raw"
export TRANSFORMED_DIR="Transformed"
export GOLD_DIR="Gold"
export CSV_FILE_NAME="file.csv"
export TRANSFORMED_FILE_NAME="2023_year_finance.csv"

# Create directories if they don't exist
mkdir -p $RAW_DIR
mkdir -p $TRANSFORMED_DIR
mkdir -p $GOLD_DIR

# Step 1: Extract - Download the CSV file
echo "Starting ETL process..."
echo "Extracting data from $CSV_URL..."
wget -q -O $RAW_DIR/$CSV_FILE_NAME $CSV_URL

# Confirm the file has been saved into the raw folder
if [ -f "$RAW_DIR/$CSV_FILE_NAME" ]; then
    echo "File successfully downloaded to $RAW_DIR/$CSV_FILE_NAME"
else
    echo "File download failed!"
    exit 1
fi

# Step 2: Transform - Rename the column and select specific columns
echo "Transforming data..."

# Read the CSV and perform the transformation using `awk`
awk -F, 'BEGIN {OFS=","} 
    NR==1 { 
        for (i=1; i<=NF; i++) { 
            if ($i == "Variable_code") $i="variable_code"; 
        } 
    } 
    { print $1, $5, $6, $9 }' $RAW_DIR/$CSV_FILE_NAME > $TRANSFORMED_DIR/$TRANSFORMED_FILE_NAME

# Confirm the file has been saved into the transformed folder
if [ -f "$TRANSFORMED_DIR/$TRANSFORMED_FILE_NAME" ]; then
    echo "File successfully transformed and saved to $TRANSFORMED_DIR/$TRANSFORMED_FILE_NAME"
else
    echo "File transformation failed!"
    exit 1
fi

# Step 3: Load - Move the transformed data into the Gold directory
echo "Loading data to $GOLD_DIR..."
mv $TRANSFORMED_DIR/$TRANSFORMED_FILE_NAME $GOLD_DIR

# Confirm the file has been saved into the gold folder
if [ -f "$GOLD_DIR/$TRANSFORMED_FILE_NAME" ]; then
    echo "File successfully loaded into $GOLD_DIR/$TRANSFORMED_FILE_NAME"
else
    echo "File loading failed!"
    exit 1
fi

echo "ETL process completed successfully!"

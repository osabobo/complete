#!/bin/bash

# Define database and user details
DB_NAME="posey"
DB_USER="postgres"  # Replace with your PostgreSQL username
DB_PASSWORD="password"  # Replace with your PostgreSQL password
CSV_DIR="csv_files"  # Directory where CSV files are stored
ERROR_LOG="error_log.txt"  # Log file for errors

# Export password for non-interactive psql sessions
export PGPASSWORD=$DB_PASSWORD

# Function to create tables with correct data types
create_table() {
    local table_name="$1"
    local create_sql="$2"

    echo "Creating table $table_name..."
    psql -U $DB_USER -d $DB_NAME -c "DROP TABLE IF EXISTS $table_name;"
    psql -U $DB_USER -d $DB_NAME -c "$create_sql"
}

# Function to import CSV data into tables
import_csv() {
    local table_name="$1"
    local file="$2"

    echo "Importing data into table $table_name from $file..."
    psql -U $DB_USER -d $DB_NAME -c "\copy $table_name FROM '$file' WITH CSV HEADER" 2>> $ERROR_LOG

    if [ $? -eq 0 ]; then
        echo "Data successfully imported into table $table_name."
    else
        echo "Error loading data from $file into table $table_name. Check $ERROR_LOG for details."
    fi
}

# Check if the CSV directory exists
if [ ! -d "$CSV_DIR" ]; then
    echo "Directory $CSV_DIR does not exist. Please create it and place your CSV files inside."
    exit 1
fi

# Create table structures with explicit data types
create_table "accounts" "CREATE TABLE accounts (id INTEGER, name TEXT, website TEXT, lat FLOAT, long FLOAT, primary_poc TEXT, sales_rep_id INTEGER);"
create_table "orders" "CREATE TABLE orders (id INTEGER, account_id INTEGER, occurred_at TIMESTAMP, standard_qty INTEGER, gloss_qty INTEGER, poster_qty INTEGER, total_qty INTEGER, standard_amt_usd FLOAT, gloss_amt_usd FLOAT, poster_amt_usd FLOAT, total_amt_usd FLOAT);"
create_table "region" "CREATE TABLE region (id INTEGER, name TEXT);"
create_table "sales_reps" "CREATE TABLE sales_reps (id INTEGER, name TEXT, region_id INTEGER);"
create_table "web_events" "CREATE TABLE web_events (id INTEGER, account_id INTEGER, occurred_at TIMESTAMP, channel TEXT);"

# Import CSV files into the corresponding tables
import_csv "accounts" "$CSV_DIR/accounts.csv"
import_csv "orders" "$CSV_DIR/orders.csv"
import_csv "region" "$CSV_DIR/region.csv"
import_csv "sales_reps" "$CSV_DIR/sales_reps.csv"
import_csv "web_events" "$CSV_DIR/web_events.csv"

# Unset the PGPASSWORD environment variable for security
unset PGPASSWORD

echo "CSV import process completed."


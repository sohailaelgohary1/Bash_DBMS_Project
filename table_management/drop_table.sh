#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")/.."
source "$SCRIPT_DIR/config.sh"

read -p "Enter table name to DROP: " table_name
echo "================================================"

# Validate input
if [[ -z "$table_name" ]]; then
    echo "<<----------------->>"
    echo -e "${RED}Error: Table name cannot be empty.${RESET}"
    echo "<<----------------->>"
    exit 1
fi

# Define table paths
TABLE_FILE="$table_name.txt"
RAW_DATA_FILE="raw_data_$table_name.txt"

# Check if table exists
if [[ ! -f "$TABLE_FILE" ]]; then
    echo "<<----------------->>"
    echo -e "${RED}Error: Table '$table_name' does not exist.${RESET}"
    echo "<<----------------->>"
    exit 1
fi

# Confirmation before deletion
read -p "Are you sure you want to drop the table '$table_name'? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "Table deletion canceled."
    exit 0
fi

# Delete the table files
rm -f "$TABLE_FILE" "$RAW_DATA_FILE"

# Verify deletion
if [[ ! -f "$TABLE_FILE" && ! -f "$RAW_DATA_FILE" ]]; then
    echo "<<----------------->>"
    echo -e "${GREEN}Table '$table_name' dropped successfully.${RESET}"
    echo "<<----------------->>"
else
    echo "<<----------------->>"
    echo -e "${RED}Error: Failed to delete table '$table_name'.${RESET}"
    echo "<<----------------->>"
fi


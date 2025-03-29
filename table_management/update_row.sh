#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")/.."
source "$SCRIPT_DIR/config.sh"

read -p "Enter the Name of the Table: " table_name
echo "================================================"

## Validation ##
if [ -z "$table_name" ]; then
    echo "<<----------------->>"
    echo -e "${RED}Error: Name of Table cannot be empty.${RESET}"
    echo "<<----------------->>"
    exit
fi

metadata_file="${table_name}.txt"
data_file="${table_name}.csv"

if [ ! -f "$metadata_file" ]; then
    echo "<<----------------->>"
    echo -e "${RED}Error: Table '$table_name' does not exist.${RESET}"
    echo "<<----------------->>"
    exit 1
fi

# Extract column names (line 2 in metadata)
columns_line=$(sed -n '2p' "$metadata_file" | tr -d '\r')  # Remove possible carriage return
IFS=':' read -ra columns_array <<< "$columns_line"

# Display available columns
echo -e "${GREEN}Available Columns: ${columns_array[*]}${RESET}"
echo "================================================"

# Ask for column to update
read -p "Enter the column name to update: " column_name

# Validate column existence (checking only names, not types)
found=0
for col in "${columns_array[@]}"; do
    col_name=$(echo "$col" | cut -d'(' -f1)  # Extract column name before '('
    if [[ "$col_name" == "$column_name" ]]; then
        found=1
        column_type=$(echo "$col" | grep -oP '(?<=\().*(?=\))')  # Extract type inside ()
        break
    fi
done

if [[ $found -eq 0 ]]; then
    echo -e "${RED}Error: Column '$column_name' does not exist.${RESET}"
    exit 1
fi

# Get primary key column
pk_column=$(sed -n '3p' "$metadata_file" | cut -d':' -f1)

if [[ "$column_name" == "$pk_column" ]]; then
    echo -e "${RED}Error: Cannot update the primary key '${pk_column}'.${RESET}"
    exit 1
fi

# Ask for old value
read -p "Enter the old value to update: " old_value
if [[ -z "$old_value" ]]; then
    echo -e "${RED}Error: Old value cannot be empty.${RESET}"
    exit 1


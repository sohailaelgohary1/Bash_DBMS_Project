#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")/.."
source "$SCRIPT_DIR/config.sh"

read -p "Enter table name: " table_name
echo "================================================"

metadata_file=${table_name}.txt
data_file= raw_data_${table_name}.txt

# Check if table exists
if [ ! -f "$metadata_file" ]; then
    echo -e "${RED}Error: Table '$table_name' does not exist.${RESET}"
    exit 1
fi

# Extract column names
start_line=4
columns_line=$(sed -n "${start_line}p" "$metadata_file")
columns=$(echo "$columns_line" | awk '{for (i=1; i<=NF; i++) if ($i != "pk:") { gsub(/\([^()]*\)/,"",$i); printf "%s ", $i } }')
columns_array=($columns)

# Display available columns
echo -e "${GREEN}Column Names: ${columns_array[@]}${RESET}"
echo "================================================"

# Ask the user for the column to delete from
read -p "Enter the column name to delete from: " columnToDelete

# Validation: Column should exist
if [[ ! " ${columns_array[@]} " =~ " ${columnToDelete} " ]]; then
    echo -e "${RED}Error: Column '$columnToDelete' does not exist in the table.${RESET}"
    exit 1
fi

# Prevent deletion from the primary key column
pk_column=$(awk -F ':' 'NR==3 {print $1}' "$metadata_file")
if [[ "$columnToDelete" == "$pk_column" ]]; then
    echo -e "${RED}Error: Cannot delete from the primary key column '${pk_column}'.${RESET}"
    exit 1
fi

echo -e "${BLUE}Available Data:${RESET}"
cat "$data_file"
echo "================================================"

# Ask for the value to delete
read -p "Enter the value of the column to delete: " valueToDelete

# Ensure value is not empty
if [[ -z "$valueToDelete" ]]; then
    echo -e "${RED}Error: Value to delete cannot be empty.${RESET}"
    exit 1
fi

# Find and delete matching rows
if grep -q "${columnToDelete}([^)]*)=${valueToDelete}" "$data_file"; then
    sed -i "/${columnToDelete}([^)]*)=${valueToDelete}/d" "$data_file"
    echo -e "${GREEN}Successfully deleted row where '$columnToDelete' = '$valueToDelete'.${RESET}"
else
    echo -e "${RED}Error: Value '$valueToDelete' not found in column '$columnToDelete'.${RESET}"
fi

# Display updated data
echo -e "${GREEN}Updated Table Data:${RESET}"
cat "$data_file"


#!/bin/bash
DB_DIR="./data"
read -p "Enter database name: " db_name
read -p "Enter table name: " table_name

table_path="$DB_DIR/$db_name/$table_name.csv"

if [ ! -f "$table_path" ]; then
    echo "Table does not exist!"
    exit 1
fi

read -p "Enter value to delete: " value
sed -i "/$value/d" "$table_path"

echo "Data deleted successfully!"


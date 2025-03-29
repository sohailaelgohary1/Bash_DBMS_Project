#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")/.."
source "$SCRIPT_DIR/config.sh"


read -p "Enter table name: " table_name
echo "================================================"

if [[ -z "$table_name" ]]; then
    echo "<<----------------->>"
    echo -e "${RED}Error: Table name cannot be empty.${RESET}"
    echo "<<----------------->>"
    exit 1
fi

if [[ "$table_name" =~ [^a-zA-Z0-9_] ]]; then
    echo "<<----------------->>"
    echo -e "${RED}Error: Invalid characters found in table name. Only letters, numbers, and underscores are allowed.${RESET}"
    echo "<<----------------->>"
    exit 1
fi

if [[ "$table_name" =~ ^[0-9] ]]; then
    echo "<<----------------->>"
    echo -e "${RED}Error: The first character cannot be a number.${RESET}"
    echo "<<----------------->>"
    exit 1
fi

table_file="$db_name/$table_name.txt"

if [[ -f "$table_file" ]]; then
    echo -e "${MAGENTA}<<<< Table '$table_name' already exists >>>>${RESET}"
    exit 1
fi

read -p "Please enter the number of columns: " numOfColumns
echo "================================================"

if ! [[ "$numOfColumns" =~ ^[1-9][0-9]*$ ]]; then
    echo "<<----------------->>"
    echo -e "${RED}Invalid input. Please enter a positive integer.${RESET}"
    echo "<<----------------->>"
    exit 1
fi

pk_set=false
pk_column=""
column_names=()

for ((i = 1; i <= numOfColumns; i++)); do
    read -p "Enter the name of column $i: " column_name
echo "================================================"

    if [[ -z "$column_name" ]]; then
        echo "<<----------------->>"
        echo -e "${RED}Error: Column name cannot be empty.${RESET}"
        echo "<<----------------->>"
        exit 1
    fi

    if [[ "$column_name" =~ [^a-zA-Z0-9_] ]]; then
        echo "<<----------------->>"
        echo -e "${RED}Error: Invalid characters found in column name.${RESET}"
        echo "<<----------------->>"
        exit 1
    fi

    if [[ "$column_name" =~ ^[0-9] ]]; then
        echo "<<----------------->>"
        echo -e "${RED}Error: The first character cannot be a number.${RESET}"
        echo "<<----------------->>"
        exit 1
    fi

    if [[ " ${column_names[@]} " =~ " $column_name " ]]; then
        echo "<<----------------->>"
        echo -e "${RED}Error: Duplicate column name '$column_name'. Column names must be unique.${RESET}"
        echo "<<----------------->>"
        exit 1
    fi

    read -p "Enter the type of this column (Text/Int): " column_type
    echo "================================================"

    column_type_lower=$(echo "$column_type" | tr '[:upper:]' '[:lower:]')
    if [[ "$column_type_lower" != "text" && "$column_type_lower" != "int" ]]; then
        echo "<<----------------->>"
        echo -e "${RED}Error: Invalid column type. Please enter 'Text' or 'Int'.${RESET}"
        echo "<<----------------->>"
        exit 1
    fi

    column_names+=("$column_name($column_type_lower)")

    if [[ "$pk_set" == false ]]; then
        read -p "Do you want to set this column as primary key? (y/n): " pk_answer
        echo "================================================"

        if [[ "$pk_answer" =~ ^[Yy]$ ]]; then
            if [[ "$column_type_lower" == "int" ]]; then
                pk_set=true
                pk_column="$column_name"
            else
                echo "<<----------------->>"
                echo -e "${RED}Error: Primary key must be of type Int.${RESET}"
                echo "<<----------------->>"
            fi
        fi
    fi

done

if [[ "$pk_set" == false ]]; then
    pk_column="id"
    column_names=("id(int)" "${column_names[@]}")
    echo -e "${GREEN}Generating default primary key column 'id'.${RESET}"
fi

touch "$table_name.txt"  
touch "raw_data_$table_name.txt"  

echo "$table_name:$column_count" > "$table_name.txt"
echo "$column_name:$column_type:$is_primary" >> "$table_name.txt"

touch "raw_data_$table_name.txt"

echo -e "${GREEN}Table '$table_name' created successfully.${RESET}"
echo "<<----------------->>"
read -p "Press Enter to continue..."


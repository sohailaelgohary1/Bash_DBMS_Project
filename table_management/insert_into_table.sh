#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")/.."
source "$SCRIPT_DIR/config.sh"

read -p "Enter the Name of the Table: " table_name
echo "================================================"

# Validate input
if [[ -z "$table_name" ]]; then
    echo "<<----------------->>"
    echo -e "${RED}Error: Table name cannot be empty.${RESET}"
    echo "<<----------------->>"
    exit 1
fi

TABLE_FILE="$table_name.txt"

# Check if table exists
if [[ ! -f "$TABLE_FILE" ]]; then
    echo "<<----------------->>"
    echo -e "${RED}Error: Table '$table_name' does not exist.${RESET}"
    echo "<<----------------->>"
    exit 1
fi

declare -a column_arr
read -r numColumns < <(awk -F ' ' '/Number of Columns:/ {print $NF}' "$table_file")
pk_column=$(awk -F '[: ]' '$3 == "pk" {print $1}' "$table_file")
read -ra column_arr < <(awk 'NR==4 {print $0}' "$table_file")

# Find the position of the primary key column
pk_column_position=$(awk -F '  ' -v pk="$pk_column" 'NR==4 {
    for (i=1; i<=NF; i++) { 
        gsub(/\(.*\)/, "", $i); 
        if ($i == pk) print i; 
    } 
    exit;
}' "$table_file")

values=()
pk_column_found=false

for ((i=0; i<numColumns; i++)); do  
    column_name=$(echo "${column_arr[i]}" | awk -F '(' '{print $1}')
    column_type=$(echo "${column_arr[i]}" | awk -F '(' '{print tolower($2)}' | tr -d ')')

    if [[ "$column_name" == "$pk_column" ]]; then
        pk_column_found=true
        read -p "Enter Value for ${column_arr[i]}: " value
        echo "================================================"

        if [ -z "$value" ]; then
            echo "<<----------------->>"
            echo -e "${RED}Error: Primary key '$pk_column' cannot be empty.${RESET}"
            echo "<<----------------->>"
            exit 1
        fi

        if ! [[ "$value" =~ ^[0-9]+$ ]]; then
            echo "<<----------------->>"
            echo -e "${RED}Error: Invalid input. Enter a valid integer.${RESET}"
            echo "<<----------------->>"
            exit 1
        fi

        # Check for duplicate primary key
        if awk -F '=' -v pos="$pk_column_position" -v val="$value" '
            {split($pos, arr, " "); if (arr[1] == val) exit 1}
        ' "raw_data_${tableName}.txt"; then
            echo "<<----------------->>"
            echo -e "${RED}Error: Duplicate value found for primary key '$pk_column'.${RESET}"
            echo "<<----------------->>"
            exit 1
        fi

        values+=("${column_arr[i]}=$value")
    else
        case $column_type in 
            text)    
                read -p "Enter Value for ${column_arr[i]}: " value
                echo "================================================"
                if [ -z "$value" ]; then value="null"; fi
                ;;
            int) 
                read -p "Enter Value for ${column_arr[i]}: " value
                echo "================================================"
                if ! [[ "$value" =~ ^[0-9]+$ ]]; then
                    echo "<<----------------->>"
                    echo -e "${RED}Error: Invalid input. Enter a valid integer.${RESET}"
                    echo "<<----------------->>"
                    exit 1
                fi
                ;;
            *)
                echo "<<----------------->>"
                echo -e "${RED}Error: Invalid column type.${RESET}"
                echo "<<----------------->>"
                exit 1
                ;;
        esac 
        values+=("${column_arr[i]}=$value")
    fi  

done

if ! $pk_column_found; then
    if [ "$pk_column" == "my_pk" ]; then
        latest_pk_value=$(awk -F '=' '{print $NF}' "raw_data_${tableName}.txt" | sort -n | tail -n 1)
        if [ -z "$latest_pk_value" ]; then
            pk_value=1
        else
            pk_value=$((latest_pk_value + 1))
        fi
        values+=("my_pk(int)=$pk_value")
    else
        echo "<<----------------->>"
        echo -e "${RED}Error: Primary Key column not found.${RESET}"
        echo "<<----------------->>"
        exit 1
    fi
fi

columns_values=$(IFS=' '; echo "${values[*]}")
echo -e "${CYAN}INSERT INTO ${table_file} VALUES ( $columns_values )${RESET}"

echo "$columns_values" >> "raw_data_${table_file}"
echo -e "${GREEN}<<<< Record inserted successfully.>>>>${RESET}"


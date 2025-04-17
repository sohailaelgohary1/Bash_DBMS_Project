#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")/.."
source "$SCRIPT_DIR/config.sh"

# Ask for a valid table name
while true; do
    read -p "Enter Table Name: " table_name
    echo "================================================"

    if [ -z "$table_name" ]; then
        echo "<<----------------->>"
        echo -e "${RED}Error: Name of Table cannot be empty.${RESET}"
        echo "<<----------------->>"
        continue
    fi

    invalid_char1=$(echo "$table_name" | grep -o '[^a-zA-Z0-9_]')
    if [ -n "$invalid_char1" ]; then
        echo "<<----------------->>"
        echo -e "${RED}Error: Invalid characters found in Table name: $invalid_char1${RESET}"
        echo "<<----------------->>"
        continue
    fi

    if [[ $table_name =~ ^[0-9] ]]; then
        echo "<<----------------->>"
        echo -e "${RED}Error: The first character cannot be a number.${RESET}"
        echo "<<----------------->>"
        continue
    fi

    # Convert to lowercase
    tableName_lower=$(echo "$table_name" | tr '[:upper:]' '[:lower:]')
    metadata_file="${tableName_lower}.txt"

    if [ ! -f "$metadata_file" ]; then
        echo "<<----------------->>"
        echo -e "${RED}Error: Table '$table_name' does not exist.${RESET}"
        echo "<<----------------->>"
        continue
    fi

    break  # if all validations pass
done


    start_line=4
    columns_line=$(sed -n "${start_line}p" "$metadata_file")
    columns=$(echo "$columns_line" | awk '{for (i=1; i<=NF; i++) if ($i != "pk:") { gsub(/\([^()]*\)/,"",$i); printf "%s ", $i } }')
    columns_array=($columns)

    # Display column names
    echo -e "${GREEN}Column Names: ${columns_array[@]}${RESET}"
    echo "<<----------------->>"

    echo -e "${BLUE}Choose The Columns To Update :${RESET}"
    echo "================================================"
    cat "raw_data_${metadata_file}"

    # Ask the user for the column to update
while true; do
    read -p "Enter the name of the column to update: " columName
    columnToUpdate=$(echo "$columName" | tr '[:upper:]' '[:lower:]')

    if [ -z "$columnToUpdate" ]; then
        echo "<<----------------->>"
        echo -e "${RED}Error: Name of column cannot be empty.${RESET}"
        echo "<<----------------->>"
        continue
    fi

    if [[ $columnToUpdate =~ ^[0-9] ]]; then
        echo "<<----------------->>"
        echo -e "${RED}Error: The first character cannot be a number.${RESET}"
        echo "<<----------------->>"
        continue
    fi

    if [[ $columnToUpdate =~ ^[0-9]+$ ]]; then
        echo "<<----------------->>"
        echo -e "${RED}Error: Column name cannot be entirely numeric.${RESET}"
        echo "<<----------------->>"
        continue
    fi

    if [[ ! " ${columns_array[@]} " =~ " ${columnToUpdate} " ]]; then
        echo "<<----------------->>"
        echo -e "${RED}Error: Column '$columnToUpdate' does not exist in the table.${RESET}"
        echo "<<----------------->>"
        continue
    fi

    if [ "$columnToUpdate" == "my_pk" ]; then
        echo -e "${RED}The default Pk can't be updated :)${RESET}"
        continue
    fi

    break  # If all checks pass
done
 
         		  
        echo "<<----------------->>"
        echo -e "${BLUE}$columnToUpdate exists in the column list.${RESET}"
        echo "<<----------------->>"
        read -p "Enter the old value to update: " oldValue

        # Validation
        if [ -z "$oldValue" ]; then
            echo "<<----------------->>"
            echo -e "${RED}Error: Old value cannot be empty.${RESET}"
            echo "<<----------------->>"
            return
        fi

        # Check for invalid characters
        invalid_char=$(echo "$oldValue" | grep -o '[^a-zA-Z0-9_]')
        if [ -n "$invalid_char" ]; then
            echo "<<----------------->>"
            echo -e "${RED}Error: Invalid characters found in value to delete: $invalid_char${RESET}"
            echo "<<----------------->>"
            return 1
	fi
        
          
        # Check the data type of the column
        column_type=$(awk -v col="$columnToUpdate" 'NR==4{match($0, col "\\(([^)]+)\\)"); if(RSTART){print substr($0, RSTART+length(col)+1, RLENGTH-length(col)-2); exit}}' "$metadata_file")
        echo -e "${BLUE}Column type for '$columnToUpdate': $column_type${RESET}"

        # Prompt for the new value based on the data type
        case $column_type in 
            text)    
                read -p "Enter new Value for $columnToUpdate: " newValue
                 echo "================================================"

                # Check if the new value is empty
                if [ -z "$newValue" ]; then
                    echo "<<----------------->>"
                    echo -e "${RED}Error: New Value cannot be empty.${RESET}"
                    echo "<<----------------->>"
                    return 1
                fi

                # Validate that the input is text
                if ! [[ "$newValue" =~ ^[a-zA-Z_]+$ ]]; then
                    echo "<<----------------->>"
                    echo "${RED}Error: Invalid input. Only letters and underscores are allowed.${RESET}"
                    echo "<<----------------->>"
                    return 1
                fi
                ;;
            int) 
                read -p "Enter New Value for $columnToUpdate: " newValue
                echo "================================================"

                # Check if the new value is empty
                if [ -z "$newValue" ]; then
                    echo "<<----------------->>"
                    echo -e "${RED}Error: New value cannot be empty.${RESET}"
                    echo "<<----------------->>"
                    return 1
                fi

                # Validate that the input is an integer
                if ! [[ "$newValue" =~ ^[0-9]+$ ]]; then
                    echo "<<----------------->>"
                    echo -e "${RED}Error: Invalid input. Please Enter a Valid Integer.${RESET}"
                    echo "<<----------------->>"
                    return 1
                fi
                ;;
            *)
                echo "<<----------------->>"
                echo -e "${RED}Error: Invalid column type.${RESET}"
                echo "<<----------------->>"
                return 1
                ;;
        esac

        # Define the data file
        data_file="raw_data_${metadata_file}"

        # Check if the old value exists in the column for the specified data type
        if grep -q "${columnToUpdate}(${column_type})=${oldValue}" "$data_file"; then
            # Check if the new value is the same as any existing primary key value
            if [ "${column_type}" = "int" ] && grep -q "${columns_array[0]}(int)=${newValue}" "$data_file"; then
                echo -e "${RED}Error: New value cannot be the same as any existing primary key value.${RESET}"
                return 1
            fi

            # Create a backup of the data file
            cp "$data_file" "${data_file}.bak"
            
            # Update the specific value from the specified column
            sed -i "s/${columnToUpdate}(${column_type})=${oldValue}/${columnToUpdate}(${column_type})=${newValue}/g" "$data_file"
            
            # Check if the update was successful
            if grep -q "${columnToUpdate}(${column_type})=${newValue}" "$data_file" && ! grep -q "${columnToUpdate}(${column_type})=${oldValue}" "$data_file"; then
                echo "Value '${oldValue}' updated to '${newValue}' in column '${columnToUpdate}' in table '${table_name}'."
                # Display the updated data file
                cat "$data_file"
            else
                echo -e "${RED}Error: Update failed! Rolling back changes.${RESET}"
                # Restore the backup file
                mv "${data_file}.bak" "$data_file"
            fi
        else
            echo -e "${RED}Error: Old value '${oldValue}' not found in column '${columnToUpdate}' of table '${table_name}'.${RESET}"
        fi

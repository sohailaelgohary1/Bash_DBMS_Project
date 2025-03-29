#!/bin/bash


read -p "Enter table name: " table_name
 echo "================================================"

    ## Validation ##
    if [ -z "$table_name" ]; then
        echo "<<----------------->>"
        echo -e "${RED}Error: Name of Table cannot be empty.${RESET}"
        echo "<<----------------->>"
        return
    fi

    metadata_file="${table_name}.txt"

    if [ ! -f "$metadata_file" ]; then
        echo "<<----------------->>"
        echo -e "${RED}Error: Table '$tableName' does not exist.${RESET}"
        echo "<<----------------->>"
        return
    fi

    start_line=4
    columns_line=$(sed -n "${start_line}p" "$metadata_file")
    columns=$(echo "$columns_line" | awk '{for (i=1; i<=NF; i++) if ($i != "pk:") { gsub(/\([^()]*\)/,"",$i); printf "%s ", $i } }')
    columns_array=($columns)

    # Display column names
    echo -e "${BLUE}Column Names: ${columns_array[@]}${RESET}"

    # Ask the user if they want to select from all columns or a specific column
    while true; do
        read -p "Do you want to select from all columns? (yes/no): " selectAll
        case $selectAll in
            [Yy][Ee][Ss])
                if [ -s "raw_data_${metadata_file}" ]; then
                    # File has content
                   echo "================================================"
                    awk '{for (i=1; i<=NF; i++) gsub(/\(text\)|\(int\)/, "", $i)}1' "raw_data_${metadata_file}"
                    echo "================================================"
                else
                    # File is empty, print the header
                    echo "================================================"
                    sed -n '2p;4p' "${metadata_file}"
                    echo "<<--------------------------------------------------------->>"
                    echo -e "${RED}<<----- The Table Is Empty. Not Data Yet !! ------>>${RESET}"
                   echo "================================================"->>"
                fi
                break;;
            [Nn][Oo])
                # Menu for selection options
                echo "Please select an option:"
                echo "1) Select from a single column"
                echo "2) Select from multiple columns"
                echo "3) Select from a single row"
                echo "4) Exit"
                read -p "Enter your choice (1/2/3/4): " selectionOption

                case $selectionOption in
                    1)
                        # Code for selecting from a single column
                        read -p "Enter the name of the column to select from: " columnToSelect
                        echo -e "${GREEN}Selected Column: $columnToSelect${RESET}"

                        ## Validations ##
                        # Check if the input is empty
                        if [ -z "$columnToSelect" ]; then
                            echo "<<----------------->>"
                            echo -e "${RED}Error: Name of column cannot be empty.${RESET}"
                            echo "<<----------------->>"
                            return
                        fi

                        # Check for invalid characters
                        invalid_char=$(echo "$columnToSelect" | grep -o '[^a-zA-Z0-9_]')
                        if [ -n "$invalid_char" ]; then
                            echo "<<----------------->>"
                            echo -e "${RED}Error: Invalid characters found in column name: $invalid_char${RESET}"
                            echo "<<----------------->>"
                            return 1
                        fi

                        # Ensure the column name does not start with a number
                        if [[ $columnToSelect =~ ^[0-9] ]]; then
                            echo "<<----------------->>"
                            echo -e "${RED}Error: The first character cannot be a number.${RESET}"
                            echo "<<----------------->>"
                            return 1
                        fi

                        # Ensure the column name is not entirely numeric
                        if [[ $columnToSelect =~ ^[0-9]+$ ]]; then
                            echo "<<----------------->>"
                            echo -e "${RED}Error: Column name cannot be entirely numeric.${RESET}"
                            echo "<<----------------->>"
                            return 1
                        fi

                        # Check if the column name is valid (only letters and underscores)
                        if ! [[ "$columnToSelect" =~ ^[a-zA-Z_]+$ ]]; then
                            echo "<<----------------->>"
                            echo -e "${RED}Error: Invalid column name. Only letters and underscores are allowed.${RESET}"
                            echo "<<----------------->>"
                            return
                        fi

                        # Check if the column exists in the table
                        if [[ ! " ${columns_array[@]} " =~ " ${columnToSelect} " ]]; then
                            echo "<<----------------->>"
                            echo -e "${RED}Error: Column '$columnToSelect' does not exist in the table.${RESET}"
                            echo "<<----------------->>"
                            return
                        fi

                        if [[ " ${columns_array[@]} " =~ " ${columnToSelect} " ]]; then
                            # Extract and display the data for the selected column
                            echo "================================================"
                            awk -F' ' -v col="$columnToSelect" '{for(i=1;i<=NF;i++) {if($i ~ col) {gsub(/\(text\)|\(int\)/, "", $i); print $i}}}' "raw_data_${metadata_file}"
                           echo "================================================"
                        fi
                        break
                        ;;
                    2)
                        while true; do
                            # Prompt the user to enter column names separated by space
                            read -p "Enter the names of the columns to select from (separated by space): " columnsToSelect
                            if [ -z "$columnsToSelect" ]; then
                            echo "<<----------------->>"
                            echo -e "${RED}Error: Name of columns cannot be empty.${RESET}"
                            echo "<<----------------->>"
                            return
                            fi

                            echo -e "${GREEN}Selected Columns: $columnsToSelect${RESET}"

                            # Initialize the validity flag
                            isValid=true

                            # Check if the input column names are valid
                            for col in $columnsToSelect; do
                                # Check if the column name is entirely numeric
                                if [[ $col =~ ^[0-9]+$ ]]; then
                                    echo "<<----------------->>"
                                    echo -e "${RED}Error: Column name cannot be entirely numeric.${RESET}"
                                    echo "<<----------------->>"
                                    isValid=false
                                    break
                                fi

                                # Check for invalid characters in the column name
                                if [[ $col =~ [^a-zA-Z0-9_] ]]; then
                                    echo "<<----------------->>"
                                    echo -e "${RED}Error: Invalid characters found in column name: $col${RESET}"
                                    echo "<<----------------->>"
                                    isValid=false
                                    break
                                fi
                            done

                            # Check if the columns entered by the user exist in the table
                            for col in $columnsToSelect; do
                                if [[ ! " ${columns_array[@]} " =~ " ${col} " ]]; then
                                    echo "<<----------------->>"
                                    echo -e "${RED}Error: Column '$col' does not exist in the table.${RESET}"
                                    echo "<<----------------->>"
                                    isValid=false
                                    break
                                fi
                            done

                            # If all column names are valid, break the loop
                            if [[ $isValid == true ]]; then
                                # Construct the awk command to print the selected columns
                                awkCommand='{'
                                for col in $columnsToSelect; do
                                    for i in "${!columns_array[@]}"; do
                                        if [[ "${columns_array[$i]}" == "$col" ]]; then
                                            awkCommand="$awkCommand printf \"%s \", \$(($i + 1));"
                                        fi
                                    done
                                done
                                awkCommand="$awkCommand print \"\";}"

                                # Check if the data file is not empty
                                if [ -s "raw_data_${metadata_file}" ]; then
                                    # File has content, extract and display the data for the selected columns
                                   echo "================================================"
                                    awk "$awkCommand" "raw_data_${metadata_file}"
                                   echo "================================================"
                                else
                                    # File is empty, print the header
                                    echo "~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*"
                                    sed -n '2p;4p' "${metadata_file}"
                                    echo "<<-------------------------------------------------------->>"
                                    echo -e "${RED}<<----- The Table Is Empty. No Data Yet !! ------>>${RESET}"
                                   echo "================================================"
                                fi
                                break
                            fi
                        done
                        break
                        ;;
                    3)
                        # Code for selecting from a single row
                        read -p "Enter the row number to select: " rowNumber

                        # Validation: Check if the input is a valid positive integer
                        if ! [[ $rowNumber =~ ^[1-9][0-9]*$ ]]; then
                            echo "<<----------------->>"
                            echo -e "${RED}Error: Please enter a positive number only.${RESET}"
                            echo "<<----------------->>"
                            return
                        fi

                        # Get the selected row using sed
                        selectedRow=$(sed -n "${rowNumber}p" "raw_data_${metadata_file}")

                        # Check if the selected row is empty
                        if [ -z "$selectedRow" ]; then
                            echo "<<----------------->>"
                            echo -e "${RED}Error: Row $rowNumber does not exist in the table.${RESET}"
                            echo "<<----------------->>"
                            return
                        fi

                        # Print the selected row
                        echo -e "${GREEN}Selected row $rowNumber:${RESET}"
                        echo "================================================"
                        echo -e "${GREEN}$selectedRow${RESET}"
                       echo "================================================"
                        break
                        ;;
                    4)
                        # Exit option
                        echo -e "${GREEN}Exiting the selection menu.${RESET}"
                        break
                        ;;
                    *)
                        echo -e "${RED}Error: Invalid selection. Please enter a valid option.${RESET}"
                        ;;
                esac
                ;;
            *)
                echo -e "${RED}Error: Invalid input. Please enter 'yes' or 'no'.${RESET}"
                ;;
        esac
    done



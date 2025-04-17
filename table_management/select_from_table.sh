#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")/.."
source "$SCRIPT_DIR/config.sh"

# Function to check valid column name
validate_column_name() {
    local col="$1"

    if [ -z "$col" ]; then
        echo -e "${RED}Error: Name of column cannot be empty.${RESET}"
        return 1
    fi

    if [[ $col =~ ^[0-9] ]]; then
        echo -e "${RED}Error: Column name cannot start with a number.${RESET}"
        return 1
    fi

    if [[ $col =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Error: Column name cannot be entirely numeric.${RESET}"
        return 1
    fi

    if [[ $col =~ [^a-zA-Z0-9_] ]]; then
        echo -e "${RED}Error: Invalid characters in column name.${RESET}"
        return 1
    fi

    return 0
}

while true; do
    read -p "Enter table name: " table_name
    echo "================================================"

    if [ -z "$table_name" ]; then
        echo -e "${RED}Error: Table name cannot be empty.${RESET}"
        continue
    fi

    metadata_file="${table_name}.txt"

    if [ ! -f "$metadata_file" ]; then
        echo -e "${RED}Error: Table '$table_name' does not exist.${RESET}"
        continue
    fi

    start_line=4
    columns_line=$(sed -n "${start_line}p" "$metadata_file")
    columns=$(echo "$columns_line" | awk '{for (i=1; i<=NF; i++) if ($i != "pk:") { gsub(/\([^()]*\)/,"",$i); printf "%s ", $i } }')
    columns_array=($columns)

    echo -e "${BLUE}Column Names: ${columns_array[@]}${RESET}"

    while true; do
        read -p "Do you want to continue or exit? (continue/exit): " continueOption
        case $continueOption in
            [Cc]ontinue)
                read -p "Do you want to select from all columns? (yes/no): " selectAll
                case $selectAll in
                    [Yy][Ee][Ss])
                        if [ -s "raw_data_${metadata_file}" ]; then
                            echo "================================================"
                            awk '{for (i=1; i<=NF; i++) gsub(/\(text\)|\(int\)/, "", $i)}1' "raw_data_${metadata_file}"
                            echo "================================================"
                        else
                            echo "================================================"
                            sed -n '2p;4p' "$metadata_file"
                            echo -e "${RED}<<----- The Table Is Empty. No Data Yet !! ------>>${RESET}"
                            echo "================================================"
                        fi
                        break
                        ;;
                    [Nn][Oo])
                        while true; do
                            echo "1) Select from a single column"
                            echo "2) Select from multiple columns"
                            echo "3) Select from a single row"
                            echo "4) Exit"
                            read -p "Enter your choice (1/2/3/4): " selectionOption

                            case $selectionOption in
                                1)
                                    while true; do
                                        read -p "Enter the name of the column to select from: " columnToSelect
                                        validate_column_name "$columnToSelect" || continue

                                        if [[ ! " ${columns_array[@]} " =~ " ${columnToSelect} " ]]; then
                                            echo -e "${RED}Error: Column '$columnToSelect' does not exist in the table.${RESET}"
                                            continue
                                        fi

                                        echo "================================================"
                                        awk -v col="$columnToSelect" 'BEGIN{IGNORECASE=1}{for(i=1;i<=NF;i++) {if($i ~ col) {gsub(/\(text\)|\(int\)/, "", $i); print $i}}}' "raw_data_${metadata_file}"
                                        echo "================================================"
                                        break
                                    done
                                    break
                                    ;;
                                2)
    while true; do
        read -p "Enter the names of the columns to select from (separated by space): " columnsToSelect
        isValid=true

        for col in $columnsToSelect; do
            validate_column_name "$col" || { isValid=false; break; }

            if [[ ! " ${columns_array[@]} " =~ " ${col} " ]]; then
                echo -e "${RED}Error: Column '$col' does not exist in the table.${RESET}"
                isValid=false
                break
            fi
        done

        if $isValid; then
            # Prepare column indexes
            declare -a indexes_to_print=()
            for col in $columnsToSelect; do
                for i in "${!columns_array[@]}"; do
                    if [[ "${columns_array[$i]}" == "$col" ]]; then
                        indexes_to_print+=($((i + 1)))  # AWK is 1-indexed
                    fi
                done
            done

            # Build the AWK command to print only selected columns
echo "================================================"
awk -v idxs="${indexes_to_print[*]}" '
BEGIN {
    split(idxs, cols, " ");
}
{
    for (i in cols) {
        fieldIndex = cols[i];
        printf "%s ", $fieldIndex;
    }
    print "";
}
' "raw_data_${metadata_file}"
echo "================================================"

            break
        fi
    done
    break
    ;;
                                3)
                                    while true; do
                                        read -p "Enter the row number to select: " rowNumber
                                        if ! [[ $rowNumber =~ ^[1-9][0-9]*$ ]]; then
                                            echo -e "${RED}Error: Please enter a positive number only.${RESET}"
                                            continue
                                        fi

                                        selectedRow=$(sed -n "${rowNumber}p" "raw_data_${metadata_file}")

                                        if [ -z "$selectedRow" ]; then
                                            echo -e "${RED}Error: Row $rowNumber does not exist in the table.${RESET}"
                                            continue
                                        fi

                                        echo -e "${GREEN}Selected row $rowNumber:${RESET}"
                                        echo "================================================"
                                        echo -e "${GREEN}$selectedRow${RESET}"
                                        echo "================================================"
                                        break
                                    done
                                    break
                                    ;;
                                4)
                                    echo -e "${GREEN}Exiting the selection menu.${RESET}"
                                    break 2
                                    ;;
                                *)
                                    echo -e "${RED}Error: Invalid selection. Please enter a valid option.${RESET}"
                                    ;;
                            esac
                        done
                        ;;
                    *)
                        echo -e "${RED}Error: Invalid input. Please enter 'yes' or 'no'.${RESET}"
                        ;;
                esac
                ;;
            [Ee]xit)
                echo -e "${GREEN}Exiting the program.${RESET}"
                exit 0
                ;;
            *)
                echo -e "${RED}Error: Invalid input. Please enter 'continue' or 'exit'.${RESET}"
                ;;
        esac
    done
    break

done

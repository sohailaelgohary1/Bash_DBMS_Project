#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")/.."
source "$SCRIPT_DIR/config.sh"

while true; do
    read -p "Enter table name: " table_name
    echo "================================================"

    if [ -z "$table_name" ]; then
        echo "<<----------------->>"
        echo -e "${RED}Error: Table name cannot be empty.${RESET}"
        echo "<<----------------->>"
        continue
    fi

    invalid_characters=$(echo "$table_name" | grep -o -E '[-!@#$%^&*()]')
    if [ -n "$invalid_characters" ]; then
        echo "<<----------------->>"
        echo -e "${RED}Error: Invalid characters found in Table name: $invalid_characters${RESET}"
        echo "<<----------------->>"
        continue
    fi

    if [[ $table_name =~ ^[0-9] ]]; then
        echo "<<----------------->>"
        echo -e "${RED}Error: The first character cannot be a number.${RESET}"
        echo "<<----------------->>"
        continue
    fi

    tableNaame_lower="$table_name"
    tableName_upper="$table_name"

   if [ -f "$tableNaame_lower.txt" ] || [ -f "$tableName_upper.txt" ]; then
     echo -e "${MAGENTA}<<<< $tableNaame_lower is already exists >>>>${RESET}"
     continue
   fi

    while true; do
        read -p "Please Enter The Number Of Columns: " numOfColumns
        echo "================================================"

        if ! [[ "$numOfColumns" =~ ^[1-9][0-9]*$ ]]; then
            echo "<<----------------->>"
            echo -e "${RED}Invalid input for the number of columns. Please enter a positive integer.${RESET}"
            echo "<<----------------->>"
        else
            break
        fi
    done

    pk_set=false
    pk_column=""
    column_names=()

    for (( i=1 ; i <=$numOfColumns ;i++ )); do
        while true; do
            read -p "Enter The Name Of Column No.$i : " name1
            echo "================================================"

            if [ -z "$name1" ]; then
                echo "<<----------------->>"
                echo -e "${RED}Error: Name of Column cannot be empty.${RESET}"
                echo "<<----------------->>"
                continue
            fi

            invalid_char1=$(echo "$name1" | grep -o -E '[-!@#$%^&*()]')
            if [ -n "$invalid_char1" ]; then
                echo "<<----------------->>"
                echo -e "${RED}Error: Invalid characters found in Column name: $invalid_char1${RESET}"
                echo "<<----------------->>"
                continue
            fi

            if [[ $name1 =~ ^[0-9] ]]; then
                echo "<<----------------->>"
                echo -e "${RED}Error: The first character cannot be a number.${RESET}"
                echo "<<----------------->>"
                continue
            fi

            name1_lower=$(echo "$name1" | tr '[:upper:]' '[:lower:]')
            if [[ " ${column_names[@]} " =~ " $name1_lower " ]]; then
                echo "<<----------------->>"
                echo -e "${RED}Error: Duplicate column name '$name1'. Column names must be unique.${RESET}"
                echo "<<----------------->>"
                continue
            fi

            break
        done

        while true; do
            read -p "Enter the Type of This Column (Text/Int): " columnType
            echo "================================================"

            if [ -z "$columnType" ]; then
                echo "<<----------------->>"
                echo -e "${RED}Error: Column type cannot be empty.${RESET}"
                echo "<<----------------->>"
                continue
            fi

            columnType_lower=$(echo "$columnType" | tr '[:upper:]' '[:lower:]')
            if [ "$columnType_lower" != "text" ] && [ "$columnType_lower" != "int" ]; then
                echo "<<----------------->>"
                echo -e "${RED}Error: Invalid column type. Please enter 'Text' or 'Int'.${RESET}"
                echo "<<----------------->>"
                continue
            fi
            break
        done

        column_names+=("$name1_lower($columnType_lower)")

        if [ "$pk_set" = false ]; then
            while true; do
                read -p "Do you Want To Set This Column As PK ? y/n: " answer
                echo "================================================"

                if [ -z "$answer" ]; then
                    echo "<<----------------->>"
                    echo -e "${RED}Error: This Field cannot be empty.${RESET}"
                    echo "<<----------------->>"
                    continue
                fi

                if [ "$answer" = Y ] || [ "$answer" = y ]; then
                    if [ "$columnType_lower" = "int" ]; then
                        pk_set=true
                        pk_column="$name1_lower"
                    else
                        echo "<<----------------->>" 
                        echo -e "${RED}Unfortunately~ PK must be of type Int :( .${RESET}"
                        echo "<<----------------->>"
                    fi    
                    break
                elif [ "$answer" = N ] || [ "$answer" = n ]; then
                    echo "OK"
                    break
                else
                    echo "<<----------------->>"
                    echo -e "${RED}Error: Invalid choice. Please enter 'y' or 'n'.${RESET}"
                    echo "<<----------------->>"
                fi
            done
        fi
    done

    if [ "$pk_set" = false ]; then
        pk_column="my_pk"
        column_names+=("$pk_column(int)")
        echo -e "${GREEN}Generating default PK column...${RESET}"
    fi

    echo "Table Name: $tableNaame_lower" > $tableNaame_lower.txt
    echo "Number of Columns: $numOfColumns " >> $tableNaame_lower.txt
    echo "pk:$pk_column" >> $tableNaame_lower.txt
    echo "${column_names[@]}" >> $tableNaame_lower.txt
    touch raw_data_$tableNaame_lower.txt
    echo -e "${GREEN}$tableNaame_lower is created successfully :)${RESET}"
    break

done

echo "<<----------------->>"
read -p "Press Enter to continue..."

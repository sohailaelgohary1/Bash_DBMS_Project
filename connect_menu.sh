#!/bin/bash

# Get script directory (absolute path)
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Source config.sh
source "$SCRIPT_DIR/config.sh"

connect_menu(){
    while true; 
    do
        echo "================== Table Management =================="
        echo "1) Create Table"
        echo "2) List Tables"
        echo "3) Drop Tables"
        echo "4) Insert into Table"
        echo "5) Select from Table"
        echo "6) Delete from Table"
        echo "7) Update Row"
        echo "8) Exit From Database"
        echo "================================================"
        read -p "Choose an option: " choice
        
        case $choice in
        1) bash "$SCRIPT_DIR/table_management/create_table.sh";;
        2) bash "$SCRIPT_DIR/table_management/list_tables.sh";;
        3) bash "$SCRIPT_DIR/table_management/drop_table.sh";;
        4) bash "$SCRIPT_DIR/table_management/insert_into_table.sh";;
        5) bash "$SCRIPT_DIR/table_management/select_from_table.sh";;
        6) bash "$SCRIPT_DIR/table_management/delete_from_table.sh";;
        7) bash "$SCRIPT_DIR/table_management/update_row.sh";;
        8) echo "Exiting Database..."; break;;
        *) echo -e "${RED}Invalid option :( Please Try Again !!${RESET}";;
        esac
    done
}

connect_menu  # Call the function when script is executed


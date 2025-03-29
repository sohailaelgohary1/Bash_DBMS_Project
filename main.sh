#!/bin/bash

# Load color variables
source ./config.sh

DB_DIR="./data"
mkdir -p "$DB_DIR"

while true; do 
    echo -e "${GREEN}<<*** Welcome to The DataBase Management System ***>>${RESET}"

    echo "================== Main Menu =================="
    echo "1) Create Database"
    echo "2) List Databases"
    echo "3) Connect to a Database"
    echo "4) Drop Database"
    echo "5) Exit"
    echo "================================================"
    read -p "Choose an option: " choice

    case $choice in
        1) bash db_management/create_db.sh ;;
        2) bash db_management/list_db.sh ;;
        3) bash db_management/connect_db.sh ;;
        4) bash db_management/drop_db.sh ;;
        5) echo "Exiting...GoodBye!"; exit 0 ;;
        *) echo -e "${RED}Invalid option :( Please Try Again !!${RESET}";;
    esac

    read -p "Press Enter to continue..."
done  


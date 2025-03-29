#!/bin/bash

# Load color variables
source "$(dirname "$0")/../config.sh"

DB_DIR="./data"
read -p "Enter database name to drop: " db_name

if [ -d "$DB_DIR/$db_name" ]; then
    rm -r "$DB_DIR/$db_name"
    echo "Database '$db_name' deleted."
     echo -e "${GREEN} Database '$db_name' deleted successfully :)${RESET}"
else
    echo "${RED} Database not found! ${RESET}"
    exit 1
fi



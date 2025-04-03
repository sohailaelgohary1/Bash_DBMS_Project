#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")/.."
source "$SCRIPT_DIR/config.sh"

DB_DIR="./data"
read -p "Enter database name to drop: " db_name

if [ -d "$DB_DIR/$db_name" ]; then
    rm -r "$DB_DIR/$db_name"
    echo "Database '$db_name' deleted."
     echo -e "${GREEN} Database '$db_name' deleted successfully :)${RESET}"
else
    echo -e "${RED} Database not found! ${RESET}"
    exit 1
fi



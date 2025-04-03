#!/bin/bash

# Load color variables
source "$(dirname "$0")/../config.sh"

DB_DIR="./data"
read -p "Enter database name: " db_name

# Validate database name (only letters, numbers, and underscores allowed)
if [[ "$db_name" =~ [^a-zA-Z0-9_] ]]; then
    echo "<<----------------->>" 
    echo -e "${RED}Error: Invalid characters found in database name. Only letters, numbers, and underscores are allowed.${RESET}"
    echo "<<----------------->>"
    exit 1
fi

# Ensure the first character is not a number
if [[ $db_name =~ ^[0-9] ]]; then 
    echo "<<----------------->>"
    echo -e "${RED}Error: The first character cannot be a number.${RESET}"
    echo "<<----------------->>"
    exit 1
fi

# Ensure database name is not empty
if [ -z "$db_name" ]; then
    echo "<<----------------->>"
    echo -e "${RED}Error: Database name cannot be empty.${RESET}"
    echo "<<----------------->>"
    exit 1
fi

if [ -d "$DB_DIR/$db_name" ]; then
   echo -e "${RED} Database $db_name is already exists${RESET}"
             echo "<<----------------->>"
             exit 1
       else 
             mkdir -p "$DB_DIR/$db_name"
             echo -e "${GREEN}<<<< Database $db_name is created successfully :) >>>>${RESET}"
       fi



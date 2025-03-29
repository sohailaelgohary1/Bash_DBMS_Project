#!/bin/bash

# Get script directory (absolute path)
SCRIPT_DIR="$(dirname "$(realpath "$0")")/.."

# Source config.sh
source "$SCRIPT_DIR/config.sh"

# Define database directory
DB_DIR="$SCRIPT_DIR/data"

# Prompt user for database name
read -p "Enter Database name to connect: " db_name
echo "================================================"

# Ensure database name is not empty
if [ -z "$db_name" ]; then
    echo "<<----------------->>"
    echo -e "${RED}Error: Database name cannot be empty.${RESET}"
    echo "<<----------------->>"
    exit 1
fi

# Check if the database directory exists
if [ -d "$DB_DIR/$db_name" ]; then
    echo -e "${GREEN}Connecting To <$db_name> Database ....${RESET}"
    
    # Export the database name for other scripts
    export CURRENT_DB="$db_name"
    
    # Change directory to the database
    cd "$DB_DIR/$db_name" || exit

    # Execute connect_menu.sh
    bash "$SCRIPT_DIR/connect_menu.sh"
else
    echo -e "${RED} << Database '$db_name' not found! >> ${RESET}"
    exit 1
fi


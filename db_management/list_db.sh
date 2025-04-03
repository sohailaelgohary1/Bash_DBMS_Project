#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")/.."
source "$SCRIPT_DIR/config.sh"

DB_DIR="./data"

  if [ -d "$DB_DIR" ] && [ "$(ls -A "$DB_DIR")" ]; then
        echo -e "${MAGENTA}<<---Your Available Databases---->>${RESET}"
        ls -d "$DB_DIR"/* | sed 's/^.*\///'
    else
        echo -e "${MAGENTA}<<<<No databases added yet.>>>>${RESET}"
    fi
    

#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")/.."
source "$SCRIPT_DIR/config.sh"

table_files="*.txt"

   if [ -n "$(ls $table_files 2>/dev/null)" ]; then
       echo -e "${MAGENTA}<<---Tables in the $db_name database--->>${RESET}"
        for table in $table_files; do
             if [[ "$table" != "raw_data_"* ]]; then
                table_name=$(basename -- "$table")
                echo "${table_name%.*}"
            fi
        done
   else
        echo "<<----------------->>"
        echo -e "${MAGENTA}There are No Tables to list yet!${RESET}"
   fi 
        


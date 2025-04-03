#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")/.."
source "$SCRIPT_DIR/config.sh"

read -p "Enter table name: " table_name
echo "================================================"

 ##validation##
  if [ -z "$table_name" ]; then
    echo "<<----------------->>"
    echo -e "${RED}Error:  Name of Table cannot be empty.${RESET}"
    echo "<<----------------->>"
    return
  fi
  invalid_char1=$(echo "$table_name" | grep -o '(?i)[-!@#$%^&*()]')
  if [ -n "$invalid_char1" ];then
    echo "<<----------------->>"
    echo -e "${RED}Error: Invalid characters found in Table name: $invalid_char1${RESET}"
    echo "<<----------------->>"
    return 1
  fi
  if [[ $table_name =~ ^[0-9] ]];then
    echo "<<----------------->>"
    echo -e "${RED}Error: The first character cannot be a number.${RESET}"
    echo "<<----------------->>"
    return 1
  fi
tableName_lower=$(echo "$table_name" | tr '[:upper:]' '[:lower:]')

  table_file="${tableName_lower}.txt"

  if [ ! -f "$table_file" ]; then
    echo "<<----------------->>"
    echo -e "${RED}Error: Table '$table_name' does not exist.${RESET}"
    echo "<<----------------->>"
    return
  fi

  declare -a column_arr
  read -r numColumns < <(awk -F ' ' '/Number of Columns:/ {print $NF}' "$table_file")
  read -r pk_column < <(awk 'BEGIN{FS=":";}{if(NR==3){print $2};}' "$table_file")
  read -ra column_arr < <(awk 'BEGIN{FS="  ";}{if(NR==4){print $0};}' "$table_file")
# Find the position of the primary key column
  pk_column_position=$(awk -F ' ' -v pk="$pk_column" 'NR==4 {for (i=1; i<=NF; i++) if ($i ~ pk) print i; exit;}' "$table_file")
# echo "$pk_column_position"
  values=()
  pk_column_found=false
  
         for ((i=0; i<numColumns; i++));
          do  
               column_name=$(echo "${column_arr[i]}" | awk -F '(' '{print $1}') 
               column_type=$(echo "${column_arr[i]}" | awk -F '(' '{print tolower($2)}' | tr -d ')')
               if [[ "$column_name" == "$pk_column" ]]; then
                   pk_column_found=true
                   
                   read -p "Enter Value for ${column_arr[i]}: " value
                echo "================================================"

                       if ! [[ "$value" =~ ^[0-9]+$ ]]; then
                            echo "<<----------------->>"
                            echo -e "${RED}Error: Invalid input. Please enter a valid integer.${RESET}"
                            echo "<<----------------->>"
                            return 1
            
                       fi
                       if [ -z "$value" ]; then
                           echo "<<----------------->>"
                           echo -e "${RED}Error: Value for primary key '$pk_column' cannot be empty.${RESET}"
                           echo "<<----------------->>"
                           return 1
                       fi
 
     if awk -F '[= ]' -v pos="$pk_column_position" -v val="$value" '$(pos*2) == val' "raw_data_${tableName_lower}.txt" | grep -q .; then
        echo "<<----------------->>"
        echo -e "${RED}Error: Duplicate value found for primary key '$pk_column'.${RESET}"
        echo "<<----------------->>"
        return 1
    fi              
                   values+=("${column_arr[i]}=$value")
                 
               else
                case $column_type in 
                   text)    
                      read -p "Enter Value for ${column_arr[i]}: " value
                    echo "================================================"

                               if [ -z "$value" ]; then
                                     value="null"
                               fi
                     ;;
                    int) 
                      read -p "Enter Value for ${column_arr[i]}: " value
                      echo "================================================"
                       if ! [[ "$value" =~ ^[0-9]+$ ]]; then
                            echo "<<----------------->>"
                            echo -e "${RED}Error: Invalid input. Please enter a valid integer.${RESET}"
                            echo "<<----------------->>"
                            return 1
                       fi
                     ;;
                    *)
                      echo "<<----------------->>"
                      echo -e "${RED}Error: Invalid column type.${RESET}"
                      echo "<<----------------->>"
                      return 1
                     ;;
               esac 
                     values+=("${column_arr[i]}=$value")
                
               
                     
               fi  
          done
               if ! $pk_column_found; then
                   if [ "$pk_column" == "my_pk" ]; then
                        #echo "inside my_pk"
                        latest_pk_value=$(awk -F '=' '{print $NF}' "raw_data_${tableName_lower}.txt" | sort -n | tail -n 1)
                         if [ -z "$latest_pk_value" ]; then
                              pk_value=1
                         else
                              pk_value=$((latest_pk_value + 1))
                         fi
                         values+=("my_pk(int)=$pk_value")
                  else
                    echo "<<----------------->>"
                    echo -e "${RED}Error: PK column not fount.${RESET}"
                    echo "<<----------------->>"
                    return 1
                  fi
               fi
  columns_values=$(IFS=' '; echo "${values[*]}")
  echo -e "${CYAN}INSERT INTO ${table_file} VALUES ( $columns_values )${RESET}"

  echo "$columns_values" >> "raw_data_${table_file}"

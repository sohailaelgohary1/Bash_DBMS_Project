#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")/.."
source "$SCRIPT_DIR/config.sh"

#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")/.."
source "$SCRIPT_DIR/config.sh"

while true; do
  read -p "Enter table name: " table_name
  echo "================================================"

  # Empty name check
  if [ -z "$table_name" ]; then
    echo "<<----------------->>"
    echo -e "${RED}Error: Name of Table cannot be empty.${RESET}"
    echo "<<----------------->>"
    continue
  fi

  # Invalid character check
  table_file="${table_name}.txt"

  if [ ! -f "$table_file" ]; then
    echo "<<----------------->>"
    echo -e "${RED}Error: Table '$table_name' does not exist.${RESET}"
    echo "<<----------------->>"
    continue
  fi
  break  # Exit loop if everything is okay
done

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
                   
                   while true; do
        read -p "Enter Value for ${column_arr[i]}: " value
        echo "================================================"

        if [ -z "$value" ]; then
          echo "<<----------------->>"
          echo -e "${RED}Error: Value for primary key '$pk_column' cannot be empty.${RESET}"
          echo "<<----------------->>"
          continue
        fi

        if ! [[ "$value" =~ ^[0-9]+$ ]]; then
          echo "<<----------------->>"
          echo -e "${RED}Error: Invalid input. Please enter a valid integer.${RESET}"
          echo "<<----------------->>"
          continue
        fi

        # Duplicate PK check
        if awk -F '[= ]' -v pos="$pk_column_position" -v val="$value" '$(pos*2) == val' "raw_data_${table_name}.txt" | grep -q .; then
          echo "<<----------------->>"
          echo -e "${RED}Error: Duplicate value found for primary key '$pk_column'. Please enter a different value.${RESET}"
          echo "<<----------------->>"
          continue
        fi

        break
      done

      values+=("${column_arr[i]}=$value")

    else
      while true; do
        case $column_type in
  text)
    read -p "Enter Value for ${column_arr[i]}: " value
    echo "================================================"
    if [[ "$value" =~ ^[0-9]+$ ]]; then
      echo "<<----------------->>"
      echo -e "${RED}Error: Invalid input. Please enter text only (no pure numbers).${RESET}"
      echo "<<----------------->>"
      continue
    fi
    [ -z "$value" ] && value="null"
    values+=("${column_arr[i]}=$value")
    break
    ;;
          int)
            read -p "Enter Value for ${column_arr[i]}: " value
            echo "================================================"
            if [[ "$value" =~ ^[0-9]+$ ]]; then
              values+=("${column_arr[i]}=$value")
              break
            else
              echo "<<----------------->>"
              echo -e "${RED}Error: Invalid input. Please enter a valid integer.${RESET}"
              echo "<<----------------->>"
            fi
            ;;
          *)
            echo "<<----------------->>"
            echo -e "${RED}Error: Invalid column type '${column_type}' for '${column_name}'.${RESET}"
            echo "<<----------------->>"
            read -p "Please re-enter the correct type (int/text): " column_type
            column_type=$(echo "$column_type" | tr '[:upper:]' '[:lower:]')
            ;;
        esac
      done
    fi
  done

  if ! $pk_column_found; then
    if [ "$pk_column" == "my_pk" ]; then
      latest_pk_value=$(awk -F '=' '{print $NF}' "raw_data_${table_name}.txt" | sort -n | tail -n 1)
      pk_value=$((latest_pk_value + 1))
      values+=("my_pk(int)=$pk_value")
    else
      echo "<<----------------->>"
      echo -e "${RED}Error: PK column not found.${RESET}"
      echo "<<----------------->>"
      continue
    fi
  fi

  columns_values=$(IFS=' '; echo "${values[*]}")
  echo -e "${CYAN}INSERT INTO ${table_file} VALUES ( $columns_values )${RESET}"
  echo "$columns_values" >> "raw_data_${table_name}.txt"

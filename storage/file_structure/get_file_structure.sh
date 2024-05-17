#!/bin/bash

# YAML file path and colors input
yaml_file="${1:-./storage/file_structure/file_structure.yaml}"
colors_input="${2:-blue,red,green,orange,purple}"

# Convert the comma-separated string into an array
IFS=',' read -r -a colors <<< "$colors_input"

# Function to parse the YAML file and find paths to empty lists
find_empty_list_paths() {
    local file="$1"
    local current_path=()
    local last_indentation=-1
    local color_section=false

    while IFS= read -r line; do
        # Calculate current indentation level
        local indentation=$(echo "$line" | sed -E 's/^([[:space:]]*).*/\1/' | wc -c)
        indentation=$((indentation - 1))

        # Remove leading and trailing whitespace
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        if [[ "$line" =~ ^[a-zA-Z0-9_-]+: ]]; then
            # Key: value pair
            key=$(echo "$line" | cut -d ':' -f 1)
            value=$(echo "$line" | cut -d ':' -f 2- | sed 's/^[[:space:]]*//')

            # Adjust the current path based on the indentation level
            if [[ $indentation -le $last_indentation ]]; then
                current_path=("${current_path[@]:0:((indentation / 2))}")
            fi

            current_path+=("$key")

            # Check if the key is "colors"
            if [[ "$key" == "colors" ]]; then
                color_section=true
                # Remove "colors" from the current path
                current_path=("${current_path[@]:0:((indentation / 2))}")

                # Add color keys and their respective paths
                for color in "${colors[@]}"; do
                    current_path+=("$color")
                    last_indentation=$indentation
                    while IFS= read -r subline; do
                        # Calculate indentation of the subline
                        local sub_indentation=$(echo "$subline" | sed -E 's/^([[:space:]]*).*/\1/' | wc -c)
                        sub_indentation=$((sub_indentation - 1))

                        # Remove leading and trailing whitespace from subline
                        subline=$(echo "$subline" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

                        # Skip empty lines and comments
                        [[ -z "$subline" || "$subline" =~ ^# ]] && continue

                        if [[ "$subline" =~ ^[a-zA-Z0-9_-]+: ]]; then
                            sub_key=$(echo "$subline" | cut -d ':' -f 1)
                            sub_value=$(echo "$subline" | cut -d ':' -f 2- | sed 's/^[[:space:]]*//')

                            # Adjust the current path based on the indentation level
                            if [[ $sub_indentation -le $last_indentation ]]; then
                                current_path=("${current_path[@]:0:$((sub_indentation / 2 + 1))}")
                            fi

                            current_path+=("$sub_key")

                            # If the value is an empty list, print the path
                            if [[ "$sub_value" == "[]" ]]; then
                                echo "${current_path[*]}" | tr ' ' '/'
                            fi

                            last_indentation=$sub_indentation
                        fi
                    done <<< "$(tail -n +$(grep -n "^ *colors:" "$yaml_file" | cut -d: -f1) "$yaml_file")"
                    current_path=("${current_path[@]:0:${#current_path[@]}-1}")
                done
                color_section=false
            elif [[ "$value" == "[]" ]]; then
                echo "${current_path[*]}" | tr ' ' '/'
            fi

            last_indentation=$indentation
        fi
    done < "$file"
}

# Collect all empty list paths
empty_list_paths=$(find_empty_list_paths "$yaml_file")

# Output the paths in a format that Terraform can parse
# Creating a JSON object with each path as a key-value pair
echo "{"
first=true
index=0
while IFS= read -r path; do
    if $first; then
        echo -n "\"path_$index\": \"$path\""
        first=false
    else
        echo -n ", \"path_$index\": \"$path\""
    fi
    index=$((index + 1))
done <<< "$empty_list_paths"
echo "}"

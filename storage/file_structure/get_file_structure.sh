#!/bin/bash

# YAML file path
yaml_file="${1:-./storage/file_structure/file_structure.yaml}"

# Function to parse the YAML file and find paths to empty lists
find_empty_list_paths() {
    local file="$1"
    local current_path=()
    local last_indentation=-1

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

            # Check if the value is an empty list
            if [[ "$value" == "[]" ]]; then
                echo "${current_path[*]}" | tr ' ' '/'
            fi

            last_indentation=$indentation
        fi
    done < "$file"
}

# Collect all empty list paths
empty_list_paths=$(find_empty_list_paths "$yaml_file")

# Format the paths as a single JSON string value
formatted_paths=$(echo "$empty_list_paths" | jq -R -s -c 'split("\n") | map(select(. != ""))')

# Output the paths in a format that Terraform can parse
echo "{"
echo "\"paths\": $formatted_paths"
echo "}"

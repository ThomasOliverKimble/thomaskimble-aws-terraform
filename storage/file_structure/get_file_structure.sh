#!/bin/bash

# Function to check if yq is installed
check_and_install_yq() {
    if ! command -v yq &> /dev/null; then
        echo "yq not found. Installing yq..."
        # Check if Homebrew is installed
        if ! command -v brew &> /dev/null; then
            echo "Homebrew not found. Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        # Install yq
        brew install yq
    else
        echo "yq is already installed."
    fi
}

# Check and install yq if necessary
check_and_install_yq

# YAML file path
yaml_file="${1:-./storage/file_structure/file_structure.yaml}"

# Find all paths leading to empty lists using yq
empty_list_paths=$(yq eval '.. | select(tag == "!!seq" and length == 0) | path | join("/")' "$yaml_file")

# Output the paths in a format that Terraform can parse
echo "{\"paths\": ["
echo "$empty_list_paths" | awk '{print "\"" $0 "\","}'
echo "]}"

#!/bin/bash

# Define the target directory
target_dir="./include"

# Determine the OS and set the appropriate sed command
if [[ "$OSTYPE" == "darwin"* ]]; then
    SED_COMMAND="sed -i ''"
else
    SED_COMMAND="sed -i"
fi

for file in `find $target_dir -type f \( -name "*.hpp" -o -name "*.txx" \)`; do
    while IFS= read -r line; do
        # Check if the line has an #include directive with angle brackets
        if echo "$line" | grep -q '#include[[:space:]]*<[^>]\+>'; then
            included_file=$(echo "$line" | sed -n 's/#include[[:space:]]*<\([^>]*\)>/\1/p')
            dir_of_current_file=$(dirname "$file")
            
            # Check if the file exists in the relative path
            if [[ -f "$dir_of_current_file/$included_file" ]]; then
                # Replace angle brackets with quotes, using the detected sed command
                $SED_COMMAND "s#<${included_file}>#\"${included_file}\"#g" "$file"
            fi
        fi
    done < "$file"
done

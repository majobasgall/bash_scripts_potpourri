#!/bin/bash
# Easily links common documents while preventing duplicates.

# Define the path to the text file containing pairs of numbers and file paths
# Use files_list_example.txt as template
files_list="files_list.txt"

# Display available documents from the text file
echo "Select one or more documents to create symbolic links for (comma-separated):"
while IFS=',' read -r number path || [[ -n $number ]]; do
  echo "$number. $path"
done < "$files_list"

# Read user input for document selection
read -p "Enter the numbers of the documents (comma-separated): " choices

# Convert the comma-separated list to an array
IFS=',' read -ra selected_indices <<< "$choices"

# Create symbolic links for selected documents
for index in "${selected_indices[@]}"; do
  # Find the corresponding path for the selected number
  path=$(grep "^${index}," "$files_list" | cut -d',' -f2-)
  
  # Expand $HOME variable if present in the path
  path="${path//\$HOME/$HOME}"
  
  if [ -n "$path" ]; then
    # Extract filename from path
    filename=$(basename "$path")
    if [ -e "$path" ]; then
      ln -s "$path" "$filename"
      echo "Created a symbolic link for $filename"
    else
      echo "Document '$filename' not found at $path"
    fi
  else
    echo "Invalid choice: $index"
  fi
done


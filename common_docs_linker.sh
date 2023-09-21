#!/bin/bash
# Easily links common documents while preventing duplicates.

# Define the directory where your documents are located
documents_directory=${HOME}"/docs/common"

# List of available documents
available_documents=("ID.pdf" "doc1.pdf" "doc2.pdf" "doc3.pdf")

# Display a menu to select a document
echo "Select a document to create a symbolic link for:"
for ((i=0; i<${#available_documents[@]}; i++)); do
  echo "$((i+1)). ${available_documents[i]}"
done

# Read user input for document selection
read -p "Enter the number of the document: " choice

# Validate user input
if [[ ! "$choice" =~ ^[1-${#available_documents[@]}]$ ]]; then
  echo "Invalid choice. Please select a valid document number."
  exit 1
fi

# Get the selected document name
selected_document="${available_documents[choice-1]}"

# Create a symbolic link for the selected document
if [ -e "$documents_directory/$selected_document" ]; then
  ln -s "$documents_directory/$selected_document" "$selected_document"
  echo "Created a symbolic link for $selected_document"
else
  echo "Document '$selected_document' not found in $documents_directory"
fi


#!/usr/bin/env zsh

# Check if a directory is provided as an argument
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Assign the input argument to a variable
target_directory=$1

# Check if the directory exists
if [[ ! -d $target_directory ]]; then
  echo "The specified directory does not exist."
  exit 1
fi

# Find and remove all .DS_Store files within the directory, recursively
find "$target_directory" -name ".DS_Store" -type f -exec rm -f {} \;

echo "All .DS_Store files removed from $target_directory."

#!/usr/bin/env zsh

# Enable nullglob so that globs return empty instead of errors if no files are found
setopt NULL_GLOB

# Check if the correct number of arguments are provided
if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <extension> <destination-folder> <exclude-toml-file>"
  exit 1
fi

# Assign the input arguments to variables
extension=$1
destination_folder=$2
exclude_toml_file=$3

# If extension does not start with ".", add it
if [[ $extension != .* ]]; then
  extension=".$extension"
fi

# Check if the destination folder exists, create it if it doesn't
if [[ ! -d $destination_folder ]]; then
  echo "Destination folder does not exist. Creating it..."
  mkdir -p $destination_folder
fi

# Check if the TOML file exists
if [[ ! -f $exclude_toml_file ]]; then
  echo "TOML file $exclude_toml_file does not exist."
  exit 1
fi

# Extract the list of files to exclude from the TOML file using awk
exclude_list=($(awk -F\" '/files = \[/,/\]/ {if($2) print $2}' $exclude_toml_file))
echo "Exclude list: $exclude_list"

# Copy all files with the given extension to the destination folder, excluding the ones in the TOML list
for file in *$extension; do
echo "File: $file"
  # Check if files exist
  if [[ -e $file ]]; then
    # Skip the files that are in the exclude list
    if [[ ! " ${exclude_list[@]} " =~ " $file " ]]; then
      cp "$file" "$destination_folder"
      echo "Copied $file to $destination_folder"
    else
      echo "Skipping $file as it is listed in the exclude list"
    fi
  else
    echo "No files with extension $extension found in the current directory."
    exit 1
  fi
done

echo "Operation complete."

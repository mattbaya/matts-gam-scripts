#!/usr/bin/bash

GAM="/root/bin/gamadv-x/gam"
USERNAME="gam-admin-address@domain.com"

# Check if the Google Drive folder ID is provided as an argument
if [[ $# -eq 0 ]]; then
  echo "Please provide the Google Drive folder ID."
  exit 1
fi

# Set the Google Drive folder ID
FOLDER_ID="$1"

# Function to list files and folders
list_files() {
  local folder_id=$1
  local indent=$2

  # List files and folders in the current folder
  "$GAM" user "$USERNAME" print drivefilelist query "'$folder_id' in parents" fields id,name,owners.emailAddress | awk -F'\t' '{print $2 " => " $3}'

  # Recursively list files and folders in sub-folders
  while IFS=$'\t' read -r child_id child_name; do
    echo "${indent}Sub-folder: $child_name"
    list_files "$child_id" "$indent  "
  done < <("$GAM" user "$USERNAME" print drivefilelist query "'$folder_id' in parents and mimeType='application/vnd.google-apps.folder'" fields id,name)
}

# Call the function with the Google Drive folder ID
list_files "$FOLDER_ID" ""


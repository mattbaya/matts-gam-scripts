#!/bin/bash

# This creates a file in the csv-files folder named: username-files-under-${PARENT_FOLDER_ID}.csv .
# this script requires a username ($1) with privileges to the shared drive and the drive ID ($2)

# Ensure both email and folder ID are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <user-email> <parent-folder-id>"
    exit 1
fi

# Set the location of the GAM executable
GAM="/root/bin/gamadv-xtd3/gam"

# Set the user's email address and parent folder ID as variables
USER_EMAIL="$1"
PARENT_FOLDER_ID="$2"

# Define folder and file paths
CSV_FOLDER="csv-files"
FILES_UNDER_PARENT_FILE="${CSV_FOLDER}/${USER_EMAIL}-files-under-${PARENT_FOLDER_ID}.csv"

# Run the GAM command to list files and save its output to the desired CSV file
$GAM user "$USER_EMAIL" print filelist select id "$PARENT_FOLDER_ID" showownedby any id title owners mimeType filepath createdTime modifiedTime filesize> "$FILES_UNDER_PARENT_FILE"

# Done
echo "List of files under $PARENT_FOLDER_ID has been generated in $FILES_UNDER_PARENT_FILE."
echo "Exiting listall script"


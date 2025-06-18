#!/bin/bash

# Define the GAM path
GAM=/root/bin/gamadv-x/gam

# Check if the script has received exactly one argument
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <USERNAME>"
    exit 1
fi

# Assign input parameter to a variable
USERNAME="$1"  # Google account username
ADMIN_USER="gam-admin-address@example.edu"  # Admin account to manage file operations

# Retrieve all file IDs owned by the user
FILE_LIST=$($GAM user $USERNAME print filelist fields id | awk -F"," 'NR>1 {print $2}')

# Loop through each file ID and change its sharing permissions
for FILE_ID in $FILE_LIST; do
    echo "Granting full access to $ADMIN_USER for file ID: $FILE_ID"
    $GAM user $USERNAME add drivefileacl "$FILE_ID" user "$ADMIN_USER" role owner
    echo "Updated sharing permissions for file: $FILE_ID"
done

echo "All files have been shared with $ADMIN_USER with full access."

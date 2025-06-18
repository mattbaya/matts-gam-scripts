#!/bin/bash

# This script moves a suspended user to a main OU with Drive access,
# renames files in their Google Drive, and then moves them back to their original OU.

# Usage: ./rename_files.sh <username>

# Check if the username is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

# Assign the username argument to a variable
username="$1"

# Define the original and main OUs
original_ou="/Suspended Accounts/Suspended - Temporary Hold"
main_ou="/Temp"

# Move the user to the main OU
echo "Moving $username to $main_ou"
/root/bin/gamadv-x/gam update user "$username" org "$main_ou"

# Check if the move was successful
if [ $? -ne 0 ]; then
    echo "Failed to move $username to $main_ou"
    exit 1
fi

# Perform file renaming (Replace this with your actual file renaming commands)
echo "Renaming files for $username"
#/root/bin/gamadv-x/gam user "$username" rename file ... # Add your file renaming commands here

# Check if the file renaming was successful
#if [ $? -ne 0 ]; then
#    echo "Failed to rename files for $username"
    # Move the user back to the original OU before exiting
#    echo "Moving $username back to $original_ou"
#    gam update user "$username" org "$original_ou"
#    exit 1
#fi

# Move the user back to the original OU
echo "Moving $username back to $original_ou"
/root/bin/gamadv-x/gam update user "$username" org "$original_ou"

# Check if the move back was successful
if [ $? -ne 0 ]; then
    echo "Failed to move $username back to $original_ou"
    exit 1
fi

echo "Completed renaming files for $username and moved back to $original_ou successfully"

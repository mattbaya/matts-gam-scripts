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

# Extract the username without the domain
USERNAME_SHORT=$(echo $USERNAME | awk -F@ '{print $1}')

# Check if a shared drive with the desired name already exists
EXISTING_DRIVE_ID=$($GAM user $ADMIN_USER print teamdrives | awk -F"," -v name="Files From $USERNAME_SHORT" '$3 == name {print $2}')

if [ -n "$EXISTING_DRIVE_ID" ]; then
    echo "A shared drive named 'Files From $USERNAME_SHORT' already exists. Using existing drive."
    SHAREDDRIVE_ID="$EXISTING_DRIVE_ID"
else
    echo "Creating new shared drive 'Files From $USERNAME_SHORT'..."
    SHAREDDRIVE_ID=$($GAM user $ADMIN_USER create teamdrive "Files From $USERNAME_SHORT" | awk -F"id: " '{print $2}')
    echo "Created shared drive with ID: $SHAREDDRIVE_ID"
fi

# Verify if the shared drive ID was successfully retrieved
if [ -z "$SHAREDDRIVE_ID" ]; then
    echo "Error: Failed to create or retrieve the shared drive ID. Exiting."
    exit 1
fi

# Grant the user write access to the shared drive
echo "Granting $USERNAME write access to the shared drive $SHAREDDRIVE_ID ..."
$GAM user $ADMIN_USER add drivefileacl "$SHAREDDRIVE_ID" user "$USERNAME" role manager 

echo "$USERNAME now has write access to the shared drivei $SHAREDDRIVE_ID ."

# Move all files and folders from the user's drive to the shared drive
echo "Moving all files and folders from $USERNAME to shared drive $SHAREDDRIVE_ID ..."
$GAM user $USERNAME copy drivefile root recursive teamdriveparentid '$SHAREDDRIVE_ID' mergewithparent true

echo "All files and folders have been moved to the shared drive: Files From $USERNAME_SHORT"
echo "Sometimes google doesn't recognize share permissions right away, if this fails wait a little bit and try again"

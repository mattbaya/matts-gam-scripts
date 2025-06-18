#!/bin/bash

# Define the GAM path
GAM="/root/bin/gamadv-x/gam"

# Check if exactly two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <FOLDERID> <owner>"
    exit 1
fi

FOLDERID="$1"
OWNER="$2"

SCRIPTPATH="/opt/organization/mjb9/shareddrives/"
TEMP="$SCRIPTPATH/temp/$FOLDERID-unsuspended-temp.csv"
temp_file="$SCRIPTPATH/temp/$FOLDERID-temp.txt"
ADMIN_USER="gam-admin-address@example.edu"
echo "Checking if file/folder $FOLDERID exists"
echo "Folder ID check = $($GAM user $OWNER show fileinfo $FOLDERID | awk -F"id: " '{print $2}'|grep $FOLDERID)"

if [[ "$($GAM user $OWNER show fileinfo $FOLDERID | awk -F"id: " '{print $2}'|grep $FOLDERID)" != $FOLDERID ]]; then
  echo "File doesn't exist. Exiting"
  exit 1
fi
if [[ -n "$($GAM user $OWNER show fileinfo $FOLDERID | grep -i 'teamDriveId')" ]]; then
  echo "This file is already in a shared folder. Exiting"
  exit 1
fi

CURRENT_OWNER=$($GAM user $OWNER show fileinfo $FOLDERID owners | grep displayName | awk -F": " '{print $2}' | tr -d '[:space:]')
echo "Current file owner: $CURRENT_OWNER"

#if [["$CURRENT_OWNER"="$ADMIN_USER"]]; then
#echo "Already owned by $ADMIN_USER skipping change ownership"
#exit 1
#fi 

if [[ $($GAM info user "$OWNER" suspended | grep "Account Suspended" | awk -F": " '{print $2}') == "True" ]]; then
    echo "$OWNER is suspended, temporarily unsuspending"
    WASSUSPENDED="true"
    "$GAM" update user "$OWNER" suspended off
else
    echo "$OWNER is not suspended, proceeding"
fi

echo "Setting $ADMIN_USER as owner of $FOLDERID"
"$GAM" user "$OWNER" add drivefileacl "$FOLDERID" user "$ADMIN_USER" role owner > "$SCRIPTPATH/temp/${FOLDERID}_change-$OWNER-to-gam-admin-address.txt"

echo "Claiming ownership of $FOLDERID for $ADMIN_USER (this might take a while)"
"$GAM" user "$ADMIN_USER" claim ownership $FOLDERID >> $SCRIPTPATH/temp/$FOLDERID-ownership-change-tree.csv
echo "Claimed $(cat $SCRIPTPATH/temp/$FOLDERID-ownership-change-tree.csv|wc -l) files. Checking for any externally owned files"

# Run the GAM command once and store the output in a temporary file
"$GAM" user "$ADMIN_USER" print filelist select id "$FOLDERID" showownedby any fields id,owners.emailaddress > "$temp_file"

# Get total number of files in the folder
total_files=$(wc -l < "$temp_file")
total_files=$((total_files - 1)) # Adjust for header row
echo "Total files to process: $total_files"
processed_files=0
echo "------------------"

# get all file owners and make sure they aren't suspended
FILEOWNERS="$(cat $temp_file |awk -F, '{print $1}'|egrep -v "owners.0.emailAddress"|sort|uniq)"
echo "FILE OWNERS: $FILEOWNERS"
echo "------------------"
echo "$FILEOWNERS"|while IFS=, read owner_email; do
if [[ "$owner_email" == *"@example.edu"* ]]; then
        if [[ $($GAM info user "$owner_email" suspended | grep "Account Suspended" | awk -F": " '{print $2}') == "True" ]]; then
            echo "$owner_email is suspended, temporarily unsuspending"
            echo "$owner_email" >> "$TEMP"
            "$GAM" update user "$owner_email" suspended off
        else
            echo "$owner_email is not suspended, proceeding"
        fi
fi
done

# Create folder for externally owned files that we copy

# Name of the folder we want to check or create
FOLDER_NAME="Copied Files from External Accounts"

# Check if the folder already exists in the parent folder
echo "Checking if '$FOLDER_NAME' already exists in the folder with ID '$FOLDERID'"
EXISTING_FOLDER_INFO=$("$GAM" user "$ADMIN_USER" show filelist query "'$FOLDERID' in parents and name='$FOLDER_NAME' and mimeType='application/vnd.google-apps.folder' and trashed=false")

# Check if the folder exists
if [[ "$EXISTING_FOLDER_INFO" == *"webViewLink"* ]] && [[ ! "$EXISTING_FOLDER_INFO" == *"https://drive.google.com/drive/folders/"* ]]; then
    # The output contains only headers and no folder details, so the folder does not exist
    echo "No existing folder named '$FOLDER_NAME'. Proceeding to create it."
    
    # Folder does not exist, create it
    CREATECOPYFOLDER=$("$GAM" user "$ADMIN_USER" add drivefile drivefilename "$FOLDER_NAME" mimetype gfolder parentid $FOLDERID)
    echo "$CREATECOPYFOLDER"
    COPYFOLDER=$(echo "$CREATECOPYFOLDER" | awk -F"(" '{print $2}' | awk -F")" '{print $1}')
    echo "New folder ID is $COPYFOLDER"
else
    # Folder exists, extract the webViewLink and then extract the ID from it
    WEBVIEWLINK=$(echo "$EXISTING_FOLDER_INFO" | grep "https://drive.google.com/drive/folders/" | head -n 1 | awk '{print $NF}')
    COPYFOLDER=$(echo "$WEBVIEWLINK" | sed 's|.*/||')
    echo "Folder '$FOLDER_NAME' already exists with ID $COPYFOLDER"
fi


echo "------------------"
# Process each file in the folder
tail -n +2 "$temp_file" |
while IFS=, read -r owner file_id count owner_email; do
    processed_files=$((processed_files + 1))
    echo "Processing file #$processed_files of $total_files: ID $file_id owned by $owner"

    if [[ "$owner_email" == *"@example.edu"* ]]; then
        # Change owner if not already owned by ADMIN_USER
        if [ "$owner" != "$ADMIN_USER" ]; then
            echo "Changing owner of file ID $file_id to $ADMIN_USER"
            "$GAM" user "$owner" add drivefileacl "$file_id" user "$ADMIN_USER" role owner | grep "$file_id"
        else
            echo "File ID $file_id is already owned by $ADMIN_USER. Skipping."
        fi
    else
        # File is not owned by a example.edu account. Make a copy.
        echo "File #$processed_files of $total_files is not owned by a example.edu account. Making a copy."

            echo "$GAM user $ADMIN_USER copy drivefile $file_id parentid $COPYFOLDER"
            copied_file_id=$("$GAM" user "$ADMIN_USER" copy drivefile "$file_id" parentid "$COPYFOLDER" | awk '/New File ID: / {print $NF}')
            echo "Made a copy of file #$processed_files of $total_files: ID $file_id in folder ID $COPYFOLDER. New file ID is $copied_file_id"
    fi
done

echo "Processed $processed_files files out of $total_files total."
echo "All files have had ownership changed to gam-admin-address."

if [[ "$WASSUSPENDED" == "true" ]]; then
    echo "Re-suspending $OWNER"
    "$GAM" update user "$OWNER" suspended on
fi

if [[ -s "$TEMP" ]]; then
    echo "$(cat $TEMP)"
    while IFS= read -r USER; do
        echo "Re-Suspending $USER"
        "$GAM" update user "$USER" suspended on
    done < "$TEMP"
    rm $TEMP
fi

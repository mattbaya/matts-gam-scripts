#!/bin/bash

# Usage: ./verify_file_or_folder.sh <FOLDERID> <OWNER>

FOLDERID="$1"
OWNER="$2"
OWNER_TEMP=$(echo $OWNER||awk -F@ '{print $1}')
OWNER=$OWNER_TEMP
GAM="/root/bin/gamadv-x/gam"

# Check if file/folder exists
FOLDER_ID_CHECK="$($GAM user $OWNER show fileinfo $FOLDERID | awk -F"id: " '{print $2}'|grep $FOLDERID)"

if [[ "$FOLDER_ID_CHECK" != $FOLDERID ]]; then
  echo "File doesn't exist. Exiting"
  exit 1
fi

CURRENT_OWNER=$($GAM user $OWNER show fileinfo $FOLDERID owners | grep "owners:" -A 2|grep "emailAddress" | awk -F": " '{print $2}' | tr -d '[:space:]'|awk -F@ '{print $1}')

if [[ $CURRENT_OWNER != $OWNER && $CURRENT_OWNER != gam-admin-address ]]; then
echo "File is owned by $CURRENT_OWNER, not by $OWNER or gam-admin-address. Skipping."
return 0
fi

# Get the MIME type of the item
MIME_TYPE="$($GAM user $OWNER show fileinfo $FOLDERID | grep "mimeType:" | awk -F": " '{print $2}')"
FOLDER_MIME_TYPE="application/vnd.google-apps.folder"

if [ "$MIME_TYPE" = "$FOLDER_MIME_TYPE" ]; then
    echo "$FOLDERID is a folder."
    IS_FOLDER=true
else
    echo "$FOLDERID is not a folder, it's a file."
    IS_FOLDER=false
fi

export IS_FOLDER


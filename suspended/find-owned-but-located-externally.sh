#!/bin/bash

# Check if the username is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <USERNAME>"
    exit 1
fi

USERNAME=$1

# Create a temporary file to hold user files data
tempfile=$(mktemp)

# Get the list of files owned by the user and store in the temporary file
/root/bin/gamadv-x/gam user $USERNAME print filelist id title mimeType owners.emailAddress > "$tempfile"

# Check each file and the owner of its parent folder
tail -n +2 "$tempfile" | while IFS=, read -r user fileID fileName mimeType owner; do
    
    # Get the folder ID where the file is located
    folderID=$(/root/bin/gamadv-x/gam user $USERNAME show fileinfo $fileID | grep 'Parent ID' | cut -d' ' -f3)
    
    # If folderID is empty, skip to the next iteration
    if [ -z "$folderID" ]; then
        continue
    fi

    # Get the owner of the folder
    folderOwner=$(/root/bin/gamadv-x/gam info fileid $folderID | grep 'Owner Email' | cut -d' ' -f3)
    
    # Check if the folder owner is different from the file owner
    if [ "$folderOwner" != "$owner" ]; then
        echo "File $fileName ($fileID) is owned by $owner but is located in a folder owned by $folderOwner"
    fi
done

# Clean up by removing the temporary file
rm -f "$tempfile"


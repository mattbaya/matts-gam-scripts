#!/bin/bash

# Adds PENDING DELETION - CONTACT OIT to $FILEID

USER_EMAIL=$1
FILEID=$2

# Path to the GAM executable
GAM="/root/bin/gamadv-x/gam"

# Run GAM info and check for existence
user_info_output=$($GAM info user "$email" 2>&1)

###########################
# Exit if the user does not exist
if echo "$user_info_output" | grep -q "Does not exist"; then
    echo "User $email does not exist. Exiting."
    exit 0
fi

echo "---------------------------------------"
    if [[ $FILEID != *"http"* ]]; then
        # Get the current filename directly from Google Drive
        current_filename=$($GAM user "$USER_EMAIL" show fileinfo "$FILEID" fields name | grep 'name:' | sed 's/name: //')

echo "####################################################################"
echo "Running rename-single-file.sh on $current_filename for $USER_EMAIL"
echo "####################################################################"
        # Only rename if the filename does not already contain "PENDING DELETION"
        if [[ $current_filename != *"PENDING DELETION - CONTACT OIT"* ]]; then
            # Construct the new filename
            new_filename="${current_filename} (PENDING DELETION - CONTACT OIT)"
            # Update the filename in Google Drive
            $GAM user "$USER_EMAIL" update drivefile "$FILEID" newfilename "$new_filename"
            echo "Updated $FILEID: $current_filename -> $new_filename"
        else
            echo "Already PENDING - $USER_EMAIL $FILEID   $current_filename"
        fi
    fi
echo "----------------------------------------------------------------------"


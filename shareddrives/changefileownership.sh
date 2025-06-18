#!/bin/bash

# Define the GAM path
GAM="/root/bin/gamadv-x/gam"

# Check if a folder ID is passed as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file_id> $1 <current owner> $2 <new owner>"
    exit 1
fi

file_id="$1"
current_owner="$2"
new_owner="$3"

SCRIPTPATH="/opt/organization/mjb9/shareddrives/"
ADMIN_USER="gam-admin-address@example.edu"

    if [[ "$current_owner" == *"@example.edu"* ]]; then
        if [[ $($GAM info user "$current_owner" suspended | grep "Account Suspended" | awk -F": " '{print $2}') == "True" ]]; then
#           echo "$current_owner is suspended, temporarily unsuspending"
#            echo "$current_owner" >> "$TEMP"
            WASSUSPENDED="true"
            "$GAM" update user "$current_owner" suspended off
        fi
        # Change owner if not already owned by $new_owner 
        if [ "$current_owner" != "$new_owner" ]; then
            echo "Changing owner of file ID $file_id to $new_owner"
#            "$GAM" user "$current_owner" add drivefileacl "$file_id" user "new_owner" role owner | grep "$file_id"
	"$GAM" user "$new_owner" claim ownership $folder_id buildtree
        else
            echo "File ID $file_id is already owned by $new_owner. Skipping."
        fi

    fi
done


if [[ "$WASSUSPENDED" == "true" ]]; then
    echo "Re-suspending $current_owner"
    "$GAM" update user "$current_owner" suspended on
fi

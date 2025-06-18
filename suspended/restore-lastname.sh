#!/bin/bash

# This script restores a user's last name by removing the suffix "(PENDING DELETION - CONTACT OIT)".
# Usage: ./restore_lastname.sh <email>

# Check if the email is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <email>"
    exit 1
fi

# Assign the email argument to a variable
email="$1"

# Get the current last name of the user using GAM
current_lastname=$(/root/bin/gamadv-x/gam info user "$email" | awk -F': ' '/Last Name:/ {print $2}')

# Check if the current last name ends with "(PENDING DELETION - CONTACT OIT)"
if [[ "$current_lastname" == *"(PENDING DELETION - CONTACT OIT)" ]]; then
    # Remove the "(PENDING DELETION - CONTACT OIT)" suffix from the current last name
    original_lastname="${current_lastname% (PENDING DELETION - CONTACT OIT)}"
    
    # Restore the original last name
    echo "Restoring $email from '$current_lastname' to '$original_lastname'"
    /root/bin/gamadv-x/gam update user "$email" lastname "$original_lastname"
else
    echo "No change needed for $email, current last name is '$current_lastname'"
fi

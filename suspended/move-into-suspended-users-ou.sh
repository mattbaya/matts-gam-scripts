#!/bin/bash

# Set the location of the GAM executable
GAM="/root/bin/gamadv-xtd3/gam"

# Log file location
LOG_FILE="/opt/organization/mjb9/suspended/not_moved_accounts.log"

USER="$1"

# Get the current OU path of the user
CURRENT_OU=$($GAM info user $USER | grep "Google Org Unit Path:" | awk '{print $5}')

# Check if the user is in the root OU ('/')
if [ "$CURRENT_OU" == "/" ]; then
    # Move the user to the 'Suspended Accounts' OU
    $GAM update user $USER org "Suspended Accounts"
    echo "User $USER moved to 'Suspended Accounts' OU."
else
    # Log the skipped account with date, time, and OU path
    echo "$(date '+%Y-%m-%d %H:%M:%S') - User $USER not moved. Current OU: $CURRENT_OU" >> "$LOG_FILE"
    echo "User $USER is not in the root OU (/), skipping. Logged to $LOG_FILE."
fi

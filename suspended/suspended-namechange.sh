#!/bin/bash

GAM="/root/bin/gamadv-xtd3/gam"
# Target Org Unit for users pending deletion
target_ou="/Suspended Accounts/Suspended - Pending Deletion"

# Check if a username (email) is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

# Set the input username (email)
email="$1"

# Run GAM info and check for existence
user_info_output=$($GAM info user "$email" 2>&1)

###########################
# Exit if the user does not exist
if echo "$user_info_output" | grep -q "Does not exist"; then
    echo "User $email does not exist. Exiting."
    exit 0
fi

# Extract fields from user info output
lastname=$(echo "$user_info_output" | awk -F': ' '/Last Name:/ {print $2}')
# Remove any quotes (") surrounding the last name
lastname="${lastname//\"/}"
suspension_status=$(echo "$user_info_output" | awk -F': ' '/Account Suspended:/ {print $2}')
current_ou=$(echo "$user_info_output" | awk -F': ' '/Org Unit Path:/ {print $2}')

#echo "Lastname:" $lastname
#echo "Suspension Status:" $suspension_status
#echo "Current OU:" $current_ou

# Remove quotes and trim whitespace
lastname="${lastname//\"/}"
lastname="$(echo -e "${lastname}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

# Echo for debug
echo "Lastname: $lastname"

# Define the deletion suffix
deletion_tag="(PENDING DELETION - CONTACT OIT)"

# If last name already ends in the full deletion tag, exit
if [[ "$lastname" == *"$deletion_tag"* ]]; then
    echo "$email already contains pending deletion tag. Exiting."
    exit 0
fi

# STEP 2 - Check if the user is suspended
if [[ "$suspension_status" == "False" ]]; then
    echo "User $email is active. Exiting."
    exit 0
fi

# STEP 3 - Move to the correct Org Unit if not already there
target_ou="/Suspended Accounts/Suspended - Pending Deletion"
if [[ "$current_ou" != "$target_ou" ]]; then
    echo "User $email is in Org Unit: $current_ou. Updating to $target_ou."
    $GAM update user "$email" org "$target_ou"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to update Org Unit for $email"
        exit 1
    fi
    echo "User $email has been moved to Org Unit: $target_ou"
fi
############################
# Add "(PENDING DELETION - CONTACT OIT)" to the last name
new_lastname="$lastname (PENDING DELETION - CONTACT OIT)"
# Echo the email and new last name
echo "$email $lastname to $new_lastname"
/root/bin/gamadv-x/gam update user "$email" lastname "$new_lastname"

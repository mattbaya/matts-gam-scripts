#!/bin/bash

# SUMMARY:
# This script scans all active user accounts in the domain to check for files
# that are marked as "PENDING DELETION - CONTACT OIT" and stores the results
# in a specified directory. If no such files are found for a user, their output
# file is removed to keep the directory clean.

# Define the output directory where scan results will be stored
output_dir="/opt/organization/mjb9/suspended/active-account-scan"

# Ensure the output directory exists; create it if it doesn't
mkdir -p "$output_dir"

# Retrieve a list of all active (not suspended) users from the domain
# Uses GAM to fetch user details and extracts the email addresses of active users
active_users=$(/root/bin/gamadv-x/gam print users query "isSuspended=False" | awk -F, 'NR>1 {print $1}')

# Iterate over each active user account
for user in $active_users; do
    echo "Scanning $user"
    
    # Define the output file that will store scan results for the current user
    output_file="${output_dir}/gam_output_${user}.txt"
    
    # Run GAM command to list files for the user and filter those pending deletion
    /root/bin/gamadv-x/gam user "$user" show filelist id name | \
    grep "(PENDING DELETION - CONTACT OIT)" > "$output_file"
    
    # If the output file is empty (no matching files found), remove it
    if [[ ! -s "$output_file" ]]; then
        rm "$output_file"
    fi

done


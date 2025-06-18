#!/bin/bash

# Check if the input file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <csv_file>"
    exit 1
fi

# Read the input file
input_file="$1"

# Process each line in the input file
while IFS=, read -r email lastname; do
    # Remove any quotes (") surrounding the last name
    lastname="${lastname//\"/}"

    # Check if the last name already ends with "(PENDING DELETION - CONTACT OIT)"
    if [[ $lastname != *"PENDING DELETION - CONTACT OIT" ]]; then
        # Add "(PENDING DELETION - CONTACT OIT)" to the last name
        new_lastname="$lastname (PENDING DELETION - CONTACT OIT)"
        # Echo the email and new last name
        echo "$email $new_lastname"
        /root/bin/gamadv-x/gam update user "$email" lastname "$new_lastname"
    else
        echo "$email $lastname"
    fi
done < "$input_file"


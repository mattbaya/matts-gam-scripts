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

    # If the last name is missing, get it using GAM
    if [ -z "$lastname" ]; then
        lastname=$(/root/bin/gamadv-x/gam info user "$email" | awk -F': ' '/Last Name:/ {print $2}')
    fi

    # Check if the last name already ends with "(PENDING DELETION - CONTACT OIT)"

if [[ "$lastname" == *"(PENDING DELETION - CONTACT OIT)" ]]; then
	echo "Lastname is already changed - $lastname"
        continue
    fi

        # Add "(PENDING DELETION - CONTACT OIT)" to the last name
        new_lastname="$lastname (PENDING DELETION - CONTACT OIT)"
        # Echo the email and new last name
        echo "$email $lastname to $new_lastname"
        /root/bin/gamadv-x/gam update user "$email" lastname "$new_lastname"
done < "$input_file"

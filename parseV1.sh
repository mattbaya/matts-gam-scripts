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
    
    # Echo the email and last name
    echo "$email $lastname"
    /root/bin/gamadv-x/gam update user $email lastname "$lastname (Pending Deletion)"
done < "$input_file"


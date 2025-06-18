#!/bin/bash

# Set the path to the file containing the usernames
USERS_FILE="exampleusers2.txt"

# Loop through each username in the file
while read -r user; do

  # Run the command with the current username and export the output to a temporary file
  #/root/bin/gamadv-x/gam user "$user" show filelist id name > /tmp/gam_output_$user.txt 2>/dev/null
  /root/bin/gamadv-x/gam user "$user" show filelist id name > /tmp/gam_output_$user.txt 

  # Read in the temporary file and extract the relevant information, skipping the header line
  while IFS=, read -r owner fileid filename; do
    if [[ $fileid != *"http"* && $filename != *"PENDING DELETION - CONTACT OIT"* ]]; then
      # If the filename doesn't already have "(PENDING DELETION - CONTACT OIT)" at the end, add it
      /root/bin/gamadv-x/gam user "$owner" update drivefile "$fileid" newfilename "$filename (PENDING DELETION - CONTACT OIT)"
    else
      echo "$owner   $fileid   $filename"
    fi
  done < <(tail -n +2 /tmp/gam_output_$user.txt) # Skip the first line (header)

  # Remove the temporary file
  rm /tmp/gam_output_$user.txt

done < "$USERS_FILE"


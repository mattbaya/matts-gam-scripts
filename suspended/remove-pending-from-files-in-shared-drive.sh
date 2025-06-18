#!/bin/bash
# This script removes the (PENDING DELETION) from filenames in a shared drive.
# mjb9 2023-03 with help from chatgpt

# Check if a drive ID was provided as a command-line argument
if [ -z "$1" ]; then
  echo "Please provide a drive ID as a command-line argument."
  exit 1
fi

# Get the drive ID from the command line
drive_id=$1

# Grant mjb9-ga editor access to the shared drive as an admin
/root/bin/gamadv-x/gam add drivefileacl $drive_id user mjb9-ga role organizer asadmin

# Query the shared drive's files and output only the files with (PENDING DELETION - CONTACT OIT) in the name
/root/bin/gamadv-x/gam user mjb9-ga print filelist select $drive_id fields id,title | grep "(PENDING DELETION - CONTACT OIT)" > /tmp/gam_output_$drive_id.txt

echo "Test run: The following files will be renamed:"
# Read in the temporary file and extract the relevant information, skipping the header line
awk -F, 'NR>1{print $2 "," substr($0, index($0,$3))}' /tmp/gam_output_$drive_id.txt | while IFS=, read -r fileid filename; do
  # Generate the new filename by removing the "(PENDING DELETION - CONTACT OIT)" string
  new_filename=${filename//"(PENDING DELETION - CONTACT OIT)"/}
  if [[ "$new_filename" != "$filename" ]]; then
    # If the filename has changed, print a message indicating the potential change
    echo "Will rename: $filename -> $new_filename"
  fi
done

# Prompt the user to confirm whether to proceed with renaming
read -p "Do you wish to proceed with renaming these files? (y/n): " confirm
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
  # If user confirms, read the temporary file again and apply the renaming
  awk -F, 'NR>1{print $2 "," substr($0, index($0,$3))}' /tmp/gam_output_$drive_id.txt | while IFS=, read -r fileid filename; do
    # Generate the new filename by removing the "(PENDING DELETION - CONTACT OIT)" string
    new_filename=${filename//"(PENDING DELETION - CONTACT OIT)"/}
    if [[ "$new_filename" != "$filename" ]]; then
      # Print the file ID and filename to debug the issue
      echo "Debug: File ID: $fileid, Filename: $filename"
      # If the filename has changed, rename the file and print a message
      /root/bin/gamadv-x/gam user mjb9-ga update drivefile "$fileid" newfilename "$new_filename"
      echo "Renamed file: $filename -> $new_filename"
    fi
  done
else
  echo "Renaming operation cancelled."
fi

# After the user confirms or cancels the renaming operation, revoke mjb9-ga's permissions
echo "Revoking mjb9-ga's permissions to the shared drive..."
/root/bin/gamadv-x/gam user mjb9-ga delete drivefileacl $drive_id mjb9-ga

echo "Permissions revoked. The script has finished executing."


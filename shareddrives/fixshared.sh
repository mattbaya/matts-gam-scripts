#!/bin/bash

#
# Removed the "PENDING DELETION" and "Suspended Account - Temporary Hold" text from all files in a shared drive
# and remove the pending deletion label too
# ./fixshared driveid
#
# Get the shared drive ID from command line
GAM="/root/bin/gamadv-x/gam"
drive_id=$1
owner=gam-admin-address@example.edu
SCRIPTPATH="/opt/organization/mjb9/suspended/"
touch $SCRIPTPATH/logs/$drive_id-renames.txt

# Add gam-admin-address as a user;
echo "Adding user gam-admin-address to the shared drive id $drive_id"
$GAM user gam-admin-address@example.edu add drivefileacl $drive_id user gam-admin-address@example.edu role editor asadmin 2>/dev/null

# Query the files in the shared drive and output only the files with "(PENDING DELETION - CONTACT OIT)" or "(Suspended Account - Temporary Hold)" in the name
allfiles="$( $GAM user gam-admin-address@example.edu show filelist select teamdriveid "$drive_id" fields "id,name" )"

#echo "$allfiles"
#echo "---------"
files=$(echo "$allfiles" | egrep -v "Owner,id" | grep -E "\(PENDING DELETION - CONTACT OIT\)|\(Suspended Account - Temporary Hold\)")
#echo "$files"
echo "---------"
echo "All Files:"$(echo "$allfiles" | wc -l) "," "Files to be renamed:"$(echo "$files" | wc -l)

# Read in the files and extract the relevant information
total=$(echo "$files" | wc -l)
# Initialize the counter
count=0
while IFS=, read -r owner fileid filename; do
  # Increment the counter
  ((count++))

  # Rename the file by removing the "(PENDING DELETION - CONTACT OIT)" and "(Suspended Account - Temporary Hold)" strings
  new_filename=${filename//"(PENDING DELETION - CONTACT OIT)"/}
  new_filename=${new_filename//"(Suspended Account - Temporary Hold)"/}
  
  if [[ "$new_filename" != "$filename" ]]; then
    # If the filename has been changed, rename the file and print a message
    $GAM user "$owner" update drivefile "$fileid" newfilename "$new_filename" 2>/dev/null
    echo "$count of $total - Renamed file: $filename -> $new_filename"
    echo "Renamed file: $filename -> $new_filename" >> $SCRIPTPATH/logs/$drive_id-renames.txt
  fi

# Remove pending deletion label from file as well
if [ -n "$fileid" ]; then
  output=$($GAM user gam-admin-address process filedrivelabels $fileid deletelabelfield xIaFm0zxPw8zVL2nVZEI9L7u9eGOz15AZbJRNNEbbFcb 62BB395EC6 2>/dev/null)
  
  # Check if the output contains "Deleted" and then print the message
  if echo "$output" | grep -q "Deleted"; then
    echo "Label deleted for file ID $fileid"
  fi
fi

done <<< "$files"

echo "Removing gam-admin-address from the shared drive id $drive_id"
/root/bin/gamadv-x/gam user gam-admin-address@example.edu delete drivefileacl $drive_id gam-admin-address@example.edu asadmin 2>/dev/null
echo "Log file for this is at /opt/organization/mjb9/suspended/logs/$drive_id-renames.txt"
echo "--------------------------------------------------"

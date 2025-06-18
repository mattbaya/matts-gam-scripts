#!/bin/bash

#
# Remove specific labels from all files in a shared drive
# Usage: ./removelabel.sh <drive_id>
#
# Get the shared drive ID from the command line
GAM="/root/bin/gamadv-x/gam"
drive_id=$1
owner=gam-admin-address@example.edu
SCRIPTPATH="/opt/organization/mjb9/suspended/"

# Define the label field IDs to remove
pending_deletion_label_id="vsltZcBDC0xJm62rO2kBqi7biuNuEX7OO0HRNNEbbFcb"
warning_label_id="xIaFm0zxPw8zVL2nVZEI9L7u9eGOz15AZbJRNNEbbFcb"

touch $SCRIPTPATH/logs/$drive_id-label-removal.txt

# Add gam-admin-address as a user if necessary (optional)
echo "Adding user gam-admin-address to the shared drive id $drive_id"
$GAM user gam-admin-address@example.edu add drivefileacl $drive_id user gam-admin-address@example.edu role organizer asadmin 2>/dev/null

# Query the files in the shared drive and list them
echo "Finding files in shared drive $drive_id"
files_with_labels=$( $GAM user gam-admin-address show filelist teamdriveid "$drive_id" fields id,name )

# Count the number of files found
total=$(echo "$files_with_labels" | grep -c "^id")
echo "Total files found: $total"
echo "--------------------------------------------------"

# Initialize the counter
count=0

# Process each file
echo "$files_with_labels" | while IFS=, read -r fileid filename; do
  # Skip the header line if any
  if [[ "$fileid" == "id" ]]; then
    continue
  fi

  # Increment the counter
  ((count++))

  # Remove the Pending Deletion label
  echo "Processing file: $filename (ID: $fileid)"
  
  # Remove the "Pending Deletion" label
  if [ -n "$fileid" ]; then
    output=$($GAM user gam-admin-address process filedrivelabels $fileid deletelabelfield "$pending_deletion_label_id" 2>/dev/null)
    if echo "$output" | grep -q "Deleted"; then
      echo "$count of $total - Removed 'Pending Deletion' label from file: $filename (ID: $fileid)"
      echo "Removed 'Pending Deletion' label from file: $filename (ID: $fileid)" >> $SCRIPTPATH/logs/$drive_id-label-removal.txt
    else
      echo "$count of $total - Failed to remove 'Pending Deletion' label from file: $filename (ID: $fileid)"
    fi
  fi

  # Remove the "Warning" label
  if [ -n "$fileid" ]; then
    output=$($GAM user gam-admin-address process filedrivelabels $fileid deletelabelfield "$warning_label_id" 2>/dev/null)
    if echo "$output" | grep -q "Deleted"; then
      echo "$count of $total - Removed 'Warning' label from file: $filename (ID: $fileid)"
      echo "Removed 'Warning' label from file: $filename (ID: $fileid)" >> $SCRIPTPATH/logs/$drive_id-label-removal.txt
    else
      echo "$count of $total - Failed to remove 'Warning' label from file: $filename (ID: $fileid)"
    fi
  fi
done

# Optionally, remove gam-admin-address from the shared drive after the operation
echo "Removing gam-admin-address from the shared drive id $drive_id"
$GAM user gam-admin-address@example.edu delete drivefileacl $drive_id gam-admin-address@example.edu asadmin 2>/dev/null

echo "Label removal completed. Log file for this operation is at /opt/organization/mjb9/suspended/logs/$drive_id-label-removal.txt"
echo "--------------------------------------------------"

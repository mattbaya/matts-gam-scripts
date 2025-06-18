#!/bin/bash

#
# Removed the "PENDING DELETION" text from all files in ALL shared drives.
# and remove the pending deletion label too
# ./fixshared driveid
#
# Get the shared drive ID from shareddrives.txt
GAM="/root/bin/gamadv-x/gam"
owner=gam-admin-address@example.edu
SCRIPTPATH="/opt/organization/mjb9/shareddrives/"

for drive_id in $(cat $SCRIPTPATH/shareddrives.txt); do 
# Add gam-admin-address as a user;
echo "Adding user gam-admin-address to the shared drive id $drive_id"
$GAM user gam-admin-address@example.edu add drivefileacl $drive_id user gam-admin-address@example.edu role editor asadmin 2>/dev/null

# Query the files in the shared drive and output only the files with "(PENDING DELETION - CONTACT OIT)" in the name
allfiles="$( $GAM user gam-admin-address@example.edu show filelist select teamdriveid "$drive_id" fields "id,name" )"
# Check if $files has more than 1 character
files=$(echo "$allfiles"|egrep -v "Owner,id"|grep "(PENDING DELETION - CONTACT OIT)")
# Check if $files has more than 1 character
if [ ${#files} -gt 1 ]; then
    echo "$files" > logs/${drive_id}-files.txt
fi
echo "---------"
echo "All Files:"$(echo "$allfiles"|wc -l) "," "Files to be renamed:"$(echo "$files"|wc -l)
#for i in $files; do echo $i | awk -F, '{print $2,$3}' >> $SCRIPTPATH/logs/${drive_id}-files-to-be-renamed.txt;done
cat $SCRIPTPATH/logs/${drive_id}-files-to-be-renamed.txt
echo "Removing gam-admin-address from the shared drive id $drive_id"
/root/bin/gamadv-x/gam user gam-admin-address@example.edu delete drivefileacl $drive_id gam-admin-address@example.edu asadmin 2>/dev/null
echo "--------------------------------------------------";
done


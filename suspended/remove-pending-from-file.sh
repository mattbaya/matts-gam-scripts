#!/bin/bash

#
# Removed the "PENDING DELETION" text & label from a drive file
#
GAM="/root/bin/gamadv-x/gam"
owner=$1
fileid=$2
ADMIN_USER=gam-admin-address@domain.com
SCRIPTPATH="/opt/organization/mjb9/suspended/"
touch $SCRIPTPATH/logs/$drive_id-renames.txt

file="$($GAM user $owner show fileinfo $fileid fields "id,name")"
filename="$(echo "$file"| grep name: |awk -F"name: " '{print $2}')"
echo $owner $fileid $filename 

  # Rename the file by removing the "(PENDING DELETION - CONTACT OIT)" string
  new_filename=${filename//"(PENDING DELETION - CONTACT OIT)"/}
  if [[ "$new_filename" != "$filename" ]]; then
    # If the filename has been changed, rename the file and print a message
echo "$GAM user "$owner" update drivefile "$fileid" newfilename "$new_filename" "
$GAM user "$owner" update drivefile "$fileid" newfilename "$new_filename" 
    echo "Renamed file:$fileid, $filename -> $new_filename" >> $SCRIPTPATH/logs/$fileid-rename.txt
  fi
# remove pending deletion label from file as well
if [ -n "$fileid" ]; then
	$GAM user $owner process filedrivelabels $fileid deletelabelfield xIaFm0zxPw8zVL2nVZEI9L7u9eGOz15AZbJRNNEbbFcb 62BB395EC6 |grep "Deleted" 
fi
echo "Log file for this is at logs/$fileid-rename.txt"
echo "--------------------------------------------------"


#!/bin/bash

# Define the GAM path
GAM=/root/bin/gamadv-x/gam

if [ "$#" -lt 3 ]; then
    echo "Usage:<OWNER> <FOLDERID> <TeamDriveID>"
    exit 1
fi
OWNER="$1"
FOLDERID="$2"
TEAMDRIVEID="$3"
ADMIN_USER="gam-admin-address@example.edu"
OWNER_TEMP=$(echo $OWNER|awk -F@ '{print $1}')
OWNER=$OWNER_TEMP

if [[ "$($GAM user $OWNER show fileinfo $FOLDERID | awk -F"id: " '{print $2}'|grep $FOLDERID)" != $FOLDERID ]]; then
  echo "File doesn't exist. Exiting"
  exit 1
fi

if [[ -n "$($GAM user $OWNER show fileinfo $FOLDERID | grep -i 'teamDriveId')" ]]; then
  echo "This file is already in a shared folder. Exiting"
  exit 1
fi

CURRENT_OWNER=$($GAM user $OWNER show fileinfo $FOLDERID owners | grep "owners:" -A 2|grep "emailAddress" | awk -F": " '{print $2}' | tr -d '[:space:]'|awk -F@ '{print $1}')

if [[ $CURRENT_OWNER != $OWNER && $CURRENT_OWNER != gam-admin-address ]]; then
echo "File is owned by $CURRENT_OWNER, not by $OWNER or gam-admin-address. Skipping."
exit 1
fi

# Change all the files in that folder to be owned by gam-admin-address
#echo "Running changing ownership for $FOLDERID $OWNER TEAMDRIVEID"

#/opt/organization/mjb9/shareddrives/changeALLfileownership.sh $FOLDERID $OWNER
source /opt/organization/mjb9/changeowner/main.sh $FOLDERID $OWNER $TEAMDRIVEID
echo "****************************************"
echo "Change ownership complete. Moving files to shared folder"
echo "****************************************"

# Grant gam-admin-address permission to the Shared Drive 
$GAM user $ADMIN_USER add drivefileacl "$TEAMDRIVEID" user gam-admin-address role organizer asadmin|grep -i "added"

# Look up the shared drive name based on the ID
TEAMDRIVENAME=$($GAM user gam-admin-address info teamdrive "$TEAMDRIVEID" | awk -F': ' '/Name/{print $2}')

echo "Moving $FOLDERID into '$TEAMDRIVENAME'"

if [[ -n "$NEW_PARENT_ID" ]]; then
    	echo "NEW_PARENT_ID is not empty, moving the file in there"
	$GAM user $ADMIN_USER move drivefile "$FOLDERID" parentid "$NEW_PARENT_ID"
else
	echo "No parent ID provided, just using teamdriveid"
	$GAM user $ADMIN_USER move drivefile "$FOLDERID" teamdriveparentid "$TEAMDRIVEID"
fi

#echo "Removing gam-admin-address from access to $TEAMDRIVENAME"
#$GAM user gam-admin-address delete drivefileacl "$TEAMDRIVEID" gam-admin-address@example.edu
echo "-------------------------------------------"
echo "if this worked as expected, the next logical step would be to run: "
echo "/opt/organization/mjb9/suspended/fixshared.sh $TEAMDRIVEID"
echo "-------------------------------------------"



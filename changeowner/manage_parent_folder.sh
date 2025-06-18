#!/bin/bash
# This script is called by main.sh
# Usage: ./manage_parent_folder.sh <FOLDERID> <OWNER> <ADMIN_USER>
# This script checks the ownership of the parent folder of a given Google Drive item. If it is then it sets a flag for the parent script to run against the parent id
# If the parent folder is not owned by the OWNER or ADMIN_USER it checks if the current owner's account is suspended 
# If the account is suspended, it flags the parent folder for moving to a shared drive.

# Assigning command-line arguments to variables.
FOLDERID="$1"
OWNER="$2"
ADMIN_USER="$3"
SCRIPTPATH="/opt/organization/mjb9/changeowner"
GAM="/root/bin/gamadv-x/gam"
RECURSE_WITH_PARENT=false
#TEAMDRIVEID is defined in the parent script, main.sh
#FOLDER_NAME="Copied Files from External Accounts"

# Retrieve the parent ID of the folder.
PARENT_ID="$($GAM user $OWNER show fileinfo $FOLDERID parents | grep "id:" | awk -F": " '{print $2}' | tr -d '[:space:]')"
echo "Retrieved parent ID: $PARENT_ID"

# Retrieve the ownership of the parent folder.
PARENT_OWNERSHIP="$($GAM user $OWNER show fileinfo $PARENT_ID owners| grep "owners:" -A 2 | grep "emailAddress" | awk -F": " '{print $2}' | tr -d '[:space:]'|awk -F@ '{print $1}')"
echo "Ownership of parent folder: $PARENT_OWNERSHIP"

PARENT_NAME=$($GAM user $PARENT_OWNERSHIP show fileinfo $PARENT_ID|grep "name:"|egrep -v canRename|awk -F": " '{print $2}')
echo "Parent Folder Name: $PARENT_NAME"
if [[ $PARENT_NAME != "My Drive" ]]; then


if [[ -n $PARENT_OWNERSHIP ]]; then

# Check if the owner of the parent is the same as $OWNER or ADMIN_USER.
if [[ "$PARENT_OWNERSHIP" == "$OWNER" || "$PARENT_OWNERSHIP" == "$ADMIN_USER" ]]; then
    echo "Parent folder is owned by the owner or admin user. So let's move that instead."
    CURRENT_OWNER=$PARENT_OWNERSHIP
    RECURSE_WITH_PARENT=true
    return 0
else
    echo "Parent folder is not owned by the owner or admin user."
    # Check the current owner of the parent folder and if the account is suspended.
    #echo "Checking the current owner of the parent of the file/folder and account suspension status."
    #CURRENT_OWNER=$($GAM user $PARENT_OWNERSHIP show fileinfo $PARENT_ID owners | grep "owners:" -A 2|grep "emailAddress" | awk -F": " '{print $2}' | tr -d '[:space:]'|awk -F@ '{print $1}')
    #ACCOUNT_SUSPENDED=$($GAM info user $CURRENT_OWNER suspended | grep "Account Suspended:" | awk -F": " '{print $2}' | tr -d '[:space:]')

    # If the current owner's account is suspended, move the parent folder to the shared drive.
    #if [[ "$ACCOUNT_SUSPENDED" == "TRUE" ]]; then
        #echo "Parent folder was owned by a suspended account ($CURRENT_OWNER), moving it to the shared drive."
        #RECURSE_WITH_PARENT=true
        #return 0
    #else
  #	echo "Parent folder is owned by a non-suspended user, so we wont mess with it"
  #  fi
fi

# This section generates a new folder name and creates that folder in the $TEAMDRIVEID if it doesn't exist.
echo "Processing item with ID: $FOLDERID"
echo "Parent Folder Name: $PARENT_NAME"
# Generate a new folder name.
NEW_FOLDER_NAME="${PARENT_NAME}_${OWNER}"
else
echo "No parent folder found, so since it's just at the users top level drive we'll just use their username as the NEW_FOLDER_NAME"
NEW_FOLDER_NAME="Files From ${OWNER}"
fi
else
echo "No parent folder found, so since it's just at the users top level drive we'll just use their username as the NEW_FOLDER_NAME"
NEW_FOLDER_NAME="Files From ${OWNER}"
fi

echo "New Folder Name: $NEW_FOLDER_NAME"

# Check if a folder with the new name already exists.
#CHECK_FOLDER_EXIST=$("$GAM" user "$ADMIN_USER" show filelist query "name='$NEW_FOLDER_NAME' and mimeType='application/vnd.google-apps.folder' and trashed=false and 'parents' in '$TEAMDRIVEID'")
"$GAM" user "$ADMIN_USER" show fileinfo teamdriveid "$TEAMDRIVEID" teamdrivefilename "$NEW_FOLDER_NAME" id|grep "id: "|head -1
CHECK_FOLDER_EXIST=$("$GAM" user "$ADMIN_USER" show fileinfo teamdriveid "$TEAMDRIVEID" teamdrivefilename "$NEW_FOLDER_NAME" id|grep "id: " |head -1)
echo "CHECK_FOLDER_EXIST = $CHECK_FOLDER_EXIST"

# If the folder exists, get the existing folder's ID. Otherwise, create a new folder and record its ID.
if [[ "$CHECK_FOLDER_EXIST" == *"id: "* ]]; then
    NEW_PARENT_ID=$(echo "$CHECK_FOLDER_EXIST" | grep "id: " | awk -F": " '{print $2}' | tr -d '[:space:]')
    echo "Folder already exists with ID: $NEW_PARENT_ID"
else
    echo "Creating new folder: $NEW_FOLDER_NAME in Team Drive: $TEAMDRIVEID"
    NEW_PARENT_ID=$("$GAM" user "$ADMIN_USER" create drivefile drivefilename "$NEW_FOLDER_NAME" mimeType gfolder parentid "$TEAMDRIVEID" | awk -F": " '{print $3}'|awk -F"(" '{print $2}'|awk -F")" '{print $1}')
    echo "New folder created with ID: $NEW_PARENT_ID"
    echo $NEW_PARENT_ID > new-folder-ids-for-${ADMIN_USER}.txt
fi

echo "manage_parent_folder Script execution completed"


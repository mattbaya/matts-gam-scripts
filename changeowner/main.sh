#!/bin/bash

# Define variables
FOLDERID="$1"
OWNER="$2"
TEAMDRIVEID="$3"
ADMIN_USER="gam-admin-address@domain.com"
SCRIPTPATH="/opt/organization/mjb9/changeowner"

# 1. Verify File/Folder
source $SCRIPTPATH/verify_file_or_folder.sh $FOLDERID $OWNER

# 2. Handle Suspension
source $SCRIPTPATH/handle_suspension.sh $OWNER

# 2.5 Rename file
source $SCRIPTPATH/add-old-username-to-filename.sh $FOLDERID $OWNER

# 3. Manage Parent Folder
source $SCRIPTPATH/manage_parent_folder.sh $FOLDERID $OWNER $ADMIN_USER $IS_FOLDER

# 4. Check if recursive call is needed
if [[ "$RECURSE_WITH_PARENT" == "true" ]]; then
    # Call main.sh recursively with the new parent ID
    echo "Calling move-folder-to-shared-drive.sh on $PARENT_OWNERSHIP $PARENT_ID $TEAMDRIVEID"
    /opt/organization/mjb9/shareddrives/move-folder-to-shared-drive.sh $PARENT_OWNERSHIP "$PARENT_ID" $TEAMDRIVEID
    #exit 0
fi

# 5. Ownership and Permissions Management
source $SCRIPTPATH/ownership_management.sh $FOLDERID $OWNER $ADMIN_USER $IS_FOLDER

# 6. Cleanup and Final Steps
source $SCRIPTPATH/cleanup_and_finalize.sh $OWNER $WASSUSPENDED


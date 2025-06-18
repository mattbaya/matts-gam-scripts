#!/bin/bash

# This script checks all files shared by $1 to $2 and transfers ownership to $2
# Also, if $3 is Y or y then rename the files with $1 included using filename_$1.pdf format

GAM="/root/bin/gamadv-x/gam"
USER="$1"
NEWOWNER="$2"
APPEND_OLD_OWNER_NAME="$3"

# Check if all required arguments are provided
if [ $# -lt 2 ]; then
    echo "Missing arguments."
    [ -z "$USER" ] && echo "CURRENT OWNER not provided."
    [ -z "$NEWOWNER" ] && echo "NEW OWNER not provided."
    [ -z "$APPEND_OLD_OWNER_NAME" ] && echo "APPEND OLD OWNER NAME not provided."
    
    # Ask for missing arguments
    [ -z "$USER" ] && read -p "Enter CURRENT OWNER: " USER
    [ -z "$NEWOWNER" ] && read -p "Enter NEW OWNER: " NEWOWNER
    [ -z "$APPEND_OLD_OWNER_NAME" ] && read -p "Should filenames be modified to add $USER at the end of the filename (Y/N)? " APPEND_OLD_OWNER_NAME
fi

# Echo back the fields and ask for confirmation
echo "CURRENT OWNER=$USER"
echo "NEW OWNER=$NEWOWNER"
echo "Rename files to add CURRENT OWNER at the end of the filename: $APPEND_OLD_OWNER_NAME"
echo "----"
read -p "Press Y to confirm this change: " confirmation

# Check if the user input is 'Y' or 'y'
if [[ $confirmation == [Yy] ]]; then
    echo "Changing ownership of all files shared by $USER to $NEWOWNER"
    # Code to execute the change
    echo "Confirmed. Proceeding with the change."
else
    echo "Change cancelled."
    exit 1
fi

SCRIPTPATH="/opt/organization/mjb9"
ACTIVE="/opt/organization/mjb9/listshared/csv-files/"$USER"_active-shares.csv"
TEMP="/opt/organization/mjb9/listshared/csv-files/$USER-chown-to-$NEWOWNER.csv"
echo "active: $ACTIVE"
echo "temp: $TEMP"
rm -Rf $TEMP
echo "-------------------------"
  echo "Regenerating $USER's active-share file"
  $SCRIPTPATH/listshared/list-users-files.sh $USER
echo "-------------------------"
echo "Creating list of files to transfer and rename (if requested)"
echo "----"
grep "${NEWOWNER}@example.edu" $ACTIVE > $TEMP

# Check if $TEMP file exists and is not empty
if [ ! -s "$TEMP" ]; then
    echo "The file $TEMP does not exist or is empty. Exiting the script."
    exit 1
else 
    count="$(cat $TEMP|wc -l)"
    echo $count " found."
fi
counter=0


echo "Changing file ownerships..."
counter=0
for file in $(cat $TEMP|awk -F, '{print $2}'); do
    ((counter++))
    echo "Working on file #${counter}"

    # Check if the user wants to rename this file
    if [[ $APPEND_OLD_OWNER_NAME == [Yy] ]]; then
        echo "Renaming file ID $file with old owner's name"
        $SCRIPTPATH/changeowner/add-old-username-to-filename.sh $file $USER
    else 
	echo "Not appending $USER to filename."
    fi

    echo "Changing file number $counter of $count"
    $SCRIPTPATH/changeowner/changefileownership.sh $USER $NEWOWNER $file
    echo "------"
done

echo "------------------------------------"
echo "Renaming any files that have (PENDING DELETION - CONTACT OIT) in them for $NEWOWNER"
$SCRIPTPATH/suspended/filesfix.sh $NEWOWNER
echo "------------------------------------"
echo "Rename log: /opt/organization/mjb9/listshared/csv-files/$USER-chown-to-$NEWOWNER.csv"


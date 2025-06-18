#!/bin/bash

# This script changes the ownership of a file id ($3) from user $1 to $2

GAM="/root/bin/gamadv-x/gam"
SCRIPTPATH="/opt/organization/mjb9/changeowner"
LOG_DIR="$SCRIPTPATH/logs"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Set the variables
# Set the variables
OLD_OWNER=$(echo "$1" | tr -d '[:space:]')
NEW_OWNER=$(echo "$2" | tr -d '[:space:]')
FILE_ID=$(echo "$3" | tr -d '[:space:]')

# Check if required parameters are provided
if [ -z "$OLD_OWNER" ] || [ -z "$NEW_OWNER" ] || [ -z "$FILE_ID" ]; then
    echo "Usage: $0 <old_owner> <new_owner> <file_id>"
    exit 1
fi

echo "Old Owner: $OLD_OWNER"
echo "New Owner: $NEW_OWNER"
echo "File ID: $FILE_ID"
echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

LOG="$LOG_DIR/$OLD_OWNER-chown-to-$NEW_OWNER.csv"

# Fetch the filename
#echo "$GAM user $OLD_OWNER print fileinfo $FILE_ID name"
#echo "%%%%%%%%%%%%%%%%%%%%%"
$GAM user $OLD_OWNER print fileinfo $FILE_ID name
FILENAME=$($GAM user $OLD_OWNER print fileinfo $FILE_ID name | grep -i "name:" | awk -F"name: " '{print $2}')

# Check if FILENAME is empty
if [ -z "$FILENAME" ]; then
    echo "Error: Unable to fetch the filename. It is likely that $OLD_OWNER no longer owns the file with ID $FILE_ID."
    exit 1
fi

echo "Filename: $FILENAME"
echo "----"
echo "Changing ownership of $FILENAME ($FILE_ID) from $OLD_OWNER to $NEW_OWNER"

# Check if old and new owners are different
if [[ "$OLD_OWNER" != "$NEW_OWNER" ]]; then
    echo "++++"
    echo "${GAM} user ${NEW_OWNER} claim ownership ${FILE_ID} filepath"
    echo "++++"
    # Uncomment the following line in production
    $GAM user ${NEW_OWNER} claim ownership ${FILE_ID} filepath

    # Log the ownership change
    echo "$FILE_ID,$OLD_OWNER,$NEW_OWNER,$(date +%Y-%m-%d-%H:%M),$FILENAME,$FILEPATH" >> "$LOG"
    echo "----"
else
    echo "$FILE_ID is already owned by $NEW_OWNER, skipping"
    exit 1
fi
echo "----------------------------------------------------------------"

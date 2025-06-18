# This script requires the file ID and former owner username.
# ./scriptname <fileID> <username>
# It will rename the file "(username) <current filename>"
#

#!/usr/bin/bash

GAM="/root/bin/gamadv-x/gam"
SCRIPTPATH="/opt/organization/mjb9/changeowner"

# Set the variables
FILE_ID="$1"
OLD_OWNER="$2"

# Check if OLD_OWNER contains "@" symbol
if [[ "$OLD_OWNER" == *'@'* ]]; then
    # Extract the username part before "@" symbol
    OLD_OWNER="${OLD_OWNER%%@*}"
fi

# Now OLD_OWNER contains only the username part

LOG="/opt/organization/mjb9/changeowner/logs/added-$OLD_OWNER_to_files_transferred_to_$NEW_OWNER.txt"

# Query current owner
NEW_OWNER="$($GAM user $OLD_OWNER show fileinfo $FILE_ID owners|grep emailAddress|awk -F": " '{print $2}'|awk -F"@" '{print $1}')"

# Query filename
FILENAME=$($GAM user $OLD_OWNER print fileinfo $FILE_ID name|grep "name:"|awk -F": " '{print $2}')
echo "Current Filename: $FILENAME"

# Regular expression to match filename, extension, extra text, and OLD_OWNER
REGEX="^(.+)\.([^.]+)( .+)?$"
OWNER_REGEX="^(.+)${OLD_OWNER}(\.[^.]+( .+)?)?$"

if [[ $FILENAME =~ $OWNER_REGEX ]]; then
    # If OLD_OWNER is already in the filename, exit the script
    echo "$OLD_OWNER is already part of the filename. Exiting."
    return 0 
elif [[ $FILENAME =~ $REGEX ]]; then
    # Extract the base filename, extension, and extra text
    BASENAME="${BASH_REMATCH[1]}"
    EXT="${BASH_REMATCH[2]}"
    EXTRA_TEXT="${BASH_REMATCH[3]}"

    # Construct new filename with OLD_OWNER before the extension
    NEWFILENAME="${BASENAME}_${OLD_OWNER}.${EXT}${EXTRA_TEXT}"
else
    # If the file does not match the pattern (no extension), simply append OLD_OWNER
    NEWFILENAME="${FILENAME}_${OLD_OWNER}"
fi

# Output the new filename
echo "New Filename: $NEWFILENAME"

# Regular expression for checking if the filename contains "_${OLD_OWNER}." before the extension
# This regex checks for the pattern "_${OLD_OWNER}." within the filename
REGEX="_${OLD_OWNER}\."

# Check if the filename already contains "_${OLD_OWNER}" before the extension
if [[ $FILENAME =~ $REGEX ]]; then
    echo "The file $FILENAME already contains _$OLD_OWNER before the extension, skipping..."
else
    echo "Renaming $FILENAME to $NEWFILENAME"
    # Rename file
    $GAM user "$OLD_OWNER" update drivefile "$FILE_ID" newfilename "$NEWFILENAME" >>$LOG
    tail -1 $LOG
fi


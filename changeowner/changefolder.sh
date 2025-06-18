#!/usr/bin/bash
#
# This script changes the ownership of all files in $2 to be owned by $1
#
# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 NEW_OWNER FOLDERID"
    exit 1
fi

GAM="/root/bin/gamadv-x/gam"
SCRIPTPATH="/opt/organization/mjb9/changeowner"
# Set the variables
NEW_OWNER="$1"
FOLDERID="$2"
echo "----"
echo "Trying Claim Ownership first."
$GAM user $NEW_OWNER claim ownership $FOLDERID
echo "----"
echo "Listing all files under $FOLDERID"
$SCRIPTPATH/listall.sh $NEW_OWNER $FOLDERID
echo "----"
FILELIST="$SCRIPTPATH/csv-files/${NEW_OWNER}-files-under-${FOLDERID}.csv"
echo $FILELIST
TOTAL=$(tail -n +2 $FILELIST|wc -l)
COUNTER=0
echo "TOTAL of $TOTAL files"

while IFS= read -r FILE; do 
        ((COUNTER++))
	echo "---"
	echo "Processing $COUNTER of $TOTAL"
	OLD_OWNER=$(echo "$FILE"|awk -F, '{print $9}'|awk -F@ '{print $1}')
	FILEID=$(echo "$FILE"|awk -F, '{print $2}')
	if [[ $OLD_OWNER != $NEW_OWNER ]]; then
	echo "Changing $FILEID from $OLD_OWNER to $NEW_OWNER"
	$SCRIPTPATH/changefileownership.sh $OLD_OWNER $NEW_OWNER $FILEID
	else
	echo "$FILEID already owned by $NEW_OWNER"
	fi
done < <(tail -n +2 "$FILELIST")

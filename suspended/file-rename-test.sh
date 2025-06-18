#!/bin/bash

# Set the path to the file containing the usernames
USER_EMAIL=$1

GAM="/root/bin/gamadv-x/gam"

# Define files. We read the active-shares file and re-generate the unique one from that. Other scripts like label-shared reference the unique_files file too.
#
INPUT_FILE="/opt/organization/mjb9/listshared/csv-files/${USER_EMAIL}_active-shares.csv"
UNIQUE_FILE="/opt/organization/mjb9/listshared/csv-files/${USER_EMAIL}_unique_files.csv"
TEMP_FILE="/opt/organization/mjb9/listshared/csv-files/${USER_EMAIL}_temp.csv"
ALL_FILE="/opt/organization/mjb9/listshared/csv-files/${USER_EMAIL}_all_files.csv"
ALL_TEMP="/opt/organization/mjb9/listshared/csv-files/${USER_EMAIL}_all_temp.csv"

# Check if active-shares file exists
if [ ! -f "$INPUT_FILE" ]; then
  # Run the /opt/organization/mjb9/listshared/list-users-files.sh to generate reports an CSV files.
	echo "$INPUT_FILE doesn't exist." 
	echo "Running /opt/organization/mjb9/listshared/list-users-files.sh $USER_EMAIL"
	/opt/organization/mjb9/listshared/list-users-files.sh $USER_EMAIL
  else
	echo "Yay! $INPUT_FILE already exists"	
fi
# Since it's pretty quick, lets regenerate the master list of all files owned by this account.
echo "Creating new $ALL_TEMP"
$GAM user ${USER_EMAIL} show filelist id title > "$ALL_TEMP"
# and lets match all the IDs from the older active-shares file but get the updated filenames from all_files
rm -f $TEMP_FILE
counter=0
total=$(cat $UNIQUE_FILE|wc -l)
echo "Creating $TEMP_FILE"
	for i in $(cat $UNIQUE_FILE | awk -F, '{print $2}'); do 
         ((counter++))
echo "$counter of $total"
	grep $i $ALL_TEMP>>$TEMP_FILE;done
	echo "$TEMP_FILE created"
	#cat $TEMP_FILE|sort|uniq|egrep -v "mimeType" > $TEMP_FILE

echo "------------------------------------------"
echo "$USER_EMAIL | "Total shared files:" $(cat $TEMP_FILE|wc -l)"
echo "------------------------------------------"

# Initialize the counter
counter=0
total=$(cat $TEMP_FILE|egrep -v "Owner,id,name"|egrep -v "PENDING DELETION"|wc -l)
echo $(cat $TEMP_FILE|wc -l)" files to be renamed"
echo $total" not renamed yet"

echo "Renaming, where applicable"
echo "---------------------------------------"
# Read in the temporary file and extract the relevant information, skipping the header line
while IFS=, read -r fileid filename; do
((counter++))
echo "$counter of $total: Filename: $filename"
  if [[ $fileid != *"http"* ]]; then
    # Get the current filename directly from Google Drive
    current_filename=$($GAM user "$USER_EMAIL" show fileinfo "$fileid" fields name | awk -F': ' '{print $2}')
#    echo "current filename: $current_filename"

    # If the current filename doesn't already have "(PENDING DELETION - CONTACT OIT)" at the end, add it
    if [[ $current_filename != *"PENDING DELETION - CONTACT OIT"* ]]; then
    $GAM user "$USER_EMAIL" update drivefile "$fileid" newfilename "$filename (PENDING DELETION - CONTACT OIT)"
    else
      echo "Already PENDING - $USER_EMAIL $fileid   $current_filename"
    fi
  fi
        done < <(cat $TEMP_FILE | egrep -v "PENDING DELETION"|egrep -v "Owner,id,name"|awk -F, '{printf $2","; for (i=3; i<=NF; i++) printf " " $i; print ""}')

echo "done scanning files"
echo ${USER_EMAIL}","$(date '+%Y-%m-%d %H:%M:%S') >> file-rename-done.txt
echo "Resetting unique file"
cat "$INPUT_FILE" | egrep -v ".DS_Store"|awk -F, '{print $1","$2","$3","$4","$5","$6","$7}' | sort | uniq > "$UNIQUE_FILE"
echo "----------------------------------------------------------------------"

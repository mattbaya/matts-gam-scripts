#!/bin/bash

# Set the path to the file containing the usernames
USER_EMAIL=$1

GAM="/root/bin/gamadv-x/gam"

INPUT_FILE="/opt/organization/mjb9/listshared/csv-files/${USER_EMAIL}_active-shares.csv"
UNIQUE_FILE="/opt/organization/mjb9/listshared/csv-files/${USER_EMAIL}_unique_files.csv"
# Check if active-shares file exists
if [ ! -f "$INPUT_FILE" ]; then
  # Run the /opt/organization/mjb9/listshared/list-users-files.sh to generate reports an CSV files.
	echo "$INPUT_FILE doesn't exist." 
	echo "Running /opt/organization/mjb9/listshared/list-users-files.sh $USER_EMAIL"
	/opt/organization/mjb9/listshared/list-users-files.sh $USER_EMAIL
  else
	echo "Yay! $INPUT_FILE already exists"	
fi

# Check if the file exists
#if [ ! -f "$UNIQUE_FILE" ]; then
  # Run the command to create the unique file
  #cat "$INPUT_FILE" | egrep -v ".DS_Store"|awk -F, '{print $1","$2","$3","$4","$5","$6","$7}' | sort | uniq > "$UNIQUE_FILE"
  cat "$INPUT_FILE" | egrep -v ".DS_Store"|egrep -v "PENDING DELETION"|awk -F, '{print $1","$2","$3","$4","$5","$6","$7}' | sort | uniq > "$UNIQUE_FILE"
#fi

echo "------------------------------------------"
echo "$USER_EMAIL , $(cat $INPUT_FILE|wc -l) , $(cat $UNIQUE_FILE|wc -l)"
echo "------------------------------------------"

FILE=$UNIQUE_FILE

if [ ! -f "$FILE" ]; then
    echo "File ${FILE} does not exist. Ending script."
    exit 1
fi

# Initialize the counter
counter=0

echo $( tail -n +2 $UNIQUE_FILE|wc -l)" files to be renamed"

# Read in the temporary file and extract the relevant information, skipping the header line
while IFS=, read -r filename fileid  ; do
  if [[ $fileid != *"http"* ]]; then
    # Get the current filename directly from Google Drive
    current_filename=$($GAM user "$USER_EMAIL" show fileinfo "$fileid" fields name | awk -F': ' '{print $2}')

    # If the current filename doesn't already have "(PENDING DELETION - CONTACT OIT)" at the end, add it
    if [[ $current_filename != *"PENDING DELETION - CONTACT OIT"* ]]; then
      /root/bin/gamadv-x/gam user "$USER_EMAIL" update drivefile "$fileid" newfilename "$filename (PENDING DELETION - CONTACT OIT)"
    else
      echo "$USER_EMAIL $fileid   $current_filename"
      # Increment the counter
      ((counter++))
#      if [[ $counter -ge 3 ]]; then
#        echo "Found 3 or more renamed files. Exiting..."
        #exit 1
      #fi
    fi
  fi
done < <(tail -n +2 /opt/organization/mjb9/listshared/csv-files/${USER_EMAIL}_active-shares.csv | egrep -v "owner,id" | awk -F, '{print $2","$3}' | uniq)
echo ${USER_EMAIL} >> file-rename-done.txt
echo "----------------------------------------------------------------------"

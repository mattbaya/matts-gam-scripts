#!/bin/bash

# Set the user's email address as a variable
USER_EMAIL=$1

GAM="/root/bin/gamadv-x/gam"

INPUT_FILE="/opt/organization/mjb9/listshared/csv-files/${USER_EMAIL}_active-shares.csv"
if [ ! -f "$INPUT_FILE" ]; then
    echo "File ${FILE} does not exist. Lets make one."
    /opt/organization/mjb9/listshared/list-users-files.sh $USER_EMAIL
fi

# Create unique filenames for this user
ALL_TRIED_FILE="/opt/organization/mjb9/listshared/csv-files/${USER_EMAIL}_all_tried.txt"
SUCCEEDED_FILE="/opt/organization/mjb9/listshared/csv-files/${USER_EMAIL}_succeeded.txt"
LOG_FILE="logs/${USER_EMAIL}_label-shared-out.txt"

UNIQUE_FILE="/opt/organization/mjb9/listshared/csv-files/${USER_EMAIL}_unique_files.csv"

# Check if the file exists
#if [ ! -f "$UNIQUE_FILE" ]; then
  # Run the command to create the unique file
  cat "$INPUT_FILE" | awk -F, '{print $1","$2","$3","$4","$5","$6","$7}' | sort | uniq > "$UNIQUE_FILE"
#fi
FILE=$UNIQUE_FILE
echo "------------------------------------------"
echo $(cat $FILE |egrep -v "vnd.google-apps.folder"|awk -F, '{print $3}'|sort|uniq|egrep -v "owner,id" | wc -l)" files to be labeled"
echo "------------------------------------------"

$GAM user $USER_EMAIL add license "Google Workspace for Education Plus"
echo "Waiting 30 seconds before storting"
sleep 30 
# sleeping 30 seconds to give the above change time to take effect

for i in $(cat $FILE |egrep -v "vnd.google-apps.folder"|egrep -v "mimeType"|awk -F, '{print $2}'|sort|uniq); do 
echo $USER_EMAIL","$i;
$GAM user $USER_EMAIL process filedrivelabels $i addlabelfield xIaFm0zxPw8zVL2nVZEI9L7u9eGOz15AZbJRNNEbbFcb 62BB395EC6 selection 68E9987D43 >> ${LOG_FILE}

done;

# Get the list of all files it tried
grep $USER_EMAIL $LOG_FILE|grep "ID:"|awk -F, '{print $2}'|awk '{print $4}'|sort -u > $ALL_TRIED_FILE

# Get the list of successful files
grep $USER_EMAIL $LOG_FILE |grep "Created"|awk '{print $6}'|awk -F, '{print $1}'|sort -u > $SUCCEEDED_FILE

# Now get the files which were tried but didn't succeed
failed_ids=$(comm -23 $ALL_TRIED_FILE $SUCCEEDED_FILE)

for id in $failed_ids; do
    # Retry the operation with the failed id
    echo "Retrying failed file $is"
    $GAM user $USER_EMAIL process filedrivelabels $id addlabelfield xIaFm0zxPw8zVL2nVZEI9L7u9eGOz15AZbJRNNEbbFcb 62BB395EC6 selection 68E9987D43
done

# Clean up the temporary files
rm $ALL_TRIED_FILE $SUCCEEDED_FILE
echo $USER_EMAIL >> /opt/organization/mjb9/suspended/label-done.txt
$GAM user $USER_EMAIL delete license "Google Workspace for Education Plus"


#!/bin/bash

# Adds PENDING DELETION - CONTACT OIT to all files for this user.

# Set the path to the file containing the usernames
USER_EMAIL=$1

# Extract the username from the email address
USERNAME=$(echo $USER_EMAIL | sed 's/@example.edu//')

# Path to the GAM executable
GAM="/root/bin/gamadv-x/gam"

# Define file paths
INPUT_FILE="/opt/organization/mjb9/listshared/csv-files/${USERNAME}_active-shares.csv"
UNIQUE_FILE="/opt/organization/mjb9/listshared/csv-files/${USERNAME}_unique_files.csv"
TEMP_FILE="/opt/organization/mjb9/listshared/csv-files/${USERNAME}_temp.csv"
ALL_FILE="/opt/organization/mjb9/listshared/csv-files/${USERNAME}_all_files.csv"
ALL_TEMP="/opt/organization/mjb9/listshared/csv-files/${USERNAME}_all_temp.csv"

# Check if the account is suspended using GAM
suspension_status=$($GAM info user "$USERNAME" | grep "Account Suspended:" | awk -F": " '{print $2}')
if [[ "$suspension_status" == "False" ]]; then
    echo "User $USERNAME is active. Exiting."
    exit 0
fi

# Check if the account last name includes "PENDING DELETION"
# Get the user's last name using GAM
last_name=$($GAM info user "$USERNAME" | grep "Last Name:" | awk -F": " '{print $2}')

# Check if "PENDING DELETION" is NOT in the last name
if [[ "$last_name" != *"PENDING DELETION"* ]]; then
    echo "User $USERNAME last name does not indicate pending deletion. Exiting."
    exit 0
fi
# Always create fresh files
echo "Running /opt/organization/mjb9/listshared/list-users-files.sh $USER_EMAIL"
/opt/organization/mjb9/listshared/list-users-files.sh $USER_EMAIL

# Regenerate the master list of all files owned by this account
echo "Creating new $ALL_TEMP"
touch $ALL_TEMP
$GAM user ${USER_EMAIL} show filelist id title > "$ALL_TEMP"
echo "${USERNAME}_all.temp.csv | $(cat $ALL_TEMP | wc -l)"

# Create the unique file
echo "Creating $UNIQUE_FILE"
touch $UNIQUE_FILE
cat "$INPUT_FILE" | egrep -v ".DS_Store" | awk -F, '{print $1","$2","$3","$4","$5","$6","$7}' | sort | uniq > "$UNIQUE_FILE"

# Match all the IDs from the older active-shares file but get the updated filenames from all_files
echo "Creating $TEMP_FILE"
touch $TEMP_FILE
counter=0
total=$(cat $UNIQUE_FILE | sort | uniq | wc -l)
echo "Total unique: $total"
for i in $(cat $UNIQUE_FILE | sort | uniq | egrep -v mimeType | awk -F, '{print $2}'); do
    ((counter++))
    echo "$counter of $total"
    grep $i $ALL_TEMP >> $TEMP_FILE
done
echo "$TEMP_FILE created"

echo "------------------------------------------"
echo "$USER_EMAIL | Total shared files: $(cat $TEMP_FILE | wc -l)"
echo "------------------------------------------"

# Initialize the counter
counter=0
total=$(cat $TEMP_FILE | egrep -v "Owner,id,name" | egrep -v "PENDING DELETION" | wc -l)
echo "$(cat $TEMP_FILE | wc -l) files to be renamed"
echo "$total not renamed yet"

echo "Renaming, where applicable"
echo "---------------------------------------"
# Read in the temporary file and extract the relevant information, skipping the header line
while IFS=, read -r fileid filename; do
    ((counter++))
    echo "$counter of $total: Filename: $filename"
    if [[ $fileid != *"http"* ]]; then
        # Get the current filename directly from Google Drive
        current_filename=$($GAM user "$USER_EMAIL" show fileinfo "$fileid" fields name | grep 'name:' | sed 's/name: //')

        # Only rename if the filename does not already contain "PENDING DELETION"
        if [[ $current_filename != *"PENDING DELETION - CONTACT OIT"* ]]; then
            # Construct the new filename
            new_filename="${current_filename} (PENDING DELETION - CONTACT OIT)"
            # Update the filename in Google Drive
            $GAM user "$USER_EMAIL" update drivefile "$fileid" newfilename "$new_filename"
            echo "Updated $fileid: $current_filename -> $new_filename"
        else
            echo "Already PENDING - $USER_EMAIL $fileid   $current_filename"
        fi
    fi
done < <(cat $TEMP_FILE | egrep -v "PENDING DELETION" | egrep -v "Owner,id,name" | awk -F, '{print $2","$3}')

echo "done scanning files"
echo ${USER_EMAIL},$(date '+%Y-%m-%d %H:%M:%S') >> file-rename-done.txt
echo "Resetting unique file"
cat "$INPUT_FILE" | egrep -v ".DS_Store" | awk -F, '{print $1","$2","$3","$4","$5","$6","$7}' | sort | uniq > "$UNIQUE_FILE"
echo "----------------------------------------------------------------------"


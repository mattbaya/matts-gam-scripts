#!/bin/bash

# Define the GAM path
GAM=/root/bin/gamadv-x/gam

output_file="shared_drives_status.txt"

# List all shared drives
#shared_drives=$($GAM all drives printshowtogeturl | grep "shared" | awk '{print $2}')
#shared_drives=$($GAM print teamdriveacls oneitemperrow)
#shared_drives=$1
drive=$1

# Iterate over each shared drive
#for drive in $shared_drives; do
  echo "Checking shared drive: $drive"
  
  # Get a list of who has access to the shared drive
  #access_list=$($GAM user ~permiss drivefileid $drive showpermissions | grep -v "Permission Id" | awk '{print $1","$2}')
  #access_list=$($GAM=/root/bin/gamadv-x/gam;$GAM user gam-admin-address show drivefileacl 0ALbAe3K_3slQUk9PVA asadmin|grep emailAddress|awk '{print $2}')
  access_list=$($GAM user gam-admin-address show drivefileacl $drive asadmin|grep emailAddress|awk '{print $2}'|grep example.edu)
  
  # Check if each user is active and output the results to the output file
  no_active_user=true
  while IFS=',' read -r user access_list; do
    user_status=$($GAM info user "$user"|grep -i suspended|egrep -v "Suspended Accounts" | awk -F": " '{print $2}')
    echo $user $user_status
    if [ "$user_status" = "False" ]; then
      no_active_user=false
#	echo "Shared drive $drive has active users."
     # break
    else if [ "$user_status" = "True" ]; then
	echo "$GAM delete drivefileacl id $drive $user "
        $GAM delete drivefileacl id $drive $user >> users-removed.log
	tail -1 users-removed.log
	fi
    fi
  done <<< "$access_list"
  
  if [ "$no_active_user" = true ]; then
    echo "******************************************" 
    echo "$drive has no active users."
    echo "******************************************" 
    echo "$drive has no active users." >> "$output_file"
    else if [ "$no_active_user" = false ]; then
	echo "$drive has active users."
	fi
	fi


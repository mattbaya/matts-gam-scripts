#!/bin/bash
user=$1
GAM="/root/bin/gamadv-x/gam"
for group in $($GAM print groups member $user|grep example.edu); do
    echo "Removing user: $user from group: $group"
    $GAM update group "$group" remove member "$user">>users-removed-from-groups.txt
done 

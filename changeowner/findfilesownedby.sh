#!/usr/bin/bash
GAM="/root/bin/gamadv-x/gam"

#for i in `cat jleamonfolders.txt`; do
#echo $i;
#$GAM user jleamon@example.edu print filetree select $i showownedby any fields id|grep jleamon|awk -F, '{print $5}'
#done 
USER="$1"
NEWOWNER="$2"
cat /opt/organization/mjb9/listshared/csv-files/$USER-active-shares.csv|grep $NEWONER>temp-$USER-to-$NEWOWNER.csv



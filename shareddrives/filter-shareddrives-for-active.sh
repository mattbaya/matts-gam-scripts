#!/bin/bash

# Define the GAM path
GAM=/root/bin/gamadv-x/gam

cat ./shareddrives.csv | awk -F',' '{print $3}' | grep example.edu|sort|uniq > users.tmp

cat users.tmp | while read email; do ./check-if-active.sh "$email"; done > users.txt

grep -f users.txt shareddrives.csv > active_shared_drives.csv

rm -Rf users.tmp





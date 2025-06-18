#!/bin/bash

# Path to GAM executable
GAM="/root/bin/gamadv-x/gam"

# Path to CSV file containing suspended accounts
SUSPENDED_CSV="allsuspended.csv"

# Query to match suspended accounts with a department of "Student"
QUERY="department: Student"

# Read in the email addresses of all suspended accounts from the CSV file
EMAILS=$(awk -F',' '/True/{print $1}' "$SUSPENDED_CSV")

# Loop through the email addresses and print out the ones that match the query
for EMAIL in $EMAILS
do
    USER_INFO=$("$GAM" info user "$EMAIL")
    if echo "$USER_INFO" | grep -q "$QUERY"
    then
        echo "$EMAIL"
    fi
done


#!/bin/bash

# Set the user email
USER_EMAIL=$1

# Define the GAM path
GAM=/root/bin/gamadv-x/gam

# Check each email address to see if it is active
  if $GAM info user "$USER_EMAIL" | grep -q 'Account Suspended: False'; then
    # Print the email address if the account is active
    echo "$USER_EMAIL" 
  fi

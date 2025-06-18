#!/bin/bash

GAM=/root/bin/gamadv-x/gam

 if $GAM info user "$USER_EMAIL" | grep -q 'Account Suspended: False'; then
    # Print the email address if the account is active
    echo "$USER_EMAIL"
  fi

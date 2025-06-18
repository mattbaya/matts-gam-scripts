#!/bin/bash

# Usage: ./handle_suspension.sh <OWNER>

OWNER="$1"
GAM="/root/bin/gamadv-x/gam"

if [[ $($GAM info user "$OWNER" suspended | grep "Account Suspended" | awk -F": " '{print $2}') == "True" ]]; then
    echo "$OWNER is suspended, temporarily unsuspending"
    WASSUSPENDED=true
    "$GAM" update user "$OWNER" suspended off
else
    echo "$OWNER is not suspended, proceeding"
    WASSUSPENDED=false
fi

export WASSUSPENDED


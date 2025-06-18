#!/bin/bash

# Usage: ./cleanup_and_finalize.sh <OWNER> <WASSUSPENDED>

OWNER="$1"
WASSUSPENDED="$2"
SCRIPTPATH="/opt/organization/mjb9/changeowner"
GAM="/root/bin/gamadv-x/gam"

if [[ "$WASSUSPENDED" == "true" ]]; then
    echo "Re-suspending $OWNER"
    "$GAM" update user "$OWNER" suspended on
fi

echo "Cleanup complete."


#!/bin/bash

# Set the location of the GAM executable
GAM="/root/bin/gamadv-xtd3/gam"

USER="$1"

$GAM update user $USER org "Suspended Accounts"

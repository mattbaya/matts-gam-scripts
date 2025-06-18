#!/bin/bash

# ------------------------------------------------------------------
# Script: findPDFurls.sh
# Purpose: Recursively export all file names + URLs under a Drive folder
# Account: sa-theses-archives@example.edu
# Output: csv-files/sa-thesis-files_<timestamp>.csv
# ------------------------------------------------------------------

# STEP 0 - Bash shell check
if [ "$SHELL" != "/bin/bash" ]; then
  echo "Error: Script must be run in a bash shell."
  exit 1
fi

# STEP 1 - Define GAM path
GAM="/root/bin/gamadv-xtd3/gam"

# STEP 2 - Variables
PARENT_ID="1_2YboAb-ee_JWQnK8OydapRJvX3sAGy1"
TIMESTAMP=$(date "+%Y%m%d-%H%M%S")
OUTDIR="csv-files"
LOGDIR="logs"
OUTCSV="${OUTDIR}/sa-thesis-files_${TIMESTAMP}.csv"
LOGFILE="${LOGDIR}/sa-thesis-log-${TIMESTAMP}.log"
TMPFOLDERLIST="temp_folder_ids_${TIMESTAMP}.txt"
TMP_SUBFOLDERS="temp_subfolders_${TIMESTAMP}.csv"

# STEP 3 - Setup folders
mkdir -p "$OUTDIR" "$LOGDIR"
exec > >(tee -a "$LOGFILE") 2>&1

echo "-------------------------------------------------"
echo "Script started: $(date)"
echo "Recursively listing all files under folder ID: $PARENT_ID"
echo "Impersonating user: sa-theses-archives@example.edu"
echo "-------------------------------------------------"

# STEP 4 - Initialize folder queue
echo "$PARENT_ID" > "$TMPFOLDERLIST"
echo "name,webViewLink" > "$OUTCSV"

i=0
while true; do
  folder_id=$(sed -n "$((i+1))p" "$TMPFOLDERLIST")
  [ -z "$folder_id" ] && break

  echo "[$i] Getting files from folder: $folder_id"
  $GAM user sa-theses-archives print filelist query "'$folder_id' in parents" fields "name,webViewLink" >> "$OUTCSV"

  echo "[$i] Getting subfolders of: $folder_id"
  $GAM user sa-theses-archives print filelist query "'$folder_id' in parents and mimeType='application/vnd.google-apps.folder'" fields "id" > "$TMP_SUBFOLDERS"

  if [ $? -ne 0 ]; then
    echo "Warning: Failed to list subfolders of $folder_id. Skipping."
    i=$((i + 1))
    continue
  fi

  awk -F, 'NR>1 {print $1}' "$TMP_SUBFOLDERS" >> "$TMPFOLDERLIST"
  i=$((i + 1))
done

# STEP 5 - Done
echo "-------------------------------------------------"
echo "Total files exported: $(($(wc -l < "$OUTCSV") - 1))"
echo "Output CSV: $OUTCSV"
echo "Log file: $LOGFILE"
echo "Script completed successfully: $(date)"
echo "-------------------------------------------------"

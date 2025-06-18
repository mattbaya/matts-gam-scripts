# Define the GAM path
GAM=/root/bin/gamadv-x/gam

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <TeamDriveID>"
    exit 1
fi

DRIVEID="$1"

# Fetching the list of files in the specified Team Drive using GAM
files_info=$($GAM user gam-admin-address print filelist select id "$DRIVEID" fields id,size)  >/dev/null 2>&1
# Initialize count and size
count=0
total_size=0

# Process the fetched files info
while read -r line; do
    if [[ $line =~ size || $line =~ [0-9] ]]; then # updated the condition to exclude the header
        # Extract size using awk
        size=$(echo "$line" | awk -F, '{print $NF}')
        
        # Check if size is a numeric value
        if [[ $size =~ ^[0-9]+([.][0-9]+)?$ ]]; then
            total_size=$(awk '{print $1 + $2}' <<< "$total_size $size")
            ((count++))
        fi
    fi
done <<< "$files_info"

# Convert total size to megabytes (1 MB = 1048576 bytes)
total_size_mb=$(awk "BEGIN {printf \"%.2f\", $total_size / 1048576}")

# Print results in a single line, comma-separated
echo "$DRIVEID,$drivename,$count,$total_size_mb MB"


#!/bin/bash

# Screenshot Upload Script
# Watches for new screenshots, uploads to remote host, copies URL to clipboard

# Configuration
host='deadline'
remotedir="/var/www/iaconelli.org/media/public_html"
webhost="media.iaconelli.org"
src="$HOME/Documents/Screenshots"
processed="$HOME/Documents/Screenshots/Processed"
logfile="$HOME/Library/Logs/screenshot-upload.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$logfile"
}

# Ensure processed folder exists
mkdir -p "$processed"

# Get most recent image
file="$(ls -t "$src" 2>/dev/null | grep -iE '\.(png|jpg|jpeg|gif|webp)$' | head -n1)"
if [ -z "$file" ]; then
    exit 0
fi

log "Processing: $file"

# Brief pause to ensure file is fully written
sleep 0.5

ext="${file##*.}"
tmpname="incoming-$$.${ext}"

# Upload to temp name
if ! scp "$src/$file" "$host:$remotedir/$tmpname" >> "$logfile" 2>&1; then
    log "ERROR: scp failed"
    osascript -e 'display notification "Screenshot upload failed" with title "Screenshot"'
    exit 1
fi

# Rename remotely, get final name back
finalname=$(ssh "$host" "cd $remotedir && newname=\"screenshot-\$(date +%Y%m%d-%H%M%S).${ext}\" && mv \"$tmpname\" \"\$newname\" && echo \"\$newname\"" 2>> "$logfile")

if [ -z "$finalname" ]; then
    log "ERROR: remote rename failed"
    osascript -e 'display notification "Remote rename failed" with title "Screenshot"'
    exit 1
fi

# Copy URL to clipboard
echo "https://$webhost/$finalname" | pbcopy

# Move original to processed folder (syncs via iCloud)
mv "$src/$file" "$processed/$finalname"

log "SUCCESS: $finalname -> https://$webhost/$finalname"

# Success notification
osascript -e "display notification \"$finalname\" with title \"Screenshot uploaded\" subtitle \"URL copied to clipboard\""

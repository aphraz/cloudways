#!/bin/bash

LOGFILE="/var/log/permissions.log"

if [ "$1" == "restore" ] && [ -f permissions.snapshot ]; then
    echo "Restoring file permissions and ownership from snapshot..." | tee -a $LOGFILE
    # Read snapshot and restore permissions and ownership
    while IFS= read -r line; do
        perm=$(echo "$line" | cut -d' ' -f1)
        owner=$(echo "$line" | cut -d' ' -f2)
        group=$(echo "$line" | cut -d' ' -f3)
        file=$(echo "$line" | cut -d' ' -f4-)
        if [ -e "$file" ]; then
            chmod $perm "$file"
            chown $owner:$group "$file"
            echo "Restored $perm and ownership ($owner:$group) to $file" | tee -a $LOGFILE
        else
            echo "Skipping $file, does not exist" | tee -a $LOGFILE
        fi
    done < permissions.snapshot
    echo "Permissions and ownership restoration completed." | tee -a $LOGFILE
elif [ "$1" == "record" ]; then
    echo "Recording file permissions and ownership..." | tee -a $LOGFILE
    # List directories to snapshot and check each file exists before logging
    find /var /usr -exec stat --format '%a %U %G %n' {} + 2>/dev/null | tee permissions.snapshot | tee -a $LOGFILE
    echo "Permissions and ownership recorded in permissions.snapshot and logged in $LOGFILE."
else
    echo "Usage: $0 [record|restore]" | tee -a $LOGFILE
fi


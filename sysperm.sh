#!/bin/bash

LOGFILE="/var/log/permissions.log"

if [ "$1" == "restore" ] && [ -f permissions.snapshot ]; then
    echo "Restoring file permissions from snapshot..." | tee -a $LOGFILE
    # Read snapshot and restore permissions
    while IFS= read -r line; do
        perm=$(echo "$line" | cut -d' ' -f1)
        file=$(echo "$line" | cut -d' ' -f2-)
        if [ -e "$file" ]; then
            chmod $perm "$file"
            echo "Restored $perm to $file" | tee -a $LOGFILE
        else
            echo "Skipping $file, does not exist" | tee -a $LOGFILE
        fi
    done < permissions.snapshot
    echo "Permissions restoration completed." | tee -a $LOGFILE
elif [ "$1" == "record" ]; then
    echo "Recording file permissions..." | tee -a $LOGFILE
    # List directories to snapshot and check each file exists before logging
    find /var /usr -exec stat --format '%a %n' {} + 2>/dev/null | tee permissions.snapshot | tee -a $LOGFILE
    echo "Permissions recorded in permissions.snapshot and logged in $LOGFILE."
else
    echo "Usage: $0 [record|restore]" | tee -a $LOGFILE
fi


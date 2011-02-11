#!/bin/bash

echo "server.sh launching MunkiReport"

MRDIR=$( dirname `dirname $0` )
SUPPORTDIR="/Library/Application Support/MunkiReport"

# Change to application directory
cd "$MRDIR"

# Check configuration
for INIFILE in groups.ini permissions.ini MunkiReport.ini users; do
    if [ ! -f "$SUPPORTDIR/$INIFILE" ]; then
        echo "$SUPPORTDIR/$INIFILE does not exist"
        exit 1
    fi
done

# Activate virtualenv
source "$MRDIR/Python/bin/activate"

# Start web server
exec paster serve "$SUPPORTDIR/MunkiReport.ini"

#!/bin/bash

echo "start.sh launching MunkiReport"

# Change to application directory
cd `dirname $0`

# Check configuration
for ETCFILE in groups.ini permissions.ini users; do
    if [ ! -f "etc/$ETCFILE" ]; then
        echo "etc/$ETCFILE does not exist, please run setup.sh"
        exit 1
    fi
done

# Activate virtualenv
source "$HOME/Library/Python/MunkiReportEnv/bin/activate"

# Start web server
exec paster serve etc/production.ini

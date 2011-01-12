#!/bin/bash

echo "start.sh launching MunkiReport"

# Check configuration
for ETCFILE in groups.ini permissions.ini users; do
    if [ ! -f "etc/$ETCFILE" ]; then
        echo "etc/$ETCFILE does not exist, please run setup.sh"
        exit 1
    fi
done

# Activate virtualenv
source $HOME/Library/Python/tg21env/bin/activate
# Change to application directory
cd `dirname $0`
# Start web server
exec paster serve etc/production.ini

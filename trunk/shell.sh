#!/bin/bash

echo
echo "*************************************************************************"
echo "******************* LIVE APPLICATION DATABASE ACCESS ********************"
echo "*************************************************************************"
echo
echo "from litsadmin.model import DBSession, Asset, AssetType, Department, NetworkConfig, NetworkDevice, NetworkSegment, Platform"
echo "import transaction"
echo

paster --plugin=Pylons shell etc/production.ini

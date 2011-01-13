#!/bin/bash

source "$HOME/Library/Python/MunkiReportEnv/bin/activate"

echo
echo "*************************************************************************"
echo "******************* LIVE APPLICATION DATABASE ACCESS ********************"
echo "*************************************************************************"
echo
echo "from litsadmin.model import DBSession, Client"
echo "import transaction"
echo

paster --plugin=Pylons shell etc/production.ini

#!/bin/bash


# Don't perform setup if there's already a production database.
if [ -e production.db ]; then
    echo "A production database already exists. Please refer to the documentation if you"
    echo "are upgrading to a new version."
    exit 1
fi


# Make sure virtualenv is installed
echo "Checking virtualenv..."
which -s virtualenv
if [ $? -ne 0 ]; then
    echo "virtualenv is not installed, install with:"
    echo "easy_install virtualenv"
    exit 1
fi


# Check PyPI
echo "Checking for PyPI access..."
PYPIURL="http://pypi.python.org/"
curl -s -f "$PYPIURL"
if [ $? -ne 0 ]; then
    echo "Can't reach $PYPIURL"
    exit 1
fi


# Create virtualenv
echo "Checking virtual environment..."
if [ ! -d "$HOME/Library/Python/MunkiReportEnv" ]; then
    echo "Creating virtual environment..."
    mkdir -p "$HOME/Library/Python"
    (
        cd "$HOME/Library/Python"
        virtualenv --no-site-packages -p python2.6 MunkiReportEnv
    )
fi
echo "Activating virtual environment"
source "$HOME/Library/Python/MunkiReportEnv/bin/activate"


# Install egg
echo "Installing egg into virtual environment..."
EGG=`ls *.egg | tail -1`
easy_install --quiet "$EGG"


# Create production.ini
echo "Creating production.ini..."
perl -e '
    $uuid = `uuidgen`;
    foreach $line (<>) {
        $line =~ s/^#(.+)SET SECRET STRING HERE/$1$uuid/;
        print $line
    }
' < etc/production.ini.template > etc/production.ini && rm etc/production.ini.template


# Create users
echo "Creating munkireport admin user..."
bin/mkusers.py
if [ $? -ne 0 ]; then
    echo "User creation failed"
    exit 1
fi
USERNAME=`cut -d: -f1 etc/users | head -1`


# Create groups.ini
echo "Creating groups.ini..."
cat > etc/groups.ini <<EOF
[admins]
$USERNAME

[viewers]
$USERNAME
EOF


# Initialize application
echo "Creating databse..."
paster setup-app etc/production.ini


# Done
echo "Setup done. The server can be started with ./start.sh."

#!/bin/bash


# Don't perform setup if there's already a production database.
if [ -e production.db ]; then
    echo "A production database already exists. Please refer to the documentation if you"
    echo "are upgrading to a new version."
    exit 1
fi


echo
echo "Checking requirements..."


# Make sure virtualenv is installed
echo -n "* Checking virtualenv"
which -s virtualenv
if [ $? -ne 0 ]; then
    echo " FAILED"
    echo "virtualenv is not installed, install with:"
    echo "easy_install virtualenv"
    exit 1
else
    echo " OK"
fi


# Check PyPI
echo -n "* Checking PyPI access"
PYPIURL="http://pypi.python.org/"
curl -s -f "$PYPIURL"
if [ $? -ne 0 ]; then
    echo " FAILED"
    echo "Can't reach $PYPIURL"
    exit 1
else
    echo " OK"
fi


echo
echo "Setting up..."


# Create virtualenv
if [ ! -d "$HOME/Library/Python/MunkiReportEnv" ]; then
    echo "* Creating virtual environment"
    mkdir -p "$HOME/Library/Python"
    (
        cd "$HOME/Library/Python"
        virtualenv --no-site-packages -p python2.6 MunkiReportEnv
    )
fi
echo "* Activating virtual environment"
source "$HOME/Library/Python/MunkiReportEnv/bin/activate"


# Install egg
echo "* Installing egg into virtual environment"
EGG=`ls *.egg | tail -1`
easy_install --quiet "$EGG"


# Create production.ini
echo "* Creating production.ini"
perl -e '
    use IO::Socket::INET;
    $sock = IO::Socket::INET->new(PeerAddr => "pypi.python.org", PeerPort => 80, Proto => "tcp");
    $localip = $sock->sockhost;
    $uuid = `uuidgen`;
    foreach $line (<>) {
        $line =~ s/^#(.+)SET SECRET STRING HERE/$1$uuid/;
        $line =~ s/\b127\.0\.0\.1\b/$localip/;
        print $line
    }
' < etc/production.ini.template > etc/production.ini && rm etc/production.ini.template


# Create users
echo "* Creating munkireport admin user"
bin/mkusers.py
if [ $? -ne 0 ]; then
    echo "User creation failed"
    exit 1
fi
USERNAME=`cut -d: -f1 etc/users | head -1`


# Create groups.ini
echo "* Creating groups.ini"
cat > etc/groups.ini <<EOF
[admins]
$USERNAME

[viewers]
$USERNAME
EOF


# Initialize application
echo
echo "Creating database..."
paster setup-app etc/production.ini


# Done
echo
echo "Setup done. The server can be started with ./start.sh."

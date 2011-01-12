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


# Create virtualenv
echo "Checking virtual environment..."
if [ ! -d "$HOME/Library/Python/MunkiReportEnv" ]; then
    mkdir -p "$HOME/Library/Python"
    (
        cd "$HOME/Library/Python"
        virtualenv --no-site-packages -p python2.6 MunkiReportEnv
    )
fi
echo "Activating virtual environment"
source "$HOME/Library/Python/MunkiReportEnv/bin/activate"


# Create production.ini
echo "Creating production.ini..."


# Create users
echo "Creating users..."


# Create groups.ini
echo "Creating groups.ini..."


# Create permissions.ini
echo "Creating permissions.ini..."

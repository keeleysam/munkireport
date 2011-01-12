#!/bin/bash


# Check for virtualenv
if [ -z "$VIRTUAL_ENV" ]; then
    echo "Activate the virtualenv before running this script."
    exit 1
fi


# Version

VERSION=`python -c 'import munkireport; print munkireport.__version__'`
SVNREV=`svnversion . | tr -cd '0-9'`


# Build distribution egg

rm -rf build dist
python setup.py bdist_egg
if [ $? -ne 0 ]; then
    echo "Egg build failed"
    exit 1
fi
rm -rf build


# Create distribution template

DISTDIR="dist/MunkiReport-$VERSION.$SVNREV"
mkdir "$DISTDIR"
mv dist/*.egg "$DISTDIR/"
rsync -C bin "$DISTDIR/"
rsync -C scripts "$DISTDIR/"
mkdir "$DISTDIR/etc"
cp etc/production.ini "$DISTDIR/etc/"

#!/bin/bash
#
# TODO: make this create a .pkg instead


# Check for virtualenv
if [ -z "$VIRTUAL_ENV" ]; then
    echo "Activate the virtualenv before running this script."
    exit 1
fi


# Version
VERSION=`python -c 'import munkireport; print munkireport.__version__'`
SVNREV=`svnversion . | cut -d: -f2 | tr -cd '[:digit:]'`


# Build distribution egg
rm -rf build dist
python setup.py --quiet bdist_egg
if [ $? -ne 0 ]; then
    echo "Egg build failed"
    exit 1
fi
rm -rf build


# Create distribution template
DISTDIR="dist/MunkiReport-$VERSION.$SVNREV"
mkdir "$DISTDIR"
mv dist/*.egg "$DISTDIR/"
rsync -rlptC bin "$DISTDIR/"
rsync -rlptC scripts "$DISTDIR/"
mkdir "$DISTDIR/etc"
mkdir "$DISTDIR/var"
mkdir "$DISTDIR/var/db"
mkdir "$DISTDIR/var/log"
mkdir "$DISTDIR/var/run"
cp etc/production.ini.template etc/permissions.ini "$DISTDIR/etc/"
cp setup.sh shell.sh start.sh "$DISTDIR/"
cp README.txt LICENSE.txt "$DISTDIR/"
cp com.googlecode.munkireport.plist "$DISTDIR/"


# Clean up
find dist -name '.DS_Store' -exec rm {} \;
xattr -d -r com.apple.FinderInfo dist
xattr -d -r com.macromates.caret dist


# Create archive
(
    cd dist
    tar jcf "MunkiReport-$VERSION.$SVNREV.tar.bz2" "MunkiReport-$VERSION.$SVNREV"
)


# Done
open dist

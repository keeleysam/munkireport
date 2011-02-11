#!/bin/bash
#
# TODO: make this create a .pkg instead


SCRIPTDIR=`dirname "$0"`
SRCDIR=`cd "$SCRIPTDIR/.."; pwd`

cd "$SRCDIr"


# Check for virtualenv
if [ ! -z "$VIRTUAL_ENV" ]; then
    echo "Deactivate virtualenv before running this script."
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


# Create pkg
sudo Setup/make_pkg.sh dist/*.egg
uid=`id -u`
gid=`id -g`
sudo chown ${uid}:${gid} dist/*.pkg


# Create distribution template
DISTDIR="dist/MunkiReport-$VERSION.$SVNREV"
mkdir "$DISTDIR"
mv dist/*.pkg "$DISTDIR/"
rsync -rlptC Scripts "$DISTDIR/"
cp README.txt LICENSE.txt "$DISTDIR/"
cp "$SCRIPTDIR/uninstall.sh" "$DISTDIR/"

# Clean up
find dist -name '.DS_Store' -exec rm {} \;
xattr -d -r com.apple.FinderInfo dist
xattr -d -r com.macromates.caret dist


# Create archive
(
    cd dist
    hdiutil create -srcfolder "MunkiReport-$VERSION.$SVNREV" -ov "MunkiReport-$VERSION.$SVNREV.dmg"
    #tar jcf "MunkiReport-$VERSION.$SVNREV.tar.bz2" "MunkiReport-$VERSION.$SVNREV"
)


# Done
open dist

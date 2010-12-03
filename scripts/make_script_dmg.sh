#!/bin/bash

tmpdir=`mktemp -d -t munkiscripts`
tmproot="$tmpdir/munkiscripts"
mkdir "$tmproot"

printf "\nChecksums:\n"
md5 preflight postflight report_broken_client

printf "\nCopying files:\n"
cp -v preflight postflight report_broken_client "$tmproot"/
sudo chown -hR root:wheel "$tmproot"
printf "\nCreating image:\n"
sudo hdiutil create -srcfolder "$tmproot" -uid 0 -gid 0 -ov MunkiScripts.dmg

printf "\nCleaning up\n"
sudo rm -rf "$tmpdir"

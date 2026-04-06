#!/usr/bin/env bash

currentuser=$(users | awk '{print $1}')

## Update Permissions
chmod -Rf 0777 /home

## Create Exceptions List
echo '*.log'>/tmp/file.lst
echo '*.tmp'>>/tmp/file.lst
echo '.var/app/tv.kodi.Kodi/data/userdata/keymaps/keyboard.xml'>>/tmp/file.lst

## Backup User Profile...
echo -e "\033[1;33mUser \"$currentuser\"... \033[1;34mBackup User Profile\033[0m"
tar --exclude-from=/tmp/file.lst -zcvf profile-backup.tar.gz --absolute-names -C '/home/'$currentuser'/' '.config/mozilla' '.var/app/tv.kodi.Kodi'
rm -f /tmp/file.lst
#!/usr/bin/env bash

currentuser=$(users | awk '{print $1}')

## Restore User Profile...
echo -e "\033[1;33mUser \"$currentuser\"... \033[1;34mRestore User Profile\033[0m"
tar -zxvf "profile-backup.tar.gz" -C '/home/'$currentuser'/'

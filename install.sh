#!/usr/bin/env bash

currentuser=$(users | awk '{print $1}')

function run-in-user-session() {
    _display_id=":$(find /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"
    _username=$(who | grep "($_display_id)" | awk '{print $1}')
    _user_id=$(id -u "$_username")
    _environment=("DISPLAY=$_display_id" "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$_user_id/bus")
    sudo -Hu "$_username" env "${_environment[@]}" "$@"
}

remove-package() {
if dpkg -s $1 >/dev/null 2>&1; then
    echo -e '\033[1;33mRemoving   \033[1;31m'$1' \033[0m\c'
    sudo apt-get -y -qq purge $1 >/dev/null
    sudo apt-get -y -qq autoremove >/dev/null
    echo -e '\033[1;36m... OK\033[0m'
fi
}

install-package() {
if ! dpkg -s $1 >/dev/null 2>&1; then
    echo -e '\033[1;33mInstalling \033[1;32m'$1' \033[0m\c'
    apt-get -y -qq install $1 >/dev/null
    echo -e '\033[1;36m... OK\033[0m'
fi
}

function get-SimpleHTTPServerWithUpload() {
echo -e '\033[1;33mInstalling \033[1;34mSimple HTTP Service with Upload\033[0m'
cp -f files/SimpleHTTPServerWithUpload.py /bin
chmod +x -f /bin/SimpleHTTPServerWithUpload.py
## Create BASH Script
echo -e '#!/bin/bash'>/bin/SimpleHTTPServerWithUpload.sh
echo -e 'clear'>>/bin/SimpleHTTPServerWithUpload.sh
echo -e 'cd /mnt/shared_media'>>/bin/SimpleHTTPServerWithUpload.sh
echo -e 'python3 /bin/SimpleHTTPServerWithUpload.py 8080'>>/bin/SimpleHTTPServerWithUpload.sh
## Create Service
echo -e '[Unit]'>/lib/systemd/system/SimpleHTTPServerWithUpload.service
echo -e 'Description=Simple HTTP Server With Upload'>>/lib/systemd/system/SimpleHTTPServerWithUpload.service
echo -e '[Service]'>>/lib/systemd/system/SimpleHTTPServerWithUpload.service
echo -e 'ExecStart=/bin/SimpleHTTPServerWithUpload.sh'>>/lib/systemd/system/SimpleHTTPServerWithUpload.service
echo -e 'Restart=Always'>>/lib/systemd/system/SimpleHTTPServerWithUpload.service
echo -e '[Install]'>>/lib/systemd/system/SimpleHTTPServerWithUpload.service
echo -e 'WantedBy=multi-user.target'>>/lib/systemd/system/SimpleHTTPServerWithUpload.service
## Change Permissions
chmod +x -f /bin/SimpleHTTPServerWithUpload.sh
chmod 0644 -f /lib/systemd/system/SimpleHTTPServerWithUpload.service
systemctl -q enable SimpleHTTPServerWithUpload
}

function desktop-settings() {
echo -e '\033[1;33mUpdating   \033[1;34mDesktop Themes And Settings\033[0m'
echo -e "GTK_THEME=Adwaita">/etc/environment
## DESKTOP ICONS
run-in-user-session dconf write /org/nemo/desktop/computer-icon-visible "true"
run-in-user-session dconf write /org/nemo/desktop/home-icon-visible "true"
run-in-user-session dconf write /org/nemo/desktop/network-icon-visible "true"
run-in-user-session dconf write /org/nemo/desktop/trash-icon-visible "true"
run-in-user-session dconf write /org/nemo/desktop/volumes-visible "true"
## INTERFACE THEME
run-in-user-session dconf write /org/cinnamon/desktop/interface/icon-theme "'mate'"
run-in-user-session dconf write /org/cinnamon/theme/name "'BlueMenta'"
## SCREEN SAVER
run-in-user-session dconf write /org/cinnamon/desktop/screensaver/lock-enabled "false"
run-in-user-session dconf write /org/cinnamon/desktop/session/idle-delay "uint32 0"
## DESKTOP BACKGROUND
run-in-user-session dconf write /org/cinnamon/desktop/background/picture-options "'stretched'"
run-in-user-session dconf write /org/cinnamon/desktop/background/picture-uri "'file:///usr/share/backgrounds/gnome/progress-l.jxl'"
run-in-user-session dconf write /org/cinnamon/desktop/background/slideshow/delay 15
run-in-user-session dconf write /org/cinnamon/desktop/background/slideshow/image-source "'xml:///usr/share/gnome-background-properties/progress.xml'"
run-in-user-session dconf write /org/cinnamon/desktop/background/slideshow/random-order "true"
run-in-user-session dconf write /org/cinnamon/desktop/background/slideshow/slideshow-enabled "true"
## POWER MANAGEMENT
run-in-user-session dconf write /org/cinnamon/settings-daemon/plugins/power/button-power "'shutdown'"
run-in-user-session dconf write /org/cinnamon/settings-daemon/plugins/power/lock-on-suspend "false"
run-in-user-session dconf write /org/cinnamon/settings-daemon/plugins/power/sleep-display-ac 0
## XSETTINGS
run-in-user-session dconf write /org/cinnamon/settings-daemon/plugins/xsettings/buttons-have-icons "true"
run-in-user-session dconf write /org/cinnamon/settings-daemon/plugins/xsettings/menus-have-icons "true"
## GNOME INTERFACE
run-in-user-session dconf write /org/gnome/desktop/interface/clock-show-date "true"
run-in-user-session dconf write /org/gnome/desktop/interface/clock-show-seconds "true"
run-in-user-session dconf write /org/gnome/desktop/interface/cursor-theme "'Adwaita'"
run-in-user-session dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita'"
run-in-user-session dconf write /org/gnome/desktop/interface/icon-theme "'mate'"
## PRIVACY
run-in-user-session dconf write /org/gnome/desktop/privacy/recent-files-max-age 0
run-in-user-session dconf write /org/gnome/desktop/privacy/remember-recent-files "false"
run-in-user-session dconf write /org/gnome/desktop/privacy/remove-old-temp-files "true"
run-in-user-session dconf write /org/gnome/desktop/privacy/remove-old-trash-files "true"
}

function get-games() {
echo -e '\033[1;33mInstalling \033[1;34mBackgammon Game\033[0m'
install-package gnubg
echo -e '\033[1;33mInstalling \033[1;34mMahjongg Game\033[0m'
install-package gnome-mahjongg
## Create Shortcuts
mkdir -p /home/$currentuser/Desktop/Games
cp -f /usr/share/applications/gnubg.desktop /home/$currentuser/Desktop/Games
cp -f /usr/share/applications/org.gnome.Mahjongg.desktop /home/$currentuser/Desktop/Games
}

function get-php() {
echo -e '\033[1;33mInstalling \033[1;34mApache\033[0m'
file="/etc/apt/sources.list.d/php.list"
if [ -f "$file" ] ; then
    rm -f "$file"
fi
wget -qO /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" >"$file"
apt-get -y -qq update >/dev/null
install-package apache2
echo -e '\033[1;33mInstalling \033[1;34mPHP 7.4\033[0m'
install-package lsb-release
install-package apt-transport-https
install-package ca-certificates
install-package php7.4
install-package php7.4-cli
install-package php7.4-json
install-package php7.4-common
install-package php7.4-mysql
install-package php7.4-zip
install-package php7.4-gd
install-package php7.4-mbstring
install-package php7.4-curl
install-package php7.4-xml
install-package php7.4-bcmath
install-package php7.4-opcache
install-package php7.4-fpm
install-package php7.4-intl
install-package php7.4-xml
install-package php7.4-bz2
install-package php7.4-cgi
install-package libapache2-mod-php7.4
a2enmod php7.4
update-alternatives --set php /usr/bin/php7.4
update-alternatives --set phar /usr/bin/phar7.4
update-alternatives --set phar.phar /usr/bin/phar.phar7.4
chmod -Rf 0777 /var/www/html
rm -r -f /var/www/html/*
unzip -o -q files/navphp4.45.zip -d/var/www/html
echo -e 'php_value upload_max_filesize 4.0G'>/var/www/html/.htaccess
echo -e 'php_value post_max_size 4.2G'>>/var/www/html/.htaccess
echo -e 'php_value memory_limit -1'>>/var/www/html/.htaccess
sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
sed -i 's/Restart=on-abort/Restart=always/g' /lib/systemd/system/apache2.service
systemctl -q enable apache2
}

function get-samba() {
echo -e '\033[1;33mInstalling \033[1;34mSMB File Sharing\033[0m'
apt-get -y -qq install samba --install-recommends >/dev/null
install-package samba-common-bin
install-package samba-dsdb-modules
install-package samba-libs
install-package samba-vfs-modules
install-package smbclient
install-package autofs
install-package cifs-utils
install-package caja-share
install-package libsmbclient0
install-package libwbclient0
install-package winbind
install-package libnss-winbind
mkdir -p /etc/samba
cp -f files/smb.conf /etc/samba
touch /etc/libuser.conf
chmod 0777 -Rf /var/lib/samba/usershares
files=$(ls -1 /var/lib/samba/usershares)
if [ "$files" != """" ]; then
  rm -f /var/lib/samba/usershares/*
fi
run-in-user-session net usershare add Shared_Media /mnt/shared_media "Media Centre" Everyone:F guest_ok=y
}

reset
history -c
xset s off
xset s noblank

install-package default-jre
install-package gedit
install-package libc6
install-package lsscsi
install-package moreutils
install-package pavucontrol
install-package nmap
install-package openssl
install-package libpam-runtime
install-package gdebi
install-package openssh-server

install-package gnupg
install-package curl
install-package xterm
install-package lxappearance
install-package arc-theme
install-package papirus-icon-theme
install-package breeze-icon-theme
install-package elementary-icon-theme
install-package gparted
install-package breeze-cursor-theme
remove-package squeekboard
remove-package wfplug-squeek
remove-package matchbox-keyboard
remove-package orca

## FIND MEDIA FILES ON NTFS DRIVE AND CREATE AN FSTAB MOUNT ENTRY.
mkdir -p /mnt/shared_media
dev=$(findmnt -t fuseblk -n -o source | head -1)
if [ -z "${dev}" ]; then
	dev=$(findmnt -t ntfs3 -n -o source | head -1)
fi
if [ -n "${dev}" ]; then
    uuid=$(blkid -s UUID $dev | cut -f2 -d':' | cut -c2-)
    mountline=$uuid' /mnt/shared_media auto nosuid,nodev,nofail 0 0'
    if ! grep -Fxq $uuid' /mnt/shared_media auto nosuid,nodev,nofail 0 0' /etc/fstab
    then
        echo $mountline>>/etc/fstab
    fi
else
	echo -e '\033[1;31mShared Media Drive not located!\033[0m'
fi

get-samba
get-php
get-SimpleHTTPServerWithUpload
get-games
desktop-settings

install-package cinnamon-desktop-environment
install-package lightdm-gtk-greeter-settings
install-package cinnamon
update-alternatives --set x-session-manager /usr/bin/cinnamon-session >/dev/null
sed -i 's/.*autologin-user=.*/#autologin-user=/' /etc/lightdm/lightdm.conf
sed -i 's/.*greeter-session=pi-greeter.*/greeter-session=lightdm-gtk-greeter/' /etc/lightdm/lightdm.conf
sed -i 's/.*xserver-command=X.*/xserver-command=X -s 0 -dpms/' /etc/lightdm/lightdm.conf

## CHANGE IP ADDRESS/DEFAULT GATEWAY OF NETWORK ADAPTER
echo -e '\033[1;33mUpdating   \033[1;34mStatic IP Address\033[0m'
netid=$(nmcli -g NAME c show --active | grep -v 'lo')
nmcli c mod "$netid" ipv4.method manual ipv4.addresses "192.168.0.160/24" ipv4.gateway "192.168.0.1" ipv4.dns "8.8.8.8,8.8.4.4"

echo -e '\033[1;33mUpdating   \033[1;34mUser Permissions\033[0m' 
chmod -Rf 0777 /home

echo -e '\033[1;33mApplying Updates...\033[0m'
apt-get -y install -f >/dev/null
dpkg --configure -a >/dev/null
apt-get -y install -f >/dev/null
apt-get -y -qq clean >/dev/null
apt-get -y -qq autoclean >/dev/null
apt-get -y -qq update >/dev/null
apt-get --yes --allow-change-held-packages -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade >/dev/null
apt-get -y -qq autoremove >/dev/null

shutdown -r now

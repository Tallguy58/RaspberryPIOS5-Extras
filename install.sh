#!/usr/bin/env bash

currentuser=$(users | awk '{print $1}')

if [ "$XDG_CURRENT_DESKTOP" != "LXDE" ]; then
    echo -e '\033cGraphical environment \033[1;31mX11\033[0m not detected.\n'
    read -n 1 -s -r -p 'Press ANY key to update and reboot...'
	sed /etc/lightdm/lightdm.conf -i -e "s/^#\\?user-session.*/user-session=rpd-x/"
	sed /etc/lightdm/lightdm.conf -i -e "s/^#\\?autologin-session.*/autologin-session=rpd-x/"
	sed /etc/lightdm/lightdm.conf -i -e "s/^#\\?greeter-session.*/greeter-session=pi-greeter-x/"
	sed /etc/lightdm/lightdm.conf -i -e "s/^fallback-test.*/#fallback-test=/"
	sed /etc/lightdm/lightdm.conf -i -e "s/^fallback-session.*/#fallback-session=/"
	sed /etc/lightdm/lightdm.conf -i -e "s/^fallback-greeter.*/#fallback-greeter=/"
	if [ -e "/var/lib/AccountsService/users/$currentuser" ] ; then
		sed "/var/lib/AccountsService/users/$currentuser" -i -e "s/XSession=.*/XSession=rpd-x/"
	fi
    reboot
fi

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

function get-kodi() {
echo -e '\033c\033[1;33mInstalling \033[1;34mKODI Media Centre\033[0m'
mkdir -p /var/lib/flatpak/exports/share
mkdir -p /root/.local/share/flatpak/exports/share
install-package flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y --noninteractive flathub tv.kodi.Kodi

if [ ! -d /home/$currentuser/.config/autostart ]; then
  mkdir -p /home/$currentuser/.config/autostart
fi

## AutoRun KODI & Add To Desktop
cp -f /var/lib/flatpak/exports/share/applications/tv.kodi.Kodi.desktop /home/$currentuser/.config/autostart
cp -f /var/lib/flatpak/exports/share/applications/tv.kodi.Kodi.desktop /home/$currentuser/Desktop

## Keymap settings...
mkdir -p /home/$currentuser/.var/app/tv.kodi.Kodi/data/userdata/keymaps/
cat <<'EOF' > /home/$currentuser/.var/app/tv.kodi.Kodi/data/userdata/keymaps/keyboard.xml
<keymap>
  <global>
    <keyboard>
      <b>noop</b>
      <backslash>noop</backslash>
      <d>noop</d>
      <e>noop</e>
      <equals>noop</equals>
      <g>noop</g>
      <h>noop</h>
      <k>noop</k>
      <minus>noop</minus>
      <numpadminus>noop</numpadminus>
      <numpadplus>noop</numpadplus>
      <t>noop</t>
      <tab>noop</tab>
      <plus>noop</plus>
      <v>noop</v>
      <volume_mute>noop</volume_mute>
      <volume_down>noop</volume_down>
      <volume_up>noop</volume_up>
      <y>noop</y>
    </keyboard>
  </global>
</keymap>
EOF
}

function get-SimpleHTTPServerWithUpload() {
echo -e '\033[1;33mInstalling \033[1;34mSimple HTTP Service with Upload\033[0m'
cp -f files/SimpleHTTPServerWithUpload.py /bin
chmod +x -f /bin/SimpleHTTPServerWithUpload.py
## Create BASH Script
cat <<'EOF' > /bin/SimpleHTTPServerWithUpload.sh
#!/bin/bash
clear
cd /mnt/shared_media
python3 /bin/SimpleHTTPServerWithUpload.py 8080
EOF
## Create Service
cat <<'EOF' > /lib/systemd/system/SimpleHTTPServerWithUpload.service
[Unit]
Description=Simple HTTP Server With Upload

[Service]
ExecStart=/bin/SimpleHTTPServerWithUpload.sh
Restart=Always

[Install]
WantedBy=multi-user.target
EOF
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
echo -e '\033c\033[1;33mInstalling \033[1;34mApache\033[0m'
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
cat <<'EOF' > /var/www/html/.htaccess
php_value upload_max_filesize 4.0G
php_value post_max_size 4.2G
php_value memory_limit -1
EOF
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
touch /etc/libuser.conf
chmod 0777 -Rf /var/lib/samba/usershares
files=$(ls -1 /var/lib/samba/usershares)
if [ "$files" != """" ]; then
  rm -f /var/lib/samba/usershares/*
fi
}

reset
history -c
xset s off s noblank
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
install-package lxappearance
install-package alacarte
install-package arc-theme
install-package papirus-icon-theme
install-package breeze-icon-theme
install-package elementary-icon-theme
install-package mate-themes
install-package gnome-tweaks
install-package gdisk
install-package gparted
install-package dosfstools
install-package mtools
install-package ntfs-3g
install-package breeze-cursor-theme
remove-package squeekboard
remove-package wfplug-squeek
remove-package matchbox-keyboard
remove-package orca

## FIND ALL NTFS DRIVES, CREATE FSTAB MOUNT ENTRIES AND CREATE SAMBA SHARING.
dev=$(lsblk -o NAME,FSTYPE -n -r | grep "ntfs" | head -n 1 | awk '{print "/dev/"$1}')
if [ -z "${dev}" ]; then
    echo -e '\033[1;31mERROR: \033[1;33mNTFS formatted devices not detected!\033[0m'
else
	get-samba
	get-SimpleHTTPServerWithUpload
	if [ ! -d /etc/samba ]; then
		mkdir -p /etc/samba
	fi
	cat <<'EOF' > /etc/samba/smb.conf
[global]
	workgroup = WORKGROUP
	client min protocol = NT1
	server min protocol = NT1
	dns proxy = No
	log file = /var/log/samba/log.%m
	map to guest = Bad User
	max log size = 1000
	min receivefile size = 16384
	name resolve order = bcast host lmhosts wins
	obey pam restrictions = Yes
	pam password change = Yes
	panic action = /usr/share/samba/panic-action %d
	passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
	passwd program = /usr/bin/passwd %u
	preferred master = Yes
	server role = standalone server
	server string = %h server (Samba, Ubuntu)
	socket options = TCP_NODELAY IPTOS_LOWDELAY
	unix password sync = Yes
	usershare allow guests = Yes
	usershare owner only = No
	wins support = yes
	local master = yes
	preferred master = yes
	aio read size = 16384
	aio write size = 16384
	strict sync = No
	use sendfile = Yes

EOF
    BASE_DIR="/mnt"
    PREFIX="shared_media"
    counter=1
    for dev in $(blkid -t TYPE=ntfs -o device); do
        if [ $counter -eq 1 ]; then
            MOUNT_POINT="${BASE_DIR}/${PREFIX}"
			if [ ! -d "$MOUNT_POINT" ]; then
				mkdir -p "$MOUNT_POINT"
			fi
			run-in-user-session net usershare add $PREFIX $MOUNT_POINT "Media Centre" Everyone:F guest_ok=y
        else
            MOUNT_POINT="${BASE_DIR}/${PREFIX}$(printf "%02d" $counter)"
			if [ ! -d "$MOUNT_POINT" ]; then
				mkdir -p "$MOUNT_POINT"
			fi
			run-in-user-session net usershare add $PREFIX$(printf "%02d" $counter) $MOUNT_POINT "Media Centre"$(printf "%02d" $counter) Everyone:F guest_ok=y
        fi
		MOUNT_NAME=$(echo "${MOUNT_POINT#\/mnt\/}" | sed 's/_/ /g' | sed -r 's/\b([a-z])([a-z0-9_]*)/\u\1\2/g')
        uuid=$(blkid -s UUID $dev | cut -f2 -d':' | cut -c2-)
        mountline=$uuid" "$MOUNT_POINT" auto nosuid,nodev,nofail 0 0"
        if ! grep -Fxq $uuid" "$MOUNT_POINT" auto nosuid,nodev,nofail 0 0" /etc/fstab; then
            echo -e '\033[1;32m'$dev'\033[1;33m saved as \033[1;32m'$MOUNT_POINT'\033[1;33m in filesystem table (\033[1;36m/etc/fstab\033[1;33m)\033[0m'
            echo $mountline>>/etc/fstab
        else
            echo -e '\033[1;32m'$dev'\033[1;33m already saved as \033[1;32m'$MOUNT_POINT'\033[1;33m in filesystem table (\033[1;36m/etc/fstab\033[1;33m). No changes made.\033[0m'
        fi
		cat <<EOF >> /etc/samba/smb.conf
	[$MOUNT_NAME]
	path = $MOUNT_POINT
	guest ok = yes
	read only = no
	writeable = yes
		
EOF
		((counter++))
    done
fi

get-php
get-games
get-kodi
desktop-settings

## CHANGE IP ADDRESS/DEFAULT GATEWAY OF NETWORK ADAPTER
echo -e '\033[1;33mUpdating   \033[1;34mStatic IP Address\033[0m'
netid=$(nmcli -g NAME c show --active | grep -v 'lo')
nmcli c mod "$netid" ipv4.method manual ipv4.addresses "192.168.0.160/24" ipv4.gateway "192.168.0.1" ipv4.dns "8.8.8.8,8.8.4.4"

## USER AUTOLOGIN
sed -i 's/.*autologin-user=.*/autologin-user='$currentuser'/' /etc/lightdm/lightdm.conf

echo -e '\033[1;33mUpdating   \033[1;34mUser Permissions\033[0m' 
chmod -Rf 0777 /home

echo -e '\033[1;33mFix Broken Dependencies...\033[0m'
apt-get -y install -f >/dev/null
echo -e '\033[1;33mFix Broken Installations...\033[0m'
dpkg --configure -a >/dev/null
echo -e '\033[1;33mFix Broken Dependencies...\033[0m'
apt-get -y install -f >/dev/null
echo -e '\033[1;33mDelete Cached Files...\033[0m'
apt-get -y -qq clean >/dev/null
echo -e '\033[1;33mDelete Obsolete Files...\033[0m'
apt-get -y -qq autoclean >/dev/null
echo -e '\033[1;33mApplying Updates...\033[0m'
apt-get -y -qq update >/dev/null
echo -e '\033[1;33mApplying Upgrades...\033[0m'
apt-get -y -qq  --allow-change-held-packages -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -o APT::Get::Always-Include-Phased-Updates=true upgrade >/dev/null
echo -e '\033[1;33mRemove Orphaned Packages...\033[0m'
apt-get -y -qq autoremove >/dev/null

shutdown -r now

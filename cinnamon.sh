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

install-package cinnamon-desktop-environment
install-package lightdm-gtk-greeter-settings
install-package cinnamon
remove-package squeekboard
remove-package wfplug-squeek
remove-package matchbox-keyboard
remove-package orca
update-alternatives --set x-session-manager /usr/bin/cinnamon-session >/dev/null
sed -i 's/.*autologin-user=.*/autologin-user='$currentuser'/' /etc/lightdm/lightdm.conf
sed -i 's/.*greeter-session=pi-greeter.*/greeter-session=lightdm-gtk-greeter/' /etc/lightdm/lightdm.conf
sed -i 's/.*xserver-command=X.*/xserver-command=X -s 0 -dpms/' /etc/lightdm/lightdm.conf

apt-get -y -qq update >/dev/null
apt-get -y -qq --allow-change-held-packages -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -o APT::Get::Always-Include-Phased-Updates=true upgrade >/dev/null

shutdown -r now

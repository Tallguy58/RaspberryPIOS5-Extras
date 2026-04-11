#!/usr/bin/env bash

currentuser=$(users | awk '{print $1}')

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
update-alternatives --set x-session-manager /usr/bin/cinnamon-session >/dev/null
sed -i 's/.*autologin-user=.*/autologin-user='$currentuser'/' /etc/lightdm/lightdm.conf
sed -i 's/.*greeter-session=pi-greeter.*/greeter-session=lightdm-gtk-greeter/' /etc/lightdm/lightdm.conf
sed -i 's/.*xserver-command=X.*/xserver-command=X -s 0 -dpms/' /etc/lightdm/lightdm.conf

apt-get -y -qq update >/dev/null
apt-get -y -qq --allow-change-held-packages -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -o APT::Get::Always-Include-Phased-Updates=true upgrade >/dev/null

shutdown -r now

#!/bin/bash

export DEBIAN_FRONTEND="noninteractive" # `curl <URL> | sudo bash` suppresses stdin
export NEEDRESTART_SUSPEND="*" # suspend needrestart or it will restart services automatically

rm /etc/apt/sources.list
touch /etc/apt/sources.list

cat <<EOT >> /etc/apt/sources.list
deb http://deb.debian.org/debian sid main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian sid main contrib non-free non-free-firmware

deb http://deb.debian.org/debian testing main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian testing main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security testing-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security testing-security main contrib non-free non-free-firmware

deb http://deb.debian.org/debian testing-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian testing-updates main contrib non-free non-free-firmware
EOT

touch /etc/apt/preferences.d/default

cat <<EOT >> /etc/apt/preferences.d/default
Package: *
Pin: release n=sid
Pin-Priority: 500

Package: *
Pin: release n=testing
Pin-Priority: 1000
EOT

dpkg --add-architecture i386

apt-get update 
apt-get upgrade -y
apt-get autoremove -y

apt-get install -y linux-headers-amd64
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark


curl -sS https://starship.rs/install.sh -o starship-inst.sh
chmod +x starship-inst.sh 
./starship-inst.sh --yes
rm starship-inst.sh

echo 'eval "$(starship init bash)"' | tee -a /etc/bash.bashrc
echo 'pfetch' | tee -a /etc/bash.bashrc

git clone https://github.com/dylanaraps/pfetch.git
install pfetch/pfetch /usr/local/bin/
rm -r pfetch/

rm /etc/locale.gen
touch /etc/locale.gen

cat <<EOT >> /etc/locale.gen
en_US.UTF-8 UTF-8
en_GB.UTF-8 UTF-8
de_DE.UTF-8 UTF-8
es_ES.UTF-8 UTF-8
fr_FR.UTF-8 UTF-8
hu_HU.UTF-8 UTF-8
it_IT.UTF-8 UTF-8
ja_JP.UTF-8 UTF-8
ko_KR.UTF-8 UTF-8
nl_NL.UTF-8 UTF-8
pl_PL.UTF-8 UTF-8
pt_BR.UTF-8 UTF-8
ru_RU.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8
C.UTF-8 UTF-8
en_US ISO-8859-1
en_US.ISO-8859-15 ISO-8859-15
EOT

locale-gen


rm /etc/NetworkManager/NetworkManager.conf
touch /etc/NetworkManager/NetworkManager.conf

cat <<EOT >> /etc/NetworkManager/NetworkManager.conf
[main]
plugins=ifupdown,keyfile

[ifupdown]
managed=true
EOT

mkdir tempfiles
cd tempfiles

git clone https://github.com/aattilam/sidx.git
cd sidx/dotfiles/
mkdir -p /etc/skel/.local/share/gnome-shell/extensions
tar -xvf extensions.tar.xz -C /etc/skel/.local/share/gnome-shell/extensions
cp -r .config /etc/skel/
chmod +x /etc/skel/.config/autostart-scripts/dconf.sh
mkdir -p /etc/skel/.local/share/themes/
wget https://github.com/lassekongo83/adw-gtk3/releases/download/v5.1/adw-gtk3v5-1.tar.xz
tar -xvf adw-gtk3v5-1.tar.xz -C /etc/skel/.local/share/themes
cd ../../../
rm -r tempfiles/



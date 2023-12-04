#!/bin/bash

export DEBIAN_FRONTEND="noninteractive" # `curl <URL> | sudo bash` suppresses stdin
export NEEDRESTART_SUSPEND="*" # suspend needrestart or it will restart services automatically

apt-get install -y git curl jq wget tar gnupg gpg gnupg2 apt-transport-https ca-certificates 

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


apt-get update 
apt-get upgrade -y
apt-get autoremove -y

#lqx kernel
#mkdir -p /etc/apt/{sources.list.d,keyrings}
#chmod 0755 /etc/apt/{sources.list.d,keyrings}
#keyring_url='https://liquorix.net/liquorix-keyring.gpg'
#keyring_path='/etc/apt/keyrings/liquorix-keyring.gpg'
#curl "$keyring_url" | gpg --batch --yes --output "$keyring_path" --dearmor
#chmod 0644 "$keyring_path"
#repo_file="/etc/apt/sources.list.d/liquorix.list"
#repo_code="sid"
#repo_line="[arch=amd64 signed-by=$keyring_path] https://liquorix.net/debian $repo_code main"
#echo "deb $repo_line"      > $repo_file
#echo "deb-src $repo_line" >> $repo_file

dpkg --add-architecture i386
apt-get update -y
#apt-get install -y linux-image-liquorix-amd64 linux-headers-liquorix-amd64
apt-get install -y linux-headers-amd64
apt-get autoremove -y
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo


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

createduser=$(ls home/)

mkdir tempfiles
cd tempfiles

git clone https://github.com/aattilam/sidx.git
cd sidx/dotfiles/
tar -xvf extensions.tar.xz -C /usr/share/gnome-shell/extensions
cp -r .config /etc/skel/
mkdir -p /home/$createduser/.config/
cp -r .config/* /home/$createduser/.config/
chmod +x /etc/skel/.config/autostart-scripts/dconf.sh
chmod +x /home/$createduser/.config/autostart-scripts/dconf.sh
cd ../../
rm -r sidx/
cd ..
rm -r tempfiles



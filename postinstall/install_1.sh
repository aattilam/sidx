#!/bin/bash

export DEBIAN_FRONTEND="noninteractive" # `curl <URL> | sudo bash` suppresses stdin
export NEEDRESTART_SUSPEND="*" # suspend needrestart or it will restart services automatically

apt-get install -y git curl wget tar gnupg gpg gnupg2 apt-transport-https ca-certificates 

rm /etc/apt/sources.list
touch /etc/apt/sources.list

echo "Recreating sources list"

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

mkdir extensions
cd extensions

repos=(
    "https://github.com/ubuntu/gnome-shell-extension-appindicator.git"
    "https://gitlab.com/smedius/desktop-icons-ng.git"
    "https://gitlab.com/arcmenu/ArcMenu.git"
    "https://github.com/home-sweet-gnome/dash-to-panel.git"
    "https://github.com/icedman/search-light.git"
    "https://github.com/MartinPL/Tray-Icons-Reloaded.git"
)

target_directory="/usr/share/gnome-shell/extensions/"

for repo in "${repos[@]}"; do
    repo_name=$(basename "$repo" .git)
    git clone "$repo" "$repo_name"
    uuid=$(jq -r .uuid "$repo_name/metadata.json")
    mv "$repo_name" "$target_directory/$uuid"
done

cd ..
rm -r extensions/


git clone https://github.com/aattilam/sidx.git
cd sidx/dotfiles/
cp -r .config /etc/skel/
INSTUSERNAME=$(debconf-get-selections | grep passwd/make-user | sed 's/^.* //')
cp -r .config/* /home/$INSTUSERNAME/.config
chmod +x /etc/skel/.config/autostart-scripts/dconf.sh
chmod +x /home/$INSTUSERNAME/.config/autostart-scripts/dconf.sh
cd ../../
rm -r sidx/

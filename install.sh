#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

apt update && apt upgrade -y
apt install curl git laptop-detect -y

echo "Recreating sources list"

rm /etc/apt/sources.list
touch /etc/apt/sources.list

cat <<EOT >> /etc/apt/sources.list
deb http://deb.debian.org/debian testing main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian testing main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security testing-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security testing-security main contrib non-free non-free-firmware

deb http://deb.debian.org/debian testing-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian testing-updates main contrib non-free non-free-firmware

deb http://deb.debian.org/debian sid main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian sid main contrib non-free non-free-firmware
EOT

echo "Setting repository priority"
cat <<EOT >> /etc/apt/preferences.d/default
package: *
Pin: release a=sid
Pin-Priority: 100

package: *
Pin: release a=testing
Pin-Priority: 90
EOT

clear
echo "Installing gnome and default software"
sleep 2
export DEBIAN_FRONTEND=noninteractive
dpkg --add-architecture i386
apt update
apt install gnome-core gnome-tweaks timeshift neofetch htop gnome-boxes gnome-initial-setup dconf-cli dirmngr libglib2.0-dev software-properties-gtk flatpak network-manager gnome-software-plugin-flatpak chrome-gnome-shell intel-microcode amd64-microcode git nala qgnomeplatform-qt5 adwaita-qt adwaita-qt6 firmware-linux-nonfree fonts-crosextra-carlito fonts-crosextra-caladea firmware-misc-nonfree ttf-mscorefonts-installer rar unrar libavcodec-extra gstreamer1.0-libav gstreamer1.0-plugins-ugly ffmpeg gstreamer1.0-vaapi winetricks wine wine32 wine64 libwine libwine:i386 fonts-wine wget gnupg gpg gnupg2 apt-transport-https ca-certificates -y
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.libreoffice.LibreOffice -y

echo "Adding lqx-kernel repository"; curl 'https://raw.githubusercontent.com/aattilam/sidx/main/lqx-kernel-install.sh' -o liquorix.sh; chmod +x liquorix.sh; ./liquorix.sh; rm liqourix.sh

if [[ $laptopoutput == *"We're a laptop"* ]]; then
   apt install tlp tlp-rdw -y; systemctl enable tlp
fi

if [[ $(lspci -nn | egrep -i "3d|display|vga" | grep "NVIDIA") == *NVIDIA* ]]; then
  echo "Found NVIDIA device, installing driver."
  apt install nvidia-driver -y; clear
fi

lspci_output_amd=$(lspci)
if echo "$lspci_output_amd" | grep -i "AMD" | grep -i "VGA" >/dev/null; then
  apt install libdrm-amdgpu1 xserver-xorg-video-amdgpu mesa-vulkan-drivers libvulkan1 vulkan-tools vulkan-validationlayers
fi

echo "Upgrading system and removing unnecessary packages"
sleep 2
apt upgrade -y; apt autoremove -y
update-initramfs -u

echo "Configuring networking"

# Stop and disable the default network service
systemctl stop networking
systemctl disable networking

rm /etc/network/interfaces
touch /etc/network/interfaces
cat <<EOT >> /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback
EOT

# Enable and start Network Manager
systemctl enable NetworkManager
systemctl start NetworkManager

cd ..
rm sidx/

echo "Done, please reboot your system."

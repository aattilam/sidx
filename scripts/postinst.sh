#!/bin/bash

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.libreoffice.LibreOffice -y

laptopoutput=$(laptop-detect -v)

if [[ $laptopoutput == *"not"* ]]; then
   echo "We are on a desktop"
else
   apt install tlp tlp-rdw -y
   systemctl enable tlp
fi

if [[ $(lspci -nn | egrep -i "3d|display|vga" | grep "NVIDIA") == *NVIDIA* ]]; then
  echo "Found NVIDIA device, installing driver."
  apt install nvidia-driver -y; clear
fi

lspci_output_amd=$(lspci)
if echo "$lspci_output_amd" | grep -i "AMD" | grep -i "VGA" >/dev/null; then
  apt install libdrm-amdgpu1 xserver-xorg-video-amdgpu mesa-vulkan-drivers libvulkan1 vulkan-tools vulkan-validationlayers
fi

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


echo "Upgrading system and removing unnecessary packages"
sleep 2
apt update; apt upgrade -y; apt autoremove -y
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

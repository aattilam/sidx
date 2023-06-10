#!/bin/bash

laptopoutput=$(laptop-detect -v)
if [[ $laptopoutput == *"We're a laptop"* ]]; then
   apt install tlp tlp-rdw -y; systemctl enable tlp
   echo "Adding lqx-kernel repository"; curl 'https://liquorix.net/install-liquorix.sh' -o liquorix.sh; chmod +x liquorix.sh; ./liquorix.sh; rm liqourix.sh
else
   echo "Adding lqx-kernel repository"; curl 'https://liquorix.net/install-liquorix.sh' -o liquorix.sh; chmod +x liquorix.sh; ./liquorix.sh; rm liqourix.sh
fi

if [[ $(lspci -nn | egrep -i "3d|display|vga" | grep "NVIDIA") == *NVIDIA* ]]; then
  echo "Found NVIDIA device, installing driver."
  apt install nvidia-driver -y; clear
fi

lspci_output_amd=$(lspci)
if echo "$lspci_output_amd" | grep -i "AMD" | grep -i "VGA" >/dev/null; then
  apt install libdrm-amdgpu1 xserver-xorg-video-amdgpu mesa-vulkan-drivers libvulkan1 vulkan-tools vulkan-validationlayers
fi

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

wget -O /etc/gnome-initial-setup/vendor.conf https://raw.githubusercontent.com/aattilam/sidx/main/gnome-init-vendor.conf

apt update; apt upgrade -y; apt autoremove -y

# Stop and disable the default network service
systemctl stop networking
systemctl disable networking

# Enable and start Network Manager
systemctl enable NetworkManager
systemctl start NetworkManager

update-initramfs -u;

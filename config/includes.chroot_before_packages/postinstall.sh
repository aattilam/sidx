#!/bin/bash

apt-get update -y
apt-get install -y dmidecode imagemagick

is_laptop=$(dmidecode -s chassis-type)

if [ "$is_laptop" == "Notebook" ] || [ "$is_laptop" == "Laptop" ]; then
  echo "System is a laptop."
  apt-get install tlp tlp-rdw -y
  systemctl enable tlp
else
  echo "System is not a laptop. Doing nothing."
fi


if [[ $(lspci -nn | egrep -i "3d|display|vga" | grep "NVIDIA") == *NVIDIA* ]]; then
  echo "Found NVIDIA device, installing driver."
  apt-get install nvidia-driver libnvcuvid1 libnvidia-encode1 nvidia-vdpau-driver -y
fi

lspci_output_amd=$(lspci)
if echo "$lspci_output_amd" | grep -i "AMD" | grep -i "VGA" >/dev/null; then
  apt-get install mesa-va-drivers libdrm-amdgpu1 vdpau-driver-all xserver-xorg-video-amdgpu mesa-vulkan-drivers libvulkan1 vulkan-tools vulkan-validationlayers libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386 -y
fi

lspci_output_intel=$(lspci)
if echo "$lspci_output_intel" | grep -i "Intel" >/dev/null; then
  apt-get install intel-media-va-driver-non-free intel-gpu-tools i965-va-driver-shaders -y 
fi


git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes
chmod +x install.sh
./install.sh -b -t tela
cd ..
rm -r grub2-themes

apt-get remove live-boot live-config debian-installer-launcher linux-image-amd64 -y
apt-get autoremove -y

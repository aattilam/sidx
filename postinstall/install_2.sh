#!/bin/bash

apt-get update
apt-get install -y dmidecode imagemagick

is_laptop=$(dmidecode -s chassis-type)

if [ "$is_laptop" == "Notebook" ] || [ "$is_laptop" == "Laptop" ]; then
  echo "System is a laptop."
  apt-get install tlp tlp-rdw -y
  systemctl enable tlp
else
  echo "System is not a laptop. Doing nothing."
fi


install_gpu_drivers() {
    if lspci | grep -i "amd" | grep -i "vga\|3d\|2d" ; then
        echo "Detected AMD GPU. Installing AMD GPU drivers..."
        apt-get install mesa-va-drivers libdrm-amdgpu1 vdpau-driver-all xserver-xorg-video-amdgpu mesa-vulkan-drivers libvulkan1 vulkan-tools vulkan-validationlayers libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386 -y
    elif lspci | grep -i "nvidia" | grep -i "vga\|3d\|2d" ; then
        echo "Detected NVIDIA GPU. Installing NVIDIA GPU drivers..."
        apt-get install nvidia-driver libnvcuvid1 libnvidia-encode1 nvidia-vdpau-driver -y
    elif lspci | grep -i "intel" | grep -i "vga\|3d\|2d" ; then
        echo "Detected Intel GPU. Installing Intel GPU drivers..."
        apt-get install intel-media-va-driver-non-free intel-gpu-tools i965-va-driver-shaders -y
    else
        echo "No supported GPU detected."
    fi
}

# Function to check CPU and install corresponding microcode
install_cpu_microcode() {
    if lscpu | grep -i "amd" ; then
        echo "Detected AMD CPU. Installing AMD microcode..."
        apt-get install amd64-microcode -y
    elif lscpu | grep -i "intel" ; then
        echo "Detected Intel CPU. Installing Intel microcode..."
        apt-get install intel-microcode -y
    else
        echo "No supported CPU detected."
    fi
}

# Main script
echo "Checking GPU and installing corresponding drivers..."
install_gpu_drivers

echo "Checking CPU and installing corresponding microcode..."
install_cpu_microcode


git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes
chmod +x install.sh
./install.sh -b -t tela
cd ..
rm -r grub2-themes

apt-get remove live-boot live-config debian-installer-launcher -y
apt-get autoremove -y

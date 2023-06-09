#!/bin/bash

export DEBIAN_FRONTEND="noninteractive" # `curl <URL> | sudo bash` suppresses stdin
export NEEDRESTART_SUSPEND="*" # suspend needrestart or it will restart services automatically

mkdir -p /etc/apt/{sources.list.d,keyrings}
chmod 0755 /etc/apt/{sources.list.d,keyrings}
keyring_url='https://liquorix.net/liquorix-keyring.gpg'
keyring_path='/etc/apt/keyrings/liquorix-keyring.gpg'
curl "$keyring_url" | gpg --batch --yes --output "$keyring_path" --dearmor
chmod 0644 "$keyring_path"
repo_file="/etc/apt/sources.list.d/liquorix.list"
repo_code="sid"
repo_line="[arch=amd64 signed-by=$keyring_path] https://liquorix.net/debian $repo_code main"
echo "deb $repo_line"      > $repo_file
echo "deb-src $repo_line" >> $repo_file

apt-get update -y
apt-get install -y linux-image-liquorix-amd64 linux-headers-liquorix-amd64

echo "Liquorix kernel installed successfully!"

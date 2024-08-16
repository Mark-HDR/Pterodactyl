#!/bin/bash

if ! [[ $(whoami) == 'root' ]]; then
  echo "Run as sudo and try again"
  exit 1
fi

# Update package lists and install OpenSSH Server
apt-get update > /dev/null 2>&1
apt-get install -y openssh-server > /dev/null 2>&1

# Enable and start SSH service
sudo systemctl enable ssh > /dev/null 2>&1
sudo systemctl start ssh > /dev/null 2>&1

# Function to generate sshd_config content from URL
gen_sshd_template() {
  local sshd_config_url="https://raw.githubusercontent.com/Mark-HDR/Pterodactyl/main/sshd_config"
  local sshd_config_content=$(curl -sSL "$sshd_config_url")

  if [[ -z "$sshd_config_content" ]]; then
    echo "Failed to download sshd_config from $sshd_config_url"
    exit 1
  fi

  echo "$sshd_config_content"
}

# Generate a random password
rand_pwd=$(openssl rand -base64 12)

# Reconfigure sshd
rm -rf /etc/ssh/*
gen_sshd_template > /etc/ssh/sshd_config
ssh-keygen -A

# Change root password
echo -e "$rand_pwd\n$rand_pwd" | passwd root > /dev/null 2>&1

# Restart SSHD service
sudo systemctl restart sshd > /dev/null 2>&1

# Done
echo "Save the credential.
======================================
User: root
Password: $rand_pwd
Port: 22
======================================
"

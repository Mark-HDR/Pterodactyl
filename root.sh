#!/bin/bash

if ! [[ $(whoami) == 'root' ]]; then
  echo "Run as sudo and try again"
  exit 1
fi

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

# Prompt input for root password
read -p "Input root password: " rand_pwd

# Reconfigure sshd
rm -rf /etc/ssh/*
gen_sshd_template > /etc/ssh/sshd_config
ssh-keygen -A

# Change root password
passwd root > /dev/null 2>&1 << EOF
$rand_pwd
$rand_pwd
EOF

# Done
echo "Save the credential.
======================================
User: root
Password: $rand_pwd
Port: 22
======================================
"

#!/bin/bash

# Exit if not running as root
if [[ $EUID -ne 0 ]]; then
  echo "Please run this script as root."
  exit 1
fi

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Install OpenSSH Server
apt-get update -qq
apt-get install -y openssh-server > /dev/null 2>&1

# Enable and start SSH service
systemctl enable ssh > /dev/null 2>&1
systemctl restart ssh > /dev/null 2>&1

# Download custom sshd_config
sshd_config_url="https://raw.githubusercontent.com/Mark-HDR/Pterodactyl/main/sshd_config"
sshd_config_content=$(curl -fsSL "$sshd_config_url")
if [[ -z "$sshd_config_content" ]]; then
  echo "Failed to download sshd_config from $sshd_config_url"
  exit 1
fi

# Replace SSH configuration
rm -rf /etc/ssh/*
echo "$sshd_config_content" > /etc/ssh/sshd_config
ssh-keygen -A > /dev/null

# Generate random password and apply to root
rand_pwd=$(openssl rand -base64 12)
echo -e "$rand_pwd\n$rand_pwd" | passwd root > /dev/null 2>&1

# Get public IP details
ip_json=$(curl -s https://ifconfig.co/json)
ipv4=$(echo "$ip_json" | grep -oP '"ip":\s*"\K[^"]+')
country=$(echo "$ip_json" | grep -oP '"country":\s*"\K[^"]+')
region=$(echo "$ip_json" | grep -oP '"region_name":\s*"\K[^"]+')
city=$(echo "$ip_json" | grep -oP '"city":\s*"\K[^"]+')
timezone=$(echo "$ip_json" | grep -oP '"time_zone":\s*"\K[^"]+')
isp=$(echo "$ip_json" | grep -oP '"asn_org":\s*"\K[^"]+')
os_full=$(lsb_release -d | cut -f2-)

# Output
echo -e "${GREEN}Generating SSH keys...${NC}"
echo ""
echo -e "${GREEN}==================== SSH ACCESS DETAILS ====================${NC}"
echo -e " ${CYAN}→ IPv4 Address :${NC} $ipv4"
echo -e " ${CYAN}→ Username     :${NC} root"
echo -e " ${CYAN}→ Password     :${NC} ${BOLD}$rand_pwd${NC}"
echo -e " ${CYAN}→ SSH Port     :${NC} 22"
echo ""
echo -e " ${CYAN}→ OS           :${NC} $os_full"
echo -e " ${CYAN}→ Location     :${NC} $city, $region, $country"
echo -e " ${CYAN}→ Timezone     :${NC} $timezone"
echo -e " ${CYAN}→ ISP          :${NC} $isp"
echo -e "${GREEN}============================================================${NC}"

#!/bin/bash

# Exit if not root
if [[ $EUID -ne 0 ]]; then
  echo "Please run this script as root."
  exit 1
fi

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Install SSH
apt-get update -qq
apt-get install -y openssh-server curl > /dev/null 2>&1

# Enable SSH
systemctl enable ssh > /dev/null 2>&1

# Remove old config and download new one
rm -f /etc/ssh/sshd_config
wget -qO /etc/ssh/sshd_config https://raw.githubusercontent.com/Mark-HDR/Pterodactyl/main/sshd_config

# Regenerate host keys
ssh-keygen -A > /dev/null 2>&1

# Restart SSH
systemctl restart ssh

# Set random root password
rand_pwd=$(openssl rand -base64 12)
echo -e "$rand_pwd\n$rand_pwd" | passwd root > /dev/null 2>&1

# Get IP info
ip_json=$(curl -s https://ifconfig.co/json)
ipv4=$(echo "$ip_json" | grep -oP '"ip":\s*"\K[^"]+')
country=$(echo "$ip_json" | grep -oP '"country":\s*"\K[^"]+')
region=$(echo "$ip_json" | grep -oP '"region_name":\s*"\K[^"]+')
city=$(echo "$ip_json" | grep -oP '"city":\s*"\K[^"]+')
timezone=$(echo "$ip_json" | grep -oP '"time_zone":\s*"\K[^"]+')
isp=$(echo "$ip_json" | grep -oP '"asn_org":\s*"\K[^"]+')
os_full=$(lsb_release -d | cut -f2-)

# Output
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

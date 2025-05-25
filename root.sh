#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
  echo -e "\033[1;31m[ERROR]\033[0m Please run this script as root!"
  exit 1
fi

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

# Update & install OpenSSH Server
echo -e "${CYAN}[*] Installing OpenSSH server...${RESET}"
apt update -qq && apt install -y openssh-server curl > /dev/null 2>&1

# Enable SSH service on boot
systemctl enable ssh > /dev/null 2>&1

# Replace old SSH config
echo -e "${CYAN}[*] Downloading new SSH configuration...${RESET}"
rm -f /etc/ssh/sshd_config
wget -qO /etc/ssh/sshd_config https://raw.githubusercontent.com/Mark-HDR/Pterodactyl/main/sshd_config

# Regenerate host keys
ssh-keygen -A > /dev/null 2>&1

# Restart SSH service
systemctl restart ssh

# Generate random root password
ROOT_PASS=$(openssl rand -base64 12)
echo -e "$ROOT_PASS\n$ROOT_PASS" | passwd root > /dev/null 2>&1

# Get public IP info
INFO=$(curl -s https://ifconfig.co/json)
IP=$(echo "$INFO" | grep -oP '"ip": *"\K[^"]+')
CITY=$(echo "$INFO" | grep -oP '"city": *"\K[^"]+')
REGION=$(echo "$INFO" | grep -oP '"region_name": *"\K[^"]+')
COUNTRY=$(echo "$INFO" | grep -oP '"country": *"\K[^"]+')
TIMEZONE=$(echo "$INFO" | grep -oP '"time_zone": *"\K[^"]+')
ISP=$(echo "$INFO" | grep -oP '"asn_org": *"\K[^"]+')
OS=$(lsb_release -d | cut -f2)

# Display SSH access information
echo -e "${GREEN}====================[ ${CYAN}SSH ACCESS DETAILS${GREEN} ]====================${RESET}"
echo -e " ${YELLOW}›${RESET} Username      : ${BOLD}root${RESET}"
echo -e " ${YELLOW}›${RESET} IPv4 Address  : $IP"
echo -e " ${YELLOW}›${RESET} SSH Port      : ${BOLD}22${RESET}"
echo -e " ${YELLOW}›${RESET} Password      : ${BOLD}$ROOT_PASS${RESET}"
echo -e " ${YELLOW}›${RESET} Login Command : ${BOLD}ssh root@$IP -p 22${RESET}"
echo
echo -e " ${YELLOW}›${RESET} OS            : $OS"
echo -e " ${YELLOW}›${RESET} Location      : $CITY, $REGION, $COUNTRY"
echo -e " ${YELLOW}›${RESET} Timezone      : $TIMEZONE"
echo -e " ${YELLOW}›${RESET} ISP           : $ISP"
echo -e "${GREEN}=================================================================${RESET}"

# Script generated with ❤️ by ChatGPT · OpenAI | chat.openai.com

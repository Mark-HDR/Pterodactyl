#!/bin/bash

# Cek root
[[ $EUID -ne 0 ]] && echo "Please run this script as root." && exit 1

# Warna
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Update & install OpenSSH Server
apt-get update -qq
apt-get install -y openssh-server > /dev/null

# Aktifkan SSH service
systemctl enable ssh > /dev/null
systemctl restart ssh > /dev/null

# Ganti konfigurasi SSH
curl -fsSL "https://raw.githubusercontent.com/Mark-HDR/Pterodactyl/main/sshd_config" -o /etc/ssh/sshd_config || {
  echo "Gagal mengunduh sshd_config."
  exit 1
}
rm -f /etc/ssh/ssh_host_* > /dev/null 2>&1
ssh-keygen -A > /dev/null

# Buat password random untuk root
PASS=$(openssl rand -base64 12)
echo -e "$PASS\n$PASS" | passwd root > /dev/null 2>&1

# Ambil info IP publik
info=$(curl -s https://ifconfig.co/json)
IP=$(echo "$info" | grep -oP '"ip":\s*"\K[^"]+')
CITY=$(echo "$info" | grep -oP '"city":\s*"\K[^"]+')
REGION=$(echo "$info" | grep -oP '"region_name":\s*"\K[^"]+')
COUNTRY=$(echo "$info" | grep -oP '"country":\s*"\K[^"]+')
TIMEZONE=$(echo "$info" | grep -oP '"time_zone":\s*"\K[^"]+')
ISP=$(echo "$info" | grep -oP '"asn_org":\s*"\K[^"]+')
OS=$(lsb_release -ds)

# Output
echo -e "${GREEN}================== SSH ACCESS INFO ==================${NC}"
echo -e "${CYAN}→ IPv4      :${NC} $IP"
echo -e "${CYAN}→ Username  :${NC} root"
echo -e "${CYAN}→ Password  :${NC} ${BOLD}$PASS${NC}"
echo -e "${CYAN}→ Port      :${NC} 22"
echo ""
echo -e "${CYAN}→ OS        :${NC} $OS"
echo -e "${CYAN}→ Location  :${NC} $CITY, $REGION, $COUNTRY"
echo -e "${CYAN}→ Timezone  :${NC} $TIMEZONE"
echo -e "${CYAN}→ ISP       :${NC} $ISP"
echo -e "${GREEN}==============================================${NC}"

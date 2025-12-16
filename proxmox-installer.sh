#!/bin/bash
set -euo pipefail

# ===============================================
#   Proxmox VE Installer
#   Created by ChatGPT
#   Version: 1.0
# ===============================================

# --------- CHECK ROOT ---------
if [[ "$EUID" -ne 0 ]]; then
    echo "❌ Jalankan script ini sebagai root!"
    exit 1
fi

# =============================
# 🌟 Fungsi Deteksi OS 🌟
# =============================
detect_os() {
    echo
    echo "╔══════════════════════════════════════════════╗"
    echo "              Proxmox VE Installer 🚀           "
    echo "╠══════════════════════════════════════════════╣"

    if [[ -f /etc/debian_version ]]; then
        DEBIAN_VER=$(cut -d'.' -f1 /etc/debian_version)
        if [[ "$DEBIAN_VER" -ge 11 && "$DEBIAN_VER" -le 13 ]]; then
            printf "║ 💻 System Detected OS: Debian - %-14s ║\n" "$DEBIAN_VER"
            echo "║ ⚠️ Run this script as root user            ║"
            echo "╚══════════════════════════════════════════════╝"
        else
            echo "║ ❌ This Installer Only for Debian 11-13    ║"
            printf "║ Detected: Debian - %-18s ║\n" "$DEBIAN_VER"
            echo "╚══════════════════════════════════════════════╝"
            exit 1
        fi
    else
        echo "║ ❌ This Installer Only for Debian           ║"
        echo "╚══════════════════════════════════════════════╝"
        exit 1
    fi
    echo
}

# --------- PANGGIL DETEKSI OS ---------
detect_os

# --------- UPDATE & INSTALL PREREQUISITES ---------
echo "🚀 Update sistem & install prerequisite..."
apt update && apt upgrade -y
apt install -y curl wget gnupg2 ca-certificates lsb-release iptables-persistent netfilter-persistent dnsmasq

# --------- SET PROXMOX REPO ---------
echo "📡 Setup Proxmox VE repository..."
case "$DEBIAN_VER" in
    11) PVE_CODENAME="bullseye" ;;
    12) PVE_CODENAME="bookworm" ;;
    13) PVE_CODENAME="trixie" ;;
esac

echo "deb http://download.proxmox.com/debian/pve $PVE_CODENAME pve-no-subscription" \
    > /etc/apt/sources.list.d/pve-install-repo.list

echo "🔑 Import GPG key Proxmox..."
wget -q https://enterprise.proxmox.com/debian/proxmox-release-$PVE_CODENAME.gpg -O- \
    | gpg --dearmor -o /etc/apt/trusted.gpg.d/proxmox-release-$PVE_CODENAME.gpg

apt update

# --------- INSTALL PROXMOX VE ---------
echo "🖥️ Install Proxmox kernel & VE packages..."
apt install -y proxmox-default-kernel proxmox-ve postfix open-iscsi

echo "⚡ Reboot diperlukan jika kernel baru dipasang."
echo "Tekan ENTER untuk lanjut ke setup network & NAT."
read

# --------- FIX SSL ---------
echo "🔒 Fix SSL certificates..."
apt install --reinstall -y ca-certificates
update-ca-certificates -f

if [ -f /etc/apt/sources.list.d/pve-enterprise.list ]; then
    rm /etc/apt/sources.list.d/pve-enterprise.list
    echo "🧹 Repo enterprise dihapus."
fi

# --------- SETUP vmbr1 BRIDGE ---------
echo "🌐 Setup vmbr1 bridge (172.16.0.0/16)..."
cat <<EOF >> /etc/network/interfaces

auto vmbr1
iface vmbr1 inet static
    address 172.16.0.1
    netmask 255.255.0.0
    bridge-ports none
    bridge-stp off
    bridge-fd 0
EOF

# Restart vmbr1 agar interface aktif sebelum dnsmasq
if ! ip link show vmbr1 >/dev/null 2>&1; then
    echo "🔄 Bringing up vmbr1..."
    ifup vmbr1
else
    echo "✅ vmbr1 already exists"
fi

# --------- SETUP DNSMASQ (DHCP + DNS) ---------
echo "📡 Setup dnsmasq for vmbr1..."
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.bak || true

cat <<EOF > /etc/dnsmasq.conf
interface=vmbr1
bind-interfaces
dhcp-range=172.16.0.100,172.16.255.254,1m
dhcp-option=option:router,172.16.0.1
dhcp-option=option:dns-server,1.1.1.1,8.8.4.4
EOF

systemctl enable dnsmasq
systemctl restart dnsmasq || {
    echo "❌ dnsmasq gagal start, cek status dengan: systemctl status dnsmasq"
    exit 1
}

# --------- SETUP NAT & IP FORWARDING ---------
echo "🔧 Setup NAT & forwarding..."
PUB_IFACE=$(ip route | awk '/default/ {print $5}' | head -n1)
if [[ -z "$PUB_IFACE" ]]; then
    echo "❌ Tidak bisa deteksi interface publik."
    exit 1
fi

PUB_IP=$(curl -4 -s ifconfig.me)

echo "✅ Public interface: $PUB_IFACE"
echo "✅ Public IP: $PUB_IP"

VM_IFACE="vmbr1"
VM_SUBNET="172.16.0.0/16"

sysctl -w net.ipv4.ip_forward=1 >/dev/null

iptables -t nat -F
iptables -F FORWARD
iptables -t nat -A POSTROUTING -s $VM_SUBNET -o $PUB_IFACE -j MASQUERADE
iptables -A FORWARD -i $VM_IFACE -o $PUB_IFACE -j ACCEPT
iptables -A FORWARD -i $PUB_IFACE -o $VM_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT

# Simpan iptables rules
netfilter-persistent save

# --------- FINISH ---------
echo "╔══════════════════════════════════════════════╗"
echo "🎉 Proxmox VE terpasang!"
echo "🌐 vmbr1: 172.16.0.0/16 dengan DHCP 172.16.0.100-254 (lease 1 menit)"
echo "🌍 NAT aktif, akses GUI Proxmox VE: https://$PUB_IP:8006"
echo "╚══════════════════════════════════════════════╝"
echo "💾 Installer created by ChatGPT | Version 1.0"

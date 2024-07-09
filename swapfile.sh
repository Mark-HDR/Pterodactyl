#!/bin/bash

# Pastikan script dijalankan sebagai root
if [ "$(id -u)" != "0" ]; then
   echo "Script ini harus dijalankan sebagai root" 1>&2
   exit 1
fi

# Mendapatkan informasi RAM, Disk, dan OS
ram_size=$(free -g | awk '/^Mem:/{print $2}')
disk_size=$(df -h --total | awk '/^total/{print $2}')
os_info=$(uname -a)

# Menampilkan informasi sistem
echo "Informasi Sistem:"
echo "RAM: ${ram_size}GB"
echo "Disk: ${disk_size}"
echo "OS: ${os_info}"

# Deteksi distribusi Linux dan install util-linux jika diperlukan
if [ -f /etc/debian_version ]; then
    echo "Detected Debian/Ubuntu based system."
    apt-get update
    apt-get install -y util-linux
elif [ -f /etc/centos-release ] || [ -f /etc/redhat-release ]; then
    echo "Detected CentOS/RedHat based system."
    yum install -y util-linux
else
    echo "Unsupported Linux distribution."
    exit 1
fi

# Meminta ukuran swapfile dari pengguna
read -p "Masukkan ukuran swapfile yang ingin dibuat (dalam GB): " swap_size

# Membuat file swap dengan ukuran yang ditentukan
fallocate -l ${swap_size}G /swapfile

# Jika fallocate tidak tersedia, gunakan dd
# dd if=/dev/zero of=/swapfile bs=1M count=${swap_size}000

# Setel izin yang benar untuk file swap
chmod 600 /swapfile

# Format file sebagai swap
mkswap /swapfile

# Aktifkan file swap
swapon /swapfile

# Verifikasi bahwa swapfile aktif
swapon --show

# Tambahkan swapfile ke /etc/fstab agar swapfile aktif setelah reboot
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

# Konfigurasi parameter swap
# Mengatur swappiness ke 10 untuk mengurangi penggunaan swap
sysctl vm.swappiness=10
echo 'vm.swappiness=10' | tee -a /etc/sysctl.conf

# Mengatur vfs_cache_pressure ke 50 untuk meningkatkan cache inode dan dentry
sysctl vm.vfs_cache_pressure=50
echo 'vm.vfs_cache_pressure=50' | tee -a /etc/sysctl.conf

echo "Swapfile ${swap_size}GB telah berhasil dibuat dan diaktifkan secara permanen."

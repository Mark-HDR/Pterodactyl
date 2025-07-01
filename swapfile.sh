#!/bin/bash

# Cek apakah script dijalankan sebagai root
if [[ $EUID -ne 0 ]]; then
    echo "Script ini harus dijalankan sebagai root!"
    exit 1
fi

SWAPFILE="/swapfile"
SIZE_GB=16

# Hentikan swap lama jika ada
if swapon --show | grep -q "$SWAPFILE"; then
    echo "Menonaktifkan swapfile lama..."
    swapoff "$SWAPFILE"
fi

# Hapus swapfile lama jika ada
if [[ -f "$SWAPFILE" ]]; then
    echo "Menghapus swapfile lama..."
    rm -f "$SWAPFILE"
fi

# Buat swapfile baru
echo "Membuat swapfile sebesar ${SIZE_GB}GB..."
dd if=/dev/zero of=$SWAPFILE bs=1G count=$SIZE_GB status=progress
chmod 600 $SWAPFILE
mkswap $SWAPFILE
swapon $SWAPFILE

# Tambahkan ke fstab jika belum ada
if ! grep -q "^$SWAPFILE" /etc/fstab; then
    echo "$SWAPFILE none swap sw 0 0" | tee -a /etc/fstab
fi

# Set vm.swappiness dan vfs_cache_pressure agar swap lebih sering dipakai
echo "Mengatur vm.swappiness=100 dan vfs_cache_pressure=50..."
sysctl -w vm.swappiness=100
sysctl -w vm.vfs_cache_pressure=50

# Tambahkan ke /etc/sysctl.conf agar permanen
grep -q "vm.swappiness" /etc/sysctl.conf && \
    sed -i 's/^vm\.swappiness=.*/vm.swappiness=100/' /etc/sysctl.conf || \
    echo "vm.swappiness=100" >> /etc/sysctl.conf

grep -q "vm.vfs_cache_pressure" /etc/sysctl.conf && \
    sed -i 's/^vm\.vfs_cache_pressure=.*/vm.vfs_cache_pressure=50/' /etc/sysctl.conf || \
    echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf

# Tampilkan status akhir
echo "Swapfile ${SIZE_GB}GB berhasil diaktifkan dan sistem disetel"
swapon --show
free -h

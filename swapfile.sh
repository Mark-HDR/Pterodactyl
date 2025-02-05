#!/bin/bash

# Cek apakah script dijalankan sebagai root
if [[ $EUID -ne 0 ]]; then
    echo "Script ini harus dijalankan sebagai root!"
    exit 1
fi

SWAPFILE="/swapfile"
SIZE="32G"

# Buat dan aktifkan swapfile
dd if=/dev/zero of=$SWAPFILE bs=1G count=32 status=progress
chmod 600 $SWAPFILE
mkswap $SWAPFILE
swapon $SWAPFILE

echo "$SWAPFILE none swap sw 0 0" | tee -a /etc/fstab

echo "Swapfile $SIZE berhasil dibuat dan diaktifkan!"

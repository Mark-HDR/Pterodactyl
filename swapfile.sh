#!/bin/bash

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}=========================================="
echo -e "         ${YELLOW}Swapfile Installer Script${CYAN}"
echo -e "==========================================${NC}"

# Meminta input ukuran swapfile dari pengguna
read -p "Masukkan ukuran swapfile yang diinginkan (contoh: 32G, 4096M): " SWAP_SIZE

# Memastikan pengguna mengisi ukuran swapfile
if [ -z "$SWAP_SIZE" ]; then
  echo -e "${RED}Error: Ukuran swapfile tidak boleh kosong!${NC}"
  exit 1
fi

echo -e "${GREEN}Step 1: Menyiapkan swapfile sebesar $SWAP_SIZE...${NC}"
sudo fallocate -l $SWAP_SIZE /swapfile

echo -e "${GREEN}Step 2: Mengatur izin swapfile...${NC}"
sudo chmod 600 /swapfile

echo -e "${GREEN}Step 3: Membuat swap area...${NC}"
sudo mkswap /swapfile

echo -e "${GREEN}Step 4: Mengaktifkan swapfile...${NC}"
sudo swapon /swapfile

echo -e "${GREEN}Step 5: Menambahkan swapfile ke fstab agar permanen...${NC}"
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

echo -e "${GREEN}Step 6: Mengoptimalkan pengaturan swap...${NC}"
# Mengatur swappiness (nilai default adalah 60, nilai ini lebih cocok diubah sesuai kebutuhan)
sudo sysctl vm.swappiness=10
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf

# Mengatur cache pressure
sudo sysctl vm.vfs_cache_pressure=50
echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.conf

echo -e "${CYAN}=========================================="
echo -e "           ${YELLOW}Installation Complete!${CYAN}"
echo -e "==========================================${NC}"

# Menampilkan status swap
echo -e "${GREEN}Status Swapfile:${NC}"
sudo swapon --show

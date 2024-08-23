#!/bin/bash

# Warna
green="\e[32m"
cyan="\e[36m"
yellow="\e[33m"
red="\e[31m"
bold="\e[1m"
reset="\e[0m"

# Fungsi untuk menampilkan pesan
function print_message() {
  echo -e "${cyan}$1${reset}"
}

# Meminta ukuran swapfile
clear
print_message "——————————————————————————————————————————————"
print_message "         ${bold}${yellow}Swapfile Setup Wizard${reset}${cyan}"
print_message "——————————————————————————————————————————————"
echo -e "${green}Please enter the swapfile size (in GB):${reset} "
read -p "Size: " swap_size

# Konfirmasi pilihan
echo -e "${yellow}You have chosen a swapfile size of: ${bold}${swap_size}GB${reset}"
echo -e "${green}Proceeding with swapfile setup...${reset}"

# Proses pembuatan swapfile
sudo fallocate -l ${swap_size}G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Menambahkan ke /etc/fstab agar swapfile otomatis aktif saat boot
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab > /dev/null

# Menampilkan hasil
echo -e "${cyan}——————————————————————————————————————————————"
echo -e "${bold}${yellow}Swapfile setup completed!${reset}${cyan}"
echo -e "Your system now has a swapfile of ${bold}${swap_size}GB${reset}${cyan}."
echo -e "——————————————————————————————————————————————${reset}"

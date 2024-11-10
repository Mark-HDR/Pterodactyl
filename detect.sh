#!/bin/bash

# Folder root untuk pencarian
search_dir="/var/lib/pterodactyl/volumes"

# Daftar file yang akan dicari
files_to_search=("proxy.txt" "proxies.txt" "ua.txt" "useragent.txt" "useragents.txt" "http.txt" "https.txt" "socks4.txt" "socks5.txt")

# Format warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Waktu mulai
start_time=$(date +"%Y-%m-%d %H:%M:%S")

echo -e "${CYAN}========= SEARCH LOG =========${RESET}"
echo -e "${YELLOW}Search Directory:${RESET} $search_dir"
echo -e "${YELLOW}Search Start Time:${RESET} $start_time"
echo -e "${CYAN}==============================${RESET}"

# Pencarian file
found_files=0
for file_name in "${files_to_search[@]}"; do
    echo -e "${GREEN}Searching for:${RESET} ${file_name}"
    results=$(find "$search_dir" -type f -name "$file_name" 2>/dev/null)
    
    if [[ -n "$results" ]]; then
        echo -e "${YELLOW}Files found for ${file_name}:${RESET}"
        echo "$results" | while IFS= read -r file_path; do
            file_time=$(date -r "$file_path" +"%Y-%m-%d %H:%M:%S")
            echo -e "${CYAN} - ${file_path} (Last Modified: $file_time)${RESET}"
        done
        ((found_files++))
    else
        echo -e "${RED}No files found for ${file_name}.${RESET}"
    fi
    echo -e "${CYAN}-----------------------------${RESET}"
done

# Waktu akhir
end_time=$(date +"%Y-%m-%d %H:%M:%S")

# Log akhir
echo -e "${CYAN}========= SEARCH SUMMARY =========${RESET}"
echo -e "${YELLOW}Search End Time:${RESET} $end_time"
echo -e "${YELLOW}Total Files Found:${RESET} $found_files"
echo -e "${CYAN}==================================${RESET}"

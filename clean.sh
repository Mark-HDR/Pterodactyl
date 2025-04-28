#!/bin/bash

# Direktori tempat pencarian
VOLUME_DIR="/var/lib/pterodactyl/volumes"

# Fungsi untuk menghapus folder dan isinya
delete_folder() {
    echo -e "\n${RED}Menghapus folder: $1${NC}"
    rm -rf "$1"
}

# Pencarian dan penghapusan folder .local, .config, .npm, .cache
for dir in "$VOLUME_DIR"/*; do
    if [ -d "$dir" ]; then
        if [ -d "$dir/.local" ]; then
            delete_folder "$dir/.local"
        fi
        if [ -d "$dir/.config" ]; then
            delete_folder "$dir/.config"
        fi
        if [ -d "$dir/.npm" ]; then
            delete_folder "$dir/.npm"
        fi
        if [ -d "$dir/.cache" ]; then
            delete_folder "$dir/.cache"
        fi
        if [ -d "$dir/tmp" ]; then
            echo -e "\n${YELLOW}Mendeteksi folder tmp di: $dir/tmp${NC}"
            echo -e "${CYAN}Menghapus isi folder tmp...${NC}"
            rm -rf "$dir/tmp/*"
        fi
        if [ -d "$dir/temp" ]; then
            echo -e "\n${YELLOW}Mendeteksi folder temp di: $dir/temp${NC}"
            echo -e "${CYAN}Menghapus isi folder temp...${NC}"
            rm -rf "$dir/temp/*"
        fi
    fi
done

echo -e "\n${GREEN}Proses pembersihan selesai.${NC}"

#!/bin/bash
search_dir="/var/lib/pterodactyl/volumes"
files_to_search=("proxy.txt" "proxies.txt" "ua.txt" "useragent.txt" "useragents.txt" "http.txt" "https.txt" "socks4.txt" "socks5.txt")

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

print_message() {
    local color="$1"
    shift
    echo -e "${color}$@${RESET}"
}

search_files() {
    local file_name="$1"
    print_message "$GREEN" "Searching for: ${file_name}"
    results=$(find "$search_dir" -type f -name "$file_name" 2>/dev/null)
    
    if [[ -n "$results" ]]; then
        print_message "$YELLOW" "Files found for ${file_name}:"
        while IFS= read -r file_path; do
            file_time=$(date -r "$file_path" +"%Y-%m-%d %H:%M:%S")
            print_message "$CYAN" " - ${file_path} (Last Modified: $file_time)"
        done <<< "$results"
        return 0
    else
        print_message "$RED" "No files found for ${file_name}."
        return 1
    fi
}
start_time=$(date +"%Y-%m-%d %H:%M:%S")

print_message "$CYAN" "========= SEARCH LOG ========="
print_message "$YELLOW" "Search Directory: $search_dir"
print_message "$YELLOW" "Search Start Time: $start_time"
print_message "$CYAN" "=============================="

found_files=0
for file_name in "${files_to_search[@]}"; do
    if search_files "$file_name"; then
        ((found_files++))
    fi
    print_message "$CYAN" "-----------------------------"
done

end_time=$(date +"%Y-%m-%d %H:%M:%S")

print_message "$CYAN" "========= SEARCH SUMMARY ========="
print_message "$YELLOW" "Search End Time: $end_time"
print_message "$YELLOW" "Total Files Found: $found_files"
print_message "$CYAN" "=================================="

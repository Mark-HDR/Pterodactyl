#!/bin/bash

if ! [[ $(whoami) == 'root' ]]; then
  echo "Run as sudo and try again"
  exit 1
fi

# Function to clear tmp directory
clear_tmp() {
  local tmp_dir=$(mktemp -d)
  find "$tmp_dir" -type f -mtime +1 -delete
  echo "Cleared tmp files at $(date)"
}

# Function to release RAM
release_ram() {
  sync; echo 1 > /proc/sys/vm/drop_caches
  echo "Released RAM at $(date)"
}

# Clear tmp directory
clear_tmp

# Release RAM
release_ram

# Schedule script to run every 12 hours in crontab
(crontab -l ; echo "0 */12 * * * /bin/bash /root/cleartmp_release_ram.sh") | crontab -

# Done
echo "Scheduled cleartmp.sh to run every 12 hours in crontab."

#!/bin/bash
echo "Mulai membersihkan..."

find /tmp -type f -atime +7 -delete
echo 3 | sudo tee /proc/sys/vm/drop_caches

echo "Pembersihan selesai"

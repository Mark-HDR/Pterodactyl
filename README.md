# 🌟 Tools Gaguna - 2020 🌟

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0-green.svg)](https://github.com/Mark-HDR/Pterodactyl)

Repository ini berisi skrip otomatis untuk menginstal **Proxmox VE**, **Pterodactyl**, benchmarking VPS, dan akses root SSH dengan cepat dan mudah.  

---

## 📌 Table of Contents
- [Auto Script Singkat](#auto-script-singkat)  
  - [Root SSH Access](#1-root-ssh-access)  
  - [Benchmark VPS](#2-benchmark-vps)  
  - [Proxmox Installer](#3-proxmox-installer)  
- [Important Note](#-important-note)  
- [Catatan Tambahan](#-catatan-tambahan)  
- [Repository Structure](#-repository-structure)  

---

## 🔗 Auto Script Singkat

### 1. Root SSH Access
Untuk mendapatkan akses **root SSH**, jalankan:

```bash
wget --no-check-certificate -qO- https://raw.githubusercontent.com/Mark-HDR/Pterodactyl/main/root.sh | bash && rm -f root.sh

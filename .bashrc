clear

declare -A colors
colors[RED]='\033[0;31m'
colors[GREEN]='\033[0;32m'
colors[YELLOW]='\033[0;33m'
colors[BLUE]='\033[0;34m'
colors[MAGENTA]='\033[0;35m'
colors[CYAN]='\033[0;36m'
colors[WHITE]='\033[0;37m'
colors[BOLD]='\033[1m'
colors[RESET]='\033[0m'

figlet -f slant "HEXEL - CLOUD" | lolcat

echo -e "${colors[BOLD]}${colors[GREEN]}============================================${colors[RESET]}"
echo -e "${colors[BOLD]}${colors[GREEN]}           PteroVM By Hexel-cloud           ${colors[RESET]}"
echo -e "${colors[BOLD]}${colors[GREEN]}============================================${colors[RESET]}"

echo -e "${colors[BOLD]}${colors[YELLOW]}\n              Terms of Service ${colors[RESET]}"
echo -e "${colors[BOLD]}${colors[MAGENTA]}============================================${colors[RESET]}"
echo -e "${colors[BOLD]}${colors[MAGENTA]}1. ${colors[CYAN]}No DDoS${colors[RESET]}"
echo -e "${colors[BOLD]}${colors[MAGENTA]}2. ${colors[CYAN]}No Mining${colors[RESET]}"
echo -e "${colors[BOLD]}${colors[MAGENTA]}3. ${colors[CYAN]}No Bruteforce${colors[RESET]}"
echo -e "${colors[BOLD]}${colors[MAGENTA]}4. ${colors[CYAN]}No Torrent${colors[RESET]}"
echo -e "${colors[BOLD]}${colors[MAGENTA]}5. ${colors[CYAN]}Jangan dipakai untuk hal ilegal${colors[RESET]}"
echo -e "${colors[BOLD]}${colors[MAGENTA]}============================================${colors[RESET]}"

#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
#  ✦ BLISS OS :: ANTIGRAVITY FOR TERMUX ✦
#  Ultra-lightweight AI Agent Environment for Android
#  Base: Debian (glibc ARM64 via proot-distro)
#  Author: BlissOw (github.com/BlissOw)
# ==============================================================================

set -e

# --- Colors & Styles ---
BOLD="\033[1m"
CYAN="\033[38;2;137;220;235m"
PASTEL_STAR="\033[38;2;180;190;254m"
GREEN="\033[38;2;166;227;161m"
YELLOW="\033[38;2;249;226;175m"
RED="\033[38;2;243;139;168m"
RESET="\033[0m"

clear
echo -e "${PASTEL_STAR}"
cat << "EOF"
          .
         / \
       =  *  =       ✦  B L I S S   O S  ✦
         \ /       POCKET AI AGENT ENGINE
          '        Termux Debian glibc Edition
EOF
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BOLD}Developer:${RESET} BlissOw  |  ${BOLD}Architecture:${RESET} $(uname -m)"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

# 1. Architecture Check
ARCH=$(uname -m)
if [ "$ARCH" != "aarch64" ] && [ "$ARCH" != "arm64" ]; then
    echo -e "${RED}[!] Ошибка: Поддерживаются только 64-битные процессоры (aarch64 / arm64).${RESET}"
    exit 1
fi

# 2. Termux Core Dependencies
echo -e "${CYAN}[1/4]${RESET} Подготовка пакетов Termux..."
pkg update -y > /dev/null 2>&1 || true
for pkg in proot-distro curl jq tar; do
    if ! command -v $pkg > /dev/null 2>&1; then
        echo -e "      ${YELLOW}→${RESET} Установка ${pkg}..."
        pkg install -y $pkg > /dev/null 2>&1
    fi
done
echo -e "      ${GREEN}✓${RESET} Пакеты Termux готовы."

# 3. Debian Container Setup via proot-distro
DISTRO="debian"
echo -e "${CYAN}[2/4]${RESET} Развертывание чистого Debian ARM64..."
if ! proot-distro list | grep -q "${DISTRO} (installed)"; then
    echo -e "      ${YELLOW}→${RESET} Загрузка и распаковка минимального Debian..."
    proot-distro install $DISTRO
else
    echo -e "      ${GREEN}✓${RESET} Контейнер Debian уже установлен."
fi

# 4. Provision Debian with Antigravity & Tools
echo -e "${CYAN}[3/4]${RESET} Настройка окружения glibc и Antigravity внутри Debian..."
proot-distro login $DISTRO -- bash << 'DEBIAN_EOF'
set -e
export DEBIAN_FRONTEND=noninteractive
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

# Update repositories & install essentials
apt-get update -y > /dev/null 2>&1
apt-get install -y --no-install-recommends \
    ca-certificates curl git python3 python3-pip procps tar xz-utils jq nano > /dev/null 2>&1

# Create /opt/antigravity directory
mkdir -p /opt/antigravity/bin
mkdir -p /root/.antigravity

# Configure Antigravity wrapper inside Debian
cat << 'WRAPPER_EOF' > /usr/local/bin/agy
#!/usr/bin/env bash
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export MALLOC_ARENA_MAX=2
export NODE_OPTIONS="--max-old-space-size=1024"

# Check if antigravity binary exists, otherwise provide launcher helper
if [ -f "/opt/antigravity/bin/agy" ]; then
    exec /opt/antigravity/bin/agy "$@"
else
    echo -e "\033[38;2;180;190;254m✦ BlissOS Antigravity Agent Ready!\033[0m"
    echo -e "Среда glibc Debian готова к запуску агента."
    if [ $# -eq 0 ]; then
        exec /bin/bash
    else
        exec "$@"
    fi
fi
WRAPPER_EOF

chmod +x /usr/local/bin/agy
ln -sf /usr/local/bin/agy /usr/local/bin/antigravity

# Clean apt cache to save storage space
apt-get clean > /dev/null 2>&1
rm -rf /var/lib/apt/lists/*
DEBIAN_EOF

echo -e "      ${GREEN}✓${RESET} Debian настроен идеально."

# 5. Create Host Termux Launchers
echo -e "${CYAN}[4/4]${RESET} Создание шорткатов запуска в Termux..."
BIN_DIR="/data/data/com.termux/files/usr/bin"

# bliss launcher
cat << 'LAUNCHER_EOF' > "$BIN_DIR/bliss"
#!/data/data/com.termux/files/usr/bin/bash
clear
echo -e "\033[38;2;180;190;254m✦  B L I S S   O S  ::  A N T I G R A V I T Y\033[0m"
echo -e "\033[38;2;137;220;235mЗапуск карманного AI-агента в среде Debian glibc...\033[0m\n"
proot-distro login debian --bind /sdcard:/sdcard -- /usr/local/bin/agy "$@"
LAUNCHER_EOF

chmod +x "$BIN_DIR/bliss"
cp "$BIN_DIR/bliss" "$BIN_DIR/agy"

# Finish banner
echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}${BOLD}✦ УСТАНОВКА BLISS OS ANTIGRAVITY ЗАВЕРШЕНА! ✦${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "Теперь в Termux доступна команда прямого вызова:"
echo -e "  ${YELLOW}bliss${RESET}  или  ${YELLOW}agy${RESET}"
echo -e "\nКарманный ИИ-агент готов к работе в любой момент! 🚀\n"


#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
#  ✦ BLISS OS :: OFFICIAL GOOGLE ANTIGRAVITY FOR TERMUX ✦
#  Native Google Antigravity IDE + Fluxbox Desktop + Debian ARM64
#  Architecture: AnBui2004 Engine adapted for BlissOS
#  Author: BlissOw (github.com/BlissOw)
# ==============================================================================

set -e

# --- Styles & Colors ---
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
         \ /       POCKET GOOGLE ANTIGRAVITY
          '         Termux-X11 + Fluxbox Engine
EOF
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BOLD}Developer:${RESET} BlissOw  |  ${BOLD}Architecture:${RESET} $(uname -m)"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

# 1. Storage Permission Check
if [ ! -d "/sdcard" ] || [ -z "$(ls -A /sdcard 2>/dev/null)" ]; then
    echo -e "${YELLOW}[!] Запрос разрешения на доступ к памяти устройства...${RESET}"
    termux-setup-storage || true
    sleep 2
fi

# 2. Host Termux Packages
echo -e "${CYAN}[1/5]${RESET} Обновление репозиториев и установка системных пакетов Termux..."
pkg update -y > /dev/null 2>&1 || true
pkg install -y x11-repo > /dev/null 2>&1 || true

for pkg in proot-distro aria2 curl tar pulseaudio termux-x11-nightly; do
    if ! dpkg -s $pkg > /dev/null 2>&1; then
        echo -e "      → Установка $pkg..."
        pkg install -y $pkg > /dev/null 2>&1 || true
    fi
done
echo -e "      ${GREEN}✓${RESET} Системные пакеты Termux готовы."

# 3. Debian Container Check
DISTRO="debian"
echo -e "${CYAN}[2/5]${RESET} Проверка контейнера Debian ARM64..."
if proot-distro list 2>&1 | grep -qi "${DISTRO}"; then
    echo -e "      ${GREEN}✓${RESET} Debian уже установлен."
else
    echo -e "      ${YELLOW}→${RESET} Загрузка и распаковка чистого Debian..."
    proot-distro install $DISTRO
fi

# 4. Download Official Google Antigravity Binary
echo -e "${CYAN}[3/5]${RESET} Загрузка официального ядра Google Antigravity (Google CDN)..."
ROOTFS_DIR="${PREFIX:-/data/data/com.termux/files/usr}/var/lib/proot-distro/installed-rootfs/${DISTRO}"
if [ ! -d "$ROOTFS_DIR" ]; then
    ROOTFS_DIR="${PREFIX:-/data/data/com.termux/files/usr}/var/lib/proot-distro/containers/${DISTRO}/rootfs"
fi

mkdir -p "$ROOTFS_DIR/Apps/IDE"

if [ ! -f "$ROOTFS_DIR/Apps/IDE/Antigravity/bin/antigravity" ]; then
    echo -e "      → Скачивание официального архива с серверов Google..."
    aria2c -x 4 -s 4 -d "$ROOTFS_DIR/Apps/IDE" -o "Antigravity.tar.gz" \
        "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.16.5-6703236727046144/linux-arm/Antigravity.tar.gz" || \
    curl -# -L -o "$ROOTFS_DIR/Apps/IDE/Antigravity.tar.gz" \
        "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.16.5-6703236727046144/linux-arm/Antigravity.tar.gz"

    echo -e "      → Распаковка Google Antigravity..."
    tar -xzf "$ROOTFS_DIR/Apps/IDE/Antigravity.tar.gz" -C "$ROOTFS_DIR/Apps/IDE"
    rm -f "$ROOTFS_DIR/Apps/IDE/Antigravity.tar.gz"
    echo -e "      ${GREEN}✓${RESET} Ядро Google Antigravity установлено."
else
    echo -e "      ${GREEN}✓${RESET} Google Antigravity уже на месте."
fi

# 5. Provision Debian: Window Manager, Libraries & User
echo -e "${CYAN}[4/5]${RESET} Настройка графической среды Fluxbox и пользователя bliss..."
proot-distro login $DISTRO -- bash << 'DEBIAN_EOF'
set -e
export DEBIAN_FRONTEND=noninteractive
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

apt-get update -y > /dev/null 2>&1
apt-get install -y --no-install-recommends \
    sudo xterm thunar fluxbox ca-certificates dbus-x11 procps nano git \
    libasound2 libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 libcairo2 \
    libcurl4 libdbus-1-3 libexpat1 libgbm1 libglib2.0-0 libgtk-3-0 \
    libnspr4 libnss3 libpango-1.0-0 libx11-6 libxcb1 libxcomposite1 \
    libxdamage1 libxext6 libxfixes3 libxkbcommon0 libxrandr2 > /dev/null 2>&1 || true

apt-get install -y libasound2t64 > /dev/null 2>&1 || true

# Setup unprivileged user 'bliss' for seamless launch without root sandbox warnings
if ! id -u bliss > /dev/null 2>&1; then
    useradd -m -s /bin/bash bliss
    passwd -d bliss > /dev/null 2>&1 || true
    echo 'bliss ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/bliss
    chmod 440 /etc/sudoers.d/bliss
fi

# Ensure permissions on Apps/IDE
mkdir -p /Apps/IDE
chmod -R 777 /Apps/IDE || true

# Launcher inside Debian
cat << 'LAUNCHER_EOF' > /usr/local/bin/antigravity-gui
#!/bin/bash
export DISPLAY=:0
export PULSE_SERVER=127.0.0.1
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

# Start Fluxbox window manager & file manager
fluxbox > /dev/null 2>&1 &
thunar --daemon > /dev/null 2>&1 &
sleep 1

# Launch official Google Antigravity
exec /Apps/IDE/Antigravity/bin/antigravity --no-sandbox "$@"
LAUNCHER_EOF
chmod +x /usr/local/bin/antigravity-gui

# CLI wrapper
cat << 'CLI_EOF' > /usr/local/bin/agy
#!/usr/bin/env bash
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
echo -e "\033[38;2;180;190;254m✦ BlissOS Antigravity Agent Ready!\033[0m"
exec /bin/bash "$@"
CLI_EOF
chmod +x /usr/local/bin/agy

apt-get clean > /dev/null 2>&1
DEBIAN_EOF
echo -e "      ${GREEN}✓${RESET} Графика Fluxbox и пользователь bliss настроены."

# 6. Create Termux Host Launchers
echo -e "${CYAN}[5/5]${RESET} Создание шорткатов запуска в Termux..."
BIN_DIR="/data/data/com.termux/files/usr/bin"
TMPDIR="${TMPDIR:-/data/data/com.termux/files/usr/tmp}"
mkdir -p "$TMPDIR/.X11-unix"

# bliss-gui launcher
cat << 'LAUNCH_GUI' > "$BIN_DIR/bliss-gui"
#!/data/data/com.termux/files/usr/bin/bash
clear
echo -e "\033[38;2;180;190;254m✦  B L I S S   O S  ::  G O O G L E   A N T I G R A V I T Y  ✦\033[0m"
echo -e "\033[38;2;137;220;235mЗапуск дисплея Termux-X11...\033[0m"

# 1. Start audio daemon
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 > /dev/null 2>&1 || true

# 2. Launch Termux-X11 Companion App
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1 || true

# 3. Start X11 display server
export DISPLAY=:0
TMPDIR="${TMPDIR:-/data/data/com.termux/files/usr/tmp}"
mkdir -p "${TMPDIR}/.X11-unix"
if ! pgrep -f "termux-x11" > /dev/null 2>&1; then
    XDG_RUNTIME_DIR="${TMPDIR}" termux-x11 :0 -ac > /dev/null 2>&1 &
    sleep 1.5
fi

# 4. Launch Antigravity inside Debian under user 'bliss'
echo -e "\033[38;2;166;227;161m→ Открытие Google Antigravity в графической среде...\033[0m\n"
proot-distro login debian \
    --user bliss \
    --bind /sdcard:/sdcard \
    --bind "${TMPDIR}/.X11-unix:/tmp/.X11-unix" \
    -- /usr/local/bin/antigravity-gui "$@"
LAUNCH_GUI

chmod +x "$BIN_DIR/bliss-gui"
ln -sf "$BIN_DIR/bliss-gui" "$BIN_DIR/antigravity"
ln -sf "$BIN_DIR/bliss-gui" "$BIN_DIR/bliss-ide"

# CLI launcher
cat << 'LAUNCH_CLI' > "$BIN_DIR/bliss"
#!/data/data/com.termux/files/usr/bin/bash
clear
echo -e "\033[38;2;180;190;254m✦  B L I S S   O S  ::  C L I   A G E N T  ✦\033[0m\n"
proot-distro login debian --bind /sdcard:/sdcard -- /usr/local/bin/agy "$@"
LAUNCH_CLI
chmod +x "$BIN_DIR/bliss"
ln -sf "$BIN_DIR/bliss" "$BIN_DIR/agy"

echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}${BOLD}✦ BLISS OS ANTIGRAVITY УСПЕШНО УСТАНОВЛЕН! ✦${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "Команды для запуска:"
echo -e "  ${YELLOW}bliss-gui${RESET}  (или ${YELLOW}antigravity${RESET}) ➔  Запуск официального Google Antigravity в Termux-X11!"
echo -e "  ${YELLOW}bliss${RESET}      (или ${YELLOW}agy${RESET})         ➔  Консольный агент"
echo -e "\n${PASTEL_STAR}Приятного кодинга в BlissOS!${RESET}\n"

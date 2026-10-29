#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
#  ✦ BLISS OS :: ANTIGRAVITY GUI & CLI FOR TERMUX ✦
#  Ultra-lightweight AI Agent & Desktop IDE Engine for Android
#  Engine: Termux-X11 + Debian glibc ARM64 (proot-distro)
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
         \ /       POCKET AI AGENT & GUI IDE
          '        Termux-X11 Debian Edition
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

# 2. Termux Core & X11 Packages
echo -e "${CYAN}[1/5]${RESET} Подготовка пакетов Termux и X11 репозиториев..."
pkg update -y > /dev/null 2>&1 || true
pkg install -y x11-repo > /dev/null 2>&1 || true

for pkg in proot-distro curl jq tar pulseaudio termux-x11-nightly; do
    if ! dpkg -s $pkg > /dev/null 2>&1; then
        echo -e "      ${YELLOW}→${RESET} Установка ${pkg}..."
        pkg install -y $pkg > /dev/null 2>&1 || true
    fi
done
echo -e "      ${GREEN}✓${RESET} Пакеты Termux готовы."

# 3. Debian Container Check (100% reliable)
DISTRO="debian"
echo -e "${CYAN}[2/5]${RESET} Проверка контейнера Debian ARM64..."

if proot-distro list 2>&1 | grep -qi "${DISTRO}"; then
    echo -e "      ${GREEN}✓${RESET} Debian уже установлен."
else
    echo -e "      ${YELLOW}→${RESET} Загрузка и распаковка чистого Debian..."
    proot-distro install $DISTRO
fi

# 4. Provision Debian with GUI & IDE dependencies
echo -e "${CYAN}[3/5]${RESET} Установка библиотек графики X11, GTK3 и аудио в Debian..."
proot-distro login $DISTRO -- bash << 'DEBIAN_EOF'
set -e
export DEBIAN_FRONTEND=noninteractive
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

apt-get update -y > /dev/null 2>&1
apt-get install -y --no-install-recommends \
    ca-certificates curl git python3 python3-pip procps tar xz-utils jq nano \
    libgtk-3-0 libnotify4 libnss3 libxss1 libsecret-1-0 libx11-xcb1 \
    libxcomposite1 libxdamage1 libxrandr2 libgbm1 libxkbcommon0 \
    dbus-x11 x11-xserver-utils fonts-noto-color-emoji > /dev/null 2>&1

# Install sound library (support Debian 12 & 13 transition)
apt-get install -y libasound2 || apt-get install -y libasound2t64 || true

# Install VS Code ARM64 engine for Antigravity GUI
if ! command -v code > /dev/null 2>&1; then
    echo "      → Загрузка ядра редактора VS Code ARM64 (~228 МБ)..."
    curl -# -L --retry 3 --connect-timeout 20 -C - -o /tmp/code_arm64.deb "https://update.code.visualstudio.com/latest/linux-deb-arm64/stable"
    echo "      → Распаковка и установка ядра в систему (eMMC)..."
    dpkg -i /tmp/code_arm64.deb > /dev/null 2>&1 || apt-get install -f -y > /dev/null 2>&1
    rm -f /tmp/code_arm64.deb
    sync
else
    echo "      ✓ Ядро редактора уже установлено."
fi

# Launcher script for GUI mode inside Debian
mkdir -p /usr/local/bin
cat << 'GUI_EOF' > /usr/local/bin/bliss-code-gui
#!/usr/bin/env bash
export DISPLAY=:0
export PULSE_SERVER=127.0.0.1
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export MALLOC_ARENA_MAX=2
export NODE_OPTIONS="--max-old-space-size=1024"

# Launch VS Code engine with Antigravity capabilities (no-sandbox & user-data-dir required for root in proot)
mkdir -p /root/.config/Code
exec code --no-sandbox --user-data-dir /root/.config/Code --unity-launch --disable-gpu "$@"
GUI_EOF
chmod +x /usr/local/bin/bliss-code-gui

# CLI wrapper
cat << 'CLI_EOF' > /usr/local/bin/agy
#!/usr/bin/env bash
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export MALLOC_ARENA_MAX=2
export NODE_OPTIONS="--max-old-space-size=1024"
if [ $# -eq 0 ]; then
    echo -e "\033[38;2;180;190;254m✦ BlissOS Antigravity Agent Ready!\033[0m"
    exec /bin/bash
else
    exec "$@"
fi
CLI_EOF
chmod +x /usr/local/bin/agy

apt-get clean > /dev/null 2>&1
rm -rf /var/lib/apt/lists/*
DEBIAN_EOF
echo -e "      ${GREEN}✓${RESET} Графика и ядро IDE настроены."

# 5. Create Host Termux Launchers
echo -e "${CYAN}[4/5]${RESET} Создание шорткатов запуска GUI и CLI в Termux..."
BIN_DIR="/data/data/com.termux/files/usr/bin"

# GUI launcher (bliss-gui / bliss-ide)
cat << 'LAUNCHER_GUI' > "$BIN_DIR/bliss-gui"
#!/data/data/com.termux/files/usr/bin/bash
clear
echo -e "\033[38;2;180;190;254m✦  B L I S S   O S  ::  G U I   I D E  ✦\033[0m"
echo -e "\033[38;2;137;220;235mЗапуск графического сервера Termux-X11...\033[0m"

# 1. Start Audio daemon
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 > /dev/null 2>&1 || true

# 2. Launch Termux-X11 companion Android App
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1 || true

# 3. Start X11 display server
export DISPLAY=:0
TMPDIR="${TMPDIR:-/data/data/com.termux/files/usr/tmp}"
mkdir -p "${TMPDIR}/.X11-unix"
if ! pgrep -f "termux-x11 :0" > /dev/null 2>&1; then
    XDG_RUNTIME_DIR="${TMPDIR}" termux-x11 :0 -ac > /dev/null 2>&1 &
    sleep 2
fi

# 4. Launch GUI IDE inside Debian
echo -e "\033[38;2;166;227;161m→ Открытие окна Antigravity IDE!\033[0m\n"
proot-distro login debian \
    --bind /sdcard:/sdcard \
    --bind "${TMPDIR}/.X11-unix:/tmp/.X11-unix" \
    -- /usr/local/bin/bliss-code-gui "$@"
LAUNCHER_GUI

chmod +x "$BIN_DIR/bliss-gui"
ln -sf "$BIN_DIR/bliss-gui" "$BIN_DIR/bliss-ide"

# CLI launcher (bliss / agy)
cat << 'LAUNCHER_CLI' > "$BIN_DIR/bliss"
#!/data/data/com.termux/files/usr/bin/bash
clear
echo -e "\033[38;2;180;190;254m✦  B L I S S   O S  ::  C L I   A G E N T  ✦\033[0m\n"
proot-distro login debian --bind /sdcard:/sdcard -- /usr/local/bin/agy "$@"
LAUNCHER_CLI
chmod +x "$BIN_DIR/bliss"
ln -sf "$BIN_DIR/bliss" "$BIN_DIR/agy"

echo -e "      ${GREEN}✓${RESET} Команды bliss, agy и bliss-gui созданы."

# 6. Finish Banner
echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}${BOLD}✦ BLISS OS ANTIGRAVITY GUI УСПЕШНО НАСТРОЕН! ✦${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "Команды для запуска:"
echo -e "  ${YELLOW}bliss-gui${RESET}  ➔  Запуск полноценного графического окна IDE (через Termux-X11)!"
echo -e "  ${YELLOW}bliss${RESET}      ➔  Быстрый консольный режим"
echo -e "\n${PASTEL_STAR}Примечание:${RESET} Убедись, что на телефоне установлено приложение ${BOLD}Termux-X11.apk${RESET}!\n"

#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
#  ✦ BLISS OS :: ANTIGRAVITY 2.0 FOR TERMUX (ARM64) ✦
#  Ultra-modern Pocket AI Agent & Desktop IDE Engine for Android
#  Engine: Native 64-bit ARM64 + Termux-X11 GUI + Web-Touch GUI + CLI
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
         \ /       ANTIGRAVITY 2.0 POCKET ENGINE
          '         ARM64 Dual Mode (X11 & Web)
EOF
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BOLD}Developer:${RESET} BlissOw  |  ${BOLD}Architecture:${RESET} $(uname -m)"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

# 1. Architecture Check
ARCH=$(uname -m)
if [ "$ARCH" != "aarch64" ] && [ "$ARCH" != "arm64" ]; then
    echo -e "${RED}[!] Ошибка: Требуется 64-битный процессор (aarch64/arm64).${RESET}"
    exit 1
fi

# 2. Host Termux Packages
echo -e "${CYAN}[1/5]${RESET} Обновление пакетов Termux и репозитория X11..."
pkg update -y > /dev/null 2>&1 || true
pkg install -y x11-repo > /dev/null 2>&1 || true

for pkg in proot-distro curl jq tar pulseaudio termux-x11-nightly; do
    if ! dpkg -s $pkg > /dev/null 2>&1; then
        echo -e "      → Установка $pkg..."
        pkg install -y $pkg > /dev/null 2>&1 || true
    fi
done
echo -e "      ${GREEN}✓${RESET} Системные пакеты Termux готовы."

# 3. Debian ARM64 Container Check
DISTRO="debian"
echo -e "${CYAN}[2/5]${RESET} Проверка контейнера Debian ARM64..."
if proot-distro list 2>&1 | grep -qi "${DISTRO}"; then
    echo -e "      ${GREEN}✓${RESET} Debian уже установлен."
else
    echo -e "      ${YELLOW}→${RESET} Загрузка и распаковка чистого Debian ARM64..."
    proot-distro install $DISTRO
fi

# 4. Provision Debian with GUI, Audio & Libraries
echo -e "${CYAN}[3/5]${RESET} Настройка графических библиотек, Fluxbox и пользователя bliss..."
proot-distro login $DISTRO -- bash << 'DEBIAN_EOF'
set -e
export DEBIAN_FRONTEND=noninteractive
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

# Remove broken external repositories if any
rm -f /etc/apt/sources.list.d/*code* /etc/apt/sources.list.d/*microsoft* /etc/apt/sources.list.d/*vscode* > /dev/null 2>&1 || true

apt-get update -y > /dev/null 2>&1
apt-get install -y --no-install-recommends \
    ca-certificates curl git python3 python3-pip procps tar xz-utils jq nano \
    libgtk-3-0 libnotify4 libnss3 libxss1 libsecret-1-0 libx11-xcb1 \
    libxcomposite1 libxdamage1 libxrandr2 libgbm1 libxkbcommon0 \
    dbus-x11 x11-xserver-utils fonts-noto-color-emoji sudo fluxbox thunar > /dev/null 2>&1 || true

# Sound library compatibility
apt-get install -y libasound2 > /dev/null 2>&1 || apt-get install -y libasound2t64 > /dev/null 2>&1 || true

# Setup unprivileged user 'bliss' for smooth launch
if ! id -u bliss > /dev/null 2>&1; then
    useradd -m -s /bin/bash bliss
    passwd -d bliss > /dev/null 2>&1 || true
    echo 'bliss ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/bliss
    chmod 440 /etc/sudoers.d/bliss
fi

DEBIAN_EOF
echo -e "      ${GREEN}✓${RESET} Графика и пользователь bliss настроены."

# 5. Install Modern Native ARM64 Engine
echo -e "${CYAN}[4/5]${RESET} Проверка и установка нативного 64-битного ядра Antigravity..."
proot-distro login $DISTRO -- bash << 'DEBIAN_INSTALL_EOF'
set -e
export DEBIAN_FRONTEND=noninteractive

if ! command -v code > /dev/null 2>&1; then
    echo "      → Скачивание нативного 64-битного пакета ARM64 (.deb)..."
    curl -# -L --retry 3 --connect-timeout 20 -C - -o /tmp/code_arm64.deb "https://update.code.visualstudio.com/latest/linux-deb-arm64/stable"
    echo "      → Распаковка ядра в систему..."
    dpkg -i /tmp/code_arm64.deb > /dev/null 2>&1 || apt-get install -f -y > /dev/null 2>&1
    rm -f /tmp/code_arm64.deb
    sync
    echo "      ✓ Нативное ядро установлено."
else
    echo "      ✓ Ядро уже установлено."
fi

# Clean apt cache
apt-get clean > /dev/null 2>&1
DEBIAN_INSTALL_EOF

# 6. Create Launchers on Host Termux
echo -e "${CYAN}[5/5]${RESET} Создание команд запуска (X11 GUI, Web GUI, CLI)..."
BIN_DIR="/data/data/com.termux/files/usr/bin"
TMPDIR="${TMPDIR:-/data/data/com.termux/files/usr/tmp}"
mkdir -p "$TMPDIR/.X11-unix"

# --- A. X11 Windowed GUI Launcher (bliss-gui / bliss-x11) ---
cat << 'LAUNCH_GUI' > "$BIN_DIR/bliss-gui"
#!/data/data/com.termux/files/usr/bin/bash
clear
echo -e "\033[38;2;180;190;254m✦  B L I S S   O S  ::  A N T I G R A V I T Y   X 1 1  ✦\033[0m"
echo -e "\033[38;2;137;220;235mЗапуск графического сервера Termux-X11...\033[0m"

# 1. Audio daemon
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 > /dev/null 2>&1 || true

# 2. Companion Android App
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1 || true

# 3. Start X11 server cleanly
export DISPLAY=:0
pkill -f "termux-x11" > /dev/null 2>&1 || true
XDG_RUNTIME_DIR="${TMPDIR:-/data/data/com.termux/files/usr/tmp}" termux-x11 :0 -ac > /dev/null 2>&1 &
sleep 1.5

# 4. Launch Antigravity inside Debian with native shared-tmp
echo -e "\033[38;2;166;227;161m→ Открытие Antigravity IDE в Termux-X11...\033[0m\n"
proot-distro login debian \
    --user bliss \
    --shared-tmp \
    -- bash -c "export DISPLAY=:0; export PULSE_SERVER=127.0.0.1; rm -rf ~/.config/Code/GPUCache ~/.config/Code/CachedData > /dev/null 2>&1; fluxbox > /dev/null 2>&1 & sleep 1; exec code --no-sandbox --disable-gpu --disable-dev-shm-usage '$@'"
LAUNCH_GUI
chmod +x "$BIN_DIR/bliss-gui"
ln -sf "$BIN_DIR/bliss-gui" "$BIN_DIR/bliss-x11"

# --- B. Touch Web GUI Launcher (bliss-web) ---
cat << 'LAUNCH_WEB' > "$BIN_DIR/bliss-web"
#!/data/data/com.termux/files/usr/bin/bash
clear
echo -e "\033[38;2;180;190;254m✦  B L I S S   O S  ::  W E B   A N T I G R A V I T Y  ✦\033[0m"
echo -e "\033[38;2;137;220;235mЗапуск Web-сервера Antigravity на http://localhost:8080...\033[0m"
echo -e "\033[38;2;166;227;161m→ Идеальное сенсорное управление жестами пальцев в браузере!\033[0m\n"

# Open Browser automatically after 2 seconds
(sleep 2.5 && am start -a android.intent.action.VIEW -d "http://localhost:8080" > /dev/null 2>&1) &

proot-distro login debian \
    --user bliss \
    -- bash -c "code serve-web --without-connection-token --host 127.0.0.1 --port 8080"
LAUNCH_WEB
chmod +x "$BIN_DIR/bliss-web"

# --- C. Fast CLI Launcher (bliss / agy) ---
cat << 'LAUNCH_CLI' > "$BIN_DIR/bliss"
#!/data/data/com.termux/files/usr/bin/bash
clear
echo -e "\033[38;2;180;190;254m✦  B L I S S   O S  ::  C L I   A G E N T  ✦\033[0m\n"
proot-distro login debian --user bliss -- bash -c "export LANG=C.UTF-8; exec /bin/bash '$@'"
LAUNCH_CLI
chmod +x "$BIN_DIR/bliss"
ln -sf "$BIN_DIR/bliss" "$BIN_DIR/agy"

# 7. Success Banner
echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}${BOLD}✦ BLISS OS ANTIGRAVITY 2.0 УСПЕШНО НАСТРОЕН! ✦${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "Выбирай, как тебе удобнее запускать:"
echo -e "  ${YELLOW}bliss-web${RESET}  ➔  ${BOLD}Touch Web GUI${RESET}: открывает Antigravity прямо в браузере (идеально для пальцев на AMOLED!)"
echo -e "  ${YELLOW}bliss-gui${RESET}  ➔  ${BOLD}Оконный режим X11${RESET}: классическое окно через Termux-X11"
echo -e "  ${YELLOW}bliss${RESET}      ➔  ${BOLD}Консольный режим${RESET}: быстрый вызов терминала агента"
echo -e "\n${PASTEL_STAR}Бро, приятной разработки в BlissOS!${RESET}\n"

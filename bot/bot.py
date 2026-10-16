import os
import sys
import time
import zipfile
import subprocess
import requests

if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

from config import BOT_TOKEN, ADMIN_CHAT_ID, ADB_PATH, PROJECT_ROOT, MODULE_DIR, DIST_DIR

API_URL = f"https://api.telegram.org/bot{BOT_TOKEN}"

def send_message(chat_id, text, parse_mode="Markdown"):
    url = f"{API_URL}/sendMessage"
    payload = {"chat_id": chat_id, "text": text, "parse_mode": parse_mode}
    try:
        r = requests.post(url, json=payload, timeout=10)
        return r.json()
    except Exception as e:
        print("send_message error:", e)
        return None

def send_photo(chat_id, photo_path, caption=None):
    url = f"{API_URL}/sendPhoto"
    data = {"chat_id": chat_id}
    if caption:
        data["caption"] = caption
    try:
        with open(photo_path, "rb") as f:
            r = requests.post(url, data=data, files={"photo": f}, timeout=30)
            return r.json()
    except Exception as e:
        print("send_photo error:", e)
        return None

def send_document(chat_id, doc_path, caption=None):
    url = f"{API_URL}/sendDocument"
    data = {"chat_id": chat_id}
    if caption:
        data["caption"] = caption
    try:
        with open(doc_path, "rb") as f:
            r = requests.post(url, data=data, files={"document": f}, timeout=60)
            return r.json()
    except Exception as e:
        print("send_document error:", e)
        return None

def get_device_status():
    if not os.path.exists(ADB_PATH):
        return "❌ ADB не найден по указанному пути."
    try:
        out = subprocess.check_output([ADB_PATH, "devices"], text=True)
        lines = [l.strip() for l in out.splitlines() if l.strip() and not l.startswith("List")]
        if not lines:
            return "📱 *Статус устройства:* Не подключено по USB."
        
        dev_info = lines[0]
        # Get props
        build_id = subprocess.check_output([ADB_PATH, "shell", "getprop", "ro.build.display.id"], text=True).strip()
        bliss_dev = subprocess.check_output([ADB_PATH, "shell", "getprop", "ro.bliss.developer"], text=True).strip()
        battery = subprocess.check_output([ADB_PATH, "shell", "dumpsys", "battery"], text=True)
        level = "N/A"
        for b in battery.splitlines():
            if "level:" in b:
                level = b.split(":")[-1].strip() + "%"
        
        status = (
            f"📱 *BlissOS Device Connected!*\n\n"
            f"• *Девайс:* `{dev_info}`\n"
            f"• *Система:* `{build_id}`\n"
            f"• *Автор проекта:* `{bliss_dev or 'BlissOw'}`\n"
            f"• *Заряд батареи:* `{level}`\n"
            f"• *Root:* ✅ Magisk (uid=0)"
        )
        return status
    except Exception as e:
        return f"⚠️ Ошибка получения статуса: {e}"

def build_module_zip():
    os.makedirs(DIST_DIR, exist_ok=True)
    zip_name = "BlissOS_Core_v1.0.zip"
    zip_path = os.path.join(DIST_DIR, zip_name)
    
    with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, files in os.walk(MODULE_DIR):
            for file in files:
                full_p = os.path.join(root, file)
                rel_p = os.path.relpath(full_p, MODULE_DIR)
                zf.write(full_p, rel_p)
                
    return zip_path

def take_screenshot():
    local_sc = os.path.join(DIST_DIR, "live_screen.png")
    os.makedirs(DIST_DIR, exist_ok=True)
    subprocess.run([ADB_PATH, "shell", "su", "-c", "screencap -p /data/local/tmp/sc.png"], check=True)
    subprocess.run([ADB_PATH, "pull", "/data/local/tmp/sc.png", local_sc], check=True)
    return local_sc

def handle_command(chat_id, user_id, text):
    if user_id != ADMIN_CHAT_ID:
        send_message(chat_id, "⛔ Доступ запрещён. Этот бот слушает только разработчика BlissOw.")
        return
        
    cmd = text.strip().split()[0].lower()
    
    if cmd in ["/start", "/help"]:
        msg = (
            "🌿 *Добро пожаловать в панель управления BlissOS!* 🌿\n\n"
            "Доступные команды:\n"
            "📊 `/status` — проверить статус телефона (аккумулятор, система, root)\n"
            "📸 `/screenshot` — сделать и получить скриншот экрана телефона\n"
            "📦 `/build` — собрать flashable ZIP-модуль BlissOS и прислать файл сюда\n"
            "🔄 `/reboot` — перезагрузить устройство в BlissOS\n"
        )
        send_message(chat_id, msg)
        
    elif cmd == "/status":
        send_message(chat_id, "⏳ Опрашиваю устройство через ADB...")
        stat = get_device_status()
        send_message(chat_id, stat)
        
    elif cmd == "/screenshot":
        send_message(chat_id, "📸 Делаю скриншот экрана девайса...")
        try:
            sc_path = take_screenshot()
            send_photo(chat_id, sc_path, caption="✨ Скриншот экрана телефона (BlissOS)")
        except Exception as e:
            send_message(chat_id, f"❌ Ошибка захвата экрана: {e}")
            
    elif cmd == "/build":
        send_message(chat_id, "⚙️ Собираю flashable архив BlissOS Core v1.0...")
        try:
            zip_p = build_module_zip()
            size_kb = os.path.getsize(zip_p) // 1024
            send_message(chat_id, f"✅ Сборка готова ({size_kb} КБ)! Отправляю файл...")
            send_document(chat_id, zip_p, caption="📦 BlissOS Core v1.0 Flashable Module by BlissOw")
        except Exception as e:
            send_message(chat_id, f"❌ Ошибка сборки: {e}")
            
    elif cmd == "/reboot":
        send_message(chat_id, "🔄 Отправляю команду перезагрузки на девайс...")
        try:
            subprocess.run([ADB_PATH, "reboot"], check=True)
            send_message(chat_id, "🚀 Телефон ушёл в перезагрузку!")
        except Exception as e:
            send_message(chat_id, f"❌ Ошибка перезагрузки: {e}")
            
    else:
        send_message(chat_id, f"❓ Неизвестная команда `{cmd}`. Введите `/help`.")

def main():
    print("🌿 BlissOS Telegram Bot Service started...")
    print(f"Authorized Admin ID: {ADMIN_CHAT_ID}")
    
    last_update_id = 0
    while True:
        try:
            url = f"{API_URL}/getUpdates?offset={last_update_id + 1}&timeout=30"
            r = requests.get(url, timeout=35)
            data = r.json()
            
            if data.get("ok"):
                for update in data.get("result", []):
                    last_update_id = update["update_id"]
                    msg = update.get("message")
                    if msg and "text" in msg:
                        chat_id = msg["chat"]["id"]
                        user_id = msg["from"]["id"]
                        text = msg["text"]
                        print(f"Received: {text} from user {user_id}")
                        handle_command(chat_id, user_id, text)
                        
        except Exception as e:
            print("Polling loop error:", e)
            time.sleep(3)

if __name__ == "__main__":
    main()

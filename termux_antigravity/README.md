# ✦ BlissOS Antigravity for Termux (GUI & CLI) ✦
> **Pocket AI Agent & Full Desktop IDE Engine for Android (Termux-X11 + Debian)**  
> *Crafted by BlissOw (github.com/BlissOw)*

---

## ⚡ Описание
**BlissOS Antigravity Edition** превращает твой Android-смартфон в полноценную портативную станцию разработки:
* **Графический режим (GUI):** запускает настоящее окно IDE с вкладками, файловым проводником и подсветкой синтаксиса через **Termux-X11**! В режиме рабочего стола (Desktop Mode) на Axion OS это выглядит как настольный монитор.
* **Консольный режим (CLI):** сверхбыстрый вызов через команду `bliss` или `agy` в терминале.
* **Оптимизация под 4 ГБ RAM:** лимиты `MALLOC_ARENA_MAX=2` и `NODE_OPTIONS` предотвращают перегрев и вылеты на процессорах Qualcomm Snapdragon.
* **Монтирование хранилища:** внутренний накопитель `/sdcard` подключен напрямую.

---

## 🚀 Установка

### Шаг 1. Скачай приложение Termux-X11 на телефон:
Для вывода графического окна нужно официальное приложение **Termux-X11**:
* [Скачать Termux-X11 APK (GitHub Releases)](https://github.com/termux/termux-x11/releases) *(файл `app-arm64-v8a-debug.apk`)*

### Шаг 2. Запусти команду установки в Termux:
```bash
curl -sSL https://raw.githubusercontent.com/BlissOw/BlissOS/main/termux_antigravity/install.sh | bash
```

---

## 🎮 Как запускать

* **Графическое окно IDE:**
  ```bash
  bliss-gui
  ```
  *(Termux сам автоматически откроет окно Termux-X11, запустит аудио-сервер и откроет редактор!)*

* **Консольный терминальный режим:**
  ```bash
  bliss
  ```
  или
  ```bash
  agy
  ```

# ✦ BlissOS Antigravity 2.0 for Termux (ARM64) ✦
> **Pocket AI Agent & Dual-Engine IDE for Android (Termux-X11 + Touch Web GUI)**  
> *Crafted by BlissOw (github.com/BlissOw)*

---

## ⚡ Описание
**BlissOS Antigravity 2.0 Edition** превращает твой Android-смартфон в полноценную портативную станцию разработки на нативной 64-битной архитектуре (AArch64):
* **Сенсорный Web-режим (`bliss-web`):** Запускает Antigravity IDE прямо в браузере телефона (Chrome/Edge/Firefox) на `http://localhost:8080`. Идеально для управления пальцами на AMOLED-экране, высокая плавность жестов без возни с курсором мыши!
* **Графический режим X11 (`bliss-gui`):** Запускает настольное окно со всеми панелями и оконным менеджером Fluxbox через **Termux-X11**. В режиме рабочего стола (Desktop Mode) ощущается как полноценный компьютер.
* **Консольный режим CLI (`bliss` / `agy`):** Сверхбыстрый вызов шелла Debian glibc в терминале.
* **Пользователь `bliss`:** Настроен непривилегированный пользователь с правами `sudo`, убирающий ошибки песочницы root.
* **Оптимизация:** Автоматическое подключение звука PulseAudio и хранилища `/sdcard`.

---

## 🚀 Установка в одну команду:

Вставь в Termux:
```bash
curl -sSL -H 'Cache-Control: no-cache' "https://raw.githubusercontent.com/BlissOw/BlissOS/main/termux_antigravity/install.sh?$(date +%s)" | bash
```

---

## 🎮 Как запускать:

* **Сенсорный режим в браузере (Рекомендуется для пальцев!):**
  ```bash
  bliss-web
  ```
  *(Termux запустит сервер и сам откроет браузер с полноценной Antigravity IDE)*.

* **Оконный режим Termux-X11:**
  ```bash
  bliss-gui
  ```
  *(Нужно установленное приложение [Termux-X11 APK](https://github.com/termux/termux-x11/releases))*.

* **Консольный режим:**
  ```bash
  bliss
  ```

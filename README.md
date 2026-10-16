# 🌿 BlissOS (BlissOw Edition)

> **Pure Minimalist, High-Aesthetic Android System & Custom ROM.**
> Designed by **BlissOw** | Powered by **AxionAOSP & LineageOS** foundations.

---

## ✨ Overview

**BlissOS** is an ultra-clean, serene Android experience designed to eliminate eye-strain and visual fatigue. Built upon the principles of modern design systems (*Material 3 Expressive, AviumUI, and AxionOS*), BlissOS replaces harsh, aggressive gaming aesthetics with warm cream/clay tones, frosted glass surfaces, and subtle, fluid micro-interactions.

---

## 🎨 Key Features

* **Calm Aesthetic Identity:**
  * Curated pastel & organic clay palette (terracotta, slate blue, warm sand).
  * Minimalist, cinematic bootanimation: breathing white `b l i s s` typography on deep AMOLED black.
* **AxPC & Productivity Integration:**
  * Freeform multi-window desktop interface on device screen (inspired by AxionOS AxPC mode).
  * Native taskbar and fluid window scaling.
* **Systemless Core Architecture:**
  * 100% systemless Magisk module integration (`ro.build.display.id`, `system.prop`, `service.sh`).
  * Patched AVB 2.0 / `init_boot` deployment via `fastbootd`.
  * Reverse-engineered vendor anti-tamper checksum bypass for Unisoc / DokeOS.
* **Remote Cloud Build & Telegram Bot:**
  * Integrated Telegram control center (`@BlissOwbot`) to monitor, manage, and build system packages remotely.

---

## 🤖 Telegram Bot Commands (`@BlissOwbot`)

| Command | Action |
|---|---|
| `/status` | Query live device health (Battery, BlissOS build ID, root status) |
| `/screenshot` | Instantly capture device screen and stream the image to Telegram |
| `/build` | Package flashable `BlissOS_Core_v1.0.zip` and deliver directly to chat |
| `/reboot` | Safely reboot device into BlissOS |

---

## 🛠️ Repository Structure

```text
BlissOS/
├── bot/                # Telegram remote bot & cloud builder controller
│   ├── bot.py
│   └── config.py
├── module/             # Magisk Systemless Core module
│   ├── module.prop
│   ├── system.prop
│   ├── service.sh
│   ├── wallpaper.png
│   └── system/media/bootanimation.zip
├── .github/workflows/  # Cloud CI/CD compilation pipelines
└── dist/               # Built release artifacts & flashable ZIPs
```

---

## 👨‍💻 Authors & Credits

* **BlissOw** — Creator, Lead Designer & Maintainer ([GitHub](https://github.com/BlissOw))
* Special thanks to the **AxionAOSP** and **AviumUI** open-source communities.

import os

# Telegram Configuration
BOT_TOKEN = os.getenv("BOT_TOKEN", "8690978655:AAHrPby4687HjOaaQEuv91REcxEAElP_qiw")
ADMIN_CHAT_ID = int(os.getenv("CHAT_ID", "8382156608"))

# ADB path
ADB_PATH = r"D:\Projects\platform-tools\adb.exe"

# Project paths
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
MODULE_DIR = os.path.join(PROJECT_ROOT, "module")
DIST_DIR = os.path.join(PROJECT_ROOT, "dist")

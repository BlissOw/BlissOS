import os

# Load variables from local .env file (NEVER committed to git)
env_path = os.path.join(os.path.dirname(__file__), '.env')
if os.path.exists(env_path):
    with open(env_path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if '=' in line and not line.startswith('#'):
                k, v = line.split('=', 1)
                os.environ[k.strip()] = v.strip().strip('"').strip("'")

BOT_TOKEN = os.getenv('BOT_TOKEN', '')
ADMIN_CHAT_ID = int(os.getenv('CHAT_ID', '8382156608'))

# Safe forward-slashes for Windows path to avoid escape character bugs ( -> bell)
ADB_PATH = "D:/Projects/platform-tools/adb.exe"

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
MODULE_DIR = os.path.join(PROJECT_ROOT, 'module')
DIST_DIR = os.path.join(PROJECT_ROOT, 'dist')

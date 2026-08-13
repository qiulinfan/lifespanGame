#!/bin/zsh

set -e
project_root=${0:A:h}
cd "$project_root"
python3 tools/sync_content.py
echo "Game content is ready. Restart Play in PocketEngine to reload it."

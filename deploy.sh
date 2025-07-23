#!/usr/bin/env bash

set -euo pipefail

# Ensure SCRIPT_PATH is defined even if BASH_SOURCE is not
SCRIPT_PATH="${BASH_SOURCE[0]:-$(realpath "$0")}"
REPO_DIR="$(dirname "$(readlink -f "$SCRIPT_PATH")")"
TARGET_DIR="$HOME/.local/share/nautilus/scripts"

mkdir -p "$TARGET_DIR"

echo "🔄 Deploying scripts from: $REPO_DIR"
echo "➡️  To Nautilus scripts directory: $TARGET_DIR"
echo

count=0
skipped=0

for script in "$REPO_DIR"/*.bash; do
  [ -e "$script" ] || continue

  filename="$(basename "$script")"

  if [[ "$filename" != *_* ]]; then
    echo "⏭️  Skipping: $filename (no underscores in name)"
    ((skipped++))
    continue
  fi

  base="${filename%.bash}"
  display_name="${base//_/ }"
  dest="$TARGET_DIR/$display_name"

  cp "$script" "$dest"
  chmod +x "$dest"
  echo "✅ Installed: $display_name"
  ((count++))
done

echo
echo "✅ Deployed: $count script(s)"
echo "⏭️  Skipped: $skipped script(s)"
echo "📁 Right-click in GNOME Files → Scripts to access them."

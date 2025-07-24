#!/bin/bash

set -euo pipefail

if [ $# -eq 0 ]; then
  zenity --error --text="No directory selected!"
  exit 1
fi

if ! command -v zstd >/dev/null; then
  zenity --error --text="zstd is not installed."
  exit 1
fi

if ! command -v pv >/dev/null; then
  zenity --error --text="pv is not installed."
  exit 1
fi

for SRC in "$@"; do
  if [ ! -d "$SRC" ]; then
    zenity --error --text="\"$SRC\" is not a directory."
    continue
  fi

  DIR_PATH="$(dirname "$SRC")"
  DIR_NAME="$(basename "$SRC")"
  FINAL_PATH="${DIR_PATH}/${DIR_NAME}.tar.zst"
  TIMESTAMP=$(date +%Y%m%d_%H%M%S_$$)
  TEMP_PATH="${FINAL_PATH}.${TIMESTAMP}.partial"
  
  # Cleanup function
  cleanup() {
    if [ -f "$TEMP_PATH" ]; then
      rm -f "$TEMP_PATH" 2>/dev/null || true
    fi
  }
  trap cleanup EXIT INT TERM

  SIZE_BYTES=$(du -sb "$SRC" | awk '{print $1}')

  # Run compression pipeline
  (
    tar --blocking-factor=64 -cf - -C "$DIR_PATH" "$DIR_NAME" |
      pv -s "$SIZE_BYTES" |
      zstd -T0 -9 -o "$TEMP_PATH"
  ) 2>&1 | zenity --progress \
    --title="Compressing $DIR_NAME" \
    --text="Creating ${DIR_NAME}.tar.zst..." \
    --pulsate \
    --auto-close

  if [ ${PIPESTATUS[0]} -eq 0 ]; then
    # Ensure all data is written to disk
    sync
    
    # Validate the archive before moving
    if zstd -t "$TEMP_PATH" 2>/dev/null; then
      mv "$TEMP_PATH" "$FINAL_PATH"
      trap - EXIT INT TERM  # Remove trap since we succeeded
      zenity --info --text="Compressed to:\n$FINAL_PATH"
    else
      zenity --error --text="Archive validation failed!\nThe compressed file appears corrupted."
      # cleanup will run via trap
    fi
  else
    zenity --error --text="Compression failed for:\n$SRC"
    # cleanup will run via trap
  fi
done

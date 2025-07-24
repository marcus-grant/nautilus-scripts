#!/bin/bash

set -e

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
  TEMP_PATH="${FINAL_PATH}.partial"

  SIZE_BYTES=$(du -sb "$SRC" | awk '{print $1}')

  (
    tar --blocking-factor=64 -cf - -C "$DIR_PATH" "$DIR_NAME" |
      pv -s "$SIZE_BYTES" |
      zstd -T0 -9 -o "$TEMP_PATH"
  ) | zenity --progress \
    --title="Compressing $DIR_NAME" \
    --text="Creating ${DIR_NAME}.tar.zst..." \
    --percentage=0 \
    --auto-close

  if [ $? -eq 0 ]; then
    mv "$TEMP_PATH" "$FINAL_PATH"
    zenity --info --text="✅ Compressed to:\n$FINAL_PATH"
  else
    rm -f "$TEMP_PATH"
    zenity --error --text="❌ Compression failed for:\n$SRC"
  fi
done

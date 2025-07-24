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
  
  # Create log directory and file
  LOG_DIR="/tmp/nautilus_compress_logs"
  mkdir -p "$LOG_DIR"
  LOG_FILE="$LOG_DIR/compress_${DIR_NAME}_${TIMESTAMP}.log"
  
  # Start logging
  echo "=== Compression Log ===" > "$LOG_FILE"
  echo "Date: $(date)" >> "$LOG_FILE"
  echo "Source: $SRC" >> "$LOG_FILE"
  echo "Target: $FINAL_PATH" >> "$LOG_FILE"
  echo "Size: $(du -sh "$SRC" | cut -f1)" >> "$LOG_FILE"
  echo "" >> "$LOG_FILE"
  
  # Cleanup function
  cleanup() {
    if [ -f "$TEMP_PATH" ]; then
      rm -f "$TEMP_PATH" 2>/dev/null || true
    fi
  }
  trap cleanup EXIT INT TERM

  SIZE_BYTES=$(du -sb "$SRC" | awk '{print $1}')

  # Run compression pipeline
  echo "Starting compression..." >> "$LOG_FILE"
  (
    tar --blocking-factor=64 -cf - -C "$DIR_PATH" "$DIR_NAME" 2>> "$LOG_FILE" |
      pv -s "$SIZE_BYTES" 2>> "$LOG_FILE" |
      zstd -T0 -9 -o "$TEMP_PATH" 2>> "$LOG_FILE"
  ) 2>&1 | zenity --progress \
    --title="Compressing $DIR_NAME" \
    --text="Creating ${DIR_NAME}.tar.zst..." \
    --pulsate \
    --auto-close

  if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "Compression completed, syncing..." >> "$LOG_FILE"
    # Ensure all data is written to disk
    sync
    
    # Validate the archive before moving
    echo "Validating archive..." >> "$LOG_FILE"
    if zstd -t "$TEMP_PATH" 2>> "$LOG_FILE"; then
      mv "$TEMP_PATH" "$FINAL_PATH"
      trap - EXIT INT TERM  # Remove trap since we succeeded
      echo "SUCCESS: Archive created at $FINAL_PATH" >> "$LOG_FILE"
      echo "Final size: $(du -sh "$FINAL_PATH" | cut -f1)" >> "$LOG_FILE"
      zenity --info --text="Compressed to:\n$FINAL_PATH\n\nLog: $LOG_FILE"
    else
      echo "ERROR: Archive validation failed!" >> "$LOG_FILE"
      zenity --error --text="Archive validation failed!\nThe compressed file appears corrupted.\n\nLog: $LOG_FILE"
      # cleanup will run via trap
    fi
  else
    echo "ERROR: Compression pipeline failed!" >> "$LOG_FILE"
    zenity --error --text="Compression failed for:\n$SRC\n\nLog: $LOG_FILE"
    # cleanup will run via trap
  fi
done

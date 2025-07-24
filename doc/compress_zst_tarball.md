# Nautilus Script: Compress zst tarball

This script compresses a selected directory into a `.tar.zst` archive with
progress indication and safety measures to avoid partial or corrupted files.

## Script File

Filename: `Compress_zst_tarball.bash`  
Menu label in Nautilus: **Compress zst tarball**

## Features

- Compresses a directory into `.tar.zst`
- Shows progress using `zenity` and `pv`
- Uses a `.partial` temp file to prevent incomplete results
- Automatically renames `.partial` to final `.tar.zst` after success

## Requirements

- `zstd`
- `pv`
- `zenity`

Install with:

```bash
sudo apt install zstd pv zenity
```

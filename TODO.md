# TODO: Compression Script Issues

## Current Problems

### 🐌 Progress Bar Ineffectiveness

- `zenity --progress` remains mostly empty during compression.
- Likely caused by `tar` buffering output heavily, especially for many small files.
- Even with `--blocking-factor=64`, it’s not consistently useful.
- Need a better way to measure and indicate progress
  - (e.g., per-file progress or alternative frontend).

### ⚠️ Phantom/Incomplete `.partial` Files

- After compression appears "complete", `.partial` file:
  - Remains in place and undeletable (`Input/output error`)
  - Appears with wrong size (e.g., 5.7GB vs expected ~24GB)
  - Cannot be opened in Nautilus: “File is of unknown type”
- Indicates the pipeline may crash, hang, or not fully close the file descriptor.

## Next Steps

- Investigate if `zstd` or `pv` hangs silently under specific conditions
  - (e.g., full disk, drive sleep).
- Log compression stdout/stderr to a temp file for debugging.
- Consider writing to a safe local path first, then copying to destination.
- Explore `tar --sparse` and `zstd --long` flags for large inputs.
- Add timestamp-based `.partial` filenames to avoid collision or stale state.
- Test against other drives and filesystems (ext4 vs NTFS/FAT).

## Potential Long-Term Improvements

- Replace `zenity --progress` with a custom GTK dialog or CLI TUI.
- Track individual file compression with `find` + `tar --files-from`.
- Use systemd-run or at least subshell with
  `set -o pipefail` for more robust process detection.

# TODO: Compression Script Fixes

## Remaining Issues to Fix

### 1. Silent Failure on Read-Only Directories
**Problem**: Progress dialog disappears without error when target is read-only
**Tasks**:
- [ ] Check write permissions before starting compression
- [ ] Show proper error dialog when output file can't be created
- [ ] Test with various permission scenarios

### 2. Progress Bar Percentage
**Problem**: Currently using --pulsate, not showing actual percentage
**Tasks**:
- [ ] Implement proper percentage parsing from pv
- [ ] Consider alternative progress tracking methods
- [ ] Test with large files to ensure smooth progress updates

## Original Issues (For Reference)

### 1. Error Handling & Pipeline Failures
**Problem**: Pipeline can fail silently, leaving phantom .partial files
**Tasks**:
- [ ] Add `set -o pipefail` to catch errors in tar|pv|zstd pipeline
- [ ] Implement trap cleanup function to remove .partial files on failure/interrupt
- [ ] Check exit codes for each command in pipeline separately
- [ ] Add proper error messages indicating which component failed

### 2. Phantom .partial Files
**Problem**: .partial files remain undeletable with I/O errors
**Tasks**:
- [ ] Add `sync` command after compression to ensure data is written
- [ ] Check available disk space before starting compression
- [ ] Use unique timestamp-based temp filenames to avoid collisions
- [ ] Implement file validation after compression (check if archive is valid)
- [ ] Add fallback cleanup with `lsof` check for open file handles

### 3. Progress Bar Issues
**Problem**: zenity progress stays empty, pv output not properly parsed
**Tasks**:
- [ ] Fix pv output parsing - extract percentage from stderr
- [ ] Use named pipe (FIFO) to properly communicate progress to zenity
- [ ] Add fallback progress based on file count (for many small files)
- [ ] Consider showing dual progress: files processed + data compressed

## Medium Priority Improvements

### 4. Debugging & Logging
**Tasks**:
- [ ] Create log file in `/tmp` for each compression operation
- [ ] Log start time, parameters, and all stderr output
- [ ] Add verbose mode option to show detailed progress
- [ ] Include system info in logs (disk space, memory, etc.)

### 5. Safety Features
**Tasks**:
- [ ] Pre-flight checks: disk space, write permissions, zstd memory requirements
- [ ] Add option to verify archive integrity after creation
- [ ] Implement resume capability for interrupted compressions
- [ ] Add compression level selection (balance speed vs size)

### 6. Performance Optimizations
**Tasks**:
- [ ] Test different tar blocking factors for various file types
- [ ] Experiment with zstd --long flag for better compression
- [ ] Add option to exclude certain file types (.git, node_modules, etc.)
- [ ] Consider parallel compression for multiple directories

## Implementation Order

1. **First**: Fix error handling (set -o pipefail, trap cleanup)
2. **Second**: Fix .partial file issues (sync, validation)
3. **Third**: Fix progress bar with proper pv parsing
4. **Fourth**: Add logging for debugging
5. **Fifth**: Add safety checks and optimizations

## Testing Checklist

- [ ] Test with single large file (>1GB)
- [ ] Test with many small files (10,000+)
- [ ] Test with insufficient disk space
- [ ] Test interruption (Ctrl+C) during compression
- [ ] Test on different filesystems (ext4, NTFS, network drives)
- [ ] Test with special characters in filenames
- [ ] Test with symbolic links and special files

## Completed Tasks

### Error Handling & Pipeline Failures ✓
- [x] Added `set -euo pipefail` to catch pipeline errors
- [x] Implemented trap cleanup for .partial files
- [x] Using ${PIPESTATUS[0]} to check pipeline exit status
- [x] Added proper error messages with log file references

### Phantom .partial Files ✓
- [x] Added `sync` after compression to ensure data is written
- [x] Using unique timestamp + PID for temp filenames
- [x] Validating archives with `zstd -t` before moving
- [x] Trap cleanup removes .partial files on failure/interrupt

### Logging & Debugging ✓
- [x] Created dedicated log directory `/tmp/nautilus_compress_logs/`
- [x] Logging start time, source, target, and sizes
- [x] Capturing stderr from all pipeline commands
- [x] Success/error dialogs show log file path

### Progress Indication (Partial) ✓
- [x] Switched to --pulsate mode for activity indication
- [x] Fixed pipeline to properly handle zenity dialog
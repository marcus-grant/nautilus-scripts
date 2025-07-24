# Contributing Guidelines

## Git Commits

### Commit Message Format

```
<prefix>: <title> (50 chars max)

- <body line 1> (72 chars max)
  - <nested detail if needed>
  - <another nested detail>
- <body line 2>
```

### Prefixes

- `Pln:` Planning, documentation, TODO updates
- `Ft:` New features or functionality
- `Ref:` Code refactoring
- `Tst:` Testing additions or changes

### Rules

1. Title: Max 50 characters after prefix
2. Body: Max 72 characters per line
3. Use bullet points (`-`) for body items
4. Indent nested items with 2 spaces
5. Separate title and body with blank line

### Example

```
Ft: Add compress zst tarball script

- Create nautilus script for directory compression
  - Uses zstd for better compression ratios
  - Shows progress with zenity dialog
- Currently has pipeline issues to fix
```
# Script Deployment: `deploy.sh`

This script deploys `.bash` scripts from
the current directory to Nautilus' Scripts directory
(`~/.local/share/nautilus/scripts/`),
renaming them for friendly display in GNOME Files.

## File Naming Convention

- Scripts must use `_` to represent spaces.
- Scripts must end with `.bash`.
- Files **without** underscores or `.bash` are **skipped**.

## Usage

```bash
chmod +x deploy.sh
./deploy.sh
```

# Dotfiles

- This is a cross-platform dotfiles repo. Always detect the current OS (macOS vs Linux) and handle platform differences. Use `uname -s` or equivalent checks. macOS uses BSD utilities (date, find, sort) which differ from GNU versions. Never assume GNU tools on macOS.

## Management approach (stow)

- Configs are managed as GNU stow packages symlinked into `$HOME`. If the user requests a configuration change, the change must always be reproducible through this repo (edit the package file, never the live file in `$HOME` directly).
- Before proposing a fix, fully read and understand the existing configuration and the stow-based approach. Do not propose changes that conflict with the stow symlink structure. Never edit profile files directly when they should be recreated through stow.

- SSH config (`~/.ssh/config`) is generated from `~/dotfiles/ssh_config.template` via `envsubst` in `install.sh`. Never edit `~/dotfiles/ssh/.ssh/config` directly — edit the template ask user to re-run `install.sh`.

## install.sh

This script must remain **idempotent**. Running it multiple times should produce the same result without errors or side effects. When making changes, ensure operations are safe to repeat (use `-f` flags, check before adding, avoid duplicate entries, etc.).

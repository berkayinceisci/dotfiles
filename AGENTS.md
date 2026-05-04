# Dotfiles

- This is a cross-platform dotfiles repo. Always detect the current OS (macOS vs Linux) and handle platform differences. Use `uname -s` or equivalent checks. macOS uses BSD utilities (date, find, sort) which differ from GNU versions. Never assume GNU tools on macOS.

- SSH config (`~/.ssh/config`) is generated from `~/dotfiles/ssh_config.template` via `envsubst` in `install.sh`. Never edit `~/dotfiles/ssh/.ssh/config` directly — edit the template ask user to re-run `install.sh`.

## install.sh

This script must remain **idempotent**. Running it multiple times should produce the same result without errors or side effects. When making changes, ensure operations are safe to repeat (use `-f` flags, check before adding, avoid duplicate entries, etc.).

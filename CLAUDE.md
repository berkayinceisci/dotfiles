# Dotfiles

- This is a cross-platform dotfiles repo. Always detect the current OS (macOS vs Linux) and handle platform differences. Use `uname -s` or equivalent checks. macOS uses BSD utilities (date, find, sort) which differ from GNU versions. Never assume GNU tools on macOS.

## install.sh

This script must remain **idempotent**. Running it multiple times should produce the same result without errors or side effects. When making changes, ensure operations are safe to repeat (use `-f` flags, check before adding, avoid duplicate entries, etc.).

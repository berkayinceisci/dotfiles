#!/bin/bash

# Install script for cross-platform dotfiles
# Handles both stow packages and system-level configurations

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR"

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected: Linux"
    OS="linux"
    FIREFOX_POLICIES_DIR="/usr/lib/firefox/distribution"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected: macOS"
    OS="macos"
    FIREFOX_POLICIES_DIR="/Applications/Firefox.app/Contents/Resources/distribution"
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

# Stow packages
echo ""
echo "Stowing dotfiles..."

# Linux-specific packages to skip on macOS
LINUX_ONLY_PACKAGES=("i3" "rofi" "systemd" "Xresources")

for package in */; do
    package="${package%/}"  # Remove trailing slash

    # Skip non-package directories
    if [[ "$package" == ".git" || "$package" == ".claude" ]]; then
        continue
    fi

    # Skip firefox (not a stow package)
    if [[ "$package" == "firefox" ]]; then
        continue
    fi

    # Skip Linux-only packages on macOS
    if [[ "$OS" == "macos" ]] && [[ " ${LINUX_ONLY_PACKAGES[@]} " =~ " ${package} " ]]; then
        echo "  ⊘ Skipping $package (Linux only)"
        continue
    fi

    echo "  → Stowing $package"
    stow "$package"
done

echo "  ✓ Stowing complete"

# System-level configurations
echo ""
echo "Installing system-level configurations..."

# Install Firefox policies
if [ -f "$DOTFILES_DIR/firefox/policies.json" ]; then
    echo "Installing Firefox policies..."
    sudo mkdir -p "$FIREFOX_POLICIES_DIR"
    sudo ln -sf "$DOTFILES_DIR/firefox/policies.json" "$FIREFOX_POLICIES_DIR/policies.json"
    echo "  ✓ Firefox policies installed to $FIREFOX_POLICIES_DIR/policies.json"
else
    echo "  ⚠ Firefox policies.json not found, skipping..."
fi

echo ""
echo "Installation complete!"
echo "Don't forget to restart Firefox for policies to take effect."

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
    ZEN_POLICIES_DIR="/opt/zen-browser/distribution"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected: macOS"
    OS="macos"
    # Check for both possible Zen Browser installation names on macOS
    if [ -d "/Applications/Zen.app" ]; then
        ZEN_POLICIES_DIR="/Applications/Zen.app/Contents/Resources/distribution"
    elif [ -d "/Applications/Zen Browser.app" ]; then
        ZEN_POLICIES_DIR="/Applications/Zen Browser.app/Contents/Resources/distribution"
    else
        ZEN_POLICIES_DIR="/Applications/Zen.app/Contents/Resources/distribution"  # Default fallback
    fi
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

    # Skip zen (not a stow package)
    if [[ "$package" == "zen" ]]; then
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

# Install Zen Browser policies
if [ -f "$DOTFILES_DIR/zen/policies.json" ]; then
    echo "Installing Zen Browser policies..."
    sudo mkdir -p "$ZEN_POLICIES_DIR"
    sudo ln -sf "$DOTFILES_DIR/zen/policies.json" "$ZEN_POLICIES_DIR/policies.json"
    echo "  ✓ Zen Browser policies installed to $ZEN_POLICIES_DIR/policies.json"
else
    echo "  ⚠ Zen Browser policies.json not found, skipping..."
fi

echo ""
echo "Installation complete!"
echo "Don't forget to restart Zen Browser for policies to take effect."

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

# Enable systemd user services (Linux only)
if [[ "$OS" == "linux" ]]; then
    echo ""
    echo "Setting up systemd user services..."
    systemctl --user daemon-reload
    if systemctl --user list-unit-files | grep -q "weather-update.timer"; then
        systemctl --user enable --now weather-update.timer
        echo "  ✓ weather-update.timer enabled"
    fi
fi

# Configure display manager for login screen (Linux only)
if [[ "$OS" == "linux" ]]; then
    echo ""
    echo "Configuring display manager..."
    
    DISPLAY_SETUP_SRC="$DOTFILES_DIR/i3/.config/i3/display_setup.sh"
    
    if [ -f "$DISPLAY_SETUP_SRC" ]; then
        # Detect display manager
        DM=$(basename "$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null)" .service 2>/dev/null || echo "unknown")
        
        case "$DM" in
            "lightdm")
                echo "  Detected: LightDM"
                sudo cp "$DISPLAY_SETUP_SRC" /etc/lightdm/display_setup.sh
                sudo chmod +x /etc/lightdm/display_setup.sh
                
                # Add display-setup-script to lightdm.conf if not present
                if ! grep -q "display-setup-script=/etc/lightdm/display_setup.sh" /etc/lightdm/lightdm.conf 2>/dev/null; then
                    if grep -q "^\[Seat:\*\]" /etc/lightdm/lightdm.conf 2>/dev/null; then
                        sudo sed -i '/^\[Seat:\*\]/a display-setup-script=/etc/lightdm/display_setup.sh' /etc/lightdm/lightdm.conf
                    else
                        echo -e "\n[Seat:*]\ndisplay-setup-script=/etc/lightdm/display_setup.sh" | sudo tee -a /etc/lightdm/lightdm.conf > /dev/null
                    fi
                fi
                echo "  ✓ LightDM configured"
                ;;
            "gdm"|"gdm3")
                echo "  Detected: GDM"
                # GDM uses monitors.xml for display configuration
                # Generate monitors.xml based on hostname
                HOST=$(hostname)
                GDM_MONITORS_DIR="/var/lib/gdm3/.config"
                [ -d "/var/lib/gdm/.config" ] && GDM_MONITORS_DIR="/var/lib/gdm/.config"
                
                sudo mkdir -p "$GDM_MONITORS_DIR"
                
                case "$HOST" in
                    "manjaro"|"ubuntu")
                        # External monitor only (HDMI-1-0 or HDMI-1-1), laptop off
                        sudo tee "$GDM_MONITORS_DIR/monitors.xml" > /dev/null << 'EOF'
<monitors version="2">
  <configuration>
    <logicalmonitor>
      <x>0</x>
      <y>0</y>
      <scale>1</scale>
      <primary>yes</primary>
      <monitor>
        <monitorspec>
          <connector>HDMI-1-0</connector>
          <vendor>unknown</vendor>
          <product>unknown</product>
          <serial>unknown</serial>
        </monitorspec>
        <mode>
          <width>2560</width>
          <height>1440</height>
          <rate>120.00</rate>
        </mode>
      </monitor>
    </logicalmonitor>
    <disabled>
      <monitorspec>
        <connector>eDP-1</connector>
        <vendor>unknown</vendor>
        <product>unknown</product>
        <serial>unknown</serial>
      </monitorspec>
    </disabled>
  </configuration>
</monitors>
EOF
                        ;;
                    "popos")
                        # Single external monitor
                        sudo tee "$GDM_MONITORS_DIR/monitors.xml" > /dev/null << 'EOF'
<monitors version="2">
  <configuration>
    <logicalmonitor>
      <x>0</x>
      <y>0</y>
      <scale>1</scale>
      <primary>yes</primary>
      <monitor>
        <monitorspec>
          <connector>HDMI-1</connector>
          <vendor>unknown</vendor>
          <product>unknown</product>
          <serial>unknown</serial>
        </monitorspec>
        <mode>
          <width>3840</width>
          <height>2160</height>
          <rate>60.00</rate>
        </mode>
      </monitor>
    </logicalmonitor>
  </configuration>
</monitors>
EOF
                        ;;
                esac
                sudo chown gdm:gdm "$GDM_MONITORS_DIR/monitors.xml" 2>/dev/null || sudo chown gdm3:gdm3 "$GDM_MONITORS_DIR/monitors.xml" 2>/dev/null
                echo "  ✓ GDM configured"
                ;;
            *)
                echo "  ⚠ Unknown display manager ($DM), skipping display manager config"
                ;;
        esac
    else
        echo "  ⚠ display_setup.sh not found, skipping display manager config"
    fi
fi

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
echo "You may need to reboot for display manager changes to take effect."

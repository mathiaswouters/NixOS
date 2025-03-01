#!/usr/bin/env bash

set -e  # Exit immediately if a command exits with a non-zero status

# Color codes for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored messages
print_step() {
    echo -e "${BLUE}==>${NC} ${GREEN}$1${NC}"
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running as root and exit if true
if [ "$(id -u)" -eq 0 ]; then
    print_error "This script should not be run as root"
    exit 1
fi

# Set variables for repositories
NIXOS_REPO_URL="https://github.com/mathiaswouters/nixos"
DOTFILES_REPO_URL="https://github.com/mathiaswouters/dotfiles"

# Set directories
NIXOS_CONFIG_DIR="$HOME/nixos"
DOTFILES_DIR="$HOME/dotfiles"

# Step 1: Install dependencies
print_step "Installing dependencies..."
if ! command_exists stow; then
    sudo nix-env -iA nixos.stow
fi

if ! command_exists git; then
    sudo nix-env -iA nixos.git
fi

# Step 2: Clone or pull the NixOS configuration repository
print_step "Setting up NixOS configuration..."
if [ -d "$NIXOS_CONFIG_DIR" ]; then
    cd "$NIXOS_CONFIG_DIR"
    git pull
else
    git clone "$NIXOS_REPO_URL" "$NIXOS_CONFIG_DIR"
    cd "$NIXOS_CONFIG_DIR"
fi

# Copy NixOS configuration files to /etc/nixos/
print_step "Copying NixOS configuration files to /etc/nixos/..."
sudo cp -f "$NIXOS_CONFIG_DIR/configuration.nix" /etc/nixos/
if [ -f "$NIXOS_CONFIG_DIR/hardware-configuration.nix" ]; then
    sudo cp -f "$NIXOS_CONFIG_DIR/hardware-configuration.nix" /etc/nixos/
fi

# Rebuild NixOS
print_step "Rebuilding NixOS with the new configuration..."
sudo nixos-rebuild switch

# Step 3: Clone or pull the dotfiles repository
print_step "Setting up dotfiles..."
if [ -d "$DOTFILES_DIR" ]; then
    cd "$DOTFILES_DIR"
    git pull
    print_step "Updated existing dotfiles repository"
else
    git clone "$DOTFILES_REPO_URL" "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
    print_step "Cloned dotfiles repository from $DOTFILES_REPO_URL"
fi

# Step 4: Copy/link config files to the appropriate locations
print_step "Setting up your dotfiles..."

# Ensure necessary directories exist
mkdir -p "$HOME/.config"

# Option 1: Use rsync to copy files
# rsync -av --progress "$DOTFILES_DIR/.config/" "$HOME/.config/"

# Option 2: Use symbolic links to link the entire .config directory
# This is better if you want to keep your changes synchronized with the repository
if [ -d "$DOTFILES_DIR/.config" ]; then
    # Create symbolic links for each configuration directory
    for config_dir in hypr mako rofi waybar; do
        if [ -d "$DOTFILES_DIR/.config/$config_dir" ]; then
            print_step "Linking $config_dir configuration..."
            # Remove existing directory if it's there
            if [ -d "$HOME/.config/$config_dir" ]; then
                rm -rf "$HOME/.config/$config_dir"
            fi
            # Create the symbolic link
            ln -sf "$DOTFILES_DIR/.config/$config_dir" "$HOME/.config/$config_dir"
            echo "✓ $config_dir configuration linked"
        else
            print_error "Directory $config_dir not found in dotfiles repository"
        fi
    done
else
    print_error ".config directory not found in your dotfiles repository."
    exit 1
fi

# Make scripts executable
print_step "Making scripts executable..."
if [ -f "$HOME/.config/hypr/scripts/set-wallpaper.sh" ]; then
    chmod +x "$HOME/.config/hypr/scripts/set-wallpaper.sh"
    echo "✓ Made set-wallpaper.sh executable"
fi

# Create Wallpapers directory if it doesn't exist
mkdir -p "$HOME/Pictures/Wallpapers"

# Final setup steps
print_step "Running final setup steps..."

# Initialize swww if installed
if command_exists swww; then
    swww init
    echo "✓ Initialized swww"
fi

# Set a wallpaper if the script exists
if [ -x "$HOME/.config/hypr/scripts/set-wallpaper.sh" ]; then
    "$HOME/.config/hypr/scripts/set-wallpaper.sh"
    echo "✓ Set wallpaper with set-wallpaper.sh"
fi

print_step "Setup complete! You may need to restart to apply all changes."
print_step "To start Hyprland, type 'Hyprland' at the login prompt or restart your computer."
#!/bin/bash

# Enable strict mode
set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="${SETUP_DIR}/packages"
CUSTOM_DIR="${SETUP_DIR}/custom"

# Source OS release info
if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Cannot detect OS. Exiting."
    exit 1
fi

echo "Detected OS: $ID"

install_packages() {
    local list_file="$1"
    local cmd="$2"
    
    if [ -f "$list_file" ]; then
        echo "Installing packages from $list_file..."
        # Read packages, ignoring comments and empty lines
        packages=$(grep -vE "^\s*#|^\s*$" "$list_file" | tr '\n' ' ')
        if [ -n "$packages" ]; then
            eval "$cmd $packages"
        else
            echo "No packages found in $list_file to install."
        fi
    else
        echo "No package list found for $ID ($list_file)"
    fi
}

# Main Logic
case "$ID" in
    opensuse*|suse)
        echo "Running OpenSUSE setup..."
        install_packages "${PACKAGE_DIR}/opensuse.txt" "sudo zypper install -y"
        ;;
    ubuntu|debian)
        echo "Running Debian/Ubuntu setup..."
        sudo apt update
        install_packages "${PACKAGE_DIR}/ubuntu.txt" "sudo apt install -y"
        
        # Ubuntu specific fixes for bat/fd (creates symlinks if missing)
        mkdir -p ~/.local/bin
        if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
            ln -s $(which batcat) ~/.local/bin/bat
            echo "Symlinked batcat -> ~/.local/bin/bat"
        fi
        if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
            ln -s $(which fdfind) ~/.local/bin/fd
            echo "Symlinked fdfind -> ~/.local/bin/fd"
        fi
        
        # Install WezTerm (External Repo)
        if ! command -v wezterm &> /dev/null; then
            echo "Installing WezTerm..."
            curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
            echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
            sudo apt update
            sudo apt install -y wezterm
        fi
        ;;
    *)
        echo "Unsupported OS family: $ID"
        echo "Skipping package installation."
        ;;
esac

# Run custom scripts
if [ -d "$CUSTOM_DIR" ]; then
    echo "Running custom installers..."
    for script in "${CUSTOM_DIR}"/*.sh; do
        if [ -f "$script" ]; then
            # Ensure it's executable
            chmod +x "$script"
            echo "Running $(basename "$script")..."
            "$script"
        fi
    done
fi

echo "System setup complete."

#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect package installer
detect_installer() {
    if command -v paru &> /dev/null; then
        echo "paru"
    elif command -v yay &> /dev/null; then
        echo "yay"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    else
        log_error "No supported package manager found (paru/yay/pacman)"
        exit 1
    fi
}

# Check if package is installed
is_installed() {
    pacman -Qi "$1" &> /dev/null
}

# Install packages from package.txt
install_packages() {
    local installer="$1"
    local package_file="package.txt"
    
    if [[ ! -f "$package_file" ]]; then
        log_error "package.txt not found!"
        exit 1
    fi
    
    log_info "Reading packages from $package_file..."
    
    # Read packages (skip comments and blank lines)
    local packages=()
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue
        packages+=("$line")
    done < "$package_file"
    
    log_info "Found ${#packages[@]} packages to process"
    
    # Install each package
    local installed_count=0
    local skipped_count=0
    local failed_count=0
    
    for package in "${packages[@]}"; do
        if is_installed "$package"; then
            log_success "$package is already installed (skipping)"
            ((skipped_count++))
        else
            log_info "Installing $package..."
            
            if [[ "$installer" == "pacman" ]]; then
                # For pacman, we need sudo and can't install AUR packages
                if sudo pacman -S --noconfirm --needed "$package" 2>/dev/null; then
                    log_success "Installed $package"
                    ((installed_count++))
                else
                    log_warning "Failed to install $package (may be AUR-only)"
                    ((failed_count++))
                fi
            else
                # AUR helpers (paru/yay) don't need sudo for AUR packages
                if $installer -S --noconfirm --needed "$package" 2>/dev/null; then
                    log_success "Installed $package"
                    ((installed_count++))
                else
                    log_warning "Failed to install $package"
                    ((failed_count++))
                fi
            fi
        fi
    done
    
    echo ""
    log_info "Installation summary:"
    echo "  - Installed: $installed_count"
    echo "  - Already installed: $skipped_count"
    echo "  - Failed: $failed_count"
    echo ""
}

# Enable LightDM
enable_lightdm() {
    log_info "Enabling LightDM display manager..."
    
    if sudo systemctl enable lightdm; then
        log_success "LightDM enabled successfully"
    else
        log_error "Failed to enable LightDM"
        return 1
    fi
}

# Launch RiceInstaller
launch_riceinstaller() {
    local rice_installer="./RiceInstaller"
    
    if [[ ! -f "$rice_installer" ]]; then
        log_error "RiceInstaller not found at $rice_installer"
        exit 1
    fi
    
    log_info "Making RiceInstaller executable..."
    chmod +x "$rice_installer"
    
    log_info "Launching RiceInstaller..."
    export RICEINSTALLER_LAUNCHED_FROM_INSTALL_SH=1
    
    "$rice_installer"
}

# Main execution
main() {
    echo ""
    log_info "=== X11 Bootstrap Installer ==="
    echo ""
    
    # Detect installer
    INSTALLER=$(detect_installer)
    log_info "Detected package manager: $INSTALLER"
    echo ""
    
    # Install packages
    install_packages "$INSTALLER"
    
    # Enable LightDM
    enable_lightdm
    echo ""
    
    # Launch RiceInstaller
    launch_riceinstaller
    
    echo ""
    log_success "Bootstrap installation complete!"
    echo ""
}

# Run main function
main "$@"

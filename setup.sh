#!/usr/bin/env bash

# Auto-install script for zsh-pnpm-completions
# Automatically detects environment and installs using the best available method
# No sudo required - all operations in user directories

set -e

# Script configuration
PLUGIN_NAME="zsh-pnpm-completions"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/zsh-pnpm-completions-install.log"
BACKUP_DIR="$HOME/.zsh-pnpm-completions-backups"
GITHUB_RAW_URL="https://raw.githubusercontent.com/michakfromparis/zsh-pnpm-completions/main"
TEMP_DIR=""
REMOTE_EXECUTION=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo -e "$1"
}

log_info() {
    log "${BLUE}[INFO]${NC} $1"
}

log_success() {
    log "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    log "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    log "${RED}[ERROR]${NC} $1"
}

# Print banner
print_banner() {
    echo -e "${BOLD}${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                  zsh-pnpm-completions                        ║"
    echo "║                   Auto-Install Script                        ║"
    echo "║                                                               ║"
    echo "║  Smart installation with environment detection & fallbacks   ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Environment detection functions
detect_os() {
    case "$(uname -s)" in
        Darwin*)    echo "macos" ;;
        Linux*)     
            if grep -q Microsoft /proc/version 2>/dev/null; then
                echo "wsl"
            else
                echo "linux"
            fi
            ;;
        CYGWIN*)    echo "cygwin" ;;
        MINGW*)     echo "mingw" ;;
        *)          echo "unknown" ;;
    esac
}

detect_shell() {
    if [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    elif [ -n "$BASH_VERSION" ]; then
        echo "bash"
    else
        echo "$(basename "$SHELL")"
    fi
}

detect_plugin_managers() {
    local managers=()
    
    # Oh My Zsh
    if [ -d "$HOME/.oh-my-zsh" ] || [ -n "$ZSH" ]; then
        managers+=("oh-my-zsh")
    fi
    
    # Prezto
    if [ -d "$HOME/.zprezto" ] || [ -n "$ZDOTDIR" ]; then
        managers+=("prezto")
    fi
    
    # Antigen
    if command -v antigen >/dev/null 2>&1 || [ -f "$HOME/.antigen/antigen.zsh" ] || grep -q "antigen" "$HOME/.zshrc" 2>/dev/null; then
        managers+=("antigen")
    fi
    
    # zplug
    if command -v zplug >/dev/null 2>&1 || [ -d "$HOME/.zplug" ] || grep -q "zplug" "$HOME/.zshrc" 2>/dev/null; then
        managers+=("zplug")
    fi
    
    # Zinit
    if [ -d "$HOME/.zinit" ] || [ -d "$HOME/.local/share/zinit" ] || grep -q "zinit" "$HOME/.zshrc" 2>/dev/null; then
        managers+=("zinit")
    fi
    
    printf '%s\n' "${managers[@]}"
}

# Remote execution detection
detect_remote_execution() {
    # Check if we're in a git repository with the expected plugin files
    if [ -f "$SCRIPT_DIR/zsh-pnpm-completions.zsh" ] && 
       [ -f "$SCRIPT_DIR/zsh-pnpm-completions.plugin.zsh" ] && 
       [ -f "$SCRIPT_DIR/zsh-pnpm-aliases.zsh" ]; then
        REMOTE_EXECUTION=false
        log_info "Running from local repository"
    else
        REMOTE_EXECUTION=true
        log_info "Running in remote mode - will download files from GitHub"
    fi
}

# Download utilities
setup_temp_dir() {
    TEMP_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'zsh-pnpm-completions')
    log_info "Created temporary directory: $TEMP_DIR"
}

cleanup_temp_dir() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
        log_info "Cleaned up temporary directory"
    fi
}

download_file() {
    local file_name="$1"
    local target_path="$2"
    local url="$GITHUB_RAW_URL/$file_name"
    
    log_info "Downloading $file_name..."
    
    # Try curl first, then wget
    if command -v curl >/dev/null 2>&1; then
        if curl -fsSL "$url" -o "$target_path"; then
            log_info "Successfully downloaded $file_name"
            return 0
        else
            log_error "Failed to download $file_name with curl"
            return 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget -q "$url" -O "$target_path"; then
            log_info "Successfully downloaded $file_name"
            return 0
        else
            log_error "Failed to download $file_name with wget"
            return 1
        fi
    else
        log_error "Neither curl nor wget is available for downloading files"
        return 1
    fi
}

download_plugin_files() {
    if [ "$REMOTE_EXECUTION" = false ]; then
        return 0  # No need to download if running locally
    fi
    
    log_info "Attempting to download plugin files from GitHub..."
    log_info "Note: This requires the repository to be publicly accessible"
    
    setup_temp_dir
    
    local files=(
        "zsh-pnpm-completions.zsh"
        "zsh-pnpm-completions.plugin.zsh"
        "zsh-pnpm-aliases.zsh"
        "README.md"
        "LICENSE"
    )
    
    local success=true
    for file in "${files[@]}"; do
        if ! download_file "$file" "$TEMP_DIR/$file"; then
            success=false
            break
        fi
    done
    
    if [ "$success" = true ]; then
        # Update SCRIPT_DIR to point to temp directory for remote execution
        SCRIPT_DIR="$TEMP_DIR"
        log_success "All plugin files downloaded successfully"
        return 0
    else
        cleanup_temp_dir
        log_error "Failed to download required plugin files from GitHub"
        echo ""
        echo "This could be because:"
        echo "  1. The repository is not yet public"
        echo "  2. Network connectivity issues"
        echo "  3. GitHub is temporarily unavailable"
        echo ""
        echo "Alternative installation methods:"
        echo "  1. Clone the repository manually: git clone https://github.com/michakfromparis/zsh-pnpm-completions.git"
        echo "  2. Then run: cd zsh-pnpm-completions && ./setup.sh"
        echo ""
        return 1
    fi
}

# Dependency checking
check_dependencies() {
    local missing_deps=()
    local optional_missing=()
    
    # Check zsh (skip in dry-run mode for testing)
    if [ "$REMOTE_EXECUTION" = false ] && [ "$dry_run" = false ] && ! command -v zsh >/dev/null 2>&1; then
        missing_deps+=("zsh")
    fi
    
    # Check git (not required for remote execution)
    if [ "$REMOTE_EXECUTION" = false ] && ! command -v git >/dev/null 2>&1; then
        missing_deps+=("git")
    fi
    
    # Check download tools for remote execution
    if [ "$REMOTE_EXECUTION" = true ]; then
        if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
            missing_deps+=("curl or wget")
        fi
    fi
    
    # Check optional dependencies
    if ! command -v pnpm >/dev/null 2>&1; then
        optional_missing+=("pnpm")
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        optional_missing+=("jq")
    fi
    
    # Report missing dependencies
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        echo "Please install the missing dependencies and try again."
        return 1
    fi
    
    if [ ${#optional_missing[@]} -gt 0 ]; then
        log_warning "Missing optional dependencies: ${optional_missing[*]}"
        echo "The plugin will work, but some features may be limited."
        echo "Install these for full functionality:"
        for dep in "${optional_missing[@]}"; do
            case $dep in
                pnpm) echo "  - pnpm: https://pnpm.io/installation" ;;
                jq) echo "  - jq: https://stedolan.github.io/jq/download/" ;;
            esac
        done
        echo ""
    fi
    
    return 0
}

# Backup and .zshrc management
backup_zshrc() {
    if [ -f "$HOME/.zshrc" ]; then
        mkdir -p "$BACKUP_DIR"
        local backup_file="$BACKUP_DIR/zshrc-backup-$(date +%Y%m%d-%H%M%S)"
        cp "$HOME/.zshrc" "$backup_file"
        log_info "Backed up .zshrc to $backup_file"
        echo "$backup_file"
    fi
}

check_existing_config() {
    if [ ! -f "$HOME/.zshrc" ]; then
        return 1
    fi
    
    # Check for various ways the plugin might already be loaded
    if grep -q "zsh-pnpm-completions" "$HOME/.zshrc" 2>/dev/null; then
        return 0
    fi
    
    return 1
}

inject_config() {
    local config_line="$1"
    local marker_comment="# Added by zsh-pnpm-completions auto-installer"
    
    if [ ! -f "$HOME/.zshrc" ]; then
        log_info "Creating new .zshrc file"
        touch "$HOME/.zshrc"
    fi
    
    # Check if already configured
    if check_existing_config; then
        log_info "Plugin appears to already be configured in .zshrc"
        return 0
    fi
    
    # Add configuration
    {
        echo ""
        echo "$marker_comment"
        echo "$config_line"
    } >> "$HOME/.zshrc"
    
    log_success "Added plugin configuration to .zshrc"
}

# Installation methods
create_directories() {
    local target_dir="$1"
    mkdir -p "$(dirname "$target_dir")"
    mkdir -p "$target_dir"
}

copy_files() {
    local target_dir="$1"
    local files=(
        "zsh-pnpm-completions.zsh"
        "zsh-pnpm-completions.plugin.zsh"
        "zsh-pnpm-aliases.zsh"
        "README.md"
        "LICENSE"
    )
    
    for file in "${files[@]}"; do
        if [ -f "$SCRIPT_DIR/$file" ]; then
            cp "$SCRIPT_DIR/$file" "$target_dir/"
            log_info "Copied $file to $target_dir"
        else
            log_warning "File $file not found in $SCRIPT_DIR"
        fi
    done
}

install_oh_my_zsh() {
    local no_aliases="$1"
    local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$PLUGIN_NAME"

    log_info "Installing for Oh My Zsh..."
    log_info "Target directory: $plugin_dir"

    if [ -d "$plugin_dir" ]; then
        log_info "Plugin directory already exists. Updating..."
        rm -rf "$plugin_dir"
    fi

    create_directories "$plugin_dir"
    copy_files "$plugin_dir"

    # Auto-configure plugins array in .zshrc
    backup_zshrc

    if [ -f "$HOME/.zshrc" ]; then
        # Check if plugins array exists and add our plugin
        if grep -q "plugins=(" "$HOME/.zshrc"; then
            # Check if our plugin is already in the array
            if ! grep -q "plugins=.*$PLUGIN_NAME" "$HOME/.zshrc"; then
                # Add to existing plugins array
                sed -i.bak "s/plugins=(/plugins=($PLUGIN_NAME /" "$HOME/.zshrc"
                log_success "Added $PLUGIN_NAME to existing plugins array"
            else
                log_info "Plugin already present in plugins array"
            fi
        else
            # Create new plugins array
            inject_config "plugins=($PLUGIN_NAME)"
        fi

        # Add environment variable if no aliases requested
        if [ "$no_aliases" = "true" ]; then
            inject_config "export ZSH_PNPM_NO_ALIASES=1"
            log_info "Disabled aliases for this installation"
        fi
    else
        inject_config "plugins=($PLUGIN_NAME)"
        if [ "$no_aliases" = "true" ]; then
            inject_config "export ZSH_PNPM_NO_ALIASES=1"
            log_info "Disabled aliases for this installation"
        fi
    fi

    log_success "Oh My Zsh installation completed!"
    return 0
}

install_antigen() {
    local no_aliases="$1"
    log_info "Installing for Antigen..."

    backup_zshrc
    inject_config "antigen bundle $PLUGIN_NAME"

    if [ "$no_aliases" = "true" ]; then
        inject_config "export ZSH_PNPM_NO_ALIASES=1"
        log_info "Disabled aliases for this installation"
    fi

    log_success "Antigen installation completed!"
    log_info "Run 'antigen reset' to reload if needed"
    return 0
}

install_zplug() {
    local no_aliases="$1"
    log_info "Installing for zplug..."

    backup_zshrc
    inject_config "zplug \"michakfromparis/zsh-pnpm-completions\", defer:2"

    if [ "$no_aliases" = "true" ]; then
        inject_config "export ZSH_PNPM_NO_ALIASES=1"
        log_info "Disabled aliases for this installation"
    fi

    log_success "zplug installation completed!"
    log_info "Run 'zplug install' to install the plugin"
    return 0
}

install_zinit() {
    local no_aliases="$1"
    log_info "Installing for Zinit..."

    backup_zshrc
    inject_config "zinit load \"michakfromparis/zsh-pnpm-completions\""

    if [ "$no_aliases" = "true" ]; then
        inject_config "export ZSH_PNPM_NO_ALIASES=1"
        log_info "Disabled aliases for this installation"
    fi

    log_success "Zinit installation completed!"
    return 0
}

install_prezto() {
    local no_aliases="$1"
    log_info "Installing for Prezto..."

    local prezto_dir="${ZDOTDIR:-$HOME}/.zprezto/modules/$PLUGIN_NAME"

    create_directories "$prezto_dir"
    copy_files "$prezto_dir"

    # Create init.zsh for Prezto with conditional alias loading
    if [ "$no_aliases" = "true" ]; then
        cat > "$prezto_dir/init.zsh" << 'EOF'
#
# Loads zsh-pnpm-completions
#

export ZSH_PNPM_NO_ALIASES=1
source "${0:h}/zsh-pnpm-completions.plugin.zsh"
EOF
    else
        cat > "$prezto_dir/init.zsh" << 'EOF'
#
# Loads zsh-pnpm-completions
#

source "${0:h}/zsh-pnpm-completions.plugin.zsh"
EOF
    fi

    backup_zshrc

    # Add to .zpreztorc if it exists
    local zpreztorc="${ZDOTDIR:-$HOME}/.zpreztorc"
    if [ -f "$zpreztorc" ]; then
        if ! grep -q "$PLUGIN_NAME" "$zpreztorc"; then
            sed -i.bak "/zmodload.*modules.*prezto/a\\  '$PLUGIN_NAME' \\\\" "$zpreztorc"
            log_success "Added $PLUGIN_NAME to .zpreztorc"
        fi
    else
        log_warning ".zpreztorc not found, manual configuration may be needed"
    fi

    if [ "$no_aliases" = "true" ]; then
        log_info "Disabled aliases for this installation"
    fi

    log_success "Prezto installation completed!"
    return 0
}

install_manual() {
    local no_aliases="$1"
    local target_dir="$HOME/.zsh-pnpm-completions"

    log_info "Installing manually..."
    log_info "Target directory: $target_dir"

    if [ -d "$target_dir" ]; then
        log_info "Plugin directory already exists. Updating..."
        rm -rf "$target_dir"
    fi

    create_directories "$target_dir"
    copy_files "$target_dir"

    backup_zshrc
    inject_config "source $target_dir/zsh-pnpm-completions.plugin.zsh"

    if [ "$no_aliases" = "true" ]; then
        inject_config "export ZSH_PNPM_NO_ALIASES=1"
        log_info "Disabled aliases for this installation"
    fi

    log_success "Manual installation completed!"
    return 0
}

# Verification
verify_installation() {
    log_info "Verifying installation..."
    
    # Check if .zshrc contains our configuration
    if check_existing_config; then
        log_success "Plugin configuration found in .zshrc"
        return 0
    else
        log_error "Plugin configuration not found in .zshrc"
        return 1
    fi
}

# Uninstall functions
uninstall_oh_my_zsh() {
    local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$PLUGIN_NAME"

    log_info "Removing Oh My Zsh installation..."

    # Remove plugin directory
    if [ -d "$plugin_dir" ]; then
        rm -rf "$plugin_dir"
        log_success "Removed plugin directory: $plugin_dir"
    else
        log_info "Plugin directory not found: $plugin_dir"
    fi

    # Safely remove from plugins array in .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        # Create backup
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"

        # Use awk to safely remove the plugin from the plugins array
        # This preserves the array structure and only removes the specific plugin
        awk '
        /^plugins=\(/ {
            # Found plugins array line
            line = $0
            # Remove the plugin name (with optional surrounding whitespace)
            gsub(/[[:space:]]*zsh-pnpm-completions[[:space:]]*/, " ", line)
            # Clean up any double spaces
            gsub(/[[:space:]]+/, " ", line)
            # Remove trailing space before closing paren
            gsub(/[[:space:]]*\)$/, ")", line)
            # Remove leading space after opening paren
            gsub(/\([[:space:]]+/, "(", line)
            print line
            next
        }
        { print }
        ' "$HOME/.zshrc" > "$HOME/.zshrc.tmp" && mv "$HOME/.zshrc.tmp" "$HOME/.zshrc"

        log_success "Safely removed plugin from .zshrc plugins array"
    fi

    return 0
}

uninstall_antigen() {
    log_info "Removing Antigen configuration..."

    # Safely remove antigen bundle line from .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        # Create backup
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"

        # Only remove lines that exactly match the antigen bundle command
        sed -i.tmp "/^antigen bundle $PLUGIN_NAME$/d" "$HOME/.zshrc"
        rm -f "$HOME/.zshrc.tmp"

        log_success "Safely removed antigen bundle from .zshrc"
    fi

    return 0
}

uninstall_zplug() {
    log_info "Removing zplug configuration..."

    # Safely remove zplug line from .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        # Create backup
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"

        # Only remove lines that contain zplug and the plugin name
        sed -i.tmp "/zplug.*$PLUGIN_NAME/d" "$HOME/.zshrc"
        rm -f "$HOME/.zshrc.tmp"

        log_success "Safely removed zplug configuration from .zshrc"
    fi

    return 0
}

uninstall_zinit() {
    log_info "Removing Zinit configuration..."

    # Safely remove zinit load line from .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        # Create backup
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"

        # Only remove lines that contain zinit load and the plugin name
        sed -i.tmp "/zinit.*load.*$PLUGIN_NAME/d" "$HOME/.zshrc"
        rm -f "$HOME/.zshrc.tmp"

        log_success "Safely removed zinit configuration from .zshrc"
    fi

    return 0
}

uninstall_prezto() {
    log_info "Removing Prezto installation..."

    local prezto_dir="${ZDOTDIR:-$HOME}/.zprezto/modules/$PLUGIN_NAME"

    # Remove plugin directory
    if [ -d "$prezto_dir" ]; then
        rm -rf "$prezto_dir"
        log_success "Removed plugin directory: $prezto_dir"
    else
        log_info "Plugin directory not found: $prezto_dir"
    fi

    # Safely remove from .zpreztorc
    local zpreztorc="${ZDOTDIR:-$HOME}/.zpreztorc"
    if [ -f "$zpreztorc" ]; then
        # Create backup
        cp "$zpreztorc" "$zpreztorc.backup.$(date +%Y%m%d_%H%M%S)"

        # Use sed to safely remove the plugin from prezto modules
        sed -i.tmp "/$PLUGIN_NAME/d" "$zpreztorc"
        rm -f "$zpreztorc.tmp"

        log_success "Safely removed plugin from .zpreztorc"
    fi

    return 0
}

uninstall_manual() {
    local target_dir="$HOME/.zsh-pnpm-completions"

    log_info "Removing manual installation..."

    # Remove plugin directory
    if [ -d "$target_dir" ]; then
        rm -rf "$target_dir"
        log_success "Removed plugin directory: $target_dir"
    else
        log_info "Plugin directory not found: $target_dir"
    fi

    # Safely remove source line from .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        # Create backup
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"

        # Only remove lines that source the plugin
        sed -i.tmp "/^source.*$PLUGIN_NAME/d" "$HOME/.zshrc"
        rm -f "$HOME/.zshrc.tmp"

        log_success "Safely removed source line from .zshrc"
    fi

    return 0
}

# Remove configuration added by auto-installer
remove_auto_config() {
    if [ -f "$HOME/.zshrc" ]; then
        # Create backup
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"

        # Safely remove the marker comment and the line that follows it
        # Use awk to be more precise
        awk '
        /# Added by zsh-pnpm-completions auto-installer/ {
            # Skip this line and the next one
            getline
            next
        }
        { print }
        ' "$HOME/.zshrc" > "$HOME/.zshrc.tmp" && mv "$HOME/.zshrc.tmp" "$HOME/.zshrc"

        log_info "Safely removed auto-installer configuration from .zshrc"
    fi
}

# Main uninstall orchestration
uninstall_plugin() {
    log_info "Starting uninstallation..."

    # Check if plugin is installed
    if ! check_existing_config; then
        log_warning "Plugin does not appear to be installed"
        return 0
    fi

    # Try to detect which installation method was used and uninstall accordingly
    local uninstalled=false

    # Check for different installation types in order of likelihood
    if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$PLUGIN_NAME" ]; then
        uninstall_oh_my_zsh && uninstalled=true
    elif [ -d "$HOME/.zsh-pnpm-completions" ]; then
        uninstall_manual && uninstalled=true
    elif [ -d "${ZDOTDIR:-$HOME}/.zprezto/modules/$PLUGIN_NAME" ]; then
        uninstall_prezto && uninstalled=true
    else
        # Fallback: try to remove any auto-installer configurations
        remove_auto_config
        log_info "Attempted to remove auto-installer configurations"
        uninstalled=true
    fi

    # Also clean up any remaining configurations that might exist
    uninstall_antigen 2>/dev/null || true
    uninstall_zplug 2>/dev/null || true
    uninstall_zinit 2>/dev/null || true

    if [ "$uninstalled" = true ]; then
        log_success "Plugin uninstallation completed"
        return 0
    else
        log_error "Could not determine installation method"
        return 1
    fi
}

# Main installation orchestration
install_plugin() {
    local force_method="$1"
    local no_aliases="$2"
    local managers=()
    local success=false
    
    if [ -n "$force_method" ]; then
        log_info "Forcing installation method: $force_method"
        case "$force_method" in
            oh-my-zsh) install_oh_my_zsh "$no_aliases" && success=true ;;
            antigen) install_antigen "$no_aliases" && success=true ;;
            zplug) install_zplug "$no_aliases" && success=true ;;
            zinit) install_zinit "$no_aliases" && success=true ;;
            prezto) install_prezto "$no_aliases" && success=true ;;
            manual) install_manual "$no_aliases" && success=true ;;
            *) log_error "Unknown installation method: $force_method" ;;
        esac
    else
        # Auto-detect and try in order of preference
        while IFS= read -r manager; do
            managers+=("$manager")
        done < <(detect_plugin_managers)
        
        if [ ${#managers[@]} -eq 0 ]; then
            log_info "No plugin managers detected, using manual installation"
            install_manual "$no_aliases" && success=true
        else
            log_info "Detected plugin managers: ${managers[*]}"
            
            for manager in "${managers[@]}"; do
                log_info "Attempting installation for $manager..."
                case "$manager" in
                    oh-my-zsh) install_oh_my_zsh "$no_aliases" && success=true && break ;;
                    prezto) install_prezto "$no_aliases" && success=true && break ;;
                    antigen) install_antigen "$no_aliases" && success=true && break ;;
                    zplug) install_zplug "$no_aliases" && success=true && break ;;
                    zinit) install_zinit "$no_aliases" && success=true && break ;;
                esac
            done

            # Fallback to manual if all failed
            if [ "$success" = false ]; then
                log_warning "All plugin manager installations failed, falling back to manual installation"
                install_manual "$no_aliases" && success=true
            fi
        fi
    fi
    
    if [ "$success" = true ]; then
        verify_installation
        return $?
    else
        return 1
    fi
}

# Usage information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Install or uninstall zsh-pnpm-completions with environment detection"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -m, --method METHOD     Force specific installation method"
    echo "                          Methods: oh-my-zsh, antigen, zplug, zinit, prezto, manual"
    echo "  -v, --verbose           Enable verbose logging"
    echo "  --dry-run              Show what would be done without making changes"
    echo "  --no-aliases           Install without loading aliases"
    echo "  --uninstall            Remove zsh-pnpm-completions from your system"
    echo ""
    echo "Examples:"
    echo "  $0                      # Auto-detect and install"
    echo "  $0 -m manual           # Force manual installation"
    echo "  $0 -m oh-my-zsh        # Force Oh My Zsh installation"
    echo "  $0 --no-aliases        # Install without aliases"
    echo "  $0 --uninstall         # Remove the plugin"
    echo ""
    echo "One-liner remote installation:"
    echo "  # Using curl (recommended)"
    echo "  bash <(curl -fsSL https://raw.githubusercontent.com/michakfromparis/zsh-pnpm-completions/main/setup.sh)"
    echo ""
    echo "  # Using wget"
    echo "  bash <(wget -qO- https://raw.githubusercontent.com/michakfromparis/zsh-pnpm-completions/main/setup.sh)"
    echo ""
    echo "Uninstall:"
    echo "  $0 --uninstall"
    echo ""
}

# Command line argument parsing
parse_args() {
    local method=""
    local verbose=false
    local dry_run=false
    local uninstall=false
    local no_aliases=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -m|--method)
                method="$2"
                shift 2
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --no-aliases)
                no_aliases=true
                shift
                ;;
            --uninstall)
                uninstall=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    echo "$method|$verbose|$dry_run|$no_aliases|$uninstall"
}

# Main function
main() {
    # Handle help option first, before any processing
    for arg in "$@"; do
        if [ "$arg" = "-h" ] || [ "$arg" = "--help" ]; then
            usage
            exit 0
        fi
    done
    
    local args
    local method verbose dry_run no_aliases uninstall

    args=$(parse_args "$@")
    IFS='|' read -r method verbose dry_run no_aliases uninstall <<< "$args"
    
    print_banner
    
    # Initialize logging
    rm -f "$LOG_FILE"
    log_info "Starting zsh-pnpm-completions auto-installation"
    log_info "Log file: $LOG_FILE"
    
    # Detect execution mode and setup files
    detect_remote_execution
    
    if [ "$REMOTE_EXECUTION" = true ]; then
        if ! download_plugin_files; then
            log_error "Failed to download required files from GitHub"
            exit 1
        fi
        # Set cleanup trap for remote execution
        trap cleanup_temp_dir EXIT
    fi
    
    # Environment detection
    local os shell
    os=$(detect_os)
    shell=$(detect_shell)
    
    log_info "Detected OS: $os"
    log_info "Detected shell: $shell"
    
    if [ "$shell" != "zsh" ]; then
        if [ "$dry_run" = true ]; then
            log_info "Running in dry-run mode - testing logic without requiring zsh"
        else
            log_warning "Current shell is $shell, but this plugin requires zsh"
            echo "Switch to zsh or ensure zsh is your login shell for the plugin to work."
        fi
    fi
    
    # Check dependencies (skip for uninstall)
    if [ "$uninstall" = false ] && ! check_dependencies; then
        exit 1
    fi

    # Uninstall mode
    if [ "$uninstall" = true ]; then
        if uninstall_plugin; then
            echo ""
            log_success "🎉 Uninstallation completed successfully!"
            echo ""
            echo "The plugin has been removed from your system."
            echo ""
            if [ "$shell" = "zsh" ]; then
                echo "To fully deactivate:"
                echo "  • Run: source ~/.zshrc"
                echo "  • Or restart your terminal"
                echo ""
            fi
        else
            echo ""
            log_error "Uninstallation failed. Check the log for details: $LOG_FILE"
            exit 1
        fi
        return 0
    fi

    # Dry run mode
    if [ "$dry_run" = true ]; then
        log_info "DRY RUN MODE - No changes will be made"
        if [ -n "$method" ]; then
            echo "Would attempt installation with: $method"
        else
            local managers=()
            while IFS= read -r manager; do
                managers+=("$manager")
            done < <(detect_plugin_managers)
            echo "Would attempt installation with: ${managers[*]:-manual}"
        fi
        exit 0
    fi

    # Perform installation
    if install_plugin "$method" "$no_aliases"; then
        echo ""
        log_success "🎉 Installation completed successfully!"
        echo ""

        # Provide activation instructions
        echo "🎯 Next steps:"
        echo ""

        if [ "$shell" = "zsh" ]; then
            echo "   1. Activate the plugin:"
            echo "      source ~/.zshrc"
            echo ""
            echo "   2. Test it works:"
            echo "      p <TAB>"
            echo ""
        else
            echo "   1. Switch to zsh:"
            echo "      exec zsh"
            echo ""
            echo "   2. Activate the plugin:"
            echo "      source ~/.zshrc"
            echo ""
            echo "   3. Test it works:"
            echo "      p <TAB>"
            echo ""
        fi

        echo "💡 Pro tip: You can also just restart your terminal instead of step 1."
        echo ""

        if [ "$REMOTE_EXECUTION" = false ]; then
            echo "For more information, see: $SCRIPT_DIR/README.md"
        else
            echo "For more information, visit: https://github.com/michakfromparis/zsh-pnpm-completions"
        fi
    else
        echo ""
        log_error "Installation failed. Check the log for details: $LOG_FILE"
        exit 1
    fi
}

# Run main function with all arguments
main "$@" 
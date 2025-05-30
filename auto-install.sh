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

# Dependency checking
check_dependencies() {
    local missing_deps=()
    local optional_missing=()
    
    # Check zsh
    if ! command -v zsh >/dev/null 2>&1; then
        missing_deps+=("zsh")
    fi
    
    # Check git
    if ! command -v git >/dev/null 2>&1; then
        missing_deps+=("git")
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
    else
        inject_config "plugins=($PLUGIN_NAME)"
    fi
    
    log_success "Oh My Zsh installation completed!"
    return 0
}

install_antigen() {
    log_info "Installing for Antigen..."
    
    backup_zshrc
    inject_config "antigen bundle $PLUGIN_NAME"
    
    log_success "Antigen installation completed!"
    log_info "Run 'antigen reset' to reload if needed"
    return 0
}

install_zplug() {
    log_info "Installing for zplug..."
    
    backup_zshrc
    inject_config "zplug \"michakfromparis/zsh-pnpm-completions\", defer:2"
    
    log_success "zplug installation completed!"
    log_info "Run 'zplug install' to install the plugin"
    return 0
}

install_zinit() {
    log_info "Installing for Zinit..."
    
    backup_zshrc
    inject_config "zinit load \"michakfromparis/zsh-pnpm-completions\""
    
    log_success "Zinit installation completed!"
    return 0
}

install_prezto() {
    log_info "Installing for Prezto..."
    
    local prezto_dir="${ZDOTDIR:-$HOME}/.zprezto/modules/$PLUGIN_NAME"
    
    create_directories "$prezto_dir"
    copy_files "$prezto_dir"
    
    # Create init.zsh for Prezto
    cat > "$prezto_dir/init.zsh" << 'EOF'
#
# Loads zsh-pnpm-completions
#

source "${0:h}/zsh-pnpm-completions.plugin.zsh"
EOF

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
    
    log_success "Prezto installation completed!"
    return 0
}

install_manual() {
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

# Main installation orchestration
install_plugin() {
    local force_method="$1"
    local managers=()
    local success=false
    
    if [ -n "$force_method" ]; then
        log_info "Forcing installation method: $force_method"
        case "$force_method" in
            oh-my-zsh) install_oh_my_zsh && success=true ;;
            antigen) install_antigen && success=true ;;
            zplug) install_zplug && success=true ;;
            zinit) install_zinit && success=true ;;
            prezto) install_prezto && success=true ;;
            manual) install_manual && success=true ;;
            *) log_error "Unknown installation method: $force_method" ;;
        esac
    else
        # Auto-detect and try in order of preference
        while IFS= read -r manager; do
            managers+=("$manager")
        done < <(detect_plugin_managers)
        
        if [ ${#managers[@]} -eq 0 ]; then
            log_info "No plugin managers detected, using manual installation"
            install_manual && success=true
        else
            log_info "Detected plugin managers: ${managers[*]}"
            
            for manager in "${managers[@]}"; do
                log_info "Attempting installation for $manager..."
                case "$manager" in
                    oh-my-zsh) install_oh_my_zsh && success=true && break ;;
                    prezto) install_prezto && success=true && break ;;
                    antigen) install_antigen && success=true && break ;;
                    zplug) install_zplug && success=true && break ;;
                    zinit) install_zinit && success=true && break ;;
                esac
            done
            
            # Fallback to manual if all failed
            if [ "$success" = false ]; then
                log_warning "All plugin manager installations failed, falling back to manual installation"
                install_manual && success=true
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
    echo "Auto-install zsh-pnpm-completions with environment detection"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -m, --method METHOD     Force specific installation method"
    echo "                          Methods: oh-my-zsh, antigen, zplug, zinit, prezto, manual"
    echo "  -v, --verbose           Enable verbose logging"
    echo "  --dry-run              Show what would be done without making changes"
    echo ""
    echo "Examples:"
    echo "  $0                      # Auto-detect and install"
    echo "  $0 -m manual           # Force manual installation"
    echo "  $0 -m oh-my-zsh        # Force Oh My Zsh installation"
    echo ""
}

# Command line argument parsing
parse_args() {
    local method=""
    local verbose=false
    local dry_run=false
    
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
            *)
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    echo "$method|$verbose|$dry_run"
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
    local method verbose dry_run
    
    args=$(parse_args "$@")
    IFS='|' read -r method verbose dry_run <<< "$args"
    
    print_banner
    
    # Initialize logging
    rm -f "$LOG_FILE"
    log_info "Starting zsh-pnpm-completions auto-installation"
    log_info "Log file: $LOG_FILE"
    
    # Environment detection
    local os shell
    os=$(detect_os)
    shell=$(detect_shell)
    
    log_info "Detected OS: $os"
    log_info "Detected shell: $shell"
    
    if [ "$shell" != "zsh" ]; then
        log_warning "Current shell is $shell, but this plugin requires zsh"
        echo "Switch to zsh or ensure zsh is your login shell for the plugin to work."
    fi
    
    # Check dependencies
    if ! check_dependencies; then
        exit 1
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
    if install_plugin "$method"; then
        echo ""
        log_success "🎉 Installation completed successfully!"
        echo ""
        echo "To activate the plugin:"
        echo "  1. Restart your terminal, or"
        echo "  2. Run: source ~/.zshrc"
        echo ""
        echo "Then try: pnpm run <TAB> to test completions!"
        echo ""
        echo "For more information, see: $SCRIPT_DIR/README.md"
    else
        echo ""
        log_error "Installation failed. Check the log for details: $LOG_FILE"
        exit 1
    fi
}

# Run main function with all arguments
main "$@" 
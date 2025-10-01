#!/usr/bin/env bash

# Installation script for zsh-pnpm-completions
# This script helps install the plugin for various zsh plugin managers

set -e

PLUGIN_NAME="zsh-pnpm-completions"
PLUGIN_DIR=""
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

usage() {
    echo "Usage: $0 [OPTION] [DIRECTORY]"
    echo ""
    echo "Install zsh-pnpm-completions plugin"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -o, --oh-my-zsh     Install as Oh My Zsh plugin (default)"
    echo "  -m, --manual        Install manually to specified directory"
    echo "      --no-aliases    Install without loading aliases"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Install to Oh My Zsh"
    echo "  $0 -m ~/.zsh-plugins                 # Manual install"
    echo "  $0 --oh-my-zsh                       # Explicit Oh My Zsh install"
    echo "  $0 --no-aliases                      # Install without aliases"
    echo ""
}

install_oh_my_zsh() {
    local no_aliases=false
    if [ "$1" = "--no-aliases" ]; then
        no_aliases=true
    fi

    PLUGIN_DIR="$ZSH_CUSTOM/plugins/$PLUGIN_NAME"

    echo "Installing $PLUGIN_NAME for Oh My Zsh..."
    echo "Target directory: $PLUGIN_DIR"

    if [ -d "$PLUGIN_DIR" ]; then
        echo "Plugin directory already exists. Updating..."
        rm -rf "$PLUGIN_DIR"
    fi

    mkdir -p "$PLUGIN_DIR"
    cp zsh-pnpm-completions.zsh "$PLUGIN_DIR/"
    cp zsh-pnpm-completions.plugin.zsh "$PLUGIN_DIR/"
    cp zsh-pnpm-aliases.zsh "$PLUGIN_DIR/"
    cp README.md "$PLUGIN_DIR/"
    cp LICENSE "$PLUGIN_DIR/"

    echo "✅ Plugin installed successfully!"
    echo ""
    echo "To activate the plugin, add '$PLUGIN_NAME' to your plugins array in ~/.zshrc:"
    echo ""
    echo "  plugins=(... $PLUGIN_NAME)"
    if [ "$no_aliases" = true ]; then
        echo "  export ZSH_PNPM_NO_ALIASES=1"
    fi
    echo ""
    echo "Then restart your terminal or run: source ~/.zshrc"
}

install_manual() {
    local target_dir=""
    local no_aliases=false

    # Parse arguments - first arg is directory, second may be --no-aliases
    if [ -z "$1" ]; then
        echo "Error: Manual installation requires a target directory"
        echo "Usage: $0 -m <directory>"
        exit 1
    fi

    target_dir="$1"
    if [ "$2" = "--no-aliases" ]; then
        no_aliases=true
    fi

    PLUGIN_DIR="$target_dir"

    echo "Installing $PLUGIN_NAME manually..."
    echo "Target directory: $PLUGIN_DIR"

    mkdir -p "$PLUGIN_DIR"
    cp zsh-pnpm-completions.zsh "$PLUGIN_DIR/"
    cp zsh-pnpm-completions.plugin.zsh "$PLUGIN_DIR/"
    cp zsh-pnpm-aliases.zsh "$PLUGIN_DIR/"
    cp README.md "$PLUGIN_DIR/"
    cp LICENSE "$PLUGIN_DIR/"

    echo "✅ Plugin installed successfully!"
    echo ""
    echo "To activate the plugin, add this line to your ~/.zshrc:"
    echo ""
    echo "  source $PLUGIN_DIR/zsh-pnpm-completions.plugin.zsh"
    if [ "$no_aliases" = true ]; then
        echo "  export ZSH_PNPM_NO_ALIASES=1"
    fi
    echo ""
    echo "Then restart your terminal or run: source ~/.zshrc"
}

check_dependencies() {
    if ! command -v pnpm >/dev/null 2>&1; then
        echo "⚠️  Warning: pnpm is not installed or not in PATH"
        echo "   Install pnpm to get full completion functionality"
        echo "   Visit: https://pnpm.io/installation"
        echo ""
    fi
    
    if [ -z "$ZSH_VERSION" ]; then
        echo "⚠️  Warning: This plugin requires zsh"
        echo "   Make sure you're running zsh as your shell"
        echo ""
    fi
}

main() {
    check_dependencies

    # Parse arguments
    local no_aliases=false
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -o|--oh-my-zsh)
                if [ "$no_aliases" = true ]; then
                    install_oh_my_zsh --no-aliases
                else
                    install_oh_my_zsh
                fi
                exit 0
                ;;
            -m|--manual)
                if [ "$no_aliases" = true ]; then
                    install_manual "$2" --no-aliases
                else
                    install_manual "$2"
                fi
                exit 0
                ;;
            --no-aliases)
                no_aliases=true
                shift
                ;;
            "")
                # Default to Oh My Zsh if available
                if [ -d "$ZSH_CUSTOM" ]; then
                    if [ "$no_aliases" = true ]; then
                        install_oh_my_zsh --no-aliases
                    else
                        install_oh_my_zsh
                    fi
                else
                    echo "Oh My Zsh not found. Please specify installation method:"
                    usage
                    exit 1
                fi
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    # Default behavior when no arguments
    if [ -d "$ZSH_CUSTOM" ]; then
        install_oh_my_zsh
    else
        echo "Oh My Zsh not found. Please specify installation method:"
        usage
        exit 1
    fi
}

main "$@" 
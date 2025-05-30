#!/usr/bin/env zsh

# Simple test script for pnpm completions
# Usage: source this file in your zsh session to test completions

echo "Testing pnpm completions..."

# Source the completions
source ./zsh-pnpm-completions.zsh

echo "✓ Completions loaded successfully!"
echo ""
echo "Try testing these completions:"
echo "  pnpm <TAB>           - Should show all pnpm commands"
echo "  pnpm run <TAB>       - Should show package.json scripts (if in a project)"
echo "  pnpm add <TAB>       - Should show available packages from cache"
echo "  pnpm remove <TAB>    - Should show installed packages from package.json"
echo ""
echo "Test aliases:"
echo "  p <TAB>              - Should work same as pnpm"
echo "  pa <TAB>             - Should work same as pnpm add"
echo "  pr <TAB>             - Should work same as pnpm remove"
echo ""

# Test if pnpm command exists
if command -v pnpm >/dev/null 2>&1; then
    echo "✓ pnpm is installed"
    echo "pnpm version: $(pnpm --version)"
else
    echo "⚠ pnpm is not installed or not in PATH"
    echo "Install pnpm to get full completion functionality"
fi

echo ""
echo "Test completed. Try the completions mentioned above!" 
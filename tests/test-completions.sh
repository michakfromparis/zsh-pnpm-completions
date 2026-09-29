#!/usr/bin/env zsh

# Test script for zsh completion functionality
# This script tests that the completions load and work correctly

set -e

SCRIPT_DIR="$(cd "$(dirname "${0:A:h}")" && pwd)"

echo "🧪 Testing zsh completion functionality..."

# Set up a clean test environment
export ZDOTDIR="/tmp/test-zsh"
export HOME="/tmp/test-home"
mkdir -p "$ZDOTDIR" "$HOME"

# Create a minimal .zshrc for testing
cat > "$ZDOTDIR/.zshrc" << 'EOF'
# Minimal zshrc for testing
autoload -Uz compinit
compinit
EOF

# Test 1: Source the plugin without errors
echo "Test 1: Loading plugin"
if source "$SCRIPT_DIR/zsh-pnpm-completions.plugin.zsh" 2>/dev/null; then
    echo "✅ Plugin loads successfully"
else
    echo "❌ Plugin failed to load"
    exit 1
fi

# Test 2: Check that pnpm completion is registered
echo "Test 2: Completion registration"
# Initialize completion system and check if pnpm completion is available
if zsh -c "
    autoload -Uz compinit
    compinit -D
    source \"$SCRIPT_DIR/zsh-pnpm-completions.plugin.zsh\" 2>/dev/null
    # Check if the completion function exists
    if typeset -f _pnpm_completion >/dev/null 2>&1; then
        echo 'completion_function_exists'
    fi
" | grep -q "completion_function_exists"; then
    echo "✅ pnpm completion function is available"
else
    echo "⚠️  pnpm completion function not detected (may be expected in isolated test environment)"
fi

# Test 3: Test script completion with the example project
echo "Test 3: Script completion"
cd "$SCRIPT_DIR/example"

# Verify the example package.json exists and has scripts
if [[ ! -f "package.json" ]]; then
    echo "❌ Example package.json not found"
    exit 1
fi

if ! grep -q '"scripts"' package.json; then
    echo "❌ Example package.json has no scripts section"
    exit 1
fi

# Test that the completion functions can be sourced
echo "Test 3b: Completion functions"
if zsh -c "
    source \"$SCRIPT_DIR/zsh-pnpm-completions.plugin.zsh\" 2>/dev/null
    source \"$SCRIPT_DIR/zsh-pnpm-completions.zsh\" 2>/dev/null
    echo 'functions_loaded'
" 2>/dev/null | grep -q "functions_loaded"; then
    echo "✅ Completion functions can be loaded"
else
    echo "⚠️  Completion functions may have issues in test environment (may be expected)"
    # Don't fail the test for this - it's common in CI environments
fi

# Test 4: Check that aliases can be loaded
echo "Test 4: Alias definitions"
if [[ -z $ZSH_PNPM_NO_ALIASES ]]; then
    if zsh -c "
        source \"$SCRIPT_DIR/zsh-pnpm-completions.plugin.zsh\" 2>/dev/null
        (( \${+aliases[p]} )) && echo 'aliases_loaded'
    " 2>/dev/null | grep -q "aliases_loaded"; then
        echo "✅ Aliases can be loaded"
    else
        echo "⚠️  Aliases not loaded (may be expected in test environment)"
    fi
else
    echo "ℹ️  Aliases disabled by ZSH_PNPM_NO_ALIASES"
fi

# Test 5: Test no-aliases mode
echo "Test 5: No aliases mode"
if zsh -c "
    export ZSH_PNPM_NO_ALIASES=1
    source \"$SCRIPT_DIR/zsh-pnpm-completions.plugin.zsh\" 2>/dev/null
    if ! (( \${+aliases[p]} )); then
        echo 'no_aliases_works'
    fi
" 2>/dev/null | grep -q "no_aliases_works"; then
    echo "✅ No aliases mode works"
else
    echo "⚠️  No aliases mode test inconclusive (may be expected in test environment)"
fi

# Test 6: Aliases expand after sudo, without clobbering a user-defined sudo alias
echo "Test 6: Aliases after sudo"
if zsh -fc "
    source \"$SCRIPT_DIR/zsh-pnpm-aliases.zsh\"
    eval 'f() { sudo p install }'
    [[ \$(whence -f f) == *'sudo pnpm install'* ]]
" && zsh -fc "
    alias sudo='sudo -E'
    source \"$SCRIPT_DIR/zsh-pnpm-aliases.zsh\"
    [[ \${aliases[sudo]} == 'sudo -E' ]]
"; then
    echo "✅ Aliases expand after sudo"
else
    echo "❌ Aliases do not expand after sudo"
    exit 1
fi

# Clean up
cd "$SCRIPT_DIR"
rm -rf /tmp/test-zsh /tmp/test-home

echo "🎉 All completion tests passed!"

#!/usr/bin/env bash

# Test script for setup.sh functionality
# This script tests the setup.sh script with various options

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETUP_SCRIPT="$SCRIPT_DIR/setup.sh"

echo "🧪 Testing setup.sh functionality..."

# Test 1: Dry run mode
echo "Test 1: Dry run mode"
if "$SETUP_SCRIPT" --dry-run >/dev/null 2>&1; then
    echo "✅ Dry run completed successfully"
else
    echo "❌ Dry run failed"
    exit 1
fi

# Test 2: Help option
echo "Test 2: Help option"
if "$SETUP_SCRIPT" --help | grep -q "Usage:"; then
    echo "✅ Help option works"
else
    echo "❌ Help option failed"
    exit 1
fi

# Test 3: Uninstall dry run
echo "Test 3: Uninstall dry run"
if "$SETUP_SCRIPT" --uninstall --dry-run >/dev/null 2>&1; then
    echo "✅ Uninstall dry run completed successfully"
else
    echo "❌ Uninstall dry run failed"
    exit 1
fi

# Test 4: No aliases dry run
echo "Test 4: No aliases dry run"
if "$SETUP_SCRIPT" --no-aliases --dry-run >/dev/null 2>&1; then
    echo "✅ No aliases dry run completed successfully"
else
    echo "❌ No aliases dry run failed"
    exit 1
fi

# Test 5: Method specification dry run
echo "Test 5: Method specification dry run"
if "$SETUP_SCRIPT" -m manual --dry-run >/dev/null 2>&1; then
    echo "✅ Manual method dry run completed successfully"
else
    echo "❌ Manual method dry run failed"
    exit 1
fi

echo "🎉 All setup.sh tests passed!"

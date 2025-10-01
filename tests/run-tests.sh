#!/usr/bin/env bash

# Main test runner script
# Run all tests for the zsh-pnpm-completions project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🧪 Running zsh-pnpm-completions test suite..."
echo "=================================================="

# Test 1: Package validation
echo ""
echo "📦 Running package validation tests..."
if npm run test:uninstall && npm pack --dry-run; then
    echo "✅ Package validation passed"
else
    echo "❌ Package validation failed"
    exit 1
fi

# Test 2: Shell syntax validation
echo ""
echo "🐚 Running shell syntax validation..."
if npm run test:shell; then
    echo "✅ Shell syntax validation passed"
else
    echo "❌ Shell syntax validation failed"
    exit 1
fi

# Test 3: Setup script tests
echo ""
echo "⚙️  Running setup script tests..."
if npm run test:setup; then
    echo "✅ Setup script tests passed"
else
    echo "❌ Setup script tests failed"
    exit 1
fi

# Test 4: Completion tests
echo ""
echo "🔧 Running completion tests..."
if npm run test:completions; then
    echo "✅ Completion tests passed"
else
    echo "❌ Completion tests failed"
    exit 1
fi

# Test 5: Bats tests (if available)
echo ""
echo "🦇 Running bats tests..."
if command -v bats >/dev/null 2>&1; then
    if bats tests/setup.bats; then
        echo "✅ Bats tests passed"
    else
        echo "❌ Bats tests failed"
        exit 1
    fi
else
    echo "ℹ️  Bats not available, skipping bats tests"
fi

echo ""
echo "=================================================="
echo "🎉 All tests passed successfully!"
echo ""
echo "You can now use these badges in your README:"
echo "- CI Status: ![CI](https://github.com/michakfromparis/zsh-pnpm-completions/actions/workflows/test.yml/badge.svg)"
echo "- npm Version: ![npm version](https://badge.fury.io/js/zsh-pnpm-completions.svg)"
echo "- License: ![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)"
echo "- Node Version: ![Node.js Version](https://img.shields.io/badge/node-%3E%3D14-brightgreen)"

#!/usr/bin/env bats

# Bats tests for setup.sh functionality

SCRIPT_DIR="$(cd "$(dirname "${BATS_TEST_DIRNAME}")" && pwd)"
SETUP_SCRIPT="$SCRIPT_DIR/setup.sh"

setup() {
    # Clean up any previous test state
    export HOME="/tmp/test-home-bats"
    export ZDOTDIR="/tmp/test-zsh-bats"
    mkdir -p "$HOME" "$ZDOTDIR"
}

teardown() {
    # Clean up test state
    rm -rf "/tmp/test-home-bats" "/tmp/test-zsh-bats"
}

@test "setup.sh --dry-run should succeed" {
    run "$SETUP_SCRIPT" --dry-run
    [ "$status" -eq 0 ]
}

@test "setup.sh --help should show usage" {
    run "$SETUP_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
}

@test "setup.sh --uninstall --dry-run should succeed" {
    run "$SETUP_SCRIPT" --uninstall --dry-run
    [ "$status" -eq 0 ]
}

@test "setup.sh --no-aliases --dry-run should succeed" {
    run "$SETUP_SCRIPT" --no-aliases --dry-run
    [ "$status" -eq 0 ]
}

@test "setup.sh -m manual --dry-run should succeed" {
    run "$SETUP_SCRIPT" -m manual --dry-run
    [ "$status" -eq 0 ]
}

@test "setup.sh with invalid method should fail" {
    run "$SETUP_SCRIPT" -m invalid-method --dry-run
    [ "$status" -ne 0 ]
}

@test "setup.sh should detect environment correctly" {
    run "$SETUP_SCRIPT" --dry-run
    [ "$status" -eq 0 ]
    # Should contain some environment detection output
    [[ "$output" =~ "Detected OS:" ]]
}

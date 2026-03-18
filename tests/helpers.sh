#!/bin/bash
# solo-dev test helpers

PASS=0
FAIL=0
TOTAL=0

assert_eq() {
  TOTAL=$((TOTAL + 1))
  if [ "$1" = "$2" ]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: $3"
    echo "    expected: '$1'"
    echo "    got:      '$2'"
  fi
}

assert_contains() {
  TOTAL=$((TOTAL + 1))
  if echo "$1" | grep -q "$2" 2>/dev/null; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: output should contain '$2'"
    echo "    got: $(echo "$1" | head -5)"
  fi
}

assert_not_contains() {
  TOTAL=$((TOTAL + 1))
  if ! echo "$1" | grep -q "$2" 2>/dev/null; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: output should NOT contain '$2'"
  fi
}

assert_file_exists() {
  TOTAL=$((TOTAL + 1))
  if [ -f "$1" ]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: file should exist: $1"
  fi
}

assert_file_not_exists() {
  TOTAL=$((TOTAL + 1))
  if [ ! -f "$1" ]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: file should NOT exist: $1"
  fi
}

assert_file_contains() {
  TOTAL=$((TOTAL + 1))
  if grep -q "$2" "$1" 2>/dev/null; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: $1 should contain '$2'"
  fi
}

assert_exit_code() {
  TOTAL=$((TOTAL + 1))
  if [ "$1" -eq "$2" ]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: $3 (expected exit $2, got $1)"
  fi
}

assert_line_count_lte() {
  TOTAL=$((TOTAL + 1))
  local count
  count=$(wc -l < "$1" 2>/dev/null | tr -d ' ')
  if [ "$count" -le "$2" ]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: $1 has $count lines, expected <= $2"
  fi
}

report() {
  echo ""
  echo "=== $1: $PASS/$TOTAL passed, $FAIL failed ==="
  [ "$FAIL" -eq 0 ]
}

setup_mock_project() {
  TMPDIR=$(mktemp -d)
  PROJECT_DIR="$TMPDIR/project"
  mkdir -p "$PROJECT_DIR/docs/yaml"
  mkdir -p "$PROJECT_DIR/docs/product"
  mkdir -p "$PROJECT_DIR/docs/agents/memory/snapshots"
  mkdir -p "$PROJECT_DIR/docs/specs"
  mkdir -p "$PROJECT_DIR/docs/contracts"
  mkdir -p "$PROJECT_DIR/docs/demos"
  mkdir -p "$PROJECT_DIR/.claude"
  export PROJECT_DIR
  export CLAUDE_PROJECT_DIR="$PROJECT_DIR"
  export CLAUDE_ENV_FILE="$TMPDIR/env"
  touch "$CLAUDE_ENV_FILE"
}

teardown() {
  rm -rf "$TMPDIR"
}

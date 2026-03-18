#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/helpers.sh"

REPACK_SCRIPT="$PLUGIN_DIR/hooks/scripts/repack-check.sh"

echo "--- test-repack-check ---"

# Test 1: Source file (.ts) changed -> repack recommended
setup_mock_project
cat > "$PROJECT_DIR/.claude/solo-dev-state.json" <<'EOF'
{"phase": "BUILD", "repomix_repack_needed": false}
EOF
result=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$REPACK_SCRIPT" "src/app.ts" 2>&1)
result_exit=$?
assert_exit_code $result_exit 0 "repack-check exits 0 for source file"
assert_contains "$result" "repack" "source .ts file triggers repack message"
# Verify state file was updated
state_repack=$(python3 -c "import json; d=json.load(open('$PROJECT_DIR/.claude/solo-dev-state.json')); print(d.get('repomix_repack_needed', False))" 2>/dev/null)
assert_eq "True" "$state_repack" "state file repomix_repack_needed set to True"
teardown

# Test 2: Doc file (.md) changed -> no repack
setup_mock_project
cat > "$PROJECT_DIR/.claude/solo-dev-state.json" <<'EOF'
{"phase": "BUILD", "repomix_repack_needed": false}
EOF
result=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$REPACK_SCRIPT" "docs/readme.md" 2>&1)
assert_not_contains "$result" "repack" ".md file should not trigger repack"
# State should remain false
state_repack=$(python3 -c "import json; d=json.load(open('$PROJECT_DIR/.claude/solo-dev-state.json')); print(d.get('repomix_repack_needed', False))" 2>/dev/null)
assert_eq "False" "$state_repack" "state file repomix_repack_needed stays False for .md"
teardown

# Test 3: Test file changed -> no repack
setup_mock_project
cat > "$PROJECT_DIR/.claude/solo-dev-state.json" <<'EOF'
{"phase": "BUILD", "repomix_repack_needed": false}
EOF
result=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$REPACK_SCRIPT" "src/auth.test.ts" 2>&1)
assert_not_contains "$result" "repack" ".test.ts file should not trigger repack"
teardown

# Test 4: No changes (no file argument) -> no repack
setup_mock_project
cat > "$PROJECT_DIR/.claude/solo-dev-state.json" <<'EOF'
{"phase": "BUILD", "repomix_repack_needed": false}
EOF
result=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$REPACK_SCRIPT" "" 2>&1)
result_exit=$?
assert_exit_code $result_exit 0 "empty file arg exits 0"
teardown

# Test 5: JSON config file -> no repack
setup_mock_project
cat > "$PROJECT_DIR/.claude/solo-dev-state.json" <<'EOF'
{"phase": "BUILD", "repomix_repack_needed": false}
EOF
result=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$REPACK_SCRIPT" "tsconfig.json" 2>&1)
assert_not_contains "$result" "repack" ".json file should not trigger repack"
teardown

# Test 6: YAML file -> no repack
setup_mock_project
cat > "$PROJECT_DIR/.claude/solo-dev-state.json" <<'EOF'
{"phase": "BUILD", "repomix_repack_needed": false}
EOF
result=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$REPACK_SCRIPT" "config.yaml" 2>&1)
assert_not_contains "$result" "repack" ".yaml file should not trigger repack"
teardown

# Test 7: .py source file -> repack recommended
setup_mock_project
cat > "$PROJECT_DIR/.claude/solo-dev-state.json" <<'EOF'
{"phase": "BUILD", "repomix_repack_needed": false}
EOF
result=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$REPACK_SCRIPT" "app/main.py" 2>&1)
assert_contains "$result" "repack" "source .py file triggers repack message"
teardown

# Test 8: File in tests/ directory -> no repack
setup_mock_project
cat > "$PROJECT_DIR/.claude/solo-dev-state.json" <<'EOF'
{"phase": "BUILD", "repomix_repack_needed": false}
EOF
result=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$REPACK_SCRIPT" "tests/unit/test_auth.py" 2>&1)
assert_not_contains "$result" "repack" "tests/ directory file should not trigger repack"
teardown

# Test 9: No state file -> still outputs message for source file
setup_mock_project
rm -f "$PROJECT_DIR/.claude/solo-dev-state.json"
result=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$REPACK_SCRIPT" "src/index.tsx" 2>&1)
result_exit=$?
assert_exit_code $result_exit 0 "no state file exits 0"
assert_contains "$result" "repack" "source file triggers message even without state file"
teardown

report "test-repack-check"

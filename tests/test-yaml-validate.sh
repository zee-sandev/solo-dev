#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/helpers.sh"

VALIDATE_SCRIPT="$PLUGIN_DIR/hooks/scripts/yaml-validate.sh"
CONVERTER_SCRIPT="$PLUGIN_DIR/hooks/scripts/yaml-to-markdown.sh"

echo "--- test-yaml-validate ---"

# Test 1: Clean state (empty YAML files with pre-generated markdown) — 0 mismatches
setup_mock_project
for f in features specs contracts demos sprints changelog backlog; do
  cp "$PLUGIN_DIR/docs/yaml/$f.yaml" "$PROJECT_DIR/docs/yaml/$f.yaml"
done
# Use a list-based memory-index (empty) so converter handles it correctly
cat > "$PROJECT_DIR/docs/yaml/memory-index.yaml" <<'MEOF'
version: 1
project: ""
files: []
MEOF
# Pre-generate markdown views so validate finds no mismatches
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$CONVERTER_SCRIPT" --all 2>/dev/null
result=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" bash "$VALIDATE_SCRIPT" 2>&1)
result_exit=$?
assert_exit_code $result_exit 0 "clean state should exit 0"
assert_contains "$result" "0 mismatches" "clean state reports 0 mismatches"
teardown

# Test 2: specs.yaml pointing to non-existent file
setup_mock_project
for f in features contracts demos sprints changelog backlog; do
  cp "$PLUGIN_DIR/docs/yaml/$f.yaml" "$PROJECT_DIR/docs/yaml/$f.yaml"
done
cp "$PLUGIN_DIR/docs/yaml/memory-index.yaml" "$PROJECT_DIR/docs/yaml/memory-index.yaml"
# Pre-generate existing markdown views
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$CONVERTER_SCRIPT" --all 2>/dev/null
cat > "$PROJECT_DIR/docs/yaml/specs.yaml" <<'EOF'
version: 1
specs:
  - feature_id: A1
    path: docs/specs/missing-file.md
    status: draft
EOF
result=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" bash "$VALIDATE_SCRIPT" 2>&1)
assert_contains "$result" "mismatch" "specs pointing to missing file reports mismatch"
teardown

# Test 3: Auto-repair (features with data but no roadmap.md)
setup_mock_project
for f in specs contracts demos sprints changelog backlog; do
  cp "$PLUGIN_DIR/docs/yaml/$f.yaml" "$PROJECT_DIR/docs/yaml/$f.yaml"
done
cp "$PLUGIN_DIR/docs/yaml/memory-index.yaml" "$PROJECT_DIR/docs/yaml/memory-index.yaml"
# Pre-generate markdown for everything except features
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$CONVERTER_SCRIPT" --all 2>/dev/null
cat > "$PROJECT_DIR/docs/yaml/features.yaml" <<'EOF'
version: 1
features:
  - id: A1
    name: Auth
    phase: A
    status: QUEUED
    value: Core
EOF
# Ensure roadmap.md does NOT exist (overwritten features needs regeneration)
rm -f "$PROJECT_DIR/docs/product/roadmap.md"
result=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" bash "$VALIDATE_SCRIPT" 2>&1)
# After auto-repair, roadmap.md should be regenerated
assert_file_exists "$PROJECT_DIR/docs/product/roadmap.md" "auto-repair regenerated roadmap.md"
assert_contains "$result" "fixed" "output mentions auto-repair (fixed)"
teardown

# Test 4: No docs/yaml/ directory (backward compat)
setup_mock_project
rm -rf "$PROJECT_DIR/docs/yaml"
result=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" bash "$VALIDATE_SCRIPT" 2>&1)
result_exit=$?
assert_exit_code $result_exit 0 "no yaml dir should exit 0"
teardown

report "test-yaml-validate"

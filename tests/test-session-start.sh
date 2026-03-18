#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SESSION_SCRIPT="$PLUGIN_DIR/hooks/scripts/session-start.sh"

echo "--- test-session-start ---"

# Test 1: Fresh project (no state file)
setup_mock_project
# Copy empty YAML files so yaml-validate does not error
for f in features specs contracts demos sprints changelog backlog; do
  cp "$PLUGIN_DIR/docs/yaml/$f.yaml" "$PROJECT_DIR/docs/yaml/$f.yaml"
done
cp "$PLUGIN_DIR/docs/yaml/memory-index.yaml" "$PROJECT_DIR/docs/yaml/memory-index.yaml"
result=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" CLAUDE_ENV_FILE="$CLAUDE_ENV_FILE" CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" bash "$SESSION_SCRIPT" 2>/dev/null)
assert_contains "$result" "New project" "fresh project shows New project"
assert_file_contains "$CLAUDE_ENV_FILE" "SAAS_DEV_PHASE=INIT" "env file has INIT phase"
teardown

# Test 2: Resume mid-feature
setup_mock_project
for f in features specs contracts demos sprints changelog backlog; do
  cp "$PLUGIN_DIR/docs/yaml/$f.yaml" "$PROJECT_DIR/docs/yaml/$f.yaml"
done
cp "$PLUGIN_DIR/docs/yaml/memory-index.yaml" "$PROJECT_DIR/docs/yaml/memory-index.yaml"
cat > "$PROJECT_DIR/.claude/solo-dev-state.json" <<'EOF'
{"phase": "DESIGN_LOOP", "current_feature": "A1"}
EOF
result=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" CLAUDE_ENV_FILE="$CLAUDE_ENV_FILE" CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" bash "$SESSION_SCRIPT" 2>/dev/null)
assert_contains "$result" "Resuming" "resume shows Resuming"
assert_contains "$result" "DESIGN_LOOP" "resume shows DESIGN_LOOP"
assert_file_contains "$CLAUDE_ENV_FILE" "SAAS_DEV_PHASE=DESIGN_LOOP" "env file has DESIGN_LOOP"
teardown

# Test 3: Stack detection — Next.js
setup_mock_project
for f in features specs contracts demos sprints changelog backlog; do
  cp "$PLUGIN_DIR/docs/yaml/$f.yaml" "$PROJECT_DIR/docs/yaml/$f.yaml"
done
cp "$PLUGIN_DIR/docs/yaml/memory-index.yaml" "$PROJECT_DIR/docs/yaml/memory-index.yaml"
cat > "$PROJECT_DIR/package.json" <<'EOF'
{"dependencies": {"next": "15.0.0"}}
EOF
result=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" CLAUDE_ENV_FILE="$CLAUDE_ENV_FILE" CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" bash "$SESSION_SCRIPT" 2>/dev/null)
assert_contains "$result" "nextjs" "detects nextjs stack"
teardown

# Test 4: Stack detection — Django
setup_mock_project
for f in features specs contracts demos sprints changelog backlog; do
  cp "$PLUGIN_DIR/docs/yaml/$f.yaml" "$PROJECT_DIR/docs/yaml/$f.yaml"
done
cp "$PLUGIN_DIR/docs/yaml/memory-index.yaml" "$PROJECT_DIR/docs/yaml/memory-index.yaml"
touch "$PROJECT_DIR/manage.py"
result=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" CLAUDE_ENV_FILE="$CLAUDE_ENV_FILE" CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" bash "$SESSION_SCRIPT" 2>/dev/null)
assert_contains "$result" "django" "detects django stack"
teardown

# Test 5: Stack detection — Go
setup_mock_project
for f in features specs contracts demos sprints changelog backlog; do
  cp "$PLUGIN_DIR/docs/yaml/$f.yaml" "$PROJECT_DIR/docs/yaml/$f.yaml"
done
cp "$PLUGIN_DIR/docs/yaml/memory-index.yaml" "$PROJECT_DIR/docs/yaml/memory-index.yaml"
touch "$PROJECT_DIR/go.mod"
result=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" CLAUDE_ENV_FILE="$CLAUDE_ENV_FILE" CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" bash "$SESSION_SCRIPT" 2>/dev/null)
assert_contains "$result" "go" "detects go stack"
teardown

# Test 6: Stack detection — unknown
setup_mock_project
for f in features specs contracts demos sprints changelog backlog; do
  cp "$PLUGIN_DIR/docs/yaml/$f.yaml" "$PROJECT_DIR/docs/yaml/$f.yaml"
done
cp "$PLUGIN_DIR/docs/yaml/memory-index.yaml" "$PROJECT_DIR/docs/yaml/memory-index.yaml"
result=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" CLAUDE_ENV_FILE="$CLAUDE_ENV_FILE" CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" bash "$SESSION_SCRIPT" 2>/dev/null)
assert_contains "$result" "unknown" "detects unknown stack"
teardown

# Test 7: Memory index loaded
setup_mock_project
for f in features specs contracts demos sprints changelog backlog; do
  cp "$PLUGIN_DIR/docs/yaml/$f.yaml" "$PROJECT_DIR/docs/yaml/$f.yaml"
done
cp "$PLUGIN_DIR/docs/yaml/memory-index.yaml" "$PROJECT_DIR/docs/yaml/memory-index.yaml"
echo "Test Memory Content" > "$PROJECT_DIR/docs/agents/memory/index.md"
result=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" CLAUDE_ENV_FILE="$CLAUDE_ENV_FILE" CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" bash "$SESSION_SCRIPT" 2>/dev/null)
assert_contains "$result" "Test Memory Content" "memory index content loaded"
teardown

report "test-session-start"

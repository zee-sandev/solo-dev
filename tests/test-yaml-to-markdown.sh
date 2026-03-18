#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCRIPT="$PLUGIN_DIR/hooks/scripts/yaml-to-markdown.sh"

echo "--- test-yaml-to-markdown ---"

# Test 1: features.yaml -> roadmap.md with 3 features
setup_mock_project
cat > "$PROJECT_DIR/docs/yaml/features.yaml" <<'EOF'
version: 1
features:
  - id: A1
    name: User Authentication
    phase: A
    status: COMPLETE
    value: Core security
    dependencies: []
  - id: A2
    name: Dashboard
    phase: A
    status: IN_PROGRESS
    value: User engagement
    dependencies: [A1]
  - id: A3
    name: Settings Page
    phase: A
    status: QUEUED
    value: User control
    dependencies: []
EOF
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$SCRIPT" features.yaml
assert_file_exists "$PROJECT_DIR/docs/product/roadmap.md" "roadmap.md created"
assert_file_contains "$PROJECT_DIR/docs/product/roadmap.md" "User Authentication"
assert_file_contains "$PROJECT_DIR/docs/product/roadmap.md" "Dashboard"
assert_file_contains "$PROJECT_DIR/docs/product/roadmap.md" "Settings Page"
assert_file_contains "$PROJECT_DIR/docs/product/roadmap.md" "COMPLETE"
assert_file_contains "$PROJECT_DIR/docs/product/roadmap.md" "IN_PROGRESS"
assert_file_contains "$PROJECT_DIR/docs/product/roadmap.md" "QUEUED"
teardown

# Test 2: changelog.yaml -> CHANGELOG.md
setup_mock_project
cat > "$PROJECT_DIR/docs/yaml/changelog.yaml" <<'EOF'
version: 1
entries:
  - date: "2026-03-15"
    type: added
    description: User login and registration
  - date: "2026-03-18"
    type: added
    description: Main dashboard view
  - date: "2026-03-18"
    type: fixed
    description: Nav bar alignment
EOF
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$SCRIPT" changelog.yaml
assert_file_exists "$PROJECT_DIR/CHANGELOG.md" "CHANGELOG.md created"
assert_file_contains "$PROJECT_DIR/CHANGELOG.md" "2026-03-15"
assert_file_contains "$PROJECT_DIR/CHANGELOG.md" "2026-03-18"
assert_file_contains "$PROJECT_DIR/CHANGELOG.md" "Added"
assert_file_contains "$PROJECT_DIR/CHANGELOG.md" "User login and registration"
assert_file_contains "$PROJECT_DIR/CHANGELOG.md" "Fixed"
teardown

# Test 3: memory-index.yaml -> index.md
setup_mock_project
cat > "$PROJECT_DIR/docs/yaml/memory-index.yaml" <<'EOF'
version: 1
project: test-project
last_updated: "2026-03-19"
features_completed: 3
files:
  - file: decisions.md
    summary: Architecture decisions log
  - file: patterns.md
    summary: Code patterns reference
EOF
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$SCRIPT" memory-index.yaml
assert_file_exists "$PROJECT_DIR/docs/agents/memory/index.md" "index.md created"
assert_line_count_lte "$PROJECT_DIR/docs/agents/memory/index.md" 200
assert_file_contains "$PROJECT_DIR/docs/agents/memory/index.md" "test-project"
assert_file_contains "$PROJECT_DIR/docs/agents/memory/index.md" "decisions.md"
assert_file_contains "$PROJECT_DIR/docs/agents/memory/index.md" "patterns.md"
teardown

# Test 4: sprints.yaml -> sprints.md
setup_mock_project
cat > "$PROJECT_DIR/docs/yaml/sprints.yaml" <<'EOF'
version: 1
sprints:
  - id: S1
    name: Sprint 1 MVP
    status: IN_PROGRESS
    features:
      - name: A1
        status: COMPLETE
        effort: S
      - name: A2
        status: IN_PROGRESS
        effort: M
EOF
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$SCRIPT" sprints.yaml
assert_file_exists "$PROJECT_DIR/docs/product/sprints.md" "sprints.md created"
assert_file_contains "$PROJECT_DIR/docs/product/sprints.md" "Sprint 1 MVP"
assert_file_contains "$PROJECT_DIR/docs/product/sprints.md" "A1"
assert_file_contains "$PROJECT_DIR/docs/product/sprints.md" "A2"
teardown

# Test 5: backlog.yaml -> backlog.md
setup_mock_project
cat > "$PROJECT_DIR/docs/yaml/backlog.yaml" <<'EOF'
version: 1
backlog:
  - id: BL1
    name: Dark mode support
    source: user
    priority: 3
    description: Add dark mode toggle
  - id: BL2
    name: Export to CSV
    source: feature-enhancement
    priority: 2
    description: Allow data export
  - id: BL3
    name: Webhook integrations
    source: idea-enhancement
    priority: 1
    description: Third-party webhook support
EOF
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$SCRIPT" backlog.yaml
assert_file_exists "$PROJECT_DIR/docs/product/backlog.md" "backlog.md created"
assert_file_contains "$PROJECT_DIR/docs/product/backlog.md" "Dark mode support"
assert_file_contains "$PROJECT_DIR/docs/product/backlog.md" "Export to CSV"
assert_file_contains "$PROJECT_DIR/docs/product/backlog.md" "Webhook integrations"
teardown

# Test 6: --all flag regenerates multiple files
setup_mock_project
cat > "$PROJECT_DIR/docs/yaml/features.yaml" <<'EOF'
version: 1
features:
  - id: A1
    name: Auth
    phase: A
    status: QUEUED
    value: Security
EOF
cat > "$PROJECT_DIR/docs/yaml/memory-index.yaml" <<'EOF'
version: 1
project: all-test
files:
  - file: decisions.md
    summary: Decisions
EOF
cat > "$PROJECT_DIR/docs/yaml/backlog.yaml" <<'EOF'
version: 1
backlog:
  - id: BL1
    name: Item One
    source: user
    priority: 1
    description: First item
EOF
# Copy other empty YAML files to avoid errors
for f in specs contracts demos sprints changelog; do
  echo "version: 1" > "$PROJECT_DIR/docs/yaml/$f.yaml"
done
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$SCRIPT" --all
assert_file_exists "$PROJECT_DIR/docs/product/roadmap.md" "roadmap.md created by --all"
assert_file_exists "$PROJECT_DIR/docs/agents/memory/index.md" "index.md created by --all"
assert_file_exists "$PROJECT_DIR/docs/product/backlog.md" "backlog.md created by --all"
teardown

# Test 7: Empty features YAML (no crash, produces output)
setup_mock_project
cat > "$PROJECT_DIR/docs/yaml/features.yaml" <<'EOF'
version: 1
features: []
EOF
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$SCRIPT" features.yaml
result_exit=$?
assert_exit_code $result_exit 0 "empty features should not crash"
assert_file_exists "$PROJECT_DIR/docs/product/roadmap.md" "roadmap.md created even when empty"
teardown

# Test 8: memory-index.yaml with dict format (actual template format)
setup_mock_project
cat > "$PROJECT_DIR/docs/yaml/memory-index.yaml" <<'EOF'
version: 1
project: dict-test
last_updated: "2026-03-19"
features_completed: 2
files:
  decisions:
    path: "docs/agents/memory/decisions.md"
    summary: "Next.js + Hono stack"
    entry_count: 3
  patterns:
    path: "docs/agents/memory/patterns.md"
    summary: "Repository pattern for data access"
    entry_count: 2
  cr_learnings:
    path: "docs/agents/memory/cr_learnings.md"
    summary: ""
    entry_count: 0
EOF
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$SCRIPT" memory-index.yaml
assert_file_exists "$PROJECT_DIR/docs/agents/memory/index.md" "index.md created from dict format"
assert_file_contains "$PROJECT_DIR/docs/agents/memory/index.md" "dict-test"
assert_file_contains "$PROJECT_DIR/docs/agents/memory/index.md" "decisions"
assert_file_contains "$PROJECT_DIR/docs/agents/memory/index.md" "patterns"
assert_file_contains "$PROJECT_DIR/docs/agents/memory/index.md" "Next.js"
teardown

# Test 9: Missing docs/yaml/ (backward compat) - renumbered from Test 8
setup_mock_project
rm -rf "$PROJECT_DIR/docs/yaml"
result=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$SCRIPT" --all 2>&1)
result_exit=$?
assert_exit_code $result_exit 0 "missing docs/yaml should exit 0"
teardown

report "test-yaml-to-markdown"

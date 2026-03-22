#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/helpers.sh"

echo "--- test-agents ---"

AGENTS_DIR="$PLUGIN_DIR/agents"

# Test 1: Expected agent count is 18
agent_count=$(ls "$AGENTS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
assert_eq "18" "$agent_count" "agent count should be 18"

# Test 2: All expected agent files exist
EXPECTED_AGENTS=(
  backend-agent.md
  business-validator.md
  code-reviewer.md
  data-agent.md
  frontend-agent.md
  gap-checker.md
  market-validator.md
  memory-curator.md
  orchestrator.md
  persona-validator.md
  product-researcher.md
  qa-validator.md
  security-reviewer.md
  strategy-evolver.md
  tech-architect.md
  test-agent.md
  ui-agent.md
  ux-researcher.md
)

for agent_file in "${EXPECTED_AGENTS[@]}"; do
  assert_file_exists "$AGENTS_DIR/$agent_file" "$agent_file exists"
done

# Test 3: Each agent has required frontmatter fields (name, model)
for agent_file in "$AGENTS_DIR"/*.md; do
  basename=$(basename "$agent_file")
  assert_file_contains "$agent_file" "^name:" "$basename has name in frontmatter"
  assert_file_contains "$agent_file" "^model:" "$basename has model in frontmatter"
done

# Test 4: gap-checker specific validation
assert_file_contains "$AGENTS_DIR/gap-checker.md" "gap" "gap-checker mentions gap"
assert_file_contains "$AGENTS_DIR/gap-checker.md" "description" "gap-checker has description"

report "test-agents"

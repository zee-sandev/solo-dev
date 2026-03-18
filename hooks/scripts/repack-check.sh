#!/bin/bash
# solo-dev Repomix Repack Check
# Called after Write/Edit — determines if repomix repack is needed

FILE="$1"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
STATE_FILE="$PROJECT_DIR/.claude/solo-dev-state.json"

# Skip non-source files
skip_patterns=(
  "*.md" "*.json" "*.yaml" "*.yml" "*.toml" "*.lock"
  "*.test.*" "*.spec.*" "__tests__/*" "tests/*" "e2e/*"
  "docs/*" ".claude/*" "node_modules/*" ".git/*"
)

for pattern in "${skip_patterns[@]}"; do
  case "$FILE" in
    $pattern) exit 0 ;;  # Skip — not a significant source change
  esac
done

# Source file changed — flag for repack
if [ -f "$STATE_FILE" ]; then
  python3 -c "
import json, sys
with open('$STATE_FILE', 'r') as f:
    state = json.load(f)
state['repomix_repack_needed'] = True
with open('$STATE_FILE', 'w') as f:
    json.dump(state, f, indent=2)
" 2>/dev/null
fi

echo "solo-dev: Source file changed — repomix repack recommended before next code exploration"
exit 0

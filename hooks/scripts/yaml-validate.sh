#!/bin/bash
# solo-dev: YAML Index Validation (Layer 3)
# Runs at SessionStart to detect and auto-repair YAML-vs-markdown mismatches.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-}"
YAML_DIR="$PROJECT_DIR/docs/yaml"

# Backward compat: no yaml dir means legacy project
if [ ! -d "$YAML_DIR" ]; then
  exit 0
fi

# Use python3 to parse YAML and check file existence
RESULT=$(python3 -c "
import os, sys
try:
    import yaml
except ImportError:
    print('0 0 0')
    sys.exit(0)

project = '$PROJECT_DIR'
yaml_dir = '$YAML_DIR'
total = 0
ok = 0
mismatches = 0

def check_file(path):
    global total, ok, mismatches
    total += 1
    if os.path.isfile(os.path.join(project, path)):
        ok += 1
    else:
        mismatches += 1

def load_yaml(name):
    path = os.path.join(yaml_dir, name)
    if not os.path.isfile(path):
        return None
    with open(path) as f:
        return yaml.safe_load(f)

# features.yaml -> docs/product/roadmap.md
data = load_yaml('features.yaml')
if data is not None:
    check_file('docs/product/roadmap.md')

# memory-index.yaml -> docs/agents/memory/index.md
data = load_yaml('memory-index.yaml')
if data is not None:
    check_file('docs/agents/memory/index.md')

# changelog.yaml -> CHANGELOG.md (only if entries exist)
data = load_yaml('changelog.yaml')
if data is not None:
    entries = data if isinstance(data, list) else (data.get('entries') or data.get('versions') or [])
    if entries:
        check_file('CHANGELOG.md')

# sprints.yaml -> docs/product/sprints.md (only if sprints exist)
data = load_yaml('sprints.yaml')
if data is not None:
    items = data if isinstance(data, list) else (data.get('sprints') or [])
    if items:
        check_file('docs/product/sprints.md')

# backlog.yaml -> docs/product/backlog.md (only if items exist)
data = load_yaml('backlog.yaml')
if data is not None:
    items = data if isinstance(data, list) else (data.get('items') or data.get('backlog') or [])
    if items:
        check_file('docs/product/backlog.md')

# specs.yaml -> each spec's referenced path
data = load_yaml('specs.yaml')
if data is not None:
    entries = data if isinstance(data, list) else (data.get('specs') or [])
    for entry in (entries or []):
        path = entry.get('path') or entry.get('file') or ''
        if path:
            check_file(path)

# contracts.yaml -> each contract's referenced path
data = load_yaml('contracts.yaml')
if data is not None:
    entries = data if isinstance(data, list) else (data.get('contracts') or [])
    for entry in (entries or []):
        path = entry.get('path') or entry.get('file') or ''
        if path:
            check_file(path)

# demos.yaml -> each demo's doc_path
data = load_yaml('demos.yaml')
if data is not None:
    entries = data if isinstance(data, list) else (data.get('demos') or [])
    for entry in (entries or []):
        path = entry.get('doc_path') or entry.get('path') or ''
        if path:
            check_file(path)

print(f'{total} {ok} {mismatches}')
" 2>/dev/null)

# Parse counts
TOTAL=$(echo "$RESULT" | awk '{print $1}')
OK=$(echo "$RESULT" | awk '{print $2}')
MISMATCHES=$(echo "$RESULT" | awk '{print $3}')

# Default to 0 if parsing failed
TOTAL="${TOTAL:-0}"
OK="${OK:-0}"
MISMATCHES="${MISMATCHES:-0}"

# Auto-repair if mismatches found
STATUS="detected"
if [ "$MISMATCHES" -gt 0 ] 2>/dev/null; then
  CONVERTER=""
  if [ -n "$PLUGIN_ROOT" ] && [ -x "$PLUGIN_ROOT/hooks/scripts/yaml-to-markdown.sh" ]; then
    CONVERTER="$PLUGIN_ROOT/hooks/scripts/yaml-to-markdown.sh"
  elif [ -x "$PROJECT_DIR/hooks/scripts/yaml-to-markdown.sh" ]; then
    CONVERTER="$PROJECT_DIR/hooks/scripts/yaml-to-markdown.sh"
  fi

  if [ -n "$CONVERTER" ]; then
    "$CONVERTER" --all >/dev/null 2>&1
    STATUS="fixed"
  fi
fi

echo "YAML Index: ${TOTAL} entries, ${OK} files OK, ${MISMATCHES} mismatches ${STATUS}"

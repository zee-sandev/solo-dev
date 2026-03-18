#!/bin/bash
# solo-dev: YAML index → Markdown view converter
# Converts YAML index files in docs/yaml/ to human-readable markdown views.
#
# Usage:
#   yaml-to-markdown.sh <yaml-file>    Convert a single YAML file
#   yaml-to-markdown.sh --all          Regenerate all markdown views

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
YAML_DIR="$PROJECT_DIR/docs/yaml"

# Backward compat: if docs/yaml/ doesn't exist, exit silently
if [ ! -d "$YAML_DIR" ]; then
  exit 0
fi

convert_features() {
  local yaml_file="$1"
  local out_dir="$PROJECT_DIR/docs/product"
  mkdir -p "$out_dir"

  python3 -c "$(cat <<'PYEOF'
import sys, yaml, os
from datetime import date

yaml_file = sys.argv[1]
out_file = sys.argv[2]

with open(yaml_file, 'r') as f:
    data = yaml.safe_load(f) or {}

features = data.get('features', [])
if not features:
    with open(out_file, 'w') as f:
        f.write('# Product Roadmap\n\nNo items yet.\n')
    sys.exit(0)

STATUS_ICONS = {
    'COMPLETE': '✅ COMPLETE',
    'IN_PROGRESS': '⏳ IN_PROGRESS',
    'QUEUED': '○ QUEUED',
    'ROLLED_BACK': '🔄 ROLLED_BACK',
    'BLOCKED': '⏸ BLOCKED',
    'DECOMPOSED': '📦 DECOMPOSED',
}

PHASE_NAMES = {
    'A': 'Phase A — MVP',
    'B': 'Phase B — Moat',
    'C': 'Phase C — Scale',
}

# Group by phase
phases = {}
for feat in features:
    phase = feat.get('phase', 'A')
    phases.setdefault(phase, []).append(feat)

lines = []
lines.append('# Product Roadmap')
lines.append('')
lines.append(f'> Auto-generated from `features.yaml` on {date.today().isoformat()}')
lines.append('')

for phase_key in sorted(phases.keys()):
    phase_label = PHASE_NAMES.get(phase_key, f'Phase {phase_key}')
    items = phases[phase_key]

    lines.append(f'## {phase_label}')
    lines.append('')
    lines.append('| ID | Feature | Value | Status | Phase | Dependencies |')
    lines.append('|----|---------|-------|--------|-------|--------------|')

    for feat in items:
        fid = feat.get('id', '—')
        name = feat.get('name', feat.get('feature', '—'))
        value = feat.get('value', '—')
        raw_status = feat.get('status', 'QUEUED')
        status = STATUS_ICONS.get(raw_status, raw_status)
        phase_col = feat.get('phase', '—')
        deps = feat.get('depends_on', feat.get('dependencies', []))
        deps_str = ', '.join(deps) if deps else '—'
        lines.append(f'| {fid} | {name} | {value} | {status} | {phase_col} | {deps_str} |')

    lines.append('')

with open(out_file, 'w') as f:
    f.write('\n'.join(lines) + '\n')
PYEOF
)" "$yaml_file" "$out_dir/roadmap.md"
}

convert_memory_index() {
  local yaml_file="$1"
  local out_dir="$PROJECT_DIR/docs/agents/memory"
  mkdir -p "$out_dir"

  python3 -c "$(cat <<'PYEOF'
import sys, yaml
from datetime import date

yaml_file = sys.argv[1]
out_file = sys.argv[2]

with open(yaml_file, 'r') as f:
    data = yaml.safe_load(f) or {}

project = data.get('project', 'unknown')
files = data.get('files', {})
features_done = data.get('features_completed', 0)

if not files:
    with open(out_file, 'w') as f:
        f.write(f'# Memory Index — {project}\n\nNo items yet.\n')
    sys.exit(0)

lines = []
lines.append(f'# Memory Index — {project}')
lines.append(f'Last updated: {date.today().isoformat()} | Features completed: {features_done}')
lines.append('')

# Handle both dict format (template) and list format
if isinstance(files, dict):
    for key, entry in files.items():
        if isinstance(entry, dict):
            summary = entry.get('summary', '[empty]') or '[empty]'
        else:
            summary = str(entry) if entry else '[empty]'
        lines.append(f'## {key}')
        lines.append(f'  {summary}')
        lines.append('')
elif isinstance(files, list):
    for entry in files:
        filename = entry.get('file', entry.get('name', '—'))
        summary = entry.get('summary', '—')
        lines.append(f'## {filename}')
        lines.append(f'  {summary}')
        lines.append('')

# Keep under 200 lines (token budget)
output = '\n'.join(lines[:200]) + '\n'
with open(out_file, 'w') as f:
    f.write(output)
PYEOF
)" "$yaml_file" "$out_dir/index.md"
}

convert_changelog() {
  local yaml_file="$1"
  local out_file="$PROJECT_DIR/CHANGELOG.md"

  python3 -c "$(cat <<'PYEOF'
import sys, yaml

yaml_file = sys.argv[1]
out_file = sys.argv[2]

with open(yaml_file, 'r') as f:
    data = yaml.safe_load(f) or {}

entries = data.get('changelog', data.get('entries', []))
if not entries:
    with open(out_file, 'w') as f:
        f.write('# Changelog\n\nAll notable changes to this project will be documented in this file.\n\nNo items yet.\n')
    sys.exit(0)

# Group by date
by_date = {}
for entry in entries:
    d = str(entry.get('date', 'Unreleased'))
    by_date.setdefault(d, []).append(entry)

CHANGE_ORDER = ['Added', 'Changed', 'Fixed', 'Removed']

lines = []
lines.append('# Changelog')
lines.append('')
lines.append('All notable changes to this project will be documented in this file.')
lines.append('')

for d in sorted(by_date.keys(), reverse=True):
    items = by_date[d]
    lines.append(f'## [{d}]')
    lines.append('')

    # Group by change type within date
    by_type = {}
    for item in items:
        change_type = item.get('type', item.get('change_type', 'Changed'))
        # Normalize: added->Added, fix/fixed->Fixed, etc.
        normalized = change_type.strip().capitalize()
        if normalized in ('Fix',):
            normalized = 'Fixed'
        if normalized in ('Add',):
            normalized = 'Added'
        if normalized in ('Remove',):
            normalized = 'Removed'
        if normalized in ('Change',):
            normalized = 'Changed'
        by_type.setdefault(normalized, []).append(item)

    for ct in CHANGE_ORDER:
        if ct not in by_type:
            continue
        lines.append(f'### {ct}')
        lines.append('')
        for item in by_type[ct]:
            desc = item.get('description', item.get('message', '—'))
            lines.append(f'- {desc}')
        lines.append('')
        del by_type[ct]

    # Any remaining types not in CHANGE_ORDER
    for ct in sorted(by_type.keys()):
        lines.append(f'### {ct}')
        lines.append('')
        for item in by_type[ct]:
            desc = item.get('description', item.get('message', '—'))
            lines.append(f'- {desc}')
        lines.append('')

with open(out_file, 'w') as f:
    f.write('\n'.join(lines) + '\n')
PYEOF
)" "$yaml_file" "$out_file"
}

convert_sprints() {
  local yaml_file="$1"
  local out_dir="$PROJECT_DIR/docs/product"
  mkdir -p "$out_dir"

  python3 -c "$(cat <<'PYEOF'
import sys, yaml
from datetime import date

yaml_file = sys.argv[1]
out_file = sys.argv[2]

with open(yaml_file, 'r') as f:
    data = yaml.safe_load(f) or {}

sprints = data.get('sprints', [])
if not sprints:
    with open(out_file, 'w') as f:
        f.write('# Sprints\n\nNo items yet.\n')
    sys.exit(0)

STATUS_ICONS = {
    'COMPLETE': '✅',
    'IN_PROGRESS': '⏳',
    'QUEUED': '○',
    'ROLLED_BACK': '🔄',
    'BLOCKED': '⏸',
    'DECOMPOSED': '📦',
}

lines = []
lines.append('# Sprints')
lines.append('')
lines.append(f'> Auto-generated from `sprints.yaml` on {date.today().isoformat()}')
lines.append('')

for sprint in sprints:
    name = sprint.get('name', sprint.get('id', '—'))
    status = sprint.get('status', 'QUEUED')
    icon = STATUS_ICONS.get(status, '')
    lines.append(f'## {icon} {name} — {status}')
    lines.append('')

    features = sprint.get('features', [])
    if features:
        lines.append('| Feature | Status | Effort |')
        lines.append('|---------|--------|--------|')
        for feat in features:
            if isinstance(feat, str):
                lines.append(f'| {feat} | — | — |')
            else:
                fname = feat.get('name', feat.get('id', '—'))
                fstatus = feat.get('status', '—')
                ficon = STATUS_ICONS.get(fstatus, fstatus)
                effort = feat.get('effort', feat.get('estimate', '—'))
                lines.append(f'| {fname} | {ficon} | {effort} |')
        lines.append('')
    else:
        lines.append('No features assigned.')
        lines.append('')

with open(out_file, 'w') as f:
    f.write('\n'.join(lines) + '\n')
PYEOF
)" "$yaml_file" "$out_dir/sprints.md"
}

convert_backlog() {
  local yaml_file="$1"
  local out_dir="$PROJECT_DIR/docs/product"
  mkdir -p "$out_dir"

  python3 -c "$(cat <<'PYEOF'
import sys, yaml
from datetime import date

yaml_file = sys.argv[1]
out_file = sys.argv[2]

with open(yaml_file, 'r') as f:
    data = yaml.safe_load(f) or {}

items = data.get('items', data.get('backlog', []))
if not items:
    with open(out_file, 'w') as f:
        f.write('# Backlog\n\nNo items yet.\n')
    sys.exit(0)

lines = []
lines.append('# Backlog')
lines.append('')
lines.append(f'> Auto-generated from `backlog.yaml` on {date.today().isoformat()}')
lines.append('')
lines.append('| ID | Name | Source | Priority | Description |')
lines.append('|----|------|--------|----------|-------------|')

for item in items:
    bid = item.get('id', '—')
    name = item.get('name', '—')
    source = item.get('source', '—')
    priority = item.get('priority', '—')
    desc = item.get('description', '—')
    lines.append(f'| {bid} | {name} | {source} | {priority} | {desc} |')

lines.append('')

with open(out_file, 'w') as f:
    f.write('\n'.join(lines) + '\n')
PYEOF
)" "$yaml_file" "$out_dir/backlog.md"
}

# Map basename to converter function
convert_file() {
  local yaml_file="$1"
  local basename
  basename=$(basename "$yaml_file")

  case "$basename" in
    features.yaml)
      convert_features "$yaml_file"
      ;;
    memory-index.yaml)
      convert_memory_index "$yaml_file"
      ;;
    changelog.yaml)
      convert_changelog "$yaml_file"
      ;;
    sprints.yaml)
      convert_sprints "$yaml_file"
      ;;
    backlog.yaml)
      convert_backlog "$yaml_file"
      ;;
    specs.yaml|contracts.yaml|demos.yaml)
      # No markdown output — used by commands directly
      ;;
    *)
      # Unknown YAML file — skip silently
      ;;
  esac
}

# --- Main ---

if [ "$1" = "--all" ]; then
  for yaml_file in "$YAML_DIR"/*.yaml; do
    [ -f "$yaml_file" ] || continue
    convert_file "$yaml_file"
  done
elif [ -n "$1" ]; then
  # Accept absolute path or basename
  if [ -f "$1" ]; then
    convert_file "$1"
  elif [ -f "$YAML_DIR/$1" ]; then
    convert_file "$YAML_DIR/$1"
  else
    echo "yaml-to-markdown: file not found: $1" >&2
    exit 1
  fi
else
  echo "Usage: yaml-to-markdown.sh <yaml-file> | --all" >&2
  exit 1
fi

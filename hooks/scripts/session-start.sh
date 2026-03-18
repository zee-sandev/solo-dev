#!/bin/bash
# solo-dev SessionStart Hook
# Loads memory index, resumes state, detects stack, checks repomix

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
ENV_FILE="${CLAUDE_ENV_FILE:-/dev/null}"
STATE_FILE="$PROJECT_DIR/.claude/solo-dev-state.json"
MEMORY_INDEX="$PROJECT_DIR/docs/agents/memory/index.md"
GLOBAL_INDEX="$HOME/.claude/solo-dev/global-memory/index.md"

echo "=== solo-dev: Session Starting ==="

# 1. Load and resume project state
if [ -f "$STATE_FILE" ]; then
  PHASE=$(python3 -c "import json,sys; d=json.load(open('$STATE_FILE')); print(d.get('phase','INIT'))" 2>/dev/null || echo "INIT")
  FEATURE=$(python3 -c "import json,sys; d=json.load(open('$STATE_FILE')); print(d.get('current_feature','none'))" 2>/dev/null || echo "none")
  echo "Resuming: phase=$PHASE feature=$FEATURE"
  echo "export SAAS_DEV_PHASE=$PHASE" >> "$ENV_FILE"
  echo "export SAAS_DEV_FEATURE=$FEATURE" >> "$ENV_FILE"
else
  echo "New project — no state file found"
  echo "export SAAS_DEV_PHASE=INIT" >> "$ENV_FILE"
fi

# 2. Load project memory index (printed to context)
if [ -f "$MEMORY_INDEX" ]; then
  echo ""
  echo "--- Project Memory Index ---"
  cat "$MEMORY_INDEX"
  echo "----------------------------"
else
  echo "No project memory index yet (run /solo-dev:init to create)"
fi

# 3. Load global memory index
if [ -f "$GLOBAL_INDEX" ]; then
  echo ""
  echo "--- Global Memory Index ---"
  cat "$GLOBAL_INDEX"
  echo "---------------------------"
fi

# 4. Detect tech stack
detect_stack() {
  if [ -f "$PROJECT_DIR/package.json" ]; then
    if grep -q '"next"' "$PROJECT_DIR/package.json" 2>/dev/null; then
      echo "nextjs"
    elif grep -q '"react"' "$PROJECT_DIR/package.json" 2>/dev/null; then
      echo "react"
    else
      echo "nodejs"
    fi
  elif [ -f "$PROJECT_DIR/manage.py" ]; then
    echo "django"
  elif [ -f "$PROJECT_DIR/go.mod" ]; then
    echo "go"
  elif [ -f "$PROJECT_DIR/pom.xml" ]; then
    echo "springboot"
  elif [ -f "$PROJECT_DIR/requirements.txt" ] || [ -f "$PROJECT_DIR/pyproject.toml" ]; then
    echo "python"
  elif [ -f "$PROJECT_DIR/Gemfile" ]; then
    echo "rails"
  elif [ -f "$PROJECT_DIR/composer.json" ]; then
    echo "laravel"
  else
    echo "unknown"
  fi
}

STACK=$(detect_stack)
echo "Detected stack: $STACK"
echo "export SAAS_DEV_STACK=$STACK" >> "$ENV_FILE"

# 5. Check repomix pack status
PACK_ID=""
if [ -f "$STATE_FILE" ]; then
  PACK_ID=$(python3 -c "import json,sys; d=json.load(open('$STATE_FILE')); print(d.get('repomix_pack_id',''))" 2>/dev/null || echo "")
fi

if [ -n "$PACK_ID" ] && [ "$PACK_ID" != "None" ]; then
  echo "Repomix pack available: $PACK_ID"
  echo "export SAAS_DEV_REPOMIX_PACK=$PACK_ID" >> "$ENV_FILE"
else
  echo "⚠️  No repomix pack found"
  echo "   Token-efficient code exploration is not set up."
  echo "   To enable: answer 'yes' when prompted, or run /solo-dev:init"
fi

# 6. Check optional plugin availability
check_plugin() {
  local plugin_name="$1"
  local plugin_path="$HOME/.claude/plugins"
  if find "$plugin_path" -name "plugin.json" -exec grep -l "\"name\": \"$plugin_name\"" {} \; 2>/dev/null | grep -q .; then
    echo "✅ $plugin_name"
    return 0
  else
    echo "⚠️  $plugin_name (not found — using bundled fallback)"
    return 1
  fi
}

echo ""
echo "--- Plugin Status ---"
check_plugin "impeccable"
check_plugin "ui-ux-pro-max"
check_plugin "everything-claude-code"
check_plugin "superpowers"
echo "---------------------"

echo ""
echo "=== solo-dev: Ready ==="

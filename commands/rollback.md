---
name: rollback
description: Rollback a completed or in-progress feature — reverts git, restores memory snapshot, and gives options to re-attempt, remove, or decompose.
argument-hint: "<feature-id>"
allowed-tools: Read, Write, Edit, Bash
---

Rollback a feature completely — git history, state, and memory are all restored to pre-feature state.

## Your Role
Execute the rollback safely. Always confirm with user before taking destructive actions.

## Process

### Step 1: Validate
Read .claude/solo-dev-state.json and docs/product/roadmap.md.
Check that the specified feature-id exists.

Check for snapshot: docs/agents/memory/snapshots/pre-{feature-id}.json
If no snapshot: "Cannot rollback — no snapshot found for {feature-id}. Snapshot is created automatically before implementation begins."

Show the user what will be rolled back:
```
⚠️  ROLLBACK: {feature-name}

This will:
  1. Revert git to commit: {commit-hash from snapshot}
  2. Restore memory to state from: {snapshot-date}
  3. Mark feature as ROLLED_BACK in roadmap

This CANNOT be undone automatically. Proceed? (yes/no)
```

### Step 2: Execute Rollback (only after user confirms "yes")

```bash
# Get commit hash from snapshot
COMMIT=$(python3 -c "import json; d=json.load(open('docs/agents/memory/snapshots/pre-{feature-id}.json')); print(d['git_commit'])")

# Revert git
git revert $COMMIT..HEAD --no-commit
git commit -m "rollback({feature-id}): revert {feature-name}"
```

Restore state from snapshot:
- .claude/solo-dev-state.json ← from snapshot.state
- docs/agents/memory/index.md ← from snapshot.memory_index
- docs/agents/memory/decisions.md ← restore entries after snapshot date
- docs/agents/memory/patterns.md ← restore entries after snapshot date

Update roadmap: mark feature as ROLLED_BACK

### Step 3: Post-Rollback Options

```
✅ Rollback complete: {feature-name}
   Git reverted to: {commit-hash}
   Memory restored to: {snapshot-date}

What would you like to do next?
  A) Re-attempt with a different approach
     → Feature re-enters Design Loop with "ROLLBACK CONTEXT" note
     → Previous spec saved as docs/specs/{feature-id}-rejected.md
  B) Remove feature from roadmap
     → Feature marked REMOVED, removed from dependency chains
  C) Decompose into smaller sub-features
     → I'll suggest how to break this into 2-3 smaller features
  D) Do nothing for now (feature stays ROLLED_BACK)
```

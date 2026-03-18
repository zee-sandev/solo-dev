# Rollback

Every feature is snapshotted before it begins — git commit, state, and full memory. This enables safe rollback at any time.

## Usage

```
/solo-dev:rollback [feature-id]
```

## What Gets Rolled Back

1. **Git** — reverts to pre-feature commit (stored in snapshot)
2. **State** — restores `.claude/solo-dev-state.json` from snapshot
3. **Memory** — restores `docs/agents/memory/` files that changed since snapshot
4. **Roadmap** — marks feature `ROLLED_BACK` in `docs/product/roadmap.md`

## After Rollback

You choose what to do next:

| Option | What happens |
|--------|-------------|
| **A) Re-attempt** | Re-enters Design Loop with "rollback context" note |
| **B) Remove from roadmap** | Feature removed entirely |
| **C) Decompose** | Run `/solo-dev:decompose {feature-id}` to break into smaller, independently shippable sub-features |

## Example

```
> /solo-dev:rollback A2

Rolling back A2 — Content Brief Generator

  ✓  3 git commits reverted
  ✓  solo-dev-state.json restored to pre-A2 snapshot
  ✓  Memory files restored (decisions, patterns, learnings)
  ✓  A2 marked ROLLED_BACK in roadmap

What would you like to do?
  A)  Re-attempt A2 from scratch
  B)  Remove A2 from roadmap entirely
  C)  Decompose A2 into smaller features

> C

Orchestrator: Suggest splitting A2 into:
  A2a — Brief template engine  (smaller, lower risk)
  A2b — AI content suggestions (larger, depends on A2a)

Proceed with this decomposition?
```

## Snapshots

Snapshots are created by `memory-curator` before each feature begins:

```json
{
  "feature_id": "A1",
  "timestamp": "2026-03-18T10:00:00Z",
  "git_commit": "abc1234",
  "state": { /* full solo-dev-state.json */ },
  "memory": {
    "index": "...",
    "decisions": "...",
    "patterns": "...",
    "cr_learnings": "...",
    "bv_learnings": "..."
  }
}
```

Stored in: `docs/agents/memory/snapshots/pre-{feature-id}.json`

## Rollback Logging

Every rollback is logged to `docs/agents/memory/decisions.md` with:
- Feature ID and name
- Reason for rollback
- User's chosen next action
- Timestamp

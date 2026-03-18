---
name: status
description: Show the current project status dashboard — phase, feature progress, roadmap, token usage, memory stats, and agent performance.
argument-hint: ""
allowed-tools: Read, Bash
---

Display a comprehensive project status dashboard. Read-only — make no changes.

## Your Role
Read state and memory files, then format a clear status report.

## Process

1. Read .claude/solo-dev-state.json
2. Read docs/yaml/features.yaml (fallback: docs/product/roadmap.md)
3. Read docs/yaml/memory-index.yaml (fallback: docs/agents/memory/index.md)
4. Read docs/agents/memory/performance-log.md (last 5 entries)
5. Read docs/yaml/sprints.yaml for current sprint (if exists)

## Output Format

```
=== solo-dev: Project Status ===

Project: {project-name}
Stack: {stack}

Current Task:
  Feature: {current_feature or "none"}
  Phase: {phase} {round > 0 ? "(round N/max)" : ""}
  Blocked: {blocked_since or "No"}

Roadmap:
  ✅ {completed features}
  ⏳ {in-progress feature with phase indicator}
  ⏸  {waiting features — note if blocked by dependency}
  ○  {queued features}

  {N} features complete | {M} remaining | {K} in backlog

Dependency Graph:
  {Build from features.yaml depends_on/blocks fields}
  {Show arrows: A1 ──→ A2 ──→ A3}
  {Independent features on their own line}

  Critical path: {longest dependency chain}
  Blocked: {features waiting on incomplete deps}

Current Sprint: {sprint-name or "none planned"}
  {If active sprint: list features with status icons and effort}

Memory:
  Project memory: {token estimate} tokens indexed
  Global memory: {N} patterns across {K} projects
  Last updated: {date}

Agent Performance (this session / last feature):
  {agent}: {N} APPROVE, {M} REJECT, {avg rounds}
  ...

Token Usage:
  Budget mode: {fixed/subscription/disabled}
  {if fixed}: {used}/{limit} tokens ({pct}%)
  {if subscription}: {used} tokens (avg per feature: {avg})
  {if disabled}: tracking disabled

Recent Decisions:
  {last 3 entries from decisions.md}
```

Phase icons:
- ✅ COMPLETE
- ⏳ IN PROGRESS (with current phase)
- ⏸  BLOCKED (show which dependency is missing)
- ○  QUEUED
- 🔄 ROLLED_BACK
- ⚠️  ESCALATED

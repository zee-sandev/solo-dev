---
name: solo-dev:status
description: Show the current project status dashboard — phase, feature progress, roadmap, token usage, memory stats, and agent performance.
argument-hint: "[--full] [--token] — show project dashboard (phase, roadmap, memory, agents)"
allowed-tools: Read, Bash
---

Display a comprehensive project status dashboard. Read-only — make no changes.

## Your Role
Read state and memory files, then format a clear status report.

## Process

1. Read .solo-dev/state.json
2. Read .solo-dev/yaml/features.yaml (fallback: .solo-dev/product/roadmap.md)
3. Read .solo-dev/yaml/memory-index.yaml (fallback: .solo-dev/memory/index.md)
4. Read .solo-dev/memory/performance-log.md (last 5 entries)
5. Read .solo-dev/yaml/sprints.yaml for current sprint (if exists)

## Output Format

```
=== solo-dev: Project Status ===

Project: {project-name}
Stack: {stack}

Current Task:
  Feature: {current_feature or "none"}
  Effort: {feature_effort or "not classified"} (XS/S/M/L/XL)
  Pipeline: {pipeline label — minimal / fast-track / full / full+ / decompose first}
  Phase: {phase} {round > 0 ? "(round N/max)" : ""}
  Total rounds this feature: {sum of all loop rounds for current feature}
  Blocked: {blocked_since or "No"}

Roadmap:
  ID   Status  Feature                      Effort  Pipeline
  ──────────────────────────────────────────────────────────
  ✅   {id}    {completed features}          {tier}  —
  ⏳   {id}    {in-progress} ({phase})       {tier}  {pipeline}
  ⏸    {id}    {blocked} (needs: {dep-id})   {tier}  {pipeline}
  ○    {id}    {queued features}             {tier}  {pipeline}

  {N} features complete | {M} remaining | {K} in backlog

  Pipeline Guide:
    ⚡ XS  minimal     Pre-Flight → Impl → Code Review → Security → Smoke → Ship
    ✦  S  fast-track  Pre-Flight → Market → Impl → Code Review → Security → Smoke → Ship
    🔄  M  full        All phases
    🔄  L  full+       All phases + mid-impl checkpoint + extended review
    ⚠️  XL decompose   Must decompose first via /solo-dev:decompose

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

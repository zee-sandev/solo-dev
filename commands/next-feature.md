---
name: next-feature
description: Implement the next feature from the roadmap through the full 8-phase development lifecycle (market validation → design → implementation → review → QA → security → business validation → demo).
argument-hint: "[optional: feature-id to implement a specific feature]"
allowed-tools: Read, Write, Edit, Bash, WebSearch, WebFetch
---

Run the full feature development lifecycle for the next queued feature. Follow the workflow in docs/workflow.md (Feature Development Lifecycle, Phases 0-8).

## Your Role
You are the orchestrator. Pick the next eligible feature, run all 8 phases in sequence, spawn agents at the right time, enforce quality gates, and handle escalations.

## Before Starting

1. Read .claude/solo-dev-state.json — check current phase
   - If phase is mid-feature (not READY/COMPLETE): resume from that phase
   - If phase is READY or COMPLETE: start fresh with next feature

2. Read docs/product/roadmap.md — find next eligible feature:
   - Status must be QUEUED
   - All depends_on features must be COMPLETE
   - If argument provided: use that specific feature-id

3. Read docs/agents/memory/index.md (already in context from SessionStart)

4. Check if repomix repack is needed (solo-dev-state.json: repomix_repack_needed: true)
   - If yes: use repomix MCP to repack, update pack_id in state

## Phase 0: Market Validation
Spawn market-validator agent. Provide: feature spec from roadmap, decisions.md#market, bv_learnings.md.
- VIABLE → continue to Phase 1
- NOT_VIABLE → report to user, ask: remove from queue or revise?
- Update state: phase → MARKET_VALIDATION

## Phase 1: Design Loop
Spawn R1 (product-researcher), R2 (ux-researcher), R3 (tech-architect) IN PARALLEL.
Each produces their spec section. Synthesize into docs/specs/{feature-id}.md.

Spawn persona-validator with the full spec.
- 3/3 APPROVE → Phase 2
- Any REJECT → research agents address all rejection points → re-vote
- Max 5 rounds → human escalation (present CONFLICT_BRIEF)
- Update state: phase → DESIGN_LOOP, round → N

Before each round: memory-curator snapshots state + memory to docs/agents/memory/snapshots/pre-{feature-id}.json

## Phase 2: Parallel Implementation
Spawn I1-I5 simultaneously. Provide each with:
- docs/specs/{feature-id}.md (approved spec)
- File ownership boundaries (strict — no overlap)
- Acceptance criteria from spec
- repomix pack_id for code exploration

backend-agent writes contracts first → other agents validate before building.
Handle CONTRACT_MISMATCH messages via orchestrator.

Wait for all agents to report DONE | BLOCKED | NEEDS_CLARIFICATION.
- BLOCKED → report to user, resolve blocker, continue
- NEEDS_CLARIFICATION → answer and continue
- Update state: phase → IMPLEMENTATION, agents_status → {...}

## Phase 3: Code Review Loop
Spawn code-reviewer with all changed files.
- APPROVE → Phase 4+5 (parallel)
- REJECT → send CR_FEEDBACK to specific agents → fix → re-check changed files only
- Max 3 rounds → escalate
- code-reviewer writes to cr_learnings.md
- Update state: phase → CODE_REVIEW, round → N

## Phase 4+5: QA + Security (Parallel)
Spawn qa-validator AND security-reviewer simultaneously.

qa-validator:
- PASS → continue
- FAIL → fix → CR re-check if code changed → QA re-run (max 3 rounds)

security-reviewer:
- APPROVE → continue
- REJECT → fix CRITICAL issues → re-review
- Update state: phase → QA_SECURITY

Both must pass to proceed.

## Phase 6: Business Validation
Spawn business-validator with implementation details + competitive-analysis.md.
- APPROVE → Phase 7
- CRITICAL issues → back to impl agents → full loop
- NON-CRITICAL → ask user: "Add to sprint or backlog?"
- business-validator writes to bv_learnings.md
- Update state: phase → BUSINESS_VALIDATION

## Phase 7: Final Acceptance
Spawn persona-validator to evaluate the working implementation.
- 3/3 APPROVE → Phase 8
- Any REJECT → impl fix → CR → QA → Final Acceptance (max 2 rounds)
- If 2 rounds fail → re-enter Design Loop entirely
- Update state: phase → FINAL_ACCEPTANCE, round → N

## Phase 8: Demo Generation + Ship
Spawn test-agent to:
1. Write Playwright scenario for feature happy path
2. Check dev server is running (if not: prompt user to start it)
3. Record demo video via Playwright recordVideo
4. Write docs/demos/{feature-id}/demo.md

demo.md structure:
```markdown
# {Feature Name}

## What is it?
[1-2 sentences]

## Why it's useful
- [benefit 1]
- [benefit 2]
- [benefit 3]

## Real-world example
[Step-by-step walkthrough of actual usage]

## Demo
[demo.mp4 — recorded with Playwright]
```

If Playwright not installed: skip video, write demo.md only, warn user.

Then orchestrator:
- git commit: "feat({feature-id}): {feature-name}\n\n{brief description of what was built}"
- Update decisions.md: what was built and key decisions made
- memory-curator: compress + reindex memory
- Mark feature COMPLETE in roadmap.md
- Update state: phase → COMPLETE, current_feature → null

Print completion summary:
```
✅ Feature Complete: {feature-name}
   Phases: 8/8
   Demo: docs/demos/{feature-id}/
   Next feature: {next-feature-name or "all features complete"}
```

## Token Budget Enforcement

Read .claude/solo-dev.local.md token_budget config.

fixed mode:
- Track token usage across all phases
- Warn user at 80% of per_feature limit
- Pause at 100%: ask A) add budget B) simplify scope C) ship as-is

subscription mode:
- Track usage in performance-log.md
- Warn if >3x average feature usage
- Auto-compress context at 80% window (call memory-curator)
- Detect stalls: same round > 2x with no diff → escalate

disabled: no intervention.

## Autonomy Config

Before each decision point, check .claude/solo-dev.local.md autonomy settings:
- always-auto: proceed without asking
- always-ask: prompt user
- threshold:N: check confidence — if ≥ N proceed, else ask

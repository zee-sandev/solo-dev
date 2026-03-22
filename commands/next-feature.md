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

2. Read docs/yaml/features.yaml (fallback: docs/product/roadmap.md if YAML doesn't exist) — find next eligible feature:
   - Status must be QUEUED
   - All depends_on features must be COMPLETE
   - If argument provided: use that specific feature-id

3. Read docs/agents/memory/index.md (already in context from SessionStart)

4. Check if repomix repack is needed (solo-dev-state.json: repomix_repack_needed: true)
   - If yes: use repomix MCP to repack, update pack_id in state

5. If onboarding_type is "foundation":
   - Read docs/agents/memory/foundation-manifest.md
   - Load example_code list and agent delegation map

## Phase 0: Market Validation
Spawn market-validator agent. Provide: feature spec from roadmap, decisions.md#market, bv_learnings.md.
- VIABLE → continue to Phase 1
- HIGH_RISK → present risk summary to user, require acknowledgment before proceeding
- BLOCKER → report to user, require explicit override to proceed (or remove from queue / revise)
- Update state: phase → MARKET_VALIDATION

## Phase 1: Design Loop
Spawn R1 (product-researcher), R2 (ux-researcher), R3 (tech-architect) IN PARALLEL.
Each produces their spec section. Synthesize into docs/specs/{feature-id}.md.

Spawn persona-validator with the full spec.
- 3/3 APPROVE → Phase 2
- Any REJECT → research agents address all rejection points → re-vote
- Max 3 rounds → human escalation (present CONFLICT_BRIEF)
- Update state: phase → DESIGN_LOOP, round → N

Before each round: memory-curator snapshots state + memory to docs/agents/memory/snapshots/pre-{feature-id}.json

## Phase 2: Parallel Implementation

### Example Code Replacement (Foundation projects only)
Before spawning impl agents, check foundation-manifest.md example_code list:
- Does this feature overlap with any tagged example code?
  - YES → include in agent instructions: "Replace {example_path} with real implementation. Remove example content entirely."
  - NO → proceed normally

### Agent Delegation (Foundation projects only)
If project has existing .claude/agents/ (per foundation-manifest.md delegation map):
- **DELEGATE** implementation to existing project agents instead of solo-dev impl agents
- Project agents know the template's conventions (contract-first, 4-layer pattern, etc.) better
- solo-dev impl agents (frontend-agent, backend-agent, etc.) become **FALLBACK only**
  - Use solo-dev agents only when no matching project agent exists
- Provide existing agents with: approved spec, file ownership, acceptance criteria, repomix pack_id
- code-reviewer: **MERGE** — run both solo-dev's and project's code-reviewer

If project has NO .claude/agents/: use solo-dev agents as normal (I1-I5).

### DAG-Based Dependency Analysis
Before spawning agents, build a dependency graph of implementation tasks:
- HARD dependencies: must complete before dependent task starts (e.g., DB schema before API routes)
- SOFT dependencies: can proceed in parallel with coordination (e.g., frontend + backend with contract)
Use DAG to determine optimal dispatch order.

### Standard Implementation
Spawn impl agents (delegated or solo-dev) simultaneously. Provide each with:
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

## Phase 3: Code Review + Security Review (Parallel)
Spawn code-reviewer AND security-reviewer simultaneously with all changed files.

code-reviewer:
- APPROVE → Phase 4
- REJECT → send CR_FEEDBACK to specific agents → fix → re-check changed files only
- Max 3 rounds → escalate
- code-reviewer writes to cr_learnings.md

security-reviewer (sole owner of all security checks):
- APPROVE → continue
- REJECT → SECURITY_ISSUE to relevant impl agents → fix → re-review

Both must APPROVE to proceed.
- Update state: phase → CODE_REVIEW, round → N

## Phase 4: QA
Spawn qa-validator.

qa-validator:
- PASS → continue
- FAIL → fix → CR re-check if code changed → QA re-run (max 3 rounds)
- Update state: phase → QA_LOOP

## Phase 6: Business Validation (runs parallel with Phase 2)
Business-validator runs in parallel with implementation after design approval. Uses 3-hat evaluation (Operations/Compliance/Growth).
Results are collected and merged at the Phase 7 gate.
- APPROVE → continue to Phase 7
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
- Update status to COMPLETE in docs/yaml/features.yaml, then regenerate roadmap.md via yaml-to-markdown.sh
- Add changelog entry to docs/yaml/changelog.yaml: read the spec for what was built, summarize changes, note any breaking changes from business validation. Then regenerate CHANGELOG.md: bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/yaml-to-markdown.sh docs/yaml/changelog.yaml
- Update state: phase → COMPLETE, current_feature → null

### Example Code Cleanup (Foundation projects only)
After marking feature COMPLETE:
- Update foundation-manifest.md: remove entries from example_code that were replaced
- If ALL roadmap features are now COMPLETE → run **Final Cleanup**:
  - List remaining unused example code from foundation-manifest.md
  - If any remain, ask user once: "These template examples are unused: {list}. Remove them? [Y/n]"
  - If yes: delete files, update manifest
  - If no: leave as-is

Print completion summary:
```
✅ Feature Complete: {feature-name}
   Phases: 8/8
   Demo: docs/demos/{feature-id}/
   {If foundation: "Examples replaced: {N} files"}
   Next feature: {next-feature-name or "all features complete"}
```

## Adaptive Phase Ordering

Classify feature effort from the roadmap spec before starting:
- **S (Small):** Fast-track — skip Design Loop and QA Loop. Run Phase 0 → 2 → 3+Security → 8.
- **M (Medium):** Standard pipeline — all phases.
- **L (Large):** Standard + extended review budget.
- **XL (Extra Large):** Suggest decomposition via `/solo-dev:decompose` before starting.

Store effort classification in state: `feature_effort: S|M|L|XL`

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

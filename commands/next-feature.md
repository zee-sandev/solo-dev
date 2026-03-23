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

## Phase 2.5: Gap Check (monorepo)
See orchestrator for full gap-check logic. If monorepo + multi-package impact map → dispatch gap-checker.
- PASS → Phase 2.6
- FAIL → targeted fix → re-check
- Update state: phase → GAP_CHECK

## Phase 2.6: Smoke Test
Dispatch smoke-tester agent.
- PASS → Phase 2.7
- FAIL → targeted feedback → agents fix → re-run failed steps
- PARTIAL (build pass, endpoints skipped due to no contract) → proceed with warning
- Update state: phase → SMOKE_TEST

## Phase 2.7: Contract Drift Check
Dispatch drift-detector (Mode 2: Contract Drift Check).
- STABLE → Phase 2.8
- DRIFTED → notify affected agents → block until re-validated
- Update state: phase → CONTRACT_DRIFT_CHECK

## Phase 2.8: Visual QA
If `design_profile` exists in `.claude/solo-dev.local.md` AND `visual_qa.enabled: true`:

1. Capture screenshots of new/changed pages using Playwright (empty, loaded, error, mobile, desktop states)
2. If `dark_mode: both` → capture dark mode variants
3. Run visual checklist: design tokens, responsive, spacing, typography, interactive states, navigation pattern
4. Verify navigation matches `design_profile.navigation` (pattern, menu structure, role-based, breadcrumbs)
5. PASS → Phase 3
6. FAIL → targeted feedback to ui-agent/frontend-agent → fix → re-screenshot (max 2 rounds, then proceed with warnings)
7. If `visual_qa.user_preview: true` → show screenshots to user for approval

Skip if: no design_profile, visual_qa disabled, effort=S, or API-only feature.
- Update state: phase → VISUAL_QA

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

Orchestrator prepares demo context, then spawns test-agent:

**Context preparation (orchestrator does this):**
1. Read features.yaml → find epic_id, related features, check if epic complete
2. Check if last feature in sprint → is_sprint_end
3. Check if feature has role-based behavior → has_roles
4. Check file overlap with other shipped features → shares_pages_with
5. Pass full context to test-agent

**test-agent generates demos using its Demo Intelligence system:**
- Decides demo type: FEATURE_CLIP, JOURNEY_DEMO, API_DEMO, or SKIP_VIDEO
- Generates realistic seed data (not test data)
- Records with screenshots at each key moment
- Creates annotations (subtitles for video)
- Generates 3 audience layers: product (demo.md), technical (demo-technical.md), onboarding (demo-onboarding.md)
- For journey demos: combines all epic features into one continuous multi-role flow
- For API-only features: terminal recording or curl documentation

**After test-agent completes:**
- Dispatch drift-detector Mode 5 (background) — check if new feature made old demos stale
- If sprint end → auto-generate showcase

**Output structure:**
```
docs/demos/
├── clips/{feature-id}/        # per-feature clips
│   ├── clip.webm, demo.md, demo-technical.md, demo-onboarding.md
│   ├── screenshots/, annotations.yaml, {id}.srt
├── journeys/{epic-id}/        # epic journey demos (when epic completes)
│   ├── journey.webm, journey.md, screenshots/, annotations.yaml
├── api/{feature-id}/          # API-only features
│   ├── api-demo.md, api-demo.cast (if asciinema available)
└── showcase/                  # sprint-end product showcase
```

If Playwright not installed: skip video, generate docs from spec + implementation data, warn user.

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
   Demo: {demo type} — docs/demos/{type}/{id}/
   {If journey triggered: "Journey demo: docs/demos/journeys/{epic-id}/"}
   {If stale demos found: "⚠️ {N} existing demos need re-recording"}
   {If sprint end: "Showcase updated: docs/showcase/"}
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

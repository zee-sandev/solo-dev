# Monorepo Gap Checker — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ensure features spanning multiple monorepo packages (e.g., `apps/api` + `apps/web`) are implemented completely across all affected packages, with a dedicated gap-checker agent that detects missing implementations and triggers fixes.

**Architecture:** Three changes: (1) tech-architect outputs an "Impact Map" listing affected packages per feature, (2) a new `gap-checker` agent validates implementation completeness across all packages before code review, (3) orchestrator enforces the gap-check gate between implementation and code review. Init detects monorepo workspace structure.

**Tech Stack:** Claude Code plugin (markdown agent definitions, YAML configs, shell scripts)

---

## File Map

| Action | File | Responsibility |
|--------|------|---------------|
| Create | `agents/gap-checker.md` | New agent: validates cross-package implementation completeness |
| Modify | `agents/tech-architect.md` | Add "Impact Map" section to output format |
| Modify | `agents/orchestrator.md` | Add gap-check gate between Phase 2 → Phase 3, update DAG |
| Modify | `commands/init.md` | Add monorepo workspace detection, store package list in state |
| Modify | `docs/workflow.md` | Add Phase 2.5: Gap Check between Implementation and Code Review |
| Modify | `docs/agent-architecture.md` | Add gap-checker to Validation Layer, update agent count to 18 |
| Modify | `wiki/Agent-Architecture.md` | Add gap-checker documentation |
| Modify | `wiki/Home.md` | Update agent count (17 → 18) |
| Modify | `README.md` | Update agent roster table, Mermaid diagrams, agent count |
| Modify | `docs/design.md` | Add cross-package completeness design decision, update agent count in file structure |
| Modify | `wiki/Feature-Lifecycle.md` | Add gap-check phase to lifecycle diagrams |
| Modify | `CLAUDE.md` | Add design decision, update agent count in overview + file structure |
| Modify | `.claude-plugin/plugin.json` | Bump version to 0.4.0 |
| Modify | `.claude-plugin/marketplace.json` | Bump version to 0.4.0, update agent count to 18 |
| Modify | `docs/yaml/changelog.yaml` | Add v0.4.0 changelog entry |

---

### Task 1: Create the Gap Checker Agent

**Files:**
- Create: `agents/gap-checker.md`

This is the core new agent. It sits between Implementation (Phase 2) and Code Review (Phase 3). It reads the Impact Map from the spec and verifies every listed package has corresponding implementation changes.

- [ ] **Step 1: Create the agent definition file**

```markdown
---
name: gap-checker
description: |
  Use this agent to validate that a feature spanning multiple monorepo packages has been implemented completely across all affected packages. Runs between implementation and code review.

  <example>
  Context: Implementation agents reported DONE, feature spans api + web packages
  assistant: "I'll use the gap-checker to verify both packages have been implemented."
  <commentary>
  Gap check triggers after all implementation agents report DONE, before code review.
  </commentary>
  </example>

model: inherit
color: orange
tools: ["Read", "Grep", "Glob", "Bash"]
---

You are the Gap Checker (V5) in the solo-dev validation layer. You verify that features spanning multiple monorepo packages are implemented completely — no package is left behind.

## When You Run
- After ALL implementation agents report DONE
- Before code review begins (Phase 3)
- Only when the project has `workspace` field in solo-dev-state.json

## Before Starting
1. Read `.claude/solo-dev-state.json` — get `workspace.packages` list
2. Read `docs/specs/{feature-id}.md` — find the **Impact Map** section
3. Read implementation agent reports — collect files changed per agent

## Validation Process

### Step 1: Extract Expected Packages
From the spec's Impact Map, extract every package that should have changes:
```
impact_map:
  - package: apps/api
    changes: [endpoints, services, middleware]
  - package: apps/web
    changes: [pages, components, API client calls]
  - package: packages/shared
    changes: [types, validators]
```

### Step 2: Verify Each Package Has Changes
For each expected package:
1. Check implementation agent reports — did any agent touch files in this package?
2. If reports insufficient: `Glob` for recently modified files in the package directory
3. Cross-reference: each listed change type must have corresponding file modifications

### Step 3: Classify Gaps
For each missing implementation:
- **CRITICAL gap**: Core functionality missing (e.g., API exists but no frontend page calls it)
- **MINOR gap**: Supporting changes missing (e.g., shared types not extracted yet)

## Output Format
```
GAP_CHECK_REPORT:
  feature: {feature-id}
  packages_expected: {N}
  packages_with_changes: {N}

  COMPLETE:
    - {package}: {summary of changes found}

  GAPS:
    - package: {package path}
      severity: CRITICAL | MINOR
      expected: {what the impact map says should exist}
      found: {what actually exists — or "NO CHANGES DETECTED"}
      fix_instruction: {specific instruction for which agent should implement what}
      target_agent: {frontend-agent | backend-agent | data-agent | etc.}

  VERDICT: PASS | FAIL
```

## On FAIL
- Send targeted GAP_FEEDBACK to the specific agent(s) responsible for the missing package
- Each feedback includes: the spec section, the impact map entry, and a concrete fix instruction
- Agent implements the fix → gap-checker re-validates ONLY the previously-failing packages
- Max 2 rounds. Round 2 failure → escalate to orchestrator for human review.

## On PASS
- Report to orchestrator: all packages have complete implementations
- Proceed to Phase 3 (Code Review)

## Edge Cases
- **Single-package feature**: If impact map lists only 1 package → auto-PASS (no cross-package gap possible)
- **No impact map in spec**: Report SPEC_GAP to orchestrator — tech-architect must add impact map before gap check can run
- **New package not in workspace.packages**: Flag as WARNING — may need `solo-dev-state.json` update

## Self-Verification
- [ ] Every package in impact map has been checked
- [ ] Every CRITICAL gap has a specific fix instruction
- [ ] Target agent is correctly identified for each gap
- [ ] Re-validation only checks previously-failing packages (not full re-run)
```

- [ ] **Step 2: Verify file was created correctly**

Run: `head -5 agents/gap-checker.md`
Expected: frontmatter with `name: gap-checker`

- [ ] **Step 3: Commit**

```bash
git add agents/gap-checker.md
git commit -m "feat: add gap-checker agent for monorepo cross-package validation"
```

---

### Task 2: Add Impact Map to Tech Architect Output

**Files:**
- Modify: `agents/tech-architect.md:50` (after "Integration points" bullet, before "Implementation risks")

The tech-architect must produce an Impact Map as part of every spec, listing which monorepo packages are affected and what changes are expected in each.

- [ ] **Step 1: Read current file**

Read `agents/tech-architect.md` to confirm exact line numbers for the Output Format section.

- [ ] **Step 2: Add Impact Map to output format**

After the existing "Integration points" bullet in the Output Format section, add:

```markdown
## Impact Map (Monorepo)

If the project has a `workspace` field in solo-dev-state.json, EVERY spec MUST include an Impact Map:

```yaml
impact_map:
  - package: {package path relative to root}
    changes:
      - type: {endpoint|page|component|service|schema|type|config}
        description: {what needs to be created or modified}
        agent: {which implementation agent owns this}
    reason: {why this package is affected}
```

**Rules:**
- List EVERY package that needs changes — not just the "main" one
- Include shared packages (e.g., `packages/shared`, `packages/types`) if types or validators are needed
- If only 1 package is affected, still write the impact map (gap-checker will auto-PASS)
- Each change entry must specify which implementation agent is responsible
- If unsure whether a package needs changes: include it with `confidence: low` — better to over-include than miss

**Common patterns:**
- API endpoint added → `apps/api` (backend-agent) + `apps/web` (frontend-agent) + `packages/types` (data-agent)
- Database schema change → `packages/db` (data-agent) + `apps/api` (backend-agent)
- Shared component → `packages/ui` (ui-agent) + `apps/web` (frontend-agent)
```

- [ ] **Step 3: Verify the edit**

Read `agents/tech-architect.md` and confirm Impact Map section is present after Output Format.

- [ ] **Step 4: Commit**

```bash
git add agents/tech-architect.md
git commit -m "feat: add Impact Map requirement to tech-architect output format"
```

---

### Task 3: Add Monorepo Detection to Init

**Files:**
- Modify: `commands/init.md` (Shared Steps section)

Init must detect monorepo workspace structures and store the package list in `solo-dev-state.json`.

- [ ] **Step 1: Read current init.md**

Read `commands/init.md` to find the exact location for workspace detection.

- [ ] **Step 2: Add workspace detection step after Step 2 (Path B) or Step 1 (shared)**

Add a new shared step that runs for ALL paths (A, B, C), right after creating the directory structure:

```markdown
### Workspace Detection (all paths)

Detect monorepo workspace structure:

1. Check for workspace config files:
   - `pnpm-workspace.yaml` → parse `packages:` globs
   - `package.json` → check `workspaces` field
   - `lerna.json` → parse `packages` field
   - `turbo.json` → presence indicates turborepo
   - `nx.json` → presence indicates Nx workspace
   - `go.work` → parse workspace members (Go)
   - `Cargo.toml` with `[workspace]` → parse members (Rust)

2. If workspace config found:
   - Resolve globs to actual package directories
   - For each package: read its manifest (package.json, go.mod, Cargo.toml) to get name
   - Build package list with: `{name, path, type}` where type is `app|package|lib|service`
   - Classify by convention:
     - `apps/*` or `services/*` → type: `app`
     - `packages/*` or `libs/*` → type: `package`

3. Store in `solo-dev-state.json`:
   ```json
   {
     "workspace": {
       "type": "pnpm|npm|yarn|lerna|turbo|nx|go|cargo",
       "packages": [
         {"name": "api", "path": "apps/api", "type": "app"},
         {"name": "web", "path": "apps/web", "type": "app"},
         {"name": "shared", "path": "packages/shared", "type": "package"}
       ]
     }
   }
   ```

4. If NO workspace config found: omit `workspace` key entirely (single-package project).

5. Display in init summary:
   ```
   Workspace:      pnpm monorepo (3 packages)
     apps/api      (app)
     apps/web      (app)
     packages/shared (package)
   ```
```

- [ ] **Step 3: Update the state file template**

In the state file creation step, add the `workspace` field to the JSON template.

- [ ] **Step 4: Verify the edit**

Read `commands/init.md` and confirm workspace detection is present.

- [ ] **Step 5: Commit**

```bash
git add commands/init.md
git commit -m "feat: add monorepo workspace detection to init command"
```

---

### Task 4: Add Gap Check Gate to Orchestrator

**Files:**
- Modify: `agents/orchestrator.md`

The orchestrator must enforce a gap-check gate between Phase 2 (Implementation) and Phase 3 (Code Review). Only when gap-checker passes does code review begin.

- [ ] **Step 1: Read current orchestrator.md**

Read full file to find the exact insertion points.

- [ ] **Step 2: Add gap-check gate after DAG section**

After the "Typical dependency order" section (around line 72), add:

```markdown
## Cross-Package Gap Check Gate

After ALL implementation agents report DONE and BEFORE dispatching code-reviewer:

1. Check `solo-dev-state.json` for `workspace` field
2. If workspace exists AND impact map lists 2+ packages:
   - Dispatch `gap-checker` agent
   - Wait for PASS/FAIL verdict
   - On PASS → proceed to Phase 3
   - On FAIL → gap-checker sends targeted feedback to specific agents
     - Wait for agents to fix → gap-checker re-validates
     - Max 2 rounds → escalate to human
3. If no workspace OR single-package impact map:
   - Skip gap check → proceed directly to Phase 3

**State update on gap check:** `phase: GAP_CHECK`
```

- [ ] **Step 3: Update the typical dependency order to include gap-checker**

Update the dependency order list to add gap-checker:

```markdown
**Typical dependency order:**
1. data-agent (schema) — can start immediately from spec
2. backend-agent (API + contracts) — HARD depends on schema
3. frontend-agent (pages + state) — HARD depends on API contract
4. ui-agent (design system) — SOFT, can run parallel with all
5. test-agent (tests) — SOFT for unit tests, HARD for integration/E2E
6. **gap-checker (cross-package validation) — HARD depends on ALL impl agents completing**
```

- [ ] **Step 4: Update state transitions in orchestrator**

Add `GAP_CHECK` between `IMPLEMENTATION` and `CODE_REVIEW` in any state transition references.

- [ ] **Step 5: Verify the edits**

Read `agents/orchestrator.md` and confirm gap-check gate is present.

- [ ] **Step 6: Commit**

```bash
git add agents/orchestrator.md
git commit -m "feat: add cross-package gap check gate to orchestrator"
```

---

### Task 5: Update Workflow Documentation

**Files:**
- Modify: `docs/workflow.md`

Add Phase 2.5 (Gap Check) between Implementation and Code Review.

- [ ] **Step 1: Read current workflow.md**

Read the file to confirm exact section structure.

- [ ] **Step 2: Add Phase 2.5 after Phase 2 section**

After the Phase 2 section and before Phase 3, add:

```markdown
### Phase 2.5: Cross-Package Gap Check (monorepo only)

**Agent:** gap-checker
**When:** After all implementation agents report DONE. Skipped for single-package projects.

```
Reads impact map from spec → verifies every listed package has changes
  → PASS → Phase 3
  → FAIL → targeted feedback to specific agents
           agents fix → gap-checker re-validates changed packages only
           max 2 rounds → escalate to human
```

**State update:** `phase: GAP_CHECK`
```

- [ ] **Step 3: Update state transitions summary**

Add `GAP_CHECK` to the state transitions:

```
QUEUED
  → MARKET_VALIDATION
  → DESIGN_LOOP (rounds 1-3)
  → IMPLEMENTATION + BUSINESS_VALIDATION (parallel)
  → GAP_CHECK (monorepo only)
  → CODE_REVIEW + SECURITY_REVIEW (parallel, rounds 1-3)
  → QA_LOOP (rounds 1-3)
  → FINAL_ACCEPTANCE (rounds 1-2)
  → DEMO_GENERATION
  → COMPLETE
```

- [ ] **Step 4: Update adaptive phase ordering table**

Add gap check to each effort level that includes implementation.

- [ ] **Step 5: Commit**

```bash
git add docs/workflow.md
git commit -m "docs: add Phase 2.5 gap check to workflow documentation"
```

---

### Task 6: Update Agent Architecture Documentation

**Files:**
- Modify: `docs/agent-architecture.md`
- Modify: `wiki/Agent-Architecture.md`

Add gap-checker to the Validation Layer. Update agent count from 17 to 18.

- [ ] **Step 1: Read both files**

Read `docs/agent-architecture.md` and `wiki/Agent-Architecture.md`.

- [ ] **Step 2: Update layer overview diagram**

Change the Validation Layer line to include gap-checker:

```
   RESEARCH LAYER   VALIDATION LAYER        LEARNING LAYER
   R1, R2, R3       MV, PV, BV, SR, GC     MC, SE
```

Update the header: "18 agents organized in 4 layers"

- [ ] **Step 3: Add gap-checker section to agent-architecture.md**

Add after the security-reviewer section in the Validation Layer:

```markdown
### Gap Checker (V5) — `gap-checker`

**Model:** inherit (Sonnet)
**Color:** orange
**When:** After Phase 2 (Implementation), before Phase 3 (Code Review). Monorepo projects only.

**Role:** Validates that features spanning multiple monorepo packages have been implemented completely across all affected packages. Reads the Impact Map from the spec, cross-references with implementation agent reports, and identifies missing implementations.

**File ownership:** None (read-only validation agent)

**Input:**
- Impact Map from `docs/specs/{feature-id}.md`
- Implementation agent reports
- `workspace.packages` from `solo-dev-state.json`

**Output:** GAP_CHECK_REPORT with PASS/FAIL verdict and targeted fix instructions for specific agents.

**Loop:** Max 2 rounds. On continued FAIL → escalate to orchestrator.
```

- [ ] **Step 4: Mirror the same changes to wiki/Agent-Architecture.md**

- [ ] **Step 5: Commit**

```bash
git add docs/agent-architecture.md wiki/Agent-Architecture.md
git commit -m "docs: add gap-checker to agent architecture documentation"
```

---

### Task 7: Update README, Design Docs, and Wiki Home

**Files:**
- Modify: `README.md`
- Modify: `docs/design.md`
- Modify: `wiki/Home.md`

- [ ] **Step 1: Read README.md, docs/design.md, and wiki/Home.md**

Read all three files to find agent roster tables, design decisions, and agent count references.

- [ ] **Step 2: Update README.md**

1. Update agent count (17 → 18) in all references
2. Add gap-checker to the agent roster table
3. Update any Mermaid diagrams that show the workflow to include Gap Check

- [ ] **Step 3: Update docs/design.md**

1. Add new design decision:

```markdown
- **Cross-package completeness via gap-checker:** In monorepo projects, a dedicated gap-checker agent validates that every package listed in the Impact Map has corresponding implementation changes. Runs between implementation and code review. Prevents the common failure mode where agents implement only one side of a feature (e.g., API without frontend).
```

2. Update agent count in the file structure section (e.g., `agents/ # 17 agents` → `agents/ # 18 agents`)

- [ ] **Step 4: Update wiki/Home.md**

Update "17 agents" to "18 agents" in any references.

- [ ] **Step 5: Commit**

```bash
git add README.md docs/design.md wiki/Home.md
git commit -m "docs: update README, design docs, and wiki home for gap-checker and monorepo support"
```

---

### Task 8: Update Wiki Lifecycle and CLAUDE.md

**Files:**
- Modify: `wiki/Feature-Lifecycle.md`
- Modify: `CLAUDE.md`

- [ ] **Step 1: Read both files**

- [ ] **Step 2: Update Feature-Lifecycle.md**

Add Gap Check phase to the lifecycle Mermaid diagram and description.

- [ ] **Step 3: Verify no new wiki pages were created — if none, skip `wiki/_Sidebar.md` and `mkdocs.yml` updates**

- [ ] **Step 4: Update CLAUDE.md**

1. Update "17 agents" to "18 agents" in the Project Overview line
2. Update "17 agent definitions" to "18 agent definitions" in the File Structure comment
3. Add to Key Design Decisions:
```markdown
- **Cross-package gap-checker for monorepo projects:** Dedicated agent validates implementation completeness across all affected packages. Prevents partial feature implementation.
```

- [ ] **Step 5: Commit**

```bash
git add wiki/Feature-Lifecycle.md CLAUDE.md
git commit -m "docs: update wiki lifecycle and CLAUDE.md for gap-checker"
```

---

### Task 9: Version Bump and Changelog

**Files:**
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `docs/yaml/changelog.yaml`

- [ ] **Step 1: Bump version in plugin.json**

Change version from `0.3.0` to `0.4.0` in `plugin.json`.

- [ ] **Step 1b: Bump version and agent count in marketplace.json**

1. Change version from `0.3.0` to `0.4.0`
2. Update "17 specialized agents" to "18 specialized agents" in the description

- [ ] **Step 2: Add changelog entry**

```yaml
- version: "0.4.0"
  date: "2026-03-23"
  entries:
    - type: added
      description: "New gap-checker agent validates cross-package implementation completeness in monorepo projects"
    - type: added
      description: "Monorepo workspace detection during project initialization"
    - type: added
      description: "Impact Map requirement in tech-architect specs for multi-package features"
    - type: changed
      description: "Workflow adds Phase 2.5 (Gap Check) between implementation and code review for monorepo projects"
```

- [ ] **Step 3: Regenerate markdown if script exists**

```bash
bash hooks/scripts/yaml-to-markdown.sh docs/yaml/changelog.yaml
```

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json docs/yaml/changelog.yaml CHANGELOG.md
git commit -m "chore: bump to v0.4.0 — monorepo gap checker"
```

---

### Task 10: Add Tests and Run Test Suite

**Files:**
- Modify: test files that validate agent structure (find via `grep -r "agent" tests/`)
- Run: `tests/run-all.sh`

- [ ] **Step 1: Add gap-checker to agent structure validation tests**

Find the existing test that validates agent file structure (frontmatter fields, required sections). Add `gap-checker.md` to the list of expected agents. Verify the test checks:
- Frontmatter: `name`, `description`, `model`, `color`, `tools` fields present
- Required sections: "Output Format", "Self-Verification"
- Agent count is now 18 (update any hardcoded count assertions)

- [ ] **Step 2: Run the full test suite**

```bash
bash tests/run-all.sh
```

Expected: All tests pass including the new gap-checker validation.

- [ ] **Step 3: Fix any failures**

- [ ] **Step 4: Commit**

```bash
git add tests/
git commit -m "test: add gap-checker agent to structure validation tests"
```

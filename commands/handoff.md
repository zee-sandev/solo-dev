---
name: handoff
description: Transition the current conversation into a solo-dev structured workflow. Captures discussion context and creates a feature spec or runs init.
argument-hint: "[optional: 'design-only' to skip implementation]"
allowed-tools: Read, Write, Edit, Bash, WebSearch, WebFetch
---

Capture the current conversation's discussion and transition it into solo-dev's structured development workflow. Use this when a conversation naturally reaches the point where building should begin.

## Your Role

You are the orchestrator. Read the conversation context, synthesize what was discussed, and guide the user into the right solo-dev workflow.

## When To Use

The user has been discussing:
- A feature idea, architecture approach, or product concept
- A bug fix or enhancement that needs structured implementation
- A technical decision that should go through design + review

And now wants to move from "talking" to "building" with solo-dev's agent system.

## How It Works

### Step 1: Check Project State

Check if solo-dev is already initialized:

1. **`.claude/solo-dev-state.json` exists** → Project is initialized → go to **Feature Handoff**
2. **No state file** → Project not initialized → go to **Quick Init + Handoff**

---

### Feature Handoff (project already initialized)

#### A. Synthesize Discussion

Read the conversation and extract:

```markdown
## Discussion Summary
- **What:** {what feature/change was discussed}
- **Why:** {the problem it solves or value it adds}
- **Key decisions made:** {any architecture, UX, or tech decisions already agreed}
- **Open questions:** {anything unresolved}
- **Constraints mentioned:** {timeline, tech, budget, compatibility}
```

Present to user for confirmation:
```
Here's what I captured from our discussion:

  What: {summary}
  Why:  {motivation}
  Decisions: {list}
  Open: {unresolved items}

Does this look right? Anything to add or correct?
```

Wait for user confirmation.

#### B. Choose Workflow Depth

```
How would you like to proceed?

  A) Full lifecycle — Design loop → Implementation → Review → QA → Demo (8 phases)
  B) Design only — Research agents produce a spec, personas validate, stop before implementation
  C) Implement now — Skip design loop, go straight to parallel implementation
     (Use when design decisions are already made in the conversation)
```

If user provided `design-only` argument: auto-select B.

#### C. Create Feature Entry

Add feature entry to docs/yaml/features.yaml with status QUEUED, source 'handoff', then regenerate roadmap.md via yaml-to-markdown.sh:
```yaml
- id: H1
  name: "{feature name}"
  value: "{why it matters}"
  status: QUEUED
  source: handoff
```

Write `docs/specs/{feature-id}-draft.md`:
```markdown
# {Feature Name} — Draft from Conversation

## Context
{Discussion summary from Step A}

## Requirements
{Extracted from conversation — what needs to be built}

## Decisions Already Made
{Architecture, UX, tech decisions from conversation}

## Open Questions
{Items that need resolution during design loop}

## Constraints
{Timeline, compatibility, tech constraints mentioned}
```

Also add entry to docs/yaml/specs.yaml with feature_id, path, status 'draft'.

#### D. Execute

Based on user's choice:
- **A) Full lifecycle** → Update state, start at Phase 0 (Market Validation) or Phase 1 (Design Loop) depending on feature type
- **B) Design only** → Run Phase 1 Design Loop only → output final spec → stop
- **C) Implement now** → Skip to Phase 2 (Parallel Implementation) using the draft spec as approved spec

Update `.claude/solo-dev-state.json` accordingly.

---

### Quick Init + Handoff (project NOT initialized)

When no solo-dev state exists, run a minimal init before handoff.

#### A. Quick Init

This is NOT the full `/solo-dev:init` — it's a lightweight setup:

1. Detect stack from project files (package.json, go.mod, etc.) or CLAUDE.md
2. Create minimal directory structure:
   ```bash
   mkdir -p docs/agents/memory/snapshots
   mkdir -p docs/product
   mkdir -p docs/specs
   mkdir -p .claude
   ```
3. Create minimal state file
4. Create minimal memory index
5. If CLAUDE.md exists: read it for foundation context (same as Foundation Mode)

Skip: autonomy config, global memory, repomix setup, detailed onboarding
These can be set up later with full `/solo-dev:init`.

```
Quick setup complete. Full configuration available via /solo-dev:init later.
Proceeding with handoff...
```

#### B. Continue to Feature Handoff

Go to Feature Handoff → Step A above.

---

## After Handoff Completes

```
Handoff complete.

  Feature: {name}
  Spec: docs/specs/{id}-draft.md
  Mode: {Full lifecycle | Design only | Implement now}

  {If full lifecycle:}
  Starting Phase {0|1}... Run /solo-dev:status to track progress.

  {If design only:}
  Design loop starting. Spec will be at docs/specs/{id}.md when complete.

  {If implement now:}
  Spawning implementation agents...
```

## Rules

- ALWAYS confirm the discussion summary with the user before proceeding
- NEVER lose context from the conversation — capture key decisions and constraints
- If the conversation was short or vague: ask clarifying questions before creating the spec
- If the user chose "implement now": warn that skipping design loop means no persona validation
- Quick Init is intentionally minimal — don't ask 5 questions, just set up the basics
- Feature IDs from handoff use "H" prefix (H1, H2...) to distinguish from roadmap features (A1, B1...)

---
name: init
description: Initialize a solo-dev project. Detects whether this is a new concept or an existing codebase and runs the appropriate onboarding flow.
argument-hint: "[optional: concept description or 'existing' to onboard existing codebase]"
allowed-tools: Read, Write, Edit, Bash
---

Initialize the solo-dev project structure. This sets up all infrastructure for the multi-agent development system. The flow differs depending on whether you are starting fresh or onboarding an existing codebase.

## Your Role
You are the orchestrator. Detect the project's starting point and run the appropriate onboarding path before feature development begins.

---

## Detect Starting Point

Check in this order:

1. **docs/product/roadmap.md exists** → came from `/solo-dev:start-from-idea` → go to **Path A**
2. **Existing codebase** (source files present, no solo-dev docs) → go to **Path B**
3. **Neither** (blank project) → ask user for concept → go to **Path A**

---

## Path A — New Project (fresh concept)

### Step 1: Load or collect concept

If roadmap.md exists:
- Read docs/product/roadmap.md and docs/product/personas.md
- Confirm with user: "Found your product concept from start-from-idea. Ready to set up for development?"
- Skip concept questions

If no roadmap exists, ask ONE AT A TIME:
1. "Describe your product concept in 1-3 sentences"
2. "Who are your target users?"
3. "Which tech stack will you use?" (offer: Next.js, Django, Go, Spring Boot, or describe your own)
4. "Who are your main competitors?"
5. "What's your monetization model?"

### Step 2: Create directory structure → Step 3 → Step 4 → Step 5 → Step 6 → Step 7 → Step 8
*(follow shared steps below)*

---

## Path B — Existing Project (onboarding existing codebase)

**No questions yet. Analyze first.**

### Step 1: Pack and Analyze

Pack codebase with Repomix MCP (`pack_codebase` for current directory).
If Repomix unavailable: fall back to reading key files directly (package.json, go.mod, requirements.txt, src/ structure, prisma/schema.prisma or equivalent).

Run parallel analysis:
- **tech-architect** → stack, architecture, file structure, API surface, test coverage signals
- **product-researcher** → product shape, feature areas, business model signals
- **ux-researcher** → pages, user flows, navigation, route structure

### Step 2: Present Stack (auto — no confirmation needed)

Display detected stack clearly. No user input required here — this is objective.

```
Framework   Next.js 14 (App Router)
ORM         Prisma + PostgreSQL
Auth        NextAuth.js
Payments    Stripe
Deployment  Vercel (inferred from vercel.json)
```

### Step 3: Present Product Understanding + Cross-check

Show what the codebase reveals about the product — no leading statements, ground everything in code signals:

```
Based on the codebase, here's my understanding:

┌─────────────────────────────────────────────────────────────┐
│  [What the product appears to do]                           │
│                                                             │
│  Confidence signals:                                        │
│  · [page routes found]                                      │
│  · [database tables found]                                  │
│  · [patterns found]                                         │
└─────────────────────────────────────────────────────────────┘

Two questions before I continue:

1. Does this match your product?
   Correct anything wrong or misleading.

2. What's the most important thing I might have missed
   that affects how features should be built going forward?
```

Wait for user response. Update understanding before continuing.

### Step 4: Present Feature Map + Resolve Unknowns

Show all detected feature areas with the signal used to determine status:

```
┌───┬──────────────────┬──────────┬──────────────────────────────────────┐
│   │ Feature          │ Status   │ How I determined this                │
├───┼──────────────────┼──────────┼──────────────────────────────────────┤
│ 1 │ [feature name]   │ Complete │ Full API + UI + tests passing        │
│ 2 │ [feature name]   │ Partial  │ [specific signal]                    │
│ 3 │ [feature name]   │ Stub     │ [specific signal]                    │
│ 4 │ [feature name]   │ Unclear  │ [why unclear]                        │
└───┴──────────────────┴──────────┴──────────────────────────────────────┘
```

Status definitions:
- **Complete** — API + UI + tests all present and wired
- **Partial** — some layer missing (no tests, UI only, API only)
- **Stub** — entry point exists but no real implementation
- **Unclear** — conflicting signals, need user input

After the table, ask specifically about every Unclear item:
```
I'm specifically unsure about items [X, Y]:
  [X] [feature] — [what's unclear]?
  [Y] [feature] — [what's unclear]?

Also: Are there features I missed entirely that aren't visible from the code?
```

Wait for user response. Update feature map before continuing.

### Step 5: Present Inferred Architecture Decisions

Show patterns that look intentional. Every entry is tagged `[INFERRED]` — agents must not treat these as ground truth until user confirms.

```
I found patterns that look like intentional decisions.
These are tagged [INFERRED] — I don't know the "why" behind them.
Please confirm, add context, or mark as "accidental / can change".

  [INFERRED] [pattern description]
  [INFERRED] [pattern description]
  [INFERRED] [pattern description]
```

For each decision user confirms:
- Record as confirmed in decisions.md with user's stated reason
- Mark unconfirmed ones as `[INFERRED — reason unknown, treat carefully]`
- Mark "accidental" ones as `[INCONSISTENT — agents should standardize going forward]`

### Step 6: Generate Docs from Analysis

Write all product docs based on confirmed understanding:

- **docs/product/idea-brief.md** — product summary from analysis + user corrections
- **docs/product/personas.md** — inferred from user types found in code + user input
- **docs/product/roadmap.md** — existing features mapped to status:
  - `SHIPPED` → Complete features
  - `WIP` → Partial features
  - `PLANNED` → Stubs + user-mentioned planned features
  - `IGNORED` → Placeholders user said to skip
- **docs/agents/memory/patterns.md** — coding patterns observed in codebase
- **docs/agents/memory/decisions.md** — confirmed decisions with reasons; unconfirmed tagged `[INFERRED]`

Then continue to shared Steps 3–8 below (skip Step 1 — already done).

---

## Shared Steps (both paths)

### Step 3 (Path A) / Step 7 (Path B): Create directory structure
```bash
mkdir -p docs/agents/memory/snapshots
mkdir -p docs/contracts
mkdir -p docs/specs
mkdir -p docs/demos
mkdir -p docs/product
mkdir -p .claude
```

### Step 4 / Step 8: Create memory index

Create docs/agents/memory/index.md:
```markdown
# Memory Index — {project-name}
Last updated: {date} | Features completed: {0 or N for existing}

## decisions.md
  {summary or [empty]}

## patterns.md
  {summary or [empty]}

## cr_learnings.md
  [empty — no code review learnings yet]

## bv_learnings.md
  [empty — no business validation learnings yet]
```

Create any missing memory files: decisions.md, patterns.md, rejected.md, persona_insights.md, cr_learnings.md, bv_learnings.md, performance-log.md

### Step 5 / Step 9: Create state file

Create .claude/solo-dev-state.json:
```json
{
  "project": "{project-name}",
  "phase": "INIT",
  "onboarding_type": "new | existing",
  "current_feature": null,
  "round": 0,
  "blocked_since": null,
  "agents_status": {},
  "repomix_pack_id": "{pack-id or null}",
  "stack": "{detected-stack}",
  "last_updated": "{current-datetime}"
}
```

### Step 6 / Step 10: Create autonomy config

Create .claude/solo-dev.local.md:
```yaml
---
# solo-dev Configuration

autonomy:
  tech_stack_selection: always-ask
  boilerplate_generation: always-auto
  research_synthesis: threshold:0.8
  design_decisions: always-ask
  implementation: always-auto
  code_review_fixes: threshold:0.9
  deployment_config: always-ask

token_budget:
  mode: "disabled"    # "fixed" | "subscription" | "disabled"
  fixed:
    per_feature: 50000
    warning_threshold: 0.8

api_contracts:
  enabled: true
  output:
    mode: "markdown"  # "markdown" | "custom"
    markdown:
      path: "docs/contracts"
---
```

### Step 7 / Step 11: Repomix setup

For **Path A** (new project): Ask "Would you like to set up Repomix? (Saves ~80% tokens on code exploration)"
For **Path B** (existing): Repomix was already used in Step 1. Save pack_id to state.

If pack created: save pack_id to solo-dev-state.json.

### Step 8 / Step 12: Global memory structure

```bash
mkdir -p ~/.claude/solo-dev/global-memory/learnings
mkdir -p ~/.claude/solo-dev/strategies
```

Create ~/.claude/solo-dev/global-memory/index.md if not exists.
Create empty strategy files if not exist: research.md, implementation.md, qa.md

### Final: Confirm setup

```
=== solo-dev: Project Initialized ===

Project:        {name}
Onboarding:     New concept | Existing codebase
Stack:          {stack}
Repomix:        enabled (pack: {id}) | disabled
Token budget:   {mode}

Memory system:  ✅
State file:     ✅
Autonomy config:✅
Product docs:   ✅

{If existing project:}
Features mapped:
  SHIPPED  → {N} features
  WIP      → {N} features
  PLANNED  → {N} features

{If decisions.md has [INFERRED] entries:}
⚠  {N} architecture decisions are marked [INFERRED].
   Review docs/agents/memory/decisions.md before next-feature
   to ensure agents work from correct assumptions.

Next steps:
  1. Review .claude/solo-dev.local.md to adjust autonomy
  2. Check docs/product/roadmap.md for feature queue
  3. Run /solo-dev:next-feature to start building

Ready to build! 🚀
```

Update state: `phase → READY`

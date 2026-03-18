# Existing Project Onboarding

When `/solo-dev:init` detects an existing codebase with no product docs, it picks one of two paths based on what's already documented.

---

## Foundation Mode (Template Projects)

If your project started from a well-documented template (has `CLAUDE.md` + `docs/` or `.claude/agents/`), solo-dev uses **Foundation Mode** — a faster path that reads existing documentation instead of analyzing from scratch.

**Total user interactions:** 1

### What solo-dev reads automatically

| Source | Extracts |
|--------|---------|
| `CLAUDE.md` | Stack, conventions, architecture, development commands |
| `docs/` | Architecture patterns, API structure, naming conventions |
| `.claude/agents/` | Existing agent capabilities → delegates implementation to them |
| `.claude/skills/` | Existing skill capabilities → uses them during feature builds |

### What solo-dev asks you

One question: **"What product are you building on this foundation?"**

That's it. No stack analysis, no architecture inference, no multi-round cross-checks.

### Agent Delegation

solo-dev's implementation agents (frontend, backend, data, test) **delegate** to existing project agents when available. Project agents know the template's conventions better. solo-dev still handles all research, validation, and learning — the template doesn't provide those.

### Example Code Handling

Template example code (demo pages, sample modules, placeholder translations) is **NOT deleted upfront**. Instead:

1. solo-dev **tags** example files during init
2. During feature builds, agents **automatically replace** examples that overlap with real features
3. After all roadmap features complete, solo-dev **prompts once** to remove any remaining unused examples

This means example code serves as a reference while you build, and disappears naturally as real features replace it.

See [Configuration](Configuration.md) for foundation settings.

---

## Standard Onboarding (Non-template Projects)

When no `CLAUDE.md` or `.claude/agents/` is detected, solo-dev runs the full analysis-first onboarding below.

**Total user interactions:** 3

---

## Step 1: Silent Analysis (no questions)

solo-dev packs the codebase with Repomix MCP and runs parallel analysis:

| Agent | Analyzes |
|-------|---------|
| `tech-architect` | Stack, architecture, file structure, API surface, test coverage signals |
| `product-researcher` | Product shape, feature areas, business model signals |
| `ux-researcher` | Pages, user flows, navigation, route structure |

No user input at this stage. The codebase speaks first.

---

## Step 2: Stack Presentation (auto — no confirmation)

Displays detected stack. This is objective — no user input needed.

```
Framework   Next.js 14 (App Router)
ORM         Prisma + PostgreSQL
Auth        NextAuth.js
Payments    Stripe
Deployment  Vercel (inferred from vercel.json)
```

---

## Step 3: Product Understanding Cross-check (Interaction 1)

Presents what the codebase reveals about the product. Every claim is grounded in a code signal.

```
Based on the codebase, here's my understanding:

A B2B web app where users track keyword rankings and monitor
search position over time. Multi-tenant, team-based access,
subscription model via Stripe.

Confidence signals:
  · /dashboard, /keywords, /rankings, /reports pages
  · keywords, serp_snapshots, teams, subscriptions tables
  · role: admin | member pattern throughout

1. Does this match your product? Correct anything wrong or misleading.
2. What's the most important thing I might have missed
   that affects how features should be built going forward?
```

**Rule:** Never present understanding as confident — present it as "what I found" and let the user correct.

---

## Step 4: Feature Map Cross-check (Interaction 2)

Shows all detected features with status and the signal used to determine each:

```
┌───┬──────────────────────────┬──────────┬──────────────────────────────┐
│ 1 │ Keyword tracking         │ Complete │ Full API + UI + tests passing │
│ 2 │ SERP position graph      │ Complete │ Full API + UI + tests passing │
│ 3 │ Content brief generator  │ Partial  │ UI exists, API has no tests   │
│ 4 │ Team management          │ Partial  │ UI complete, no backend       │
│ 5 │ Email reports            │ Unclear  │ DB model exists, no send logic│
│ 6 │ Billing / subscriptions  │ Stub     │ Stripe configured, no flow    │
│ 7 │ Onboarding               │ Unclear  │ 1 page found, no completion   │
└───┴──────────────────────────┴──────────┴──────────────────────────────┘
```

### Status Definitions

| Status | Meaning |
|--------|---------|
| **Complete** | API + UI + tests all present and wired |
| **Partial** | Some layer missing (no tests, UI only, API only) |
| **Stub** | Entry point exists but no real implementation |
| **Unclear** | Conflicting signals — needs user input |

Asks specifically about every **Unclear** item, plus:
"Are there features I missed entirely that aren't visible from the code?"

---

## Step 5: Architecture Decisions Cross-check (Interaction 3)

Surfaces patterns that look intentional. Every entry is tagged `[INFERRED]`.

```
I found patterns that look like intentional decisions.
These are tagged [INFERRED] — I don't know the "why" behind them.
Please confirm, add context, or mark as "accidental / can change".

  [INFERRED] Multi-tenancy via tenantId on every table
  [INFERRED] Soft deletes via deletedAt (not hard delete)
  [INFERRED] Server Actions for mutations, not REST
```

### How User Responses Map

| User says | Written as |
|-----------|-----------|
| Confirmed + reason given | Confirmed decision with stated reason |
| Confirmed, no reason | `[INFERRED — reason unknown, treat carefully]` |
| "Accidental / can change" | `[INCONSISTENT — agents should standardize going forward]` |

**Why this matters:** Agents read `decisions.md` before every task. Wrong decisions compound across every feature.

---

## Step 6: Generate Docs

Writes all product docs from confirmed understanding:

| File | Contents |
|------|---------|
| `docs/product/idea-brief.md` | Product summary from analysis + user corrections |
| `docs/product/personas.md` | User types inferred from code + user input |
| `docs/product/roadmap.md` | Features mapped to status |
| `docs/agents/memory/patterns.md` | Coding patterns observed |
| `docs/agents/memory/decisions.md` | Confirmed decisions with reasons; unconfirmed tagged `[INFERRED]` |

### Roadmap Status Mapping

| Feature Map Status | Roadmap Status |
|-------------------|---------------|
| Complete | `SHIPPED` |
| Partial | `WIP` |
| Stub (user confirms upcoming) | `PLANNED` |
| Unclear (resolved by user) | Mapped accordingly |
| Explicitly excluded by user | `IGNORED` |
| User-added (not found in code) | `PLANNED` |

---

## After Onboarding

The project is now ready for feature development:

```
=== solo-dev: Project Initialized ===

Project:        my-project
Onboarding:     Existing codebase
Stack:          Next.js 14 + Prisma + PostgreSQL

Features mapped:
  SHIPPED  →  2 features
  WIP      →  3 features
  PLANNED  →  2 features

⚠  1 architecture decision marked [INCONSISTENT].
   Agents will standardize to REST endpoints for new features.

Next steps:
  1. Review docs/agents/memory/decisions.md
  2. Check docs/product/roadmap.md
  3. Run /solo-dev:next-feature to start building
```

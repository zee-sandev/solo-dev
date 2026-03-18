# solo-dev — Memory Flow

> How agents interact with the memory system. Designed for token efficiency:
> index loads once (~300 tokens total), everything else loads on-demand.

---

## Memory Architecture

```
SESSION CONTEXT (always loaded)
  ├── docs/agents/memory/index.md     ~200 tokens  ← project index
  └── ~/.claude/solo-dev/global-memory/index.md  ~100 tokens  ← cross-project index

ON-DEMAND (agents pull when needed, ~500 tokens each)
  ├── docs/agents/memory/decisions.md
  ├── docs/agents/memory/patterns.md
  ├── docs/agents/memory/rejected.md
  ├── docs/agents/memory/persona_insights.md
  ├── docs/agents/memory/cr_learnings.md
  ├── docs/agents/memory/bv_learnings.md
  └── docs/agents/memory/performance-log.md

STRATEGY FILES (loaded by respective agents, ~200 tokens each)
  ├── ~/.claude/solo-dev/strategies/research.md
  ├── ~/.claude/solo-dev/strategies/implementation.md
  └── ~/.claude/solo-dev/strategies/qa.md

CROSS-PROJECT LEARNINGS (search-only via index, never loaded upfront)
  └── ~/.claude/solo-dev/global-memory/learnings/*.md

SNAPSHOTS (rollback only)
  └── docs/agents/memory/snapshots/pre-{feature-id}.json
```

---

## SessionStart Hook Flow

```
Session begins
  │
  ├─ 1. Read .claude/solo-dev-state.json
  │      → Determine current phase + feature
  │      → Set $SAAS_DEV_PHASE, $SAAS_DEV_FEATURE env vars
  │
  ├─ 2. Load docs/agents/memory/index.md (~200 tokens)
  │      → Provides: what's in memory, key decision pointers
  │
  ├─ 3. Load ~/.claude/solo-dev/global-memory/index.md (~100 tokens)
  │      → Provides: cross-project pattern summaries
  │
  ├─ 4. Detect tech stack from project files
  │      package.json → Next.js | manage.py → Django | go.mod → Go | etc.
  │      → Export $SAAS_DEV_STACK to $CLAUDE_ENV_FILE
  │
  ├─ 5. Check repomix pack
  │      → If pack_id in state.json AND pack still valid: set $REPOMIX_PACK_ID
  │      → If no pack: prompt "Set up Repomix for token-efficient exploration?"
  │
  └─ 6. Check optional plugins
         → Detect: impeccable, ui-ux-pro-max, ecc plugins
         → Report: "Using bundled fallback for: [missing plugins]"

Total tokens loaded at start: ~300-400
```

---

## What Each Agent Reads Before Starting

| Agent | Reads | Why |
|-------|-------|-----|
| `orchestrator` | state.json + index.md | Know current phase, what's in memory |
| `product-researcher` | decisions.md#market, bv_learnings.md, global index | Avoid repeating past decisions, apply competitive learnings |
| `ux-researcher` | persona_insights.md, personas.md | Build on past UX observations |
| `tech-architect` | patterns.md, rejected.md, repomix pack | Use proven patterns, avoid rejected approaches |
| `market-validator` | decisions.md#market | Check market decisions already made |
| `persona-validator` | personas.md, current spec | Evaluate from persona perspective |
| `business-validator` | bv_learnings.md, competitive-analysis.md | Apply competitive learnings |
| `security-reviewer` | cr_learnings.md#security | Check known security anti-patterns |
| `frontend-agent` | repomix pack, patterns.md | Understand existing code structure |
| `backend-agent` | repomix pack, patterns.md, decisions.md#api | Follow established patterns |
| `ui-agent` | repomix pack, patterns.md | Match existing design system |
| `data-agent` | repomix pack, decisions.md#schema | Follow schema conventions |
| `test-agent` | current spec, acceptance criteria | Test against agreed criteria |
| `code-reviewer` | cr_learnings.md | Proactively check known failure patterns |
| `qa-validator` | approved spec, acceptance criteria | Validate against agreed spec |
| `memory-curator` | all memory files | Compress and reindex |
| `strategy-evolver` | performance-log.md, strategy files | Identify improvement patterns |

---

## What Each Agent Writes After Completing

| Agent | Writes To | Content |
|-------|-----------|---------|
| `product-researcher` | decisions.md#market | Market decisions + rationale |
| `ux-researcher` | persona_insights.md | UX patterns, friction observed |
| `tech-architect` | patterns.md, rejected.md | Accepted patterns, tried-and-rejected |
| `persona-validator` | persona_insights.md | Feedback themes per persona |
| `business-validator` | bv_learnings.md | Business gaps to avoid in future specs |
| `code-reviewer` | cr_learnings.md | Common failure patterns to proactively avoid |
| `memory-curator` | index.md (reindex), snapshots/ | Compressed index, pre-feature snapshot |
| `strategy-evolver` | strategies/*.md | Updated agent strategies |

---

## memory-index.md Format

The index is always ≤200 tokens. It is a summary of what's in each memory file, not the content itself.

```markdown
# Memory Index — {project-name}
Last updated: {date} | Feature count: {N}

## decisions.md
- Tech: Next.js 15 + Hono, MongoDB (decided 2026-03-10)
- API: REST with oRPC wrappers (decided 2026-03-12)
- Auth: Better Auth with magic links (decided 2026-03-14)
  [3 total decisions]

## patterns.md
- Repository pattern for all data access [since feature A1]
- API response envelope: {success, data, error, meta} [since feature A1]
  [2 patterns]

## rejected.md
- WebSocket for SERP scoring — too complex, use polling [A1]
  [1 rejection]

## persona_insights.md
- Sarah (Agency): bulk operations must complete in ≤2 clicks [A1]
- Alex (SMB): avoid jargon in UI labels [A1]
  [2 insights]

## cr_learnings.md
- backend-agent: often misses rate limiting on auth routes [A1]
  [1 learning]

## bv_learnings.md
- billing features: always include dunning + proration + grace period [—]
  [1 learning]
```

---

## Memory Compression Rules (memory-curator)

Runs after every feature ships. Compresses to keep files readable and fast.

```
decisions.md:
  Keep: final decisions with rationale
  Remove: superseded decisions (mark as [SUPERSEDED])
  Never remove: architectural decisions

patterns.md:
  Keep: patterns still in use
  Archive: patterns replaced by better ones (move to rejected.md)

persona_insights.md:
  Keep: recurring themes (appeared 2+ times)
  Compress: one-off feedback into bullet points
  Max file size: 1000 tokens

cr_learnings.md:
  Keep: patterns that caused failures
  Remove: issues resolved by codebase changes
  Max file size: 800 tokens
```

---

## Cross-Project Learning Flow

```
Feature ships in Project A
  │
  ▼
memory-curator identifies reusable patterns:
  "multi-tenant auth with Better Auth — tested pattern"
  │
  ▼
Writes to: ~/.claude/solo-dev/global-memory/learnings/
  auth-patterns.md       ← auth patterns across projects
  billing-patterns.md    ← billing edge cases seen
  api-patterns.md        ← API design patterns
  │
  ▼
Updates: ~/.claude/solo-dev/global-memory/index.md
  "auth-patterns.md: 3 patterns (Better Auth, magic links, multi-tenant)"
  │
  ▼
Project B starts, needs auth
  tech-architect reads global index → finds auth-patterns.md
  → smart_search("multi-tenant authentication") → retrieves pattern
  → applies immediately, skips re-research
```

---

## Strategy File Format

Maintained by strategy-evolver. Loaded by respective agents.

```markdown
# Research Strategy — Updated 2026-03-18

## What works well
- Search competitor G2 reviews before proposing features (saves 1-2 research rounds)
- Check bv_learnings.md for domain-specific checklists before spec

## Common mistakes to avoid
- product-researcher: missing dunning/proration in billing features
- ux-researcher: not checking mobile viewport for forms

## Confidence calibration
- Market size estimates: confidence 0.7 (use threshold:0.7 for research_synthesis)
- Competitor feature detection: confidence 0.85

## Last evolved: 2026-03-18 | Features analyzed: 3
```

---

## Token Budget Enforcement

| Mode | Behavior |
|------|---------|
| `fixed` | Hard stop at limit. Warn at 80%. Pause + ask user at 100%. |
| `subscription` | No hard stop. Warn if feature uses >3x average. Auto-compress at context 80%. Detect stalls (agent loops with no diff). |
| `disabled` | No intervention. No tracking. |

**Auto-compress trigger (subscription mode):**
```
Context window > 80% full
  → memory-curator: compress low-priority context
  → Completed phases (earlier design rounds, resolved conflicts)
  → Old agent outputs (keep only final decisions)
  → Never compress: current spec, active agent state, memory index
```

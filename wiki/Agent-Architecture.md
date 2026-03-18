# Agent Architecture

solo-dev uses 17 agents organized into 4 layers. Each agent has a defined role, skill set, file ownership boundaries, and memory read/write rules.

## Layer Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      ORCHESTRATOR                           │
│  Coordinates all agents. Never writes code or designs.      │
└────────────────────────┬────────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         ▼               ▼               ▼
   RESEARCH LAYER   VALIDATION LAYER   LEARNING LAYER
   R1, R2, R3       MV, PV, BV, SR     MC, SE
         │               │
         └───────┬───────┘
                 ▼
       IMPLEMENTATION LAYER
       I1, I2, I3, I4, I5 (parallel)
```

---

## Orchestrator

| | |
|---|---|
| **ID** | `orchestrator` |
| **Model** | Sonnet |
| **Role** | Central coordinator — manages phases, spawns agents, enforces loop termination, handles conflicts |

**Never does:** write code, make design decisions unilaterally, skip quality gates.

**Skills:** `superpowers:dispatching-parallel-agents`, `ecc:enterprise-agent-ops`, `ecc:autonomous-loops`

**Responsibilities:**
- Read `solo-dev-state.json` to determine current phase
- Spawn correct agents per phase
- Collect outputs and detect conflicts
- Enforce loop max-retries and escalate when exceeded
- Commit to git after each completed feature
- Update state after each phase transition

---

## Research Layer

### R1 — Product Researcher

| | |
|---|---|
| **ID** | `product-researcher` |
| **Role** | Market fit, monetization, competitor analysis, feature positioning |
| **Skills** | `ecc:market-research`, `ecc:search-first` |
| **Reads** | `decisions.md#market`, `bv_learnings.md`, global index |
| **Writes** | `decisions.md#market`, global learnings |

### R2 — UX Researcher

| | |
|---|---|
| **ID** | `ux-researcher` |
| **Role** | User behavior, information architecture, journey mapping, friction analysis |
| **Skills** | `ui-ux-pro-max` (or `solo-dev:ux-design` fallback), `impeccable:critique`, `impeccable:onboard` |
| **Reads** | `persona_insights.md`, `personas.md` |
| **Writes** | `persona_insights.md` |

### R3 — Tech Architect

| | |
|---|---|
| **ID** | `tech-architect` |
| **Role** | Technical feasibility, API design, performance, scalability |
| **Skills** | `ecc:backend-patterns` (or fallback), `ecc:api-design`, `ecc:deployment-patterns`, `ecc:docker-patterns`, stack-specific skills |
| **Reads** | `patterns.md`, `rejected.md`, Repomix pack |
| **Writes** | `patterns.md`, `rejected.md` |

---

## Validation Layer

### Market Validator

| | |
|---|---|
| **ID** | `market-validator` |
| **Role** | Commercial viability gate (Phase 0). Advisor only — human decides on conflicts |
| **Validates** | 2/3 competitors have this OR users requested it; ties to acquisition/activation/retention/revenue; ships in ≤2 weeks |
| **Output** | `VIABLE` or `NOT_VIABLE` + reasoning |

### Persona Validator

| | |
|---|---|
| **ID** | `persona-validator` |
| **Role** | Evaluates specs from generated user persona perspectives |
| **Voting** | `APPROVE` / `CONDITIONAL` / `REJECT` per persona. 3/3 APPROVE required. CONDITIONAL = REJECT until resolved |
| **Reads** | `personas.md`, current spec |
| **Writes** | `persona_insights.md` |

### Business Validator

| | |
|---|---|
| **ID** | `business-validator` |
| **Role** | Business completeness + competitive gap analysis (runs after QA, before Final Acceptance) |
| **Reviews** | Business logic completeness, real-world correctness, competitive gaps, enhancement opportunities |
| **Writes** | `bv_learnings.md` |

### Security Reviewer

| | |
|---|---|
| **ID** | `security-reviewer` |
| **Role** | SaaS security gate (runs parallel with QA) |
| **Checklist** | Auth & identity, multi-tenancy isolation, payment security, API security, PII protection |
| **Output** | `SECURITY_REPORT` with severity levels + `APPROVE` / `REJECT` |

---

## Implementation Layer

All 5 agents run **in parallel** with **strict file ownership** — no agent touches files owned by another.

### I1 — Frontend Agent

| | |
|---|---|
| **ID** | `frontend-agent` |
| **Owns** | `pages/`, `app/`, `routes/`, `components/` (non-design-system) |
| **Skills** | `impeccable:*` (or `solo-dev:ui-quality` fallback), `ui-ux-pro-max` (or fallback), `ecc:frontend-patterns` |

### I2 — Backend Agent

| | |
|---|---|
| **ID** | `backend-agent` |
| **Owns** | `src/api/`, `src/services/`, `src/repositories/`, `src/middleware/` |
| **Skills** | `ecc:backend-patterns` (or fallback), `ecc:api-design`, `ecc:coding-standards`, stack-specific, Better Auth MCP |
| **Also** | Defines API contracts → `docs/contracts/{feature}-api.md` |

### I3 — UI Agent

| | |
|---|---|
| **ID** | `ui-agent` |
| **Owns** | `src/components/ui/`, `src/design-system/`, `src/styles/` |
| **Skills** | `impeccable:*` (primary), `ui-ux-pro-max` (or fallback) |
| **Must invoke** | `impeccable:polish` + `impeccable:critique` before reporting DONE |

### I4 — Data Agent

| | |
|---|---|
| **ID** | `data-agent` |
| **Owns** | `prisma/`, `migrations/`, `src/db/`, `schemas/` |
| **Skills** | `ecc:database-migrations`, `ecc:postgres-patterns` |

### I5 — Test Agent

| | |
|---|---|
| **ID** | `test-agent` |
| **Owns** | `tests/`, `__tests__/`, `spec/`, `e2e/` |
| **Skills** | `ecc:tdd` (or fallback), `ecc:tdd-workflow`, `ecc:e2e-testing` |
| **Also** | Phase 8 demo generation (Playwright recording + demo.md) |

---

## Quality + Learning Layer

### Code Reviewer

| | |
|---|---|
| **ID** | `code-reviewer` |
| **Role** | Technical gatekeeper (runs after all I agents complete) |
| **Dimensions** | Security, Maintainability, Scalability, Tech Debt |
| **Output** | `CR_REPORT` with `APPROVE` / `REJECT` |
| **If REJECT** | Targeted `CR_FEEDBACK` to specific agents → fix → re-review changed files only (max 3 rounds) |
| **Writes** | `cr_learnings.md` |

### QA Validator

| | |
|---|---|
| **ID** | `qa-validator` |
| **Role** | Functional correctness and business logic verification |
| **Checklist** | Functional (acceptance criteria, edge cases), Business Logic (multi-tenant, plan gates), Integration (regression, API contracts), Performance (load times, API response) |
| **If FAIL** | `QA_FAILURE` → agents fix → CR re-checks → QA re-runs (max 3 rounds) |

### Memory Curator

| | |
|---|---|
| **ID** | `memory-curator` |
| **Role** | Memory compression, indexing, snapshots, cross-project learning |
| **Runs** | Before each feature (snapshot), after each feature (compress + reindex), after feedback cycles |
| **Manages** | All memory files, snapshots, global memory sync |

### Strategy Evolver

| | |
|---|---|
| **ID** | `strategy-evolver` |
| **Role** | Analyzes performance data → updates strategy files for future sessions |
| **Triggered by** | `/solo-dev:evolve` command (not automatic) |
| **Requires** | At least 3 completed features |
| **Updates** | `~/.claude/solo-dev/strategies/` (research, implementation, qa) |

---

## Memory Read/Write Summary

| Agent | Reads Before Starting | Writes After Completing |
|-------|----------------------|------------------------|
| `orchestrator` | state.json, index.md | state.json |
| `product-researcher` | decisions.md#market, bv_learnings.md, global index | decisions.md#market, global learnings |
| `ux-researcher` | persona_insights.md, personas.md | persona_insights.md |
| `tech-architect` | patterns.md, rejected.md, Repomix pack | patterns.md, rejected.md |
| `persona-validator` | personas.md, current spec | persona_insights.md |
| `business-validator` | bv_learnings.md, competitive-analysis.md | bv_learnings.md |
| `code-reviewer` | cr_learnings.md | cr_learnings.md |
| `memory-curator` | all memory files | index.md, snapshots/ |
| `strategy-evolver` | performance-log.md, strategy files | strategies/*.md |

# Agent Architecture

solo-dev uses 18 agents organized into 4 layers. Each agent has a defined role, skill set, file ownership boundaries, and memory read/write rules.

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
   R1, R2, R3       MV, PV, BV, SR, GC  MC, SE
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
| **Role** | Central coordinator — DAG dispatching, adaptive phases, spawns agents, enforces loop termination, conflict precedence, state recovery |

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
| **Role** | Market fit, monetization, competitor analysis, feature positioning, trend prediction, disruption risk |
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
| **Role** | Technical feasibility, API design, performance targets, scalability, build-vs-buy analysis |
| **Skills** | `ecc:backend-patterns` (or fallback), `ecc:api-design`, `ecc:deployment-patterns`, `ecc:docker-patterns`, stack-specific skills |
| **Reads** | `patterns.md`, `rejected.md`, Repomix pack |
| **Writes** | `patterns.md`, `rejected.md` |

---

## Validation Layer

### Market Validator

| | |
|---|---|
| **ID** | `market-validator` |
| **Role** | Commercial viability gatekeeper with 3-tier verdicts (VIABLE/HIGH_RISK/BLOCKER). Evidence-based — HIGH_RISK requires user acknowledgment, BLOCKER requires user override |
| **Validates** | 2/3 competitors have this OR users requested it; ties to acquisition/activation/retention/revenue; ships in ≤2 weeks |
| **Output** | `VIABLE`, `HIGH_RISK` (with risks + mitigation), or `BLOCKER` (with evidence) |

### Persona Validator

| | |
|---|---|
| **ID** | `persona-validator` |
| **Role** | Simulates difficult, demanding users who actively find flaws, edge cases, and UX friction. Never approves easily. |
| **Voting** | `APPROVE` / `CONDITIONAL` / `REJECT` per persona. 3/3 APPROVE required. CONDITIONAL = REJECT until resolved. REJECT severity: `REJECT_BLOCKING` (stops pipeline) or `REJECT_DEGRADED` (can ship with known limitation) |
| **Reads** | `personas.md`, current spec |
| **Writes** | `persona_insights.md` |

### Business Validator

| | |
|---|---|
| **ID** | `business-validator` |
| **Role** | Business completeness, compliance, and competitive gaps — runs parallel with implementation (3-hat evaluation) |
| **Reviews** | Business logic completeness, real-world correctness, competitive gaps, enhancement opportunities |
| **Writes** | `bv_learnings.md` |

### Security Reviewer

| | |
|---|---|
| **ID** | `security-reviewer` |
| **Role** | Sole owner of all security checks — threat modeling, supply chain, operational security (runs parallel with code review) |
| **Checklist** | Auth & identity, multi-tenancy isolation, payment security, API security, PII protection, threat modeling, supply chain analysis |
| **Output** | `SECURITY_REPORT` with severity levels + `APPROVE` / `REJECT` |

### Gap Checker (V5)

| | |
|---|---|
| **ID** | `gap-checker` |
| **Model** | inherit (Sonnet) |
| **Color** | orange |
| **When** | After Phase 2 (Implementation), before Phase 3 (Code Review). Monorepo projects only. |
| **Role** | Validates that features spanning multiple monorepo packages have been implemented completely across all affected packages. Reads the Impact Map from the spec, cross-references with implementation agent reports, and identifies missing implementations. |
| **File ownership** | None (read-only validation agent) |
| **Input** | Impact Map from `docs/specs/{feature-id}.md`, implementation agent reports, `workspace.packages` from `solo-dev-state.json` |
| **Output** | `GAP_CHECK_REPORT` with PASS/FAIL verdict and targeted fix instructions for specific agents |
| **Triggers** | Post-implementation (mandatory), post-CR fix, post-QA fix. Round counter is cumulative. |
| **Loop** | Configurable: `gap_check.min_rounds` (default: 1), `gap_check.max_rounds` (default: 3). On exceeding max → escalate to orchestrator |

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
| **Voting** | Reports `DONE` / `BLOCKED` / `NEEDS_CLARIFICATION` with evidence |
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
| **Voting** | Reports `DONE` / `BLOCKED` / `NEEDS_CLARIFICATION` with evidence. Includes compliance validation |
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
| **Dimensions** | Logic Correctness, Maintainability, Scalability, Tech Debt (no security — deferred to security-reviewer). Stack-aware limits |
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
| **Requires** | At least 2 completed features |
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

# Feature Lifecycle

Every feature goes through 9 phases (0-8) before shipping. State is persisted in `.claude/solo-dev-state.json` so sessions can resume from any phase.

## Overview

```mermaid
flowchart TD
    classDef orch fill:#374151,color:#fff,stroke:#374151
    classDef research fill:#3b82f6,color:#fff,stroke:#2563eb
    classDef impl fill:#10b981,color:#fff,stroke:#059669
    classDef quality fill:#f59e0b,color:#1a1a1a,stroke:#d97706
    classDef memory fill:#8b5cf6,color:#fff,stroke:#7c3aed
    classDef terminal fill:#f3f4f6,stroke:#6b7280,color:#374151

    U([User]):::terminal --> O[Orchestrator]:::orch

    subgraph RESEARCH["  Research & Validation  "]
        P0["Market Validation<br/>Is this idea worth building?"]:::research
        P12["Design Loop<br/>product-researcher · ux-researcher · tech-architect<br/>Persona vote 3/3 · L3 feedback · max 3 rounds"]:::research
    end

    subgraph IMPL["  Implementation + Business Validation  "]
        P2["Implementation Swarm<br/>frontend · backend · ui · data · test — all parallel<br/>Strict file ownership · L1 contract feedback"]:::impl
        BV["Business Validation (parallel)<br/>Business logic · Compliance · Competitive gaps<br/>3-hat evaluation"]:::quality
    end

    subgraph QUALITY["  Quality Gate  "]
        P3["Code Review + Security (parallel)<br/>CR: Logic · Maintainability · Scalability · Tech Debt<br/>SR: Threat modeling · Supply chain · Operational security<br/>L2 feedback · max 3 rounds"]:::quality
        P45["QA<br/>Functional correctness · Business logic verification"]:::quality
        P7["Final Acceptance<br/>Persona vote 3/3 · max 2 rounds"]:::quality
        P8["Demo Generation<br/>Playwright video + demo.md"]:::quality
    end

    subgraph LEARNING["  Learning  "]
        MC[memory-curator]:::memory
        SE[strategy-evolver]:::memory
    end

    O --> P0
    P0 -->|APPROVE| P12
    P0 -.->|REJECT| U
    P12 -->|3/3 APPROVE| P2
    P12 -->|3/3 APPROVE| BV
    P2 --> GC["Gap Check<br/>Cross-package completeness"]:::quality
    BV --> GC
    GC --> P3
    P3 --> P45
    P45 --> P7
    P7 -->|3/3 APPROVE| P8
    P7 -.->|REJECT| P12
    P8 --> SHIP([Ship]):::terminal
    SHIP --> MC
    MC --> SE
    SE -.->|Learning Loop| O
```

---

## Phase 0: Market Validation

**Agent:** `market-validator`

Validates the feature is worth building before any design work begins.

**Checks:**
- At least 2/3 competitors have this feature OR users explicitly requested it
- Feature ties to acquisition, activation, retention, or revenue
- Feature is on the right plan tier
- Can ship in ≤2 weeks
- No external dependency with >2-week integration risk

**Output:** `VIABLE` → Phase 1 | `HIGH_RISK` → requires user acknowledgment | `BLOCKER` → requires user override or removal from queue

---

## Phase 1: Design Loop

**Agents:** R1 + R2 + R3 (parallel) → persona-validator (sequential)

1. Research agents produce spec independently, then synthesize:
   - R1: business flow, monetization
   - R2: UX, information architecture, user journey
   - R3: technical approach, API design, performance
2. `memory-curator` snapshots state + memory
3. `persona-validator` evaluates (all 3 personas vote)
   - 3/3 APPROVE → Phase 2
   - Any REJECT → research revises → re-vote
   - Max 3 rounds → human escalation

**Output:** `docs/specs/{feature-id}.md`

---

## Phase 2: Parallel Implementation

**Agents:** I1-I5 (frontend, backend, ui, data, test)

All 5 agents work simultaneously with strict file ownership boundaries.

Each agent:
1. Reads Repomix pack for code exploration
2. Reads relevant memory files (patterns, decisions)
3. Implements within file ownership boundaries
4. Validates against spec
5. Reports: `DONE` | `BLOCKED` | `NEEDS_CLARIFICATION`

`backend-agent` writes API contracts first → other agents validate before building (see [Agent Feedback Protocol](Agent-Feedback-Protocol.md) L1).

!!! note "Foundation Projects"
    If initialized from a template with existing `.claude/agents/`, solo-dev **delegates** implementation to the template's agents (they know the conventions better). solo-dev's implementation agents become fallback only. Example code from the template is automatically replaced when a real feature overlaps with it.

---

### Phase 2.5: Cross-Package Gap Check (monorepo only)

**Agent:** gap-checker
**Config:** `gap_check.min_rounds` (default: 1), `gap_check.max_rounds` (default: 3) in `.claude/solo-dev.local.md`

Validates that every package listed in the Impact Map has corresponding implementation changes. Skipped for single-package projects.

**Trigger points** (round counter is cumulative across all triggers):

| Trigger | When | Why |
|---------|------|-----|
| **Post-Implementation** | After all impl agents DONE, before code review | Mandatory first check — catches missing packages |
| **Post-CR Fix** | After code-reviewer REJECT → agents fix | Catches accidental package removal during CR fixes |
| **Post-QA Fix** | After QA FAIL → agents fix | Catches broken cross-package completeness during QA fixes |

On FAIL → targeted feedback to specific agents → fix → re-verify. On exceeding `max_rounds` → escalate to human.

---

## Phase 3: Code Review + Security (parallel)

**Agents:** `code-reviewer` + `security-reviewer` (run in parallel)

**Code reviewer** reviews 4 dimensions (stack-aware limits):
1. **Logic Correctness** — algorithm correctness, edge cases, error paths
2. **Maintainability** — function size, file size, nesting, naming
3. **Scalability** — N+1 queries, indexes, pagination, stateless ops
4. **Tech Debt** — any types, TODOs, duplication, error handling

**Security reviewer** (sole owner of all security):
- Threat modeling, supply chain analysis, operational security
- Auth & identity, multi-tenancy, payment, API, PII

- Both APPROVE → Phase 4
- CR REJECT → targeted `CR_FEEDBACK` to specific agents → fix → re-review changed files only
- Security REJECT → agents fix → security re-reviews
- Max 3 rounds → architectural review escalation

---

## Phase 4 + 5: QA Validation

**Agent:** `qa-validator`

**QA checks:** Functional correctness, business logic, integration, performance

> **Note:** Security review now runs in parallel with code review (Phase 3). Business validation runs in parallel with implementation (Phase 2).

- APPROVE → Phase 7 (Final Acceptance)
- QA FAIL → agents fix → CR re-checks → QA re-runs (max 3 rounds → re-enter Design Loop)

---

## Business Validation (parallel with Phase 2)

**Agent:** `business-validator` (runs in parallel with implementation, not sequentially after QA)

Reviews using 3-hat evaluation:
1. Business logic completeness and compliance
2. Real-world correctness (domain-specific edge cases)
3. Competitive gap analysis and enhancement opportunities

- Findings feed into code review (Phase 3) — CRITICAL issues block CR approval
- NON-CRITICAL → orchestrator asks user: "Add to this sprint or backlog?"

---

## Phase 7: Final Acceptance

**Agent:** `persona-validator`

Personas review the actual built feature (not just the spec).

- 3/3 APPROVE → Phase 8
- Any REJECT → back to impl → CR → QA → Final Acceptance
- Max 2 rounds → re-enter Design Loop entirely

---

## Phase 8: Demo Generation + Ship

**Agent:** `test-agent`

1. Writes Playwright scenario (happy path)
2. Checks dev server is running (prompts user if not)
3. Records video via Playwright `recordVideo`
4. Writes `demo.md` (what it is, why useful, real-world example)
5. Saves to `docs/demos/{feature-id}/`

Then orchestrator:
- git commit
- Update decisions.md
- Update memory index
- Mark feature `COMPLETE` in roadmap
- Load next feature → back to Phase 0

### Changelog Generation
After shipping, solo-dev adds a changelog entry to `docs/yaml/changelog.yaml` and regenerates `CHANGELOG.md` automatically.

**Fallback:** Playwright not installed → skip video, write demo.md only

---

## Loop Termination Rules

| Loop | Max Rounds | On Exceed |
|------|-----------|-----------|
| Design Loop | 3 | Human escalation |
| Code Review | 3 | Architectural review escalation |
| QA Loop | 3 | Re-enter Design Loop |
| Final Acceptance | 2 | Re-enter Design Loop entirely |

**Infinite loop prevention:**
- Each round MUST produce a diff (something must change)
- No diff → orchestrator terminates + escalates immediately
- Escalation logged to `docs/agents/memory/escalations.md`

---

## State Transitions

```
QUEUED
  → MARKET_VALIDATION
  → DESIGN_LOOP (rounds 1-3)
  → IMPLEMENTATION
  → GAP_CHECK (monorepo only)
  → CODE_REVIEW (rounds 1-3)
  → CODE_REVIEW + SECURITY_REVIEW (parallel, rounds 1-3)
  → QA_LOOP (rounds 1-3)
  → FINAL_ACCEPTANCE (rounds 1-2)
  → DEMO_GENERATION
  → COMPLETE

Special states:
  ESCALATED       ← awaiting human decision
  ROLLED_BACK     ← feature reverted
  BLOCKED         ← dependency not complete
```

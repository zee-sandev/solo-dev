# Agent Feedback Protocol

Agents communicate through 3 levels of structured feedback. Each level has a defined protocol, message format, resolution path, and memory write rule.

## Overview

| Level | Name | When | Direction |
|-------|------|------|-----------|
| L1 | Contract Validation | Implementation phase | backend ↔ frontend/data/test |
| L2 | Quality Feedback | Review phase | reviewers → impl agents |
| L3 | Strategic Feedback | Design loop | persona-validator → research agents |

---

## Message Format (All Levels)

```yaml
from: {agent-id}
to: {agent-id}
type: {message-type}
phase: {current-phase}
round: {round-number}
severity: BLOCKING | WARNING | INFO
summary: "{brief description}"
detail: |
  {full context — specific file:line, quote from spec, evidence}
artifacts:
  - type: {api_contract | spec_section | code_diff | report}
    path: {file path}
requires_ack: true | false
```

### Message Types

| Type | Direction | Meaning |
|------|-----------|---------|
| `CONTRACT_MISMATCH` | impl → impl via orchestrator | API contract disagreement |
| `CONTRACT_UPDATE` | backend → frontend/data/test | Contract changed |
| `CONTRACT_RESOLVED` | impl → impl | Mismatch resolved |
| `CR_FEEDBACK` | code-reviewer → impl agents | Code issues with fix instructions |
| `QA_FAILURE` | qa-validator → impl agents | Functional test failures |
| `SECURITY_ISSUE` | security-reviewer → impl agents | Security issues found |
| `BV_FEEDBACK` | business-validator → orchestrator | Business gaps found |
| `PERSONA_REJECTION` | persona-validator → research | Spec rejected with conditions |
| `REVISION_COMPLETE` | research → persona-validator | Spec revised, re-evaluate |
| `RESOLVED` | any → any | Issue resolved, continue |

---

## Level 1: Contract Validation

Runs during the Implementation phase. Backend-agent writes API contracts first, then other agents validate.

### Flow

```
backend-agent defines endpoint
  → Writes to: docs/contracts/{feature}-api.md
  → Notifies: frontend-agent, data-agent, test-agent

Each consumer reads contract and validates
  ├── CONTRACT OK → CONTINUE
  └── CONTRACT MISMATCH → sends to backend via orchestrator
        → backend reviews:
          A) Updates contract (CONTRACT_UPDATE) or
          B) Explains why original is correct
        → All consumers re-validate → RESOLVED
```

### What Each Consumer Validates

| Consumer | Validates |
|----------|-----------|
| `frontend-agent` | Response shape, field names, error format, auth requirements |
| `data-agent` | Request body matches schema, query params match indexed fields |
| `test-agent` | Endpoints match acceptance criteria, error codes match spec |

### Contract File Format

```markdown
# {Feature Name} — API Contract

## POST /api/{resource}
**Auth:** Bearer token (required)
**Body:** { field: type, ... }
**Response 200:** { field: type, ... }
**Error 400:** { error: "validation_error", detail: string }
**Error 401:** { error: "unauthorized" }
**Error 429:** { error: "rate_limit_exceeded", retry_after: number }

Last updated: {date} by backend-agent
```

---

## Level 2: Quality Feedback

Runs during the Review phase after implementation is complete.

### Sequence

1. `code-reviewer` runs after all I agents report DONE
2. `qa-validator` + `security-reviewer` run after code-reviewer APPROVE (parallel)
3. `business-validator` runs after qa-validator PASS

### Code Review Feedback

```
code-reviewer reviews 4 dimensions
  ├── APPROVE → continue
  └── REJECT → CR_FEEDBACK to specific agents (targeted, not broadcast)
        → Agent fixes ONLY specified issues
        → Replies: RESOLVED with diff summary
        → code-reviewer re-checks ONLY changed files
        → max 3 rounds → escalate
```

### QA Failure Flow

```
qa-validator finds failure
  → QA_FAILURE to relevant impl agents (based on file ownership)
  → Agents fix logic
  → code-reviewer re-checks changed files
  → qa-validator re-runs ONLY affected test suite
  → max 3 rounds → re-enter Design Loop
```

### Business Validator Feedback

```
business-validator finds gap
  ├── CRITICAL (BLOCKING) → return to impl agents for required fixes
  └── NON-CRITICAL (WARNING) → orchestrator asks user:
        "Add to this sprint or backlog?"
        A) Add to sprint
        B) Add to backlog
        C) Skip
```

### Memory Writes

| Source | Writes To |
|--------|-----------|
| code-reviewer findings | `cr_learnings.md` |
| business-validator findings | `bv_learnings.md` |
| qa-validator patterns | `performance-log.md` |

---

## Level 3: Strategic Feedback

Runs during the Design Loop. Research agents produce specs → personas evaluate → feedback → revise → repeat.

### Flow

```
R1+R2+R3 produce spec
  → persona-validator evaluates (3 personas independently, in parallel)
  ├── 3/3 APPROVE → proceed to implementation
  └── Any REJECT/CONDITIONAL
        → PERSONA_REJECTION to targeted research agent
           (with specific condition to satisfy)
        → Research agent revises ONLY rejected sections
        → Sends REVISION_COMPLETE
        → Persona re-evaluates ONLY changed sections
        → max 5 rounds → human escalation
```

### Conflict Resolution

When tech-architect and a persona are in direct conflict, orchestrator surfaces a `CONFLICT_BRIEF` to the human:

```
CONFLICT — Human Decision Required

Feature: {name}

BACKGROUND
  R3 position: {what tech-architect claims}
  Evidence: {technical constraints, cost, time}

  P_ position: {what persona claims}
  Evidence: {user behavior, frequency, impact}

WHAT WAS TRIED
  Round N: {what was proposed and why rejected}

MARKET VALIDATOR RECOMMENDATION
  {data-backed suggestion}

YOUR OPTIONS
  A) Accept recommendation
  B) {specific alternative}
  C) Ship MVP now, full version next sprint
  D) Custom decision...
```

**Important:** `market-validator` is advisor only — it provides data-backed input but human makes the final call.

### Memory Writes

| Source | Writes To |
|--------|-----------|
| Approved decisions | `decisions.md` |
| Persona feedback themes | `persona_insights.md` |
| Escalations | `escalations.md` |

---

## Escalation Protocol

### Triggers

| Loop | Max Rounds | Escalation |
|------|-----------|------------|
| Design Loop | 5 | Personas still reject |
| Code Review | 3 | CR still rejects |
| QA Loop | 3 | QA still fails |
| Final Acceptance | 2 | Personas reject implementation |

### Notification Format

```
ESCALATION REQUIRED

Feature: {feature-id}
Loop: {loop-type} — {rounds}/{max} rounds exhausted
Blocking issue: {description}

Agents involved: {list}
Last artifacts:
  - Spec: docs/specs/{feature}-v{N}.md
  - Last CR report: docs/reviews/{feature}-cr-round{N}.md

Recommendation: {orchestrator's suggestion}

Options:
  A) Accept recommendation and continue
  B) Make a manual decision
  C) Remove feature from current sprint
  D) Decompose feature into smaller sub-features
```

---

## Feedback Memory Routing

`memory-curator` intercepts all feedback and routes to the correct memory file:

| Feedback Type | Memory File | Compression Rule |
|---------------|-------------|-----------------|
| CONTRACT_MISMATCH resolution | `patterns.md#api-contracts` | Keep if reusable |
| CR_FEEDBACK issues | `cr_learnings.md` | Keep all; remove if codebase changed |
| QA_FAILURE patterns | `performance-log.md` | Keep last 10 per feature |
| BV_FEEDBACK gaps | `bv_learnings.md` | Keep all domain checklists |
| PERSONA_REJECTION themes | `persona_insights.md` | Keep if appeared 2+ times |
| CONFLICT resolution | `decisions.md` | Always keep with full context |
| ESCALATION | `escalations.md` | Always keep |

# solo-dev — Inter-Agent Feedback Flow

> Three levels of feedback between agents. Each level has a defined protocol,
> message format, resolution path, and memory write rule.

---

## Overview

```
Level 1: CONTRACT VALIDATION   (Implementation phase)
         backend ↔ frontend/data/test — API contract alignment

Level 2: QUALITY FEEDBACK      (Review phase)
         code-reviewer/qa/security/business → implementation agents

Level 3: STRATEGIC FEEDBACK    (Design loop)
         persona-validator → research agents — spec refinement
```

---

## Message Format (All Levels)

```yaml
from: {agent-id}
to: {agent-id}              # or "orchestrator" for broadcast
type: {message-type}        # see type table below
phase: {current-phase}
round: {round-number}
severity: BLOCKING | WARNING | INFO
summary: "{brief description}"
detail: |
  {full context — specific file:line, quote from spec, evidence}
artifacts:
  - type: {api_contract | spec_section | code_diff | report}
    path: {file path}
requires_ack: true | false  # true = agent cannot proceed until acknowledged
```

**Message Types:**

| Type | Direction | Meaning |
|------|-----------|---------|
| `CONTRACT_MISMATCH` | impl → impl via orchestrator | API contract disagreement |
| `CONTRACT_UPDATE` | backend → frontend/data/test | Contract changed, update consumers |
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

### When it runs
Immediately after backend-agent defines API endpoints (during Implementation phase).
Backend-agent writes contracts first → other agents validate before building.

### Flow

```
backend-agent defines endpoint
  → Writes to: docs/contracts/{feature}-api.md
  → Notifies: frontend-agent, data-agent, test-agent
        │
        ▼
Each consumer agent reads contract
  → Validates against their own requirements
        │
   ┌────┴────────────────┐
CONTRACT OK          CONTRACT MISMATCH
   │                      │
   ▼                      ▼
consumer: CONTINUE    consumer sends:
                       CONTRACT_MISMATCH to backend via orchestrator
                            │
                            ▼
                       backend-agent reviews and either:
                         A) Updates contract (CONTRACT_UPDATE)
                         B) Explains why original is correct
                            │
                            ▼
                       All consumers re-validate
                       RESOLVED → all continue parallel work
```

### What gets validated by each consumer

| Consumer | Validates |
|----------|-----------|
| `frontend-agent` | Response shape, field names, error format, auth requirements |
| `data-agent` | Request body matches schema, query params match indexed fields |
| `test-agent` | Endpoints match acceptance criteria, error codes match spec |

### Contract file format

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

### Memory write
- Contract files: `docs/contracts/{feature}-api.md`
- After resolution: pattern saved to `docs/agents/memory/patterns.md#api-contracts`

---

## Level 2: Quality Feedback

### When it runs
- code-reviewer: after all I agents report DONE
- qa-validator + security-reviewer: after code-reviewer APPROVE (parallel)
- business-validator: after qa-validator PASS

### Code Review Feedback Flow

```
code-reviewer runs 4 dimensions (security, maintainability, scalability, tech debt)
        │
   ┌────┴────────┐
APPROVE          REJECT
   │                │
   ▼                ▼
continue        CR_FEEDBACK to specific agents:
                  {
                    from: code-reviewer,
                    to: backend-agent,       ← targeted, not broadcast
                    type: CR_FEEDBACK,
                    severity: BLOCKING,
                    summary: "Missing rate limiting on auth routes",
                    detail: "src/api/auth.ts:45 — login endpoint has no rate limit.
                             Add: import rateLimit from patterns.md#security",
                    requires_ack: true
                  }
                        │
                        ▼
                impl agent receives fix list
                  → Fixes ONLY the specified issues
                  → Replies: RESOLVED with diff summary
                        │
                        ▼
                code-reviewer re-checks ONLY changed files
                (not full re-review)
                        │
                max 3 rounds → escalate if still failing
```

### QA Failure Flow

```
qa-validator fails test:
  {
    from: qa-validator,
    to: [relevant-impl-agents],   ← based on which files are responsible
    type: QA_FAILURE,
    severity: BLOCKING,
    summary: "Persona bulk delete only removes first selected item",
    detail: "Test: tests/e2e/bulk-delete.spec.ts:34
             Expected: all 5 selected items deleted
             Actual: only first item deleted
             Related spec: docs/specs/feature-a1.md#bulk-operations"
  }
        │
        ▼
backend-agent fixes logic
test-agent updates test if spec was wrong
        │
        ▼
code-reviewer re-checks changed files
qa-validator re-runs ONLY affected test suite
```

### Business Validator Feedback Flow

```
business-validator finds gap:
  {
    from: business-validator,
    to: orchestrator,
    type: BV_FEEDBACK,
    severity: BLOCKING | WARNING,
    summary: "Subscription billing missing dunning management",
    detail: "Feature implements basic charge but missing:
             - Retry logic on card failure (industry standard: 3 retries)
             - Grace period before account suspension (standard: 7 days)
             - Email notifications at each retry step
             Reference: bv_learnings.md#billing"
  }
        │
   ┌────┴────────────────────┐
CRITICAL (BLOCKING)      NON-CRITICAL (WARNING)
   │                           │
   ▼                           ▼
return to impl agents      orchestrator asks user:
  for required fixes         "BV found 2 enhancements.
                              Add to this sprint or backlog?"
                              A) Add to sprint
                              B) Add to backlog
                              C) Skip
```

### Memory writes after quality feedback
- code-reviewer findings → `docs/agents/memory/cr_learnings.md`
- business-validator findings → `docs/agents/memory/bv_learnings.md`
- qa-validator patterns → `docs/agents/memory/performance-log.md`

---

## Level 3: Strategic Feedback (Design Loop)

### When it runs
During the Design Loop — R1+R2+R3 produce spec → personas evaluate → feedback → revise → repeat.

### Flow

```
Research agents (R1+R2+R3) produce spec
  → Each writes their section
  → R1: business flow + monetization
  → R2: UX + information architecture
  → R3: technical approach
        │
        ▼
Persona agents evaluate independently (in parallel)
  → P1 reads spec → APPROVE | CONDITIONAL | REJECT + feedback
  → P2 reads spec → APPROVE | CONDITIONAL | REJECT + feedback
  → P3 reads spec → APPROVE | CONDITIONAL | REJECT + feedback
        │
   ┌────┴────────────┐
3/3 APPROVE         Any REJECT or CONDITIONAL
   │                      │
   ▼                      ▼
proceed to impl    PERSONA_REJECTION sent to research:
                   {
                     from: persona-validator,
                     to: ux-researcher,       ← targeted to relevant researcher
                     type: PERSONA_REJECTION,
                     round: 2,
                     persona: "P2 (Agency)",
                     summary: "Bulk operations take 4+ clicks",
                     condition: "Must complete in ≤2 actions",
                     evidence: "Sarah does this 50+ times/day — unacceptable friction",
                     requires_ack: true
                   }
                        │
                        ▼
                research agent(s) revise ONLY the rejected sections
                  → Read the specific condition
                  → Propose targeted change
                  → Send REVISION_COMPLETE:
                    {
                      from: ux-researcher,
                      to: persona-validator,
                      type: REVISION_COMPLETE,
                      round: 3,
                      summary: "Added keyboard shortcut + bulk action toolbar",
                      addresses: "P2 condition from round 2",
                      changed_section: "docs/specs/feature-a1.md#bulk-operations"
                    }
                        │
                        ▼
                persona re-evaluates ONLY changed sections
                (not full spec re-read)
                        │
                max 5 rounds → human escalation
```

### Conflict Resolution (within design loop)

When R3 and a persona are in direct conflict:

```
orchestrator surfaces CONFLICT_BRIEF to human:

╔══════════════════════════════════════════════════╗
║  ⚡ CONFLICT — Human Decision Required           ║
╠══════════════════════════════════════════════════╣
║  Feature: {name}                                 ║
║                                                  ║
║  BACKGROUND                                      ║
║  R3 position: {what tech-architect claims}       ║
║  Evidence: {technical constraints, cost, time}   ║
║                                                  ║
║  P_ position: {what persona claims}              ║
║  Evidence: {user behavior, frequency, impact}    ║
║                                                  ║
║  WHAT WAS TRIED                                  ║
║  Round N: {what was proposed and why rejected}   ║
║                                                  ║
║  MARKET VALIDATOR RECOMMENDATION                 ║
║  {data-backed suggestion from competitor/market} ║
║                                                  ║
║  YOUR OPTIONS                                    ║
║  A) Accept recommendation                        ║
║  B) {specific alternative}                       ║
║  C) Ship MVP now, full version next sprint       ║
║  D) Custom decision...                           ║
╚══════════════════════════════════════════════════╝

→ User decides
→ decision + full context logged in decisions.md
→ Agents resume from that decision
```

**Important:** market-validator is **advisor only** — it provides data-backed input but human makes the final call.

### Memory writes after design loop
- All approved decisions → `docs/agents/memory/decisions.md`
- Persona feedback themes → `docs/agents/memory/persona_insights.md`
- Escalations → `docs/agents/memory/escalations.md`

---

## Escalation Protocol

### Triggers
| Loop | Max Retries | Escalation Trigger |
|------|-------------|-------------------|
| Design Loop | 5 rounds | personas still reject after round 5 |
| Code Review | 3 rounds | CR still rejects after round 3 |
| QA Loop | 3 rounds | QA still fails after round 3 |
| Final Acceptance | 2 rounds | personas reject implementation after round 2 |

### Escalation Notification to User

```
⚠️ ESCALATION REQUIRED

Feature: {feature-id}
Loop: {loop-type} — {rounds-exhausted}/{max} rounds exhausted
Blocking issue: {clear description of what couldn't be resolved}

Agents involved: {list}
Last artifacts:
  - Spec: docs/specs/{feature}-v{N}.md
  - Last CR report: docs/reviews/{feature}-cr-round{N}.md

Recommendation: {orchestrator's suggested resolution}

Options:
  A) Accept recommendation and continue
  B) Make a manual decision: {describe your preferred approach}
  C) Remove feature from current sprint → add to backlog
  D) Decompose feature into smaller sub-features

Your decision:
```

Escalation logged to: `docs/agents/memory/escalations.md`

---

## Feedback Memory Routing

memory-curator intercepts all feedback and routes to correct memory file:

| Feedback Type | Memory File | Compression Rule |
|---------------|-------------|-----------------|
| CONTRACT_MISMATCH resolution | patterns.md#api-contracts | Keep if pattern is reusable |
| CR_FEEDBACK issues | cr_learnings.md | Keep all; remove if codebase changed |
| QA_FAILURE patterns | performance-log.md | Keep last 10 per feature |
| BV_FEEDBACK gaps | bv_learnings.md | Keep all domain checklists |
| PERSONA_REJECTION themes | persona_insights.md | Keep if appeared 2+ times |
| CONFLICT resolution | decisions.md | Always keep with full context |
| ESCALATION | escalations.md | Always keep |

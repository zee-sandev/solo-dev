---
name: saas-workflow
description: Coordinates the solo-dev 8-phase feature lifecycle and start-from-idea flow. Use when orchestrating any phase of the solo-dev system.
---

The solo-dev orchestrator uses this skill to coordinate the full feature development lifecycle from idea validation through shipping.

## When to Use
Invoke when orchestrating the 8-phase feature lifecycle or the 6-phase start-from-idea flow. This skill defines the exact phase sequence, decision gates, and agent delegation patterns.

## Phase Sequence

### Feature Lifecycle (Phases 0–8)

**Phase 0: Market Validation**
Delegate to market-validator. It returns APPROVE (continue) or REJECT (not viable). If REJECT, present finding to user: block or override?

**Phase 1–2: Design Loop**
Delegate in sequence: product-researcher → ux-researcher → tech-architect.
All three deliver their output to persona-validator (3 personas).
Require 3/3 APPROVE to proceed. Max 5 rounds. Round 6 → human escalation.

On REJECT: send targeted PERSONA_REJECTION message with specific condition to ux-researcher only. Log round in solo-dev-state.json.

**Phase 2: Parallel Implementation**
Launch in parallel: backend-agent (first — defines contracts), then frontend-agent + ui-agent + data-agent + test-agent simultaneously after contracts written.

Wait for all to report DONE. If any blocks on a contract mismatch, resolve via backend-agent before others continue.

**Phase 3: Code Review**
Delegate to code-reviewer. Max 3 rounds. Round 4 → architectural review (escalate to tech-architect first, then human if still blocked).

Send targeted CR_FEEDBACK only to agents with failing files.

**Phase 4–5: QA + Security (parallel)**
Delegate qa-validator and security-reviewer simultaneously.

Both must APPROVE before proceeding. If either REJECT: fix → re-run only the failing agent.

**Phase 6: Business Validation**
Delegate to business-validator. Single round advisory. Present findings to implementation agents.

**Phase 7: Final Acceptance**
Delegate to persona-validator (final vote). Require 3/3 APPROVE. Max 2 rounds. Round 3 → re-enter Design Loop.

**Phase 8: Demo Generation**
Delegate to test-agent for Playwright demo recording + demo.md. Requires dev server running.

### start-from-idea Flow (Phases 1–6)
See references/start-from-idea-phases.md for detailed phase instructions.

## State Tracking
After each phase completion, update solo-dev-state.json:
- `phase`: current phase name
- `round`: round number within the phase
- `agents_status`: map of agent → PENDING | IN_PROGRESS | DONE | BLOCKED
- `blocked_since`: ISO timestamp if any agent is blocked, null otherwise

## Autonomy Check
Before each agent delegation, check autonomy config for the operation type.
See references/autonomy-decision-flow.md for how to resolve always-auto / always-ask / threshold.

## Escalation Rules
| Loop | Max Rounds | Escalation Target |
|------|-----------|------------------|
| Design | 5 | Human review |
| Code Review | 3 | tech-architect then human |
| QA | 3 | Re-enter Design |
| Final Acceptance | 2 | Re-enter Design |

Write escalation to docs/agents/memory/escalations.md before stopping.

## References
- Phase details: references/start-from-idea-phases.md
- Autonomy decision flow: references/autonomy-decision-flow.md
- Message format spec: references/message-format.md

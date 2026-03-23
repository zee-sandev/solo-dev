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
Delegate to market-validator. It runs self-critique checklist before submitting verdict.
Returns APPROVE (continue) or REJECT (not viable). If REJECT, present finding to user: block or override?

**Phase 1–2: Design Loop**
Delegate in sequence: product-researcher → ux-researcher → tech-architect.
Each agent runs self-critique checklist before submitting.

**Self-Refinement (before persona review):**
Read `self_refinement.intensity` from config:
- `light`: Each agent self-critiques only (1 round). Design loop max: 3.
- `standard`: Cross-agent critique — each R agent critiques OTHER agents' sections (up to 2 rounds). Design loop max: 2.
- `thorough`: Cross-agent critique (up to 3 rounds). Design loop max: 2.

After refinement → Spec Clarity Gate (drift-detector Mode 1) → persona-validator (3 personas).
Require 3/3 APPROVE to proceed. Max rounds per intensity. Next round → human escalation.

On REJECT: send targeted PERSONA_REJECTION message with specific condition to ux-researcher only. Log round in solo-dev-state.json.

**Phase 2: Parallel Implementation**
Launch in parallel: backend-agent (first — defines contracts + runs contract self-review), then frontend-agent + ui-agent + data-agent + test-agent simultaneously after contracts written.

If `self_refinement.intensity` is `standard` or `thorough`: orchestrator sends contracts to tech-architect for cross-agent critique before dispatching other impl agents.

Wait for all to report DONE. If any blocks on a contract mismatch, resolve via backend-agent before others continue.

**Phase 2.5: Gap Check (monorepo only)**
Dispatch gap-checker to verify cross-package completeness. Content validation runs for all projects.

**Phase 2.6: Smoke Test**
Dispatch smoke-tester. Build verification + runtime endpoint testing. On FAIL → targeted feedback → fix → re-test.

**Phase 2.7: Contract Drift Check**
Dispatch drift-detector (Mode 2). Verify contracts haven't changed since impl started. On DRIFTED → notify affected agents.

**Phase 2.8: Visual QA**
If `design_profile` exists and `visual_qa.enabled: true`:
- Capture screenshots of all new/changed pages (empty, loaded, error, mobile, desktop, dark mode)
- Run automated visual checklist against design_profile (tokens, responsive, spacing, typography, interactive states)
- Verify navigation matches design_profile.navigation (pattern, menu structure, mobile, role-based)
- On PASS → Phase 3. On FAIL → targeted feedback to ui-agent/frontend-agent → fix → re-check (max 2 rounds)
- If `visual_qa.user_preview: true` → show screenshots to user for approval
- Skip if: no design_profile, visual_qa disabled, effort=S, or API-only feature

**Phase 3: Code Review + Security (parallel)**
Delegate code-reviewer and security-reviewer simultaneously.

**Phase 4–5: QA**
Delegate qa-validator (security already reviewed in Phase 3).

Must APPROVE before proceeding. If REJECT: fix → re-run qa-validator only.

**Phase 6: Business Validation**
Delegate to business-validator. Single round advisory. Present findings to implementation agents.

**Phase 7: Final Acceptance**
Delegate to persona-validator (final vote). Require 3/3 APPROVE. Max 2 rounds. Round 3 → re-enter Design Loop.

**Phase 8: Demo Generation**
Orchestrator prepares demo context (epic completion, sprint end, roles, shared pages).
Delegate to test-agent — uses Demo Intelligence to choose demo type (clip, journey, API, skip).
After demo: dispatch drift-detector Mode 5 (demo staleness check) in background.
If sprint end → auto-generate showcase.

### start-from-idea Flow (Phases 1–6)
See references/start-from-idea-phases.md for detailed phase instructions.
Self-refinement applies to: market research (Phase 2), roadmap (Phase 4), tech decisions (Phase 5).

## State Tracking
After each phase completion, update solo-dev-state.json:
- `phase`: current phase name
- `round`: round number within the phase
- `agents_status`: map of agent → PENDING | IN_PROGRESS | DONE | BLOCKED
- `blocked_since`: ISO timestamp if any agent is blocked, null otherwise
- `refinement_rounds`: total self-refinement rounds used in current phase
- `refinement_intensity`: current intensity level

## Autonomy Check
Before each agent delegation, check autonomy config for the operation type.
See references/autonomy-decision-flow.md for how to resolve always-auto / always-ask / threshold.

## Escalation Rules
| Loop | Max Rounds (light) | Max Rounds (standard/thorough) | Escalation Target |
|------|-------------------|-------------------------------|------------------|
| Design | 3 | 2 | Human review |
| Code Review | 3 | 3 | tech-architect then human |
| QA | 3 | 3 | Re-enter Design |
| Final Acceptance | 2 | 2 | Re-enter Design |

Write escalation to docs/agents/memory/escalations.md before stopping.

## References
- Phase details: references/start-from-idea-phases.md
- Autonomy decision flow: references/autonomy-decision-flow.md
- Message format spec: references/message-format.md

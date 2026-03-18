# solo-dev — Workflow Reference

> Three main workflows: existing project onboarding, idea development, and feature implementation.
> State is persisted across sessions in `.claude/solo-dev-state.json`.

---

## Workflow 0: `/solo-dev:init` — Existing Project Onboarding

Onboards an existing codebase that has no solo-dev docs. Agents analyze the project first — no upfront questions — then cross-check understanding with the user at two key checkpoints.

**When triggered:** `init` detects source files present but no docs/product/ directory.
**User interactions:** 3 (product understanding, feature map, architecture decisions)

```
/solo-dev:init
```

### Step 1: Silent Analysis (no questions)

Pack codebase with Repomix MCP. Run parallel analysis:

| Agent | Analyzes |
|-------|---------|
| tech-architect | Stack, architecture, file structure, API surface, test coverage signals |
| product-researcher | Product shape, feature areas, business model signals |
| ux-researcher | Pages, user flows, navigation, route structure |

**State update:** `phase: ONBOARDING_ANALYSIS`

---

### Step 2: Stack Presentation (auto — no confirmation)

Present detected stack. This is objective — no user input needed.

```
Framework   Next.js 14 (App Router)
ORM         Prisma + PostgreSQL
Auth        NextAuth.js
Payments    Stripe
Deployment  Vercel
```

---

### Step 3: Product Understanding Cross-check ← Interaction 1

Present what the codebase reveals. Ground every claim in a code signal. Then ask two open questions:

1. "Does this match your product? Correct anything wrong or misleading."
2. "What's the most important thing I might have missed that affects how features should be built going forward?"

**Rule:** Never present understanding as confident — present it as "what I found" and let user correct.
**State update:** `phase: ONBOARDING_PRODUCT_CHECK`

---

### Step 4: Feature Map Cross-check ← Interaction 2

Present all detected feature areas. Every row includes the signal used to determine status:

| Status | Meaning |
|--------|---------|
| Complete | API + UI + tests all present and wired |
| Partial | Some layer missing (no tests, UI only, API only) |
| Stub | Entry point exists, no real implementation |
| Unclear | Conflicting signals — needs user input |

Ask specifically about every **Unclear** item. Also ask:
"Are there features I missed entirely that aren't visible from the code?"

**State update:** `phase: ONBOARDING_FEATURE_CHECK`

---

### Step 5: Architecture Decisions Cross-check ← Interaction 3

Present patterns that look intentional. Every entry tagged `[INFERRED]`.

User response maps to one of three outcomes per decision:

| User says | Written as |
|-----------|-----------|
| Confirmed + reason given | Confirmed decision with reason |
| Confirmed, no reason | `[INFERRED — reason unknown, treat carefully]` |
| "Accidental / can change" | `[INCONSISTENT — agents should standardize]` |

**Why this matters:** Agents read decisions.md before every task. Wrong decisions compound across every feature.

**State update:** `phase: ONBOARDING_DECISIONS_CHECK`

---

### Step 6: Generate Docs

Write all product docs from confirmed understanding:

| File | Contents |
|------|---------|
| docs/product/idea-brief.md | Product summary from analysis + user corrections |
| docs/product/personas.md | User types inferred from code + user input |
| docs/product/roadmap.md | Existing features mapped: SHIPPED / WIP / PLANNED / IGNORED |
| docs/agents/memory/patterns.md | Coding patterns observed in codebase |
| docs/agents/memory/decisions.md | Confirmed decisions with reasons; unconfirmed tagged [INFERRED] |

**State update:** `phase: READY`

---

### Onboarding Decision Mapping

```
roadmap.md status ← based on confirmed feature map

  Complete  →  SHIPPED
  Partial   →  WIP
  Stub      →  PLANNED  (if user confirms it's upcoming)
  Unclear   →  resolved by user in Interaction 2
  Ignored   →  IGNORED  (explicitly excluded by user)
  User-added →  PLANNED  (features not found in code)
```

---

---

## Workflow 1: `/solo-dev:start-from-idea`

Transforms a rough idea into a validated product concept + actionable roadmap.
Output feeds directly into `/solo-dev:init`.

```
/solo-dev:start-from-idea [optional: rough idea text]
```

### Phase 1: Idea Exploration

**Goal:** Understand the problem, audience, and constraints.
**Method:** Dialogue — one question at a time until clear picture emerges.

Questions asked (not all at once):
- What problem does this solve? For whom?
- B2B, B2C, or both?
- Have you seen similar products? What's missing in them?
- What would make someone pay for this vs. use a free alternative?
- Any constraints? (timeline, budget, team size)

**State update:** `phase: IDEA_EXPLORATION`
**Exit:** User satisfied with exploration → move to Phase 2

---

### Phase 2: Market Reality Check

**Goal:** Validate the idea exists in a real market with real demand.
**Agents:** product-researcher (R1) + market-validator

Produces:
- Competitor list with product URLs and key features
- Market size estimate
- "Why now?" analysis (trends, timing, technology shifts)
- Initial positioning recommendation

**State update:** `phase: MARKET_REALITY_CHECK`
**Exit:** User reviews findings → may pivot/narrow scope → Phase 2b

---

### Phase 2b: Competitor Gap Analysis

**Goal:** Find what competitors do poorly and where whitespace exists.
**Agents:** product-researcher (R1) + market-validator

Produces:
- Feature gap matrix (competitors have / we don't)
- Competitor weaknesses from user reviews (G2, Capterra, Reddit, etc.)
- Market whitespace (unmet needs, emerging trends)
- Positioning recommendation

**Output format:**
```
FEATURE GAPS:
  [Feature]    Competitor A  B  C  Gap Priority
  Bulk export      ✅        ✅  ❌   LOW
  API access       ✅        ❌  ❌   HIGH
  White-label      ❌        ✅  ❌   MEDIUM

COMPETITOR WEAKNESSES:
  - "too expensive for small teams" (247 mentions, Competitor A)
  - "clunky UI, steep learning curve" (183 mentions, Competitor B)

WHITESPACE:
  - GEO/AI citation optimization — no competitor has this properly
```

**State update:** `phase: GAP_ANALYSIS`
**Exit:** User reviews → Phase 3

---

### Phase 3: User Persona Generation

**Goal:** Define real target users (not generic).
**Agent:** ux-researcher (R2)

Generates 2-3 personas from the concept:
- Role, company size, workflow
- Goals specific to this product
- Budget range
- Pain points this product solves
- Behavioral patterns (power user vs. simple user, etc.)

Written to: `docs/product/personas.md`

**State update:** `phase: PERSONA_GENERATION`
**Exit:** User reviews + adjusts personas → Phase 4

---

### Phase 4: Core Feature Definition

**Goal:** Define MVP + competitive moat features with priorities.
**Agents:** R1 + R2 + R3 (synthesized)

Produces:
- MVP feature set (3-5 features that validate core value)
- Competitive moat features (unique capabilities)
- Priority matrix: impact × effort
- Initial feature dependency graph

**State update:** `phase: FEATURE_DEFINITION`
**Exit:** User reviews feature list → Phase 4b

---

### Phase 4b: AI Feature Enhancement

**Goal:** Make each defined feature significantly better.
**Agents:** R1 + R2 + R3

Per feature, suggests:
- **Depth enhancements** — make the feature itself deeper
- **Breadth enhancements** — expand the feature's value
- **Differentiation plays** — make it unique vs. competitors
- **Quick wins** — low effort, high impact additions

User selects which suggestions to add to roadmap.
Unselected → `docs/product/backlog.md` automatically.

**State update:** `phase: FEATURE_ENHANCEMENT`

---

### Phase 4c: Idea Enhancement Suggestions

**Goal:** Improve the overall product, not just individual features.
**Agents:** R1 + market-validator

Suggests:
- **Monetization** — pricing model improvements, upsell opportunities
- **Distribution** — viral loops, integrations, acquisition channels
- **Product moat** — data lock-in, switching costs, network effects
- **Emerging opportunities** — 2025-2026 trends competitors haven't captured

User selects → roadmap. Unselected → backlog.

**State update:** `phase: IDEA_ENHANCEMENT`

---

### Phase 5: Roadmap Generation

**Goal:** Create actionable phased roadmap.

Generates:
```
docs/product/
  idea-brief.md              ← concept summary (1-2 pages)
  personas.md                ← generated user personas
  competitive-analysis.md    ← gap analysis + weaknesses
  feature-enhancements.md    ← AI suggestions per feature
  idea-enhancements.md       ← big picture improvements
  roadmap.md                 ← phased feature roadmap with deps
  backlog.md                 ← future ideas (not this sprint)
```

**roadmap.md format:**
```markdown
## Phase A — MVP (Feature Parity)
| ID | Feature | Value | Personas | depends_on | blocks |
|----|---------|-------|----------|-----------|--------|
| A1 | Feature Name | why it matters | P1, P2 | [] | [A2] |

## Phase B — Moat
...

## Phase C — Scale
...
```

**State update:** `phase: ROADMAP_GENERATION`

---

### Phase 6: User Approval

Present summary → user decides:
- **A) Approve** → run `/solo-dev:init` to start building
- **B) Adjust** → specify which section, iterate
- **C) Start over** → new angle or pivot

**State update on approve:** `phase: IDEA_APPROVED`

---

## Workflow 2: Feature Development Lifecycle

Triggered by `/solo-dev:next-feature`. Runs phases 0-8 per feature.

```
/solo-dev:next-feature
  → Reads roadmap.md
  → Finds next QUEUED feature where all depends_on are COMPLETE
  → Begins Phase 0
```

---

### Phase 0: Market Validation

**Agent:** market-validator
**When:** Before any design work begins.

Validates:
- At least 2/3 competitors have this OR users explicitly requested it
- Feature ties to acquisition/activation/retention/revenue
- Feature is on the right plan tier
- Ships in ≤2 weeks, no external dep with >2-week risk

```
VIABLE → proceed to Phase 1
NOT_VIABLE → research agents revise or remove from queue
```

**State update:** `phase: MARKET_VALIDATION, feature: {id}`

---

### Phase 1: Design Loop

**Agents:** R1 + R2 + R3 (parallel) → persona-validator (sequential)

```
R1, R2, R3 produce spec independently → synthesize
  → R1 section: business flow, monetization
  → R2 section: UX, IA, user journey
  → R3 section: technical approach, API design, performance
        ↓
memory-curator: snapshot state + memory
        ↓
persona-validator evaluates (all 3 personas)
  → 3/3 APPROVE → Phase 2
  → Any REJECT → research revises → re-vote
  → Max 5 rounds → human escalation
```

**State update:** `phase: DESIGN_LOOP, round: N`
**Output:** `docs/specs/{feature-id}.md`

---

### Phase 2: Parallel Implementation

**Agents:** I1-I5 (frontend, backend, ui, data, test) — strictly parallel

```
Each agent receives:
  - Approved spec (docs/specs/{feature-id}.md)
  - File ownership boundaries (no overlap)
  - Acceptance criteria

Each agent:
  1. Reads repomix pack (code exploration)
  2. Reads relevant memory files (patterns, decisions)
  3. Implements within file ownership
  4. Validates against spec
  5. Reports: DONE | BLOCKED (with reason) | NEEDS_CLARIFICATION

backend-agent also:
  → Writes API contracts to docs/contracts/{feature}-api.md
  → Other agents validate contract before building

All agents report DONE → orchestrator collects → Phase 3
```

**State update:** `phase: IMPLEMENTATION, agents_status: {...}`

---

### Phase 3: Code Review Loop

**Agent:** code-reviewer (runs after all I agents DONE)

```
Reviews 4 dimensions: SECURITY, MAINTAINABILITY, SCALABILITY, TECH DEBT
  → APPROVE → Phase 4
  → REJECT → targeted CR_FEEDBACK to specific agents
             agents fix → CR re-checks changed files only
             max 3 rounds → architectural review escalation
```

Writes learnings to `cr_learnings.md` after each round.

**State update:** `phase: CODE_REVIEW, round: N`

---

### Phase 4: QA Loop (parallel with Phase 5)

**Agent:** qa-validator

```
Runs functional + business logic + integration + performance checklist
  → PASS → continue
  → FAIL → QA_FAILURE to relevant impl agents
           agents fix → CR re-checks if code changed → QA re-runs
           max 3 rounds → re-enter design loop
```

**State update:** `phase: QA_LOOP, round: N`

---

### Phase 5: Security Review (parallel with Phase 4)

**Agent:** security-reviewer

```
Runs SaaS security checklist:
  auth, multi-tenancy, payment, API, PII
  → APPROVE → continue
  → REJECT → SECURITY_ISSUE to relevant impl agents
             agents fix → security re-reviews
```

**State update:** `phase: SECURITY_REVIEW`

---

### Phase 6: Business Validation

**Agent:** business-validator (runs after Phase 4 + 5 both pass)

```
Reviews: business completeness, real-world correctness,
         competitive gaps, enhancement opportunities
  → APPROVE → Phase 7
  → CRITICAL issues → return to impl agents
  → NON-CRITICAL → orchestrator asks user: sprint or backlog?
```

**State update:** `phase: BUSINESS_VALIDATION`

---

### Phase 7: Final Acceptance

**Agent:** persona-validator (re-evaluates working implementation)

```
Personas review the actual built feature (not just spec)
  → 3/3 APPROVE → Phase 8
  → Any REJECT → back to impl → CR → QA → Final Acceptance
               max 2 rounds → re-enter Design Loop entirely
```

Writes to `persona_insights.md`.

**State update:** `phase: FINAL_ACCEPTANCE, round: N`

---

### Phase 8: Demo Generation + Ship

**Agent:** test-agent

```
1. Writes Playwright scenario (happy path of the feature)
2. Checks dev server is running (if not: prompt user)
3. Records demo video via Playwright recordVideo
4. Writes demo.md (what it is, why useful, real-world example)
5. Saves both to: docs/demos/{feature-id}/demo.mp4 + demo.md

Then orchestrator:
6. git commit with descriptive message
7. Update decisions.md with what was built and why
8. Update memory index
9. Mark feature COMPLETE in roadmap.md
10. Load next feature → back to Phase 0
```

**Fallback:** Playwright not installed → skip video, write demo.md only + warn user

**State update:** `phase: COMPLETE, feature: {id}`

---

## State Transitions Summary

```
QUEUED
  → MARKET_VALIDATION
  → DESIGN_LOOP (rounds 1-5)
  → IMPLEMENTATION
  → CODE_REVIEW (rounds 1-3)
  → QA_LOOP + SECURITY_REVIEW (parallel, rounds 1-3)
  → BUSINESS_VALIDATION
  → FINAL_ACCEPTANCE (rounds 1-2)
  → DEMO_GENERATION
  → COMPLETE

Special states:
  ESCALATED       ← awaiting human decision
  ROLLED_BACK     ← feature reverted
  BLOCKED         ← dependency not complete
```

---

## Loop Termination Rules

| Loop | Max Retries | On Exceed |
|------|-------------|-----------|
| Design Loop | 5 rounds | Human escalation (cannot continue automatically) |
| Code Review | 3 rounds | Architectural review escalation |
| QA Loop | 3 rounds | Re-enter Design Loop |
| Final Acceptance | 2 rounds | Re-enter Design Loop entirely |

**Infinite loop prevention:**
- Each retry round MUST produce a diff (something must change)
- If round produces no diff → orchestrator terminates + escalates immediately
- Escalation logged to `docs/agents/memory/escalations.md`

---

## Rollback Procedure

```
/solo-dev:rollback {feature-id}

1. Verify feature exists and has a snapshot:
   docs/agents/memory/snapshots/pre-{feature-id}.json

2. git revert to pre-feature commit hash (stored in snapshot)

3. Restore .claude/solo-dev-state.json from snapshot

4. Restore memory files from snapshot:
   - docs/agents/memory/index.md
   - docs/agents/memory/decisions.md
   - docs/agents/memory/patterns.md
   (Only files that changed since snapshot)

5. Mark feature ROLLED_BACK in docs/product/roadmap.md

6. Ask user:
   A) Re-attempt with different approach
      → Re-enters Design Loop with "rollback context" note
   B) Remove from roadmap entirely
   C) Decompose into smaller sub-features
      → Orchestrator suggests decomposition

7. Log rollback to docs/agents/memory/decisions.md
```

---

## Feature Dependency Enforcement

```
orchestrator.pickNextFeature():
  for each feature in roadmap where status == QUEUED:
    if all(dep.status == COMPLETE for dep in feature.depends_on):
      return feature
    else:
      continue

  if no eligible feature found:
    report: "No features available. Blocked features: {list with missing deps}"
    ask: "Implement missing dependency first, or adjust roadmap?"

  if circular dependency detected:
    escalate to human with dependency graph visualization
```

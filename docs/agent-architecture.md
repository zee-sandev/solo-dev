# solo-dev — Agent Architecture

> 22 agents organized in 5 layers. Each agent has a defined role, skills, file ownership, and communication protocol.

---

## Layer Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      ORCHESTRATOR                           │
│  Coordinates all agents. Never writes code or designs.      │
└────────────────────────┬────────────────────────────────────┘
                         │
    ┌────────────────────┼────────────────────┐
    ▼                    ▼                    ▼
 DISCOVERY LAYER   RESEARCH LAYER        LEARNING LAYER
 D1, D2           R1, R2, R3             MC, SE
    │                    │
    └──────┬─────────────┘
           ▼
    VALIDATION LAYER
    MV, PV, BV, SR, GC, ST, DD
           │
           ▼
    IMPLEMENTATION LAYER
    I1, I2, I3, I4, I5 (parallel)
```

---

## Orchestrator

**ID:** `orchestrator`
**Model:** inherit (Sonnet)
**Color:** blue

**Role:** Central coordinator. Manages phase transitions, spawns agents, collects outputs, enforces loop termination, handles conflicts. Uses DAG-based dispatching to run independent agents in parallel and adaptive phase ordering based on feature effort classification (S/M/L/XL).

**Never does:**
- Write code or config
- Make design decisions unilaterally
- Skip quality gates

**Skills:**
- `superpowers:dispatching-parallel-agents`
- `everything-claude-code:enterprise-agent-ops`
- `everything-claude-code:autonomous-loops`

**Responsibilities:**
- Read `solo-dev-state.json` → determine current phase
- Build DAG of agent dependencies → dispatch independent agents in parallel
- Classify feature effort (S/M/L/XL) → select adaptive phase ordering
- Spawn the correct agents for each phase
- Collect agent outputs and detect conflicts
- Apply conflict precedence: Security > Business > Persona > Code
- Enforce loop max-retries → escalate to human when exceeded
- Monitor developer fatigue (session length, escalation frequency) → suggest breaks
- State recovery: resume from last successful phase after crash/interruption
- Commit to git after each completed feature
- Update `solo-dev-state.json` after each phase transition

---

## Discovery Layer

### D1 — Discovery Agent
**ID:** `discovery-agent`
**Color:** magenta

**Role:** Deep problem space exploration for vague ideas, assumption auditing, simulated user interviews, and problem reframing when features get stuck. Ensures the team builds the RIGHT thing before building it well.

**4 Modes:**
1. **Problem Deep-Dive** — 5-Whys, Jobs-to-be-Done, Problem Space Mapping
2. **Assumption Audit** — Surface and risk-rate every product assumption
3. **Simulated User Interviews** — Generate realistic persona interview dialogues
4. **Problem Reframing** — Inversion, analogy, constraint removal, perspective shifts

**Reads before starting:**
- `docs/product/personas.md`
- `docs/agents/memory/decisions.md` (section: discovery)
- `docs/product/idea-brief.md`

**Writes after completing:**
- `docs/agents/memory/decisions.md` (section: discovery)

---

### D2 — Venture Strategist
**ID:** `venture-strategist`
**Color:** gold

**Role:** Blue-sky strategic thinking — 10x opportunity analysis, competitive white-space mapping, combinatorial feature synergies, future-proofing, and category creation assessment. Pushes beyond "is this viable?" to "is this a category-defining opportunity?"

**5 Modes:**
1. **10x Opportunity Scan** — Evaluate if features could be radically better
2. **Competitive Divergence** — Map what NO competitor does (true white space)
3. **Combinatorial Analysis** — Find emergent value from feature combinations
4. **Future-Proofing** — Technology shift, market shift, AI integration opportunities
5. **Category Creation** — Assess if the product could define a new category

**Reads before starting:**
- `docs/yaml/features.yaml`
- `docs/product/competitive-analysis.md`
- `docs/product/roadmap.md`
- `docs/agents/memory/decisions.md`

**Writes after completing:**
- `docs/agents/memory/decisions.md` (section: strategy)
- `docs/yaml/backlog.yaml` (strategic opportunities)

---

## Research Layer

### R1 — Product Researcher
**ID:** `product-researcher`
**Color:** cyan

**Role:** Market fit, monetization, competitor analysis, feature positioning, business flow design. Includes trend prediction, disruption risk assessment, and source citations for all claims.

**Skills:**
- `everything-claude-code:market-research`
- `everything-claude-code:search-first`

**Reads before starting:**
- `docs/agents/memory/decisions.md` (section: market)
- `docs/agents/memory/bv_learnings.md` (competitive gaps from past features)
- `~/.claude/solo-dev/global-memory/index.md`

**Writes after completing:**
- `docs/agents/memory/decisions.md` (market decisions)
- `~/.claude/solo-dev/global-memory/learnings/` (cross-project patterns)

**Enhancements:**
- Trend prediction: identifies emerging market shifts that may affect feature relevance
- Disruption risk: flags if competitors or new entrants could undermine feature value
- Source citations: every market claim includes verifiable source reference

---

### R2 — UX Researcher
**ID:** `ux-researcher`
**Color:** cyan

**Role:** User behavior, information architecture, user journey mapping, friction points, accessibility. Applies persona skepticism — challenges assumptions about user behavior with evidence. Verifies accessibility compliance.

**Skills:**
- `ui-ux-pro-max` (or `solo-dev:ux-design` fallback)
- `impeccable:critique`
- `impeccable:onboard`

**Reads before starting:**
- `docs/agents/memory/persona_insights.md`
- `docs/product/personas.md`

**Writes after completing:**
- `docs/agents/memory/persona_insights.md` (UX patterns observed)

**Enhancements:**
- Persona skepticism: challenges "users want X" claims — requires behavioral evidence
- Accessibility verification: WCAG compliance check for all proposed UX flows

---

### R3 — Tech Architect
**ID:** `tech-architect`
**Color:** cyan

**Role:** Technical feasibility, API design, performance implications, integration patterns, scalability. Includes build-vs-buy analysis, performance targets, and operational considerations (monitoring, alerting, runbooks).

**Skills:**
- `everything-claude-code:backend-patterns` (or `solo-dev:backend-patterns` fallback)
- `everything-claude-code:api-design`
- `everything-claude-code:deployment-patterns`
- `everything-claude-code:docker-patterns`
- Stack-specific skills (loaded dynamically)

**Reads before starting:**
- `docs/agents/memory/patterns.md`
- `docs/agents/memory/rejected.md`
- Repomix pack (for existing codebase structure)

**Writes after completing:**
- `docs/agents/memory/patterns.md` (accepted patterns)
- `docs/agents/memory/rejected.md` (tried and rejected approaches)

**Enhancements:**
- Build vs buy: evaluates whether to implement, use a library, or integrate a service
- Performance targets: defines latency, throughput, and resource budgets per feature
- Operational considerations: monitoring hooks, alerting thresholds, runbook outlines

---

## Validation Layer

### Market Validator
**ID:** `market-validator`
**Color:** yellow

**Role:** Commercial viability gatekeeper with enforcement power. Runs BEFORE Design Loop. Validates feature is worth building using evidence-based validation.

**Skills:**
- `everything-claude-code:market-research`

**Validates:**
- At least 2/3 competitors have this OR users explicitly request it
- Feature ties to acquisition, activation, retention, or revenue
- Feature is on the right plan tier
- Can ship in ≤ 2 weeks
- No external dependency with >2-week integration risk

**Output:** 3-tier verdict system:
```
VIABLE      → proceed to Design Loop
HIGH_RISK   → requires user acknowledgment before proceeding
BLOCKER     → requires explicit user override to proceed
```
Each verdict includes evidence summary and reasoning.
**If BLOCKER:** Feature cannot proceed without explicit user override.
**If HIGH_RISK:** Orchestrator presents risk summary — user must acknowledge to continue.

---

### Persona Validator
**ID:** `persona-validator`
**Color:** green

**Role:** Simulates difficult, demanding user personas who actively find flaws, edge cases, and UX friction. Final acceptance gate — never approves easily.

**Note:** Personas are NOT hardcoded. They are generated by R2 during `/solo-dev:start-from-idea` and stored in `docs/product/personas.md`.

**Voting rules:**
- `APPROVE` / `CONDITIONAL` / `REJECT` + detailed feedback
- REJECT includes severity: `BLOCKING` (feature cannot ship) or `DEGRADED` (feature works but poorly for this persona)
- 3/3 APPROVE → move to implementation
- Any REJECT → research agents must address ALL rejection points
- CONDITIONAL counts as REJECT until condition resolved
- Max 3 design rounds → human escalation
- Auto-escalation: if same rejection reason appears 2+ rounds, escalate immediately with business impact assessment

**Reads:** `docs/product/personas.md`, current feature spec
**Writes:** `docs/agents/memory/persona_insights.md`

---

### Business Validator
**ID:** `business-validator`
**Color:** yellow

**Role:** Business completeness + competitive gap analysis. Runs PARALLEL with implementation (Phase 2), after design approval. Uses 3-hat evaluation approach.

**Skills:**
- `everything-claude-code:market-research`
- `everything-claude-code:search-first`

**3-Hat Evaluation:**
1. **Operations hat:** Business logic completeness, real-world correctness, domain edge cases
2. **Compliance hat:** Regulatory requirements, data handling, industry standards
3. **Growth hat:** Competitive gap analysis, enhancement opportunities (20% effort → 80% value)

**Output:**
```yaml
MISSING_LOGIC:      # Critical business rules not implemented
COMPETITIVE_GAP:    # Features competitors have that we lack
COMPLIANCE:         # Regulatory or standards gaps
ENHANCEMENT:        # Low-effort high-value additions
VERDICT: APPROVE | REJECT
```

**Writes:** `docs/agents/memory/bv_learnings.md`

---

### Security Reviewer
**ID:** `security-reviewer`
**Color:** red

**Role:** **Sole owner of all security checks.** Runs PARALLEL with code-reviewer (not after). No other agent performs security review.

**Skills:**
- `everything-claude-code:security-review` (or `solo-dev:security` fallback)
- Stack-specific: `ecc:django-security` / `ecc:springboot-security` as applicable

**SaaS Security Checklist:**
- Auth & Identity: token scope/expiry, password hashing, OAuth state, session fixation
- Multi-tenancy: every query filtered by tenantId, no cross-tenant data leakage
- Payment: no raw card data, webhook signature verification, idempotency keys
- API: rate limiting, input validation, no PII in URLs/logs, CORS
- PII: encrypted at rest, retention policy, GDPR deletion capability

**Additional security responsibilities:**
- Threat modeling: identifies attack vectors specific to the feature
- Supply chain checks: reviews new dependencies for known vulnerabilities and maintenance status
- Security has highest conflict precedence — overrides all other agent recommendations

**Output:**
```
SECURITY_REPORT:
  CRITICAL: [must fix before ship]
  HIGH: [fix this sprint]
  MEDIUM: [backlog OK]
  THREATS: [identified attack vectors]
  SUPPLY_CHAIN: [dependency risk assessment]
  VERDICT: APPROVE | REJECT
```

---

### Gap Checker (V5) — `gap-checker`

**Model:** inherit (Sonnet)
**Color:** orange
**When:** After Phase 2 (Implementation), before Phase 3 (Code Review). Monorepo projects only.

**Role:** Validates that features spanning multiple monorepo packages have been implemented completely across all affected packages. Reads the Impact Map from the spec, cross-references with implementation agent reports, and identifies missing implementations.

**File ownership:** None (read-only validation agent)

**Input:**
- Impact Map from `docs/specs/{feature-id}.md`
- Implementation agent reports
- `workspace.packages` from `solo-dev-state.json`

**Output:** GAP_CHECK_REPORT with PASS/FAIL verdict and targeted fix instructions for specific agents.

**Triggers:** Post-implementation (mandatory), post-CR fix, post-QA fix. Round counter is cumulative.

**Loop:** Configurable via `gap_check.min_rounds` (default: 1) and `gap_check.max_rounds` (default: 3) in `.claude/solo-dev.local.md`. On exceeding max → escalate to orchestrator.

---

### Smoke Tester
**ID:** `smoke-tester`
**Model:** inherit (Sonnet)
**Color:** orange
**When:** Phase 2.6 — after gap-checker PASS, before code review. Also post-CR fix and post-QA fix.

**Role:** Runtime verification agent. Builds the project, starts the dev server, and tests endpoints against API contracts. Catches false DONE reports by verifying code actually runs. Manages port conflicts (kills known dev servers only when configured).

**File ownership:** None (read-only verification + Bash for build/server/curl)

**Output:** SMOKE_TEST_REPORT with PASS/FAIL/PARTIAL verdict and targeted feedback for specific agents on failure.

**On FAIL:** Targeted feedback (BUILD_FEEDBACK, SERVER_FEEDBACK, ENDPOINT_FEEDBACK, VALIDATION_FEEDBACK) to responsible agents. Re-runs only failed steps. Max rounds from `smoke_test.max_rounds` config.

---

### Drift Detector
**ID:** `drift-detector`
**Model:** inherit (Sonnet)
**Color:** yellow
**When:** Multiple lifecycle points — session start (Mode 3), after spec produced (Mode 1), Phase 2.7 (Mode 2), post-ship (Mode 4).

**Role:** Detects inconsistencies that cause agent divergence: vague spec criteria, contract drift during implementation, stale memory patterns, and unverified pattern promotion.

**File ownership:** None (read-only validation + Bash for checksums/git)

**4 Modes:**
1. **Spec Clarity Check** — flags vague acceptance criteria before implementation
2. **Contract Drift Check** — detects contract changes that leave agents working against stale versions
3. **Memory Drift Check** — finds stale patterns, contradictions, and YAML/markdown sync issues
4. **Pattern Validation Check** — requires CR+QA proof before promoting patterns

**Output:** Mode-specific reports (SPEC_CLARITY_REPORT, CONTRACT_DRIFT_REPORT, MEMORY_DRIFT_REPORT, PATTERN_VALIDATION_REPORT)

---

## Implementation Layer

All implementation agents run **in parallel** with **strict file ownership** — no agent touches files owned by another.

### I1 — Frontend Agent
**ID:** `frontend-agent`
**Color:** magenta
**File ownership:** pages/, app/, routes/, components/ (non-design-system)

**Skills:**
- `impeccable:animate`, `impeccable:polish`, `impeccable:critique`, `impeccable:harden` (or `solo-dev:ui-quality` fallback)
- `ui-ux-pro-max` (or `solo-dev:ux-design` fallback)
- `everything-claude-code:frontend-patterns`

**Skill invocation by scenario:**

| Scenario | Skill |
|----------|-------|
| New component built | `impeccable:animate` + `impeccable:polish` |
| Design review | `impeccable:critique` |
| Error/empty states | `impeccable:harden` |
| Design too plain | `impeccable:bolder` |
| Design too loud | `impeccable:quieter` |
| Layout problems | `impeccable:arrange` |
| Design decisions | `ui-ux-pro-max` |

**Code exploration:** Repomix MCP (not direct file reads)

**Enhancements:**
- Security checklist: validates no XSS vectors, sanitized rendering, CSP-compatible output
- Performance budget: enforces bundle size limits, lazy loading for heavy components

---

### I2 — Backend Agent
**ID:** `backend-agent`
**Color:** magenta
**File ownership:** src/api/, src/services/, src/repositories/, src/middleware/

**Skills:**
- `everything-claude-code:backend-patterns` (or `solo-dev:backend-patterns` fallback)
- `everything-claude-code:api-design`
- `everything-claude-code:coding-standards`
- Stack-specific skills (loaded by SessionStart)
- `claude.ai Better Auth` MCP (if project uses Better Auth)

**Code exploration:** Repomix MCP

**Additional responsibility:** Defines API contracts → written to `docs/contracts/{feature}-api.md`

**Enhancements:**
- Voting mechanism: reports DONE | BLOCKED (with reason) | NEEDS_CLARIFICATION
- Partial failure handling: can report partial completion with list of remaining work

---

### I3 — UI Agent
**ID:** `ui-agent`
**Color:** magenta
**File ownership:** src/components/ui/, src/design-system/, src/styles/

**Skills:**
- `impeccable:*` (primary — all impeccable skills)
- `ui-ux-pro-max` (or `solo-dev:ux-design` fallback)

**Must invoke before reporting DONE:**
- `impeccable:polish` — final quality pass
- `impeccable:critique` — design effectiveness check

**Enhancements:**
- Good enough threshold: avoids infinite polish loops — 3 polish iterations max
- Ownership boundary: only touches design-system and shared UI components, never page-level layout

---

### I4 — Data Agent
**ID:** `data-agent`
**Color:** magenta
**File ownership:** prisma/, migrations/, src/db/, schemas/

**Skills:**
- `everything-claude-code:database-migrations`
- `everything-claude-code:postgres-patterns`

**Code exploration:** Repomix MCP

**Enhancements:**
- Voting mechanism: reports DONE | BLOCKED (with reason) | NEEDS_CLARIFICATION
- Partial failure handling: can report partial completion with list of remaining work
- Compliance checklist: verifies data retention policies, PII handling, audit trail fields

---

### I5 — Test Agent
**ID:** `test-agent`
**Color:** magenta
**File ownership:** tests/, __tests__/, spec/, e2e/

**Skills:**
- `everything-claude-code:tdd` (or `solo-dev:tdd` fallback)
- `everything-claude-code:tdd-workflow`
- `everything-claude-code:e2e-testing`

**Also responsible for:** Phase 8 demo generation (Playwright recording + demo.md)

**Enhancements:**
- Beyond-spec testing: proactively tests edge cases not explicitly in acceptance criteria
- Security tests: writes tests for auth boundaries, tenant isolation, input validation

---

## Quality + Learning Layer

### Code Reviewer
**ID:** `code-reviewer`
**Color:** red

**Role:** Technical gatekeeper between implementation and QA. Runs after all I agents complete. Security-reviewer runs in parallel.

**Skills:**
- `everything-claude-code:coding-standards`

**Reviews 4 dimensions (in sequence):**
1. LOGIC — correctness of business logic, algorithm validity, edge case handling
2. MAINTAINABILITY — function size (<50 lines), file size (stack-aware limits), nesting, naming
3. SCALABILITY — N+1 queries, indexes, sync long operations, pagination, stateless ops
4. TECH DEBT — any types, TODO/FIXME, copy-paste duplication, follows patterns, error handling

**Note:** Security dimension removed — sole responsibility of security-reviewer.

**Stack-aware size limits:**
- Frontend (React/Vue/Svelte): <300 lines per component file
- Backend (API routes): <500 lines per module
- Infrastructure/config: <800 lines

**Output:**
```
CR_REPORT:
  PASS: [checks passed]
  FAIL: [issues with file:line + fix instruction]
  VERDICT: APPROVE | REJECT
```

If REJECT → I agents fix → CR re-reviews only changed sections (max 3 rounds)
**Writes:** `docs/agents/memory/cr_learnings.md`

---

### QA Validator
**ID:** `qa-validator`
**Color:** green

**Role:** Functional correctness and business logic verification. No security checks (handled by security-reviewer).

**Skills:**
- `everything-claude-code:e2e-testing`

**Checklist:**
- FUNCTIONAL: acceptance criteria, happy path, edge cases, error states, loading/empty states
- BUSINESS LOGIC: matches approved spec, multi-tenant isolation, plan gates, audit trail
- INTEGRATION: no regression, API contracts match, DB state consistent
- PERFORMANCE: page load <2s, API <500ms non-AI, AI ops show loading

**Enhancements:**
- Exploratory testing: proactively tests scenarios beyond the spec checklist
- Spec gap detection: identifies acceptance criteria that are ambiguous or missing — reports to orchestrator

If FAIL → I agents fix → CR re-checks if code changed → QA re-runs (max 3 rounds)

---

### Memory Curator
**ID:** `memory-curator`
**Color:** blue

**Role:** Manages memory compression, indexing, snapshots, and cross-project learning. Validates patterns before promoting them to global memory.

**Skills:**
- `everything-claude-code:iterative-retrieval`
- `everything-claude-code:continuous-learning-v2`

**Runs:**
- After each feedback cycle (compress + categorize new learnings)
- Before each feature starts (snapshot current state)
- After each feature ships (full memory reindex)

**Memory files it manages:**
```
docs/agents/memory/
  index.md              ← always ≤200 tokens
  decisions.md
  patterns.md
  rejected.md
  persona_insights.md
  cr_learnings.md
  bv_learnings.md
  performance-log.md
  snapshots/            ← pre-feature snapshots

~/.claude/solo-dev/
  global-memory/index.md
  global-memory/learnings/
  strategies/research.md
  strategies/implementation.md
  strategies/qa.md
```

---

### Strategy Evolver
**ID:** `strategy-evolver`
**Color:** blue

**Role:** Analyzes agent performance logs → updates strategy files for future sessions.

**Skills:**
- `everything-claude-code:continuous-learning-v2`
- `everything-claude-code:agentic-engineering`
- `everything-claude-code:agent-harness-construction`

**Triggered by:** `/solo-dev:evolve` command (not automatic)
**Threshold:** Activates after 2 features shipped (lowered from 3) — enough data to identify patterns.

**Process:**
1. Read last N entries from `docs/agents/memory/performance-log.md`
2. Read current strategy files
3. Identify patterns: what worked, what failed, what caused loops
4. Create strategy snapshot before updating (for rollback)
5. Write updated strategies to `~/.claude/solo-dev/strategies/`
6. Analyze abandoned/rolled-back features for systemic issues
7. Append evolution summary to `docs/agents/memory/decisions.md`

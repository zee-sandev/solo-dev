# solo-dev Plugin — Full Design

> **Purpose:** A Claude Code plugin that transforms any SaaS product concept into a working codebase
> through a self-learning, self-improving multi-agent system.
>
> Input: product concept / user story / business logic
> Output: working codebase + feature roadmap + learning memory

---

## Core Design Principles

| Principle | Meaning |
|-----------|---------|
| **Generic stack** | Adapts to any tech stack — Next.js, Django, Go, Spring Boot, etc. |
| **Configurable autonomy** | User decides per-decision-type: autonomous, always-ask, or confidence-threshold |
| **Token-first** | Index-first memory + Repomix for code exploration — overhead < 2,000 tokens/session |
| **Self-improving** | Agents evaluate performance, strategy-evolver updates strategies across sessions |
| **Human-in-the-loop** | Conflicts and escalations always surface to human with full context |
| **Loop until right** | No feature ships until every quality gate passes |
| **DAG-based dispatching** | Agent dependencies modeled as a DAG — independent agents always run in parallel |
| **Adaptive phase ordering** | Feature effort classification (S/M/L/XL) determines which phases run and in what order. Small features fast-track through fewer gates |
| **Cost-aware execution** | Small features skip expensive phases (design loop, full QA) to avoid overhead exceeding feature value |
| **Deep discovery before building** | Discovery agent explores the problem space (5-Whys, Jobs-to-be-Done, simulated interviews, assumption auditing) before any feature definition. Ensures the team builds the RIGHT thing |
| **Venture-scale strategic thinking** | Venture strategist evaluates 10x opportunities, competitive white space, combinatorial feature synergies, and category creation potential. Pushes beyond "viable?" to "category-defining?" |
| **3-Checkpoint interaction model** | User confirmations concentrated at 3 natural boundaries: Pre-Flight (confirm understanding before research), Mid-Flight (confirm design spec before build — prevents wasted work), Post-Flight (confirm ship + review deferred items). Between checkpoints, only critical blockers interrupt. S features skip Mid-Flight (2 checkpoints). M/L/XL use all 3 |
| **Security sole ownership** | Security reviewer is the single owner of all security checks — no duplication across agents |
| **Business validation parallel** | Business validator runs parallel with implementation (after design approval), not sequentially after QA |
| **Cross-package completeness via gap-checker** | In monorepo projects, a dedicated gap-checker agent validates that every package listed in the Impact Map has corresponding implementation changes. Runs between implementation and code review. Prevents the common failure mode where agents implement only one side of a feature (e.g., API without frontend) |
| **Runtime verification via smoke-tester** | Agents report DONE but orchestrator now verifies: build succeeds, server starts, endpoints respond correctly. Port management with safeguards (only kills known dev servers). |
| **Drift detection via drift-detector** | 4-mode agent catches: vague specs (Mode 1), contract drift (Mode 2), stale memory (Mode 3), unverified patterns (Mode 4). Prevents the compounding of bad assumptions across features. |
| **QA runtime + E2E via Playwright** | QA validator enhanced from static-only to 3-layer: static analysis → API runtime tests → E2E browser tests. Playwright always used for E2E regardless of project stack. |
| **Content validation in gap-checker** | Gap-checker now verifies file content matches expected type, not just file existence. Runs for all projects (not just monorepo). |
| **Layer-based gap checking** | Gap-checker validates cross-layer completeness for ALL projects (not just monorepo). Checks: API endpoint has frontend page, new page has route registration, auth-protected routes have guards, etc. |
| **Innovation Path for novel ideas** | Market-validator has VIABLE_EXPERIMENTAL verdict for features with no competitor precedent. Validates via pain evidence + adjacent market + cost-to-test instead of auto-rejecting. |
| **Persona Evolution Protocol** | Personas evolve every 5 features, on repeated rejections, or user corrections. Prevents frozen personas from blocking valid features. |
| **Devil's Advocate in self-refinement** | Cross-agent critique includes a contrarian round — the agent with fewest issues must argue against its own section. Prevents groupthink. |
| **Decision Expiry System** | All decisions in memory have expiry metadata. Drift-detector checks for expired decisions at session start. Auto-expiry defaults by type (tech stack=never, library=6mo, UX=3 features). |
| **Failure Learning Protocol (2x weight)** | Strategy-evolver weights failure data 2x over success data. Memory-curator writes structured failure entries on rollback/near-failure. Same failure 2+ times auto-promotes to anti-pattern. |
| **Feature Health Check (anti-feature-factory)** | Every 5 features, auto-run health check: velocity trends, tech debt signals, coherence audit. Offers consolidation mode to address integration gaps before adding more features. |
| **Spike & Experiment modes** | Not every idea needs 8 phases. Spike mode (30min, throwaway) answers "can we build this?". Experiment mode (60min, deployable) answers "should we build this?". |
| **Effort Calibration (anti-optimism-bias)** | Historical effort tracking detects systematic underestimation. Pre-Flight shows calibration warning when past features consistently took more rounds than classified. |
| **Backtrack Path (impl → design)** | When implementation reveals fundamental spec gaps, controlled backtrack to design loop. Updates only affected spec section, resumes from saved state. Max 2 backtracks per feature. |
| **Checkpoint Engagement Verification** | Varied checkpoint formats, periodic depth questions, and concrete diff summaries prevent users from blindly approving checkpoints. |
| **Cross-Feature UX Coherence** | Every 3 features, audit navigation consistency, terminology, and component patterns. Pre-Flight flags navigation impact for new pages. |
| **Lazy dispatch & cost tiers** | Not all agents needed for every feature. Dispatch rules skip irrelevant agents. Cost tier guidance helps users configure model overrides per agent role. |

---

## Foundation-Aware Design

When a project starts from a well-documented template/boilerplate (has CLAUDE.md + docs/ or .claude/agents/):

| Principle | Meaning |
|-----------|---------|
| **Read, don't re-analyze** | If CLAUDE.md describes the stack, trust it — don't run analysis agents |
| **Delegate, don't replace** | If template has agents that know conventions, let them handle implementation |
| **Replace, don't delete** | Example code stays until real features naturally replace it |
| **1 question, not 3** | Foundation projects need only "what are you building?" |

### Agent Delegation (Foundation Projects)

| solo-dev agent | If project has | Action |
|----------------|---------------|--------|
| frontend-agent | Any frontend/web agent | **DELEGATE** |
| backend-agent | Any api/backend agent | **DELEGATE** |
| data-agent | Any database/migration agent | **DELEGATE** |
| test-agent | Any test-runner agent | **DELEGATE** |
| ui-agent | (no equivalent) | USE solo-dev |
| code-reviewer | Any code-reviewer agent | **MERGE** both |

Discovery + Research + Validation + Learning agents → always solo-dev (template doesn't provide these).

### Replace-as-you-go

Template example code (demo pages, sample modules) is tagged during init, not deleted.
- During feature build: agents auto-replace overlapping examples with real implementation
- After all features complete: prompt to remove remaining unused examples

---

## Plugin Structure

```
solo-dev/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── saas-workflow/        # Full workflow documentation for agents
│   ├── ui-quality/           # Bundled fallback for impeccable
│   ├── ux-design/            # Bundled fallback for ui-ux-pro-max
│   ├── backend-patterns/     # Bundled fallback for ecc:backend-patterns
│   ├── security/             # Bundled fallback for ecc:security-review
│   └── tdd/                  # Bundled fallback for ecc:tdd-workflow
├── agents/                   # 22 agents
├── commands/                 # 8 commands
├── hooks/
│   ├── hooks.json
│   └── scripts/
│       ├── session-start.sh
│       └── repack-check.sh
└── README.md
```

---

## Commands

| Command | Purpose | Autonomy |
|---------|---------|----------|
| `/solo-dev:start-from-idea` | Idea → validated concept + roadmap | Guided |
| `/solo-dev:init` | Setup project from concept/docs/template | Semi-guided |
| `/solo-dev:next-feature` | Implement next feature from roadmap | Per config |
| `/solo-dev:consult` | Quick expert consultation with any agent — no init required | Read-only |
| `/solo-dev:handoff` | Transition conversation discussion into structured workflow | Semi-guided |
| `/solo-dev:evolve` | Run strategy-evolver to improve agents | Semi-auto |
| `/solo-dev:status` | Progress dashboard + token usage | Read-only |
| `/solo-dev:set-autonomy` | Configure autonomy levels interactively | Interactive |
| `/solo-dev:rollback` | Rollback a specific feature | Always-ask |
| `/solo-dev:resume` | Resume from escalation or paused state | Interactive |
| `/solo-dev:showcase` | Compile feature demos into a product showcase | Read-only |
| `/solo-dev:sprint` | Plan sprints — select features, estimate effort | Interactive |
| `/solo-dev:decompose` | Break a large feature into smaller sub-features | Semi-guided |

---

## Configurable Autonomy

```yaml
# .claude/solo-dev.local.md
autonomy:
  tech_stack_selection: always-ask
  boilerplate_generation: always-auto
  research_synthesis: threshold:0.8
  design_decisions: always-ask
  implementation: always-auto
  code_review_fixes: threshold:0.9
  deployment_config: always-ask
```

- `always-auto` — proceed without asking
- `always-ask` — prompt user every time
- `threshold:N` — auto if agent confidence ≥ N, else ask

---

## Skill Resolution (Try/Fallback)

All agents first try external skills, fall back to bundled versions:

```
Agent invokes: "impeccable:polish"
  → If installed: use full impeccable skill
  → If not found: use "solo-dev:ui-quality" (bundled ~70% capability)
```

Bundled skills cover: ui-quality, ux-design, backend-patterns, security, tdd, saas-workflow

---

## YAML-First Architecture

All structured agent outputs are stored as YAML indexes in `docs/yaml/`:

| YAML File | Source of Truth For | Markdown View |
|-----------|-------------------|---------------|
| features.yaml | Feature roadmap | docs/product/roadmap.md |
| specs.yaml | Feature specs | (used by commands) |
| contracts.yaml | API contracts | (used by commands) |
| demos.yaml | Demo recordings | (used by commands) |
| sprints.yaml | Sprint plans | docs/product/sprints.md |
| changelog.yaml | Changelog | CHANGELOG.md |
| memory-index.yaml | Memory index | docs/agents/memory/index.md |
| backlog.yaml | Backlog items | docs/product/backlog.md |

### 3-Layer Consistency
1. **YAML-First Write** (PostToolUse hook) — agents write YAML, hook regenerates markdown
2. **Stop Reconciliation** (Stop hook) — validates YAML-markdown sync before session ends
3. **Start Validation** (SessionStart hook) — detects and auto-repairs drift at session start

---

## Stack-Specific Skills (Dynamic Loading)

SessionStart detects stack from project files → loads relevant skills:

| Detected Stack | Additional Skills Loaded |
|---------------|------------------------|
| Next.js (package.json) | ecc:frontend-patterns |
| Django (manage.py) | ecc:django-patterns, ecc:django-security, ecc:django-tdd |
| Spring Boot (pom.xml) | ecc:springboot-patterns, ecc:springboot-security, ecc:jpa-patterns |
| Go (go.mod) | ecc:golang-patterns, ecc:golang-testing |
| Python (requirements.txt) | ecc:python-patterns, ecc:python-testing |
| Better Auth (config) | claude.ai Better Auth MCP |

---

## Token Budget Configuration

```yaml
# .claude/solo-dev.local.md
token_budget:
  enabled: true
  mode: "fixed"           # "fixed" | "subscription" | "disabled"

  fixed:
    per_feature: 50000    # Hard cap per feature
    warning_threshold: 0.8

  subscription:           # For unlimited plan users
    track_usage: true     # Track but don't cap
    warn_inefficiency: true   # Alert on abnormal usage
    auto_compress: true   # Auto-compress context at 80%
    stall_detection: true # Detect agent loops without progress

  disabled: {}            # No tracking, no limits
```

---

## API Contract Auto-Documentation

```yaml
# .claude/solo-dev.local.md
api_contracts:
  enabled: true
  output:
    mode: "markdown"      # "markdown" | "custom"
    markdown:
      path: "docs/contracts"
    custom:
      prompt: |
        # Define your own documentation target, e.g.:
        # "Add to docs/openapi.yaml under /paths"
        # "Update Notion API reference page via MCP"
        # "Write MDX file to src/docs/{endpoint-name}.mdx"
```

---

## Project State

```json
{
  "project": "my-saas",
  "phase": "QA_LOOP",
  "current_feature": "A1_feature_id",
  "round": 2,
  "blocked_since": null,
  "agents_status": {
    "qa-validator": "IN_PROGRESS",
    "code-reviewer": "APPROVED"
  },
  "repomix_pack_id": "abc123",
  "last_updated": "2026-03-18T10:30:00Z"
}
```

Stored in `.claude/solo-dev-state.json` — SessionStart hook reads and resumes automatically.

---

## Demo Generation (Phase 8)

After Final Acceptance of every feature:

```
docs/demos/{feature-id}/
  demo.mp4    ← Playwright recorded video (happy path)
  demo.md     ← What it is, why useful, real-world example
```

- `test-agent` writes + runs Playwright scenario
- Records via `recordVideo` option against running dev server
- Falls back to demo.md only if Playwright not installed

---

## Rollback

```
/solo-dev:rollback [feature-id]
  1. git revert to pre-feature commit
  2. Restore state from .claude/solo-dev-state.json snapshot
  3. Restore memory from docs/agents/memory/snapshots/pre-{feature}.json
  4. Mark feature ROLLED_BACK in roadmap
  5. Offer: Re-attempt | Remove | Decompose
```

Memory-curator snapshots state + memory before each feature begins.

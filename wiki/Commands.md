# Commands

solo-dev provides 13 commands for the full product development lifecycle.

## Overview

| Command | Description |
|---------|-------------|
| `/solo-dev:start-from-idea` | Turn a rough idea into a validated roadmap |
| `/solo-dev:init` | Initialize a project from a concept, codebase, or template |
| `/solo-dev:next-feature` | Build and ship the next feature on your roadmap |
| `/solo-dev:consult <agent>` | Quick expert consultation with any agent — no init required |
| `/solo-dev:handoff` | Transition a conversation discussion into a structured build |
| `/solo-dev:status` | Progress dashboard — roadmap, phase, token usage |
| `/solo-dev:set-autonomy` | Configure per-decision autonomy levels interactively |
| `/solo-dev:evolve` | Analyze performance data and improve agent strategies |
| `/solo-dev:rollback [feature-id]` | Revert a feature — git, state, and memory snapshots |
| `/solo-dev:resume` | Resume from a human escalation or paused state |
| `/solo-dev:showcase` | Compile feature demos into a product showcase |
| `/solo-dev:sprint` | Plan sprints — select features, estimate effort |
| `/solo-dev:decompose <id>` | Break a large feature into smaller sub-features |

---

## `/solo-dev:start-from-idea`

Transforms a rough idea into a validated product concept with a prioritized roadmap.

**Phases:**
1. Idea Exploration — dialogue to understand problem, audience, constraints
2. Market Reality Check — competitor research, market size, timing
3. Competitor Gap Analysis — feature gaps, weaknesses, whitespace
4. Persona Generation — 2-3 personas from concept
5. Feature Definition + AI Enhancement — MVP features + depth/breadth/differentiation suggestions
6. Roadmap Generation — prioritized features with dependency graph

**Output:** `docs/product/` with idea-brief, personas, competitive-analysis, roadmap, backlog

**Next step:** `/solo-dev:init`

---

## `/solo-dev:init`

Sets up the project for development. Detects whether this is a new concept or existing codebase.

**Path A (new project):** Reads roadmap from `start-from-idea`, creates directory structure, memory system, state file, autonomy config.

**Path B (existing codebase):** Analyzes codebase silently, cross-checks understanding with user (3 interactions), generates docs. See [Existing Project Onboarding](Existing-Project-Onboarding.md).

**Path C (template/foundation):** Reads existing CLAUDE.md, docs/, .claude/agents/ — delegates implementation to template agents, tags example code. 1 interaction only. See [Existing Project Onboarding](Existing-Project-Onboarding.md).

**Next step:** `/solo-dev:next-feature`

---

## `/solo-dev:next-feature`

Runs the full [Feature Lifecycle](Feature-Lifecycle.md) (phases 0-8) for the next feature on the roadmap.

Automatically selects the next `QUEUED` feature where all `depends_on` are `COMPLETE`. If no feature is eligible, reports which dependencies are blocking.

---

## `/solo-dev:consult`

Quick, standalone consultation with any solo-dev agent. **No init required** — works from any conversation.

```
/solo-dev:consult tech-architect "should I use REST or GraphQL?"
/solo-dev:consult security-reviewer "review this auth middleware"
/solo-dev:consult product-researcher "competitors for invoice automation"
```

**Available agents for consultation:**

| Agent | Expertise |
|-------|----------|
| `tech-architect` | Architecture, API design, stack selection, performance |
| `product-researcher` | Market fit, competitors, positioning, monetization |
| `ux-researcher` | User journey, UX patterns, information architecture |
| `market-validator` | Commercial viability, market size, timing |
| `business-validator` | Business logic, real-world edge cases, competitive gaps |
| `security-reviewer` | Auth, multi-tenancy, payment security, OWASP |
| `code-reviewer` | Code quality — security, maintainability, scalability |
| `persona-validator` | Evaluate from user persona perspectives |

If the project is initialized, agents have access to project memory (decisions, patterns). If not, they work as standalone experts.

**Next step (optional):** `/solo-dev:handoff` to transition the consultation into a structured build.

---

## `/solo-dev:handoff`

Transitions the current conversation into solo-dev's structured workflow. Use this when a discussion naturally reaches the point where building should begin.

```
/solo-dev:handoff              # Full lifecycle (8 phases)
/solo-dev:handoff design-only  # Design loop only, stop before implementation
```

**What it does:**

1. Synthesizes the conversation — extracts what was discussed, decisions made, open questions
2. Confirms the summary with you
3. Asks how deep to go:
   - **A) Full lifecycle** — Design → Implementation → Review → QA → Demo (8 phases)
   - **B) Design only** — Research agents produce a spec, personas validate, stop
   - **C) Implement now** — Skip design, go straight to parallel implementation
4. Creates a feature spec from the discussion and enters the workflow

If the project isn't initialized yet, handoff runs a **quick init** (minimal setup) before proceeding.

---

## `/solo-dev:status`

Displays current project status:
- Current phase and feature
- Roadmap progress (shipped / WIP / planned)
- Token usage (if budget enabled)
- Agent performance summary
- Memory file sizes

---

## `/solo-dev:set-autonomy`

Interactive configuration of per-decision autonomy levels.

```
Current settings:
  tech_stack_selection    always-ask
  boilerplate_generation  always-auto
  design_decisions        always-ask
  implementation          always-auto
  code_review_fixes       threshold:0.9
  deployment_config       always-ask

Which setting to change? design_decisions
New value: threshold:0.85

✓  Saved. Design decisions with ≥85% confidence proceed automatically.
```

See [Configuration](Configuration.md) for all available settings.

---

## `/solo-dev:evolve`

Triggers the `strategy-evolver` agent to analyze performance data and update agent strategies.

**Requires:** At least 3 completed features (needs enough data to identify patterns).

**Process:**
1. Reads `performance-log.md` for recent feature data
2. Reads current strategy files
3. Identifies: what worked, what failed, what caused loops
4. Updates `~/.claude/solo-dev/strategies/` (research, implementation, qa)
5. Logs evolution summary to `decisions.md`

---

## `/solo-dev:rollback [feature-id]`

Reverts a specific feature — git commits, state, and memory.

See [Rollback](Rollback.md) for details.

---

## `/solo-dev:resume`

Resumes from a human escalation or paused state.

Reads `.claude/solo-dev-state.json` to determine where the project left off:
- If `ESCALATED` — presents the escalation context and asks for decision
- If mid-phase — resumes from the exact phase and round
- If `BLOCKED` — reports what's blocking and suggests options

---

## `/solo-dev:showcase`

Compiles all recorded feature demos into a single showcase page.
Reads docs/yaml/demos.yaml and generates docs/showcase/index.md.
Use `html` argument for an HTML showcase page.
**Requires:** At least 1 completed feature with a demo.

---

## `/solo-dev:sprint`

Plans development sprints from the feature roadmap.
`/solo-dev:sprint` — interactive sprint planning
`/solo-dev:sprint show` — display current active sprint
Reads features.yaml for available features, groups by priority/dependency, asks for effort estimates.

---

## `/solo-dev:decompose`

Breaks a large feature into 2-5 smaller sub-features.
`/solo-dev:decompose A3` — decompose feature A3
Each sub-feature is independently shippable. Also offered as option C after /solo-dev:rollback.

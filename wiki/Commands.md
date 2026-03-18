# Commands

solo-dev provides 8 commands for the full product development lifecycle.

## Overview

| Command | Description |
|---------|-------------|
| `/solo-dev:start-from-idea` | Turn a rough idea into a validated roadmap |
| `/solo-dev:init` | Initialize a project from an existing concept or codebase |
| `/solo-dev:next-feature` | Build and ship the next feature on your roadmap |
| `/solo-dev:status` | Progress dashboard — roadmap, phase, token usage |
| `/solo-dev:set-autonomy` | Configure per-decision autonomy levels interactively |
| `/solo-dev:evolve` | Analyze performance data and improve agent strategies |
| `/solo-dev:rollback [feature-id]` | Revert a feature — git, state, and memory snapshots |
| `/solo-dev:resume` | Resume from a human escalation or paused state |

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

**Next step:** `/solo-dev:next-feature`

---

## `/solo-dev:next-feature`

Runs the full [Feature Lifecycle](Feature-Lifecycle.md) (phases 0-8) for the next feature on the roadmap.

Automatically selects the next `QUEUED` feature where all `depends_on` are `COMPLETE`. If no feature is eligible, reports which dependencies are blocking.

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

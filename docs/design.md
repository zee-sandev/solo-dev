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
├── agents/                   # 17 agents
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
| `/solo-dev:init` | Setup project from concept/docs | Semi-guided |
| `/solo-dev:next-feature` | Implement next feature from roadmap | Per config |
| `/solo-dev:evolve` | Run strategy-evolver to improve agents | Semi-auto |
| `/solo-dev:status` | Progress dashboard + token usage | Read-only |
| `/solo-dev:set-autonomy` | Configure autonomy levels interactively | Interactive |
| `/solo-dev:rollback` | Rollback a specific feature | Always-ask |
| `/solo-dev:resume` | Resume from escalation or paused state | Interactive |

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

# solo-dev Plugin — Development Instructions

## Project Overview

This is a Claude Code plugin (`solo-dev`) — a multi-agent SaaS development system with 20 agents, 13 commands, 6 bundled skills, hooks, and a self-learning memory system.

## Documentation Sync Rules

This project maintains 3 documentation surfaces that MUST stay in sync:

1. **`README.md`** — GitHub landing page (overview, quick start, examples, diagrams)
2. **`docs/`** — Detailed architecture reference (design, agents, memory, feedback, workflow)
3. **`wiki/`** — GitHub wiki pages (user-facing docs, guides, configuration)

### When to Update Each

| Change Type | Update |
|-------------|--------|
| New/modified agent | `README.md` (agent roster table), `docs/agent-architecture.md` (full details), `wiki/Agent-Architecture.md` |
| New/modified command | `README.md` (commands table + examples if applicable), `wiki/Commands.md`, `docs/design.md` (commands table) |
| Workflow/phase change | `README.md` (Mermaid diagrams), `docs/workflow.md`, `wiki/Feature-Lifecycle.md` |
| Feedback protocol change | `docs/agent-feedback-flow.md`, `wiki/Agent-Feedback-Protocol.md` |
| Memory system change | `docs/memory-flow.md`, `wiki/Memory-System.md` |
| Configuration change | `README.md` (config section), `wiki/Configuration.md` |
| New bundled skill | `README.md` (bundled skills table), `wiki/Bundled-Skills.md` |
| New supported stack | `README.md` (supported stacks table), `wiki/Supported-Stacks.md` |
| Onboarding flow change | `README.md` (onboarding example), `commands/init.md`, `wiki/Existing-Project-Onboarding.md`, `docs/workflow.md` |
| Rollback change | `wiki/Rollback.md`, `docs/workflow.md` |
| New/modified YAML index | N/A | `docs/memory-flow.md` (YAML sync section) | `wiki/Memory-System.md` |
| Mermaid diagram needs update | `README.md`, `wiki/Feature-Lifecycle.md` (both have same diagrams) |

### Sync Checklist

After ANY plugin component change, verify:

- [ ] README.md reflects the change (tables, diagrams, examples)
- [ ] Relevant docs/ file is updated
- [ ] Relevant wiki/ page is updated
- [ ] wiki/_Sidebar.md is updated if new pages were added
- [ ] Mermaid diagrams still accurately represent the flow

## File Structure

```
solo-dev/
├── .claude-plugin/plugin.json   # Plugin manifest
├── README.md                     # GitHub landing page
├── CLAUDE.md                     # This file
├── agents/                       # 20 agent definitions
├── commands/                     # 8 command definitions
├── hooks/                        # hooks.json + scripts/
├── skills/                       # 6 bundled fallback skills
├── docs/                         # Architecture reference docs
│   ├── yaml/                     # YAML indexes (source of truth)
│   ├── design.md
│   ├── agent-architecture.md
│   ├── memory-flow.md
│   ├── agent-feedback-flow.md
│   └── workflow.md
└── wiki/                         # GitHub wiki pages
    ├── _Sidebar.md
    ├── Home.md
    ├── Getting-Started.md
    ├── Commands.md
    ├── Agent-Architecture.md
    ├── Feature-Lifecycle.md
    ├── Agent-Feedback-Protocol.md
    ├── Memory-System.md
    ├── Existing-Project-Onboarding.md
    ├── Configuration.md
    ├── Supported-Stacks.md
    ├── Bundled-Skills.md
    └── Rollback.md
```

## Conventions

### Agents
- One file per agent in `agents/`
- Filename = agent ID (e.g., `backend-agent.md`)
- Frontmatter: name, whenToUse (with examples), model, color, tools, systemPrompt

### Commands
- One file per command in `commands/`
- Frontmatter: name, description, argument-hint, allowed-tools
- Written FOR Claude (instructions), not TO user

### Skills
- One directory per skill in `skills/`
- Each has `SKILL.md` with frontmatter (name, description)
- References in `references/` subdirectory

### YAML Indexes
- Source of truth for all indexed content in docs/yaml/
- Agents write YAML first, hooks generate markdown views
- Never edit generated markdown directly for indexed content
- 8 indexes: features, specs, contracts, demos, sprints, changelog, memory-index, backlog

### Wiki Pages (also GitHub Pages via MkDocs)
- GitHub wiki format: `Page-Name.md` (hyphenated)
- `_Sidebar.md` for GitHub Wiki navigation (uses `[[Page Name]]` links)
- Content links use standard markdown: `[Page Name](Page-Name.md)` (MkDocs compatible)
- Mermaid diagrams should match README.md versions
- Navigation structure defined in `mkdocs.yml` → `nav` section
- If new wiki page added: update both `wiki/_Sidebar.md` AND `mkdocs.yml` nav

### Mermaid Diagrams
- Use `<br/>` for line breaks in node labels (never `\n`)
- Use `TD` (top-down) layout for better readability
- Use `classDef` for color-coded subgraphs
- Wrap edge labels in quotes
- Keep diagrams consistent between README.md and wiki/Feature-Lifecycle.md

## GitHub Pages (MkDocs)

Wiki pages are deployed to GitHub Pages via MkDocs Material.

- **Config:** `mkdocs.yml` (uses `wiki/` as `docs_dir`)
- **CI/CD:** `.github/workflows/deploy-docs.yml` (auto-deploys on push to `main` when `wiki/` or `mkdocs.yml` changes)
- **Build output:** `site/` (gitignored)
- **Local preview:** `mkdocs serve` from project root
- **Dependencies:** `mkdocs-material`, `pymdown-extensions`

When adding a new wiki page:
1. Create `wiki/New-Page.md`
2. Add to `mkdocs.yml` → `nav` section
3. Add to `wiki/_Sidebar.md` (for GitHub Wiki compatibility)
4. Use standard markdown links in content: `[Page Name](Page-Name.md)`

## Design Plan Reference

The full design plan is at: `~/.claude/plans/crystalline-chasing-dolphin.md`

## Key Design Decisions

- **Analyze-first for existing projects:** When onboarding an existing codebase, agents analyze silently before asking any questions. The codebase speaks first.
- **`[INFERRED]` tagging:** Auto-detected architecture decisions are tagged `[INFERRED]` until user confirms. Wrong decisions compound across features.
- **Strict file ownership:** Implementation agents never touch files owned by another agent.
- **Index-first memory:** Only ~200 token index loads at session start. Everything else on-demand.
- **Bundled skill fallbacks:** Try external plugin first, fall back to bundled ~70% version.
- **market-validator is a gatekeeper with teeth:** Provides VIABLE/HIGH_RISK/BLOCKER verdicts. HIGH_RISK requires user acknowledgment, BLOCKER requires user override.
- **Business validator runs parallel with implementation, not after QA:** 3-hat evaluation (Operations/Compliance/Growth) starts as soon as design is approved.
- **Security reviewer is sole owner of all security checks:** No other agent performs security review. Runs parallel with code review. Includes threat modeling and supply chain checks.
- **Design loop max 3 rounds (reduced from 5):** Tighter iteration to prevent over-engineering. Auto-escalation if same rejection repeats.
- **DAG-based dependency analysis for parallel agent dispatching:** Independent agents always run in parallel. Hard vs soft dependency classification.
- **Adaptive phase ordering by feature effort (S/M/L/XL):** Small features fast-track through fewer gates. XL features decompose before starting.
- **Foundation-aware init:** When CLAUDE.md + docs/ or .claude/agents/ detected, read existing docs instead of re-analyzing. Delegate implementation to template's agents.
- **Replace-as-you-go:** Example code from templates is tagged, not deleted. Auto-replaced during feature implementation. Final cleanup prompt after all roadmap features complete.
- **Cross-package gap-checker for monorepo projects:** Dedicated agent validates implementation completeness across all affected packages. Prevents partial feature implementation.
- **Runtime verification via smoke-tester:** Build + server + endpoint testing after implementation. Port management with safeguards. Catches false DONE reports.
- **Drift detection via drift-detector:** 4-mode detection for vague specs, contract drift, stale memory, and unverified patterns.
- **QA enhanced with runtime + E2E:** Static → API runtime → Playwright E2E. Three-layer testing pipeline.
- **Visual Quality System via design_profile:** Interactive visual preview during init collects user's style/color/navigation/component preferences. ux-researcher translates into Visual Direction per feature. ui-agent enforces design tokens. Visual QA (Phase 2.8) verifies screenshots against profile before code review.

## Changelog Rules

Every implementation session MUST write a changelog entry:

1. **When to write:** After implementation is complete and tests pass, before commit
2. **Where to write:** `docs/yaml/changelog.yaml` (source of truth) → then regenerate `CHANGELOG.md` via `bash hooks/scripts/yaml-to-markdown.sh changelog.yaml`
3. **Entry format:**
   ```yaml
   - date: "YYYY-MM-DD"
     type: added|changed|fixed|removed
     description: "Clear, user-facing description of what changed"
     feature_id: "optional — link to feature if applicable"
   ```
4. **Rules:**
   - Write from user perspective, not developer perspective ("Add dark mode toggle" not "Implement ThemeProvider context")
   - One entry per logical change, not per file
   - Breaking changes MUST be flagged with `breaking: true`
   - Group related changes under same date
   - Include the version number if bumping plugin version

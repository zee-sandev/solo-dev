# solo-dev

A Claude Code plugin that turns a product concept into a production-ready SaaS — with autonomous multi-agent orchestration, self-learning memory, and demo videos shipped with every feature.

## What It Does

You describe an idea. solo-dev handles the rest:

- **Idea to Roadmap** — Market validation, competitor gap analysis, AI-enhanced feature suggestions, and a prioritized roadmap — before writing a single line of code
- **Feature-by-feature development** — Each feature goes through research, parallel implementation, code review, QA, security, business validation, and demo recording in a structured 8-phase lifecycle
- **Self-learning** — Agents learn from every feature cycle and continuously improve their own strategies across sessions and projects
- **Token-efficient** — Index-first memory (~200 tokens at session start), Repomix MCP for code exploration instead of raw file reads

## At a Glance

| | |
|---|---|
| **Agents** | 18 across 4 layers (Research, Validation, Implementation, Quality+Learning) |
| **Commands** | 8 (`start-from-idea`, `init`, `next-feature`, `status`, `set-autonomy`, `evolve`, `rollback`, `resume`) |
| **Skills** | 6 bundled fallbacks + dynamic stack-specific loading |
| **Memory** | Index-first (~200 tokens), on-demand pulls, cross-project learning |
| **Quality gates** | Market validation, persona voting, code review, QA, security, business validation |

## Quick Links

- [Getting Started](Getting-Started.md) — Installation and first run
- [Commands](Commands.md) — All 8 commands with usage
- [Agent Architecture](Agent-Architecture.md) — 18 agents, roles, and ownership
- [Feature Lifecycle](Feature-Lifecycle.md) — 8-phase development process
- [Configuration](Configuration.md) — Autonomy, token budget, API contracts
- [Existing Project Onboarding](Existing-Project-Onboarding.md) — Use solo-dev with an existing codebase

## Requirements

**Required**
- [Claude Code](https://claude.ai/claude-code) CLI

**Optional — enhances quality, solo-dev works without them**
- [`impeccable`](https://github.com/...) — superior UI polish and critique
- [`ui-ux-pro-max`](https://github.com/...) — advanced UX design patterns
- [`everything-claude-code`](https://github.com/...) — stack-specific backend, testing, and deployment patterns
- [Repomix](https://github.com/yamadashy/repomix) (`npm install -g repomix`) — token-efficient codebase exploration

> When optional plugins are missing, solo-dev automatically falls back to its [Bundled Skills](Bundled-Skills.md).

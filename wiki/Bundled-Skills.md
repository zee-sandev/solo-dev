# Bundled Skills

solo-dev ships with fallback versions of its key skill dependencies. If the external plugin is not installed, the bundled version activates automatically.

## Skill Resolution

Agents first try the external plugin, then fall back to the bundled skill:

```
Agent invokes: "impeccable:polish"
  → If installed: use full impeccable skill
  → If not found: use "solo-dev:ui-quality" (~70% capability)
```

## Bundled Skills

| Bundled Skill | Replaces | Coverage |
|---------------|---------|----------|
| `saas-workflow` | Always bundled | Orchestration reference for 8-phase lifecycle |
| `ui-quality` | `impeccable:polish`, `impeccable:critique`, `impeccable:harden` | Polish, critique, harden, animation guidelines, WCAG AA |
| `ux-design` | `ui-ux-pro-max` | IA principles, SaaS UX patterns, onboarding, dashboards |
| `backend-patterns` | `ecc:backend-patterns` | REST API design, service layer, multi-tenancy, validation |
| `security` | `ecc:security-review` | SaaS security checklist (auth, injection, API, payment, PII) |
| `tdd` | `ecc:tdd`, `ecc:tdd-workflow` | TDD workflow, unit/integration/E2E patterns, test isolation |

## When to Install External Plugins

The bundled skills cover ~70% of the original capability. Install the full plugins for:

- **impeccable** — advanced animation, design system extraction, color theory, typography, 14+ specialized skills
- **ui-ux-pro-max** — deep UX design intelligence, research-backed patterns, mobile-first design
- **everything-claude-code** — 50+ skills covering backend, frontend, testing, deployment, security, and more

## saas-workflow Skill

Always bundled (not a fallback). Provides:
- Feature lifecycle phase sequence and rules
- State tracking (what updates at each phase)
- Autonomy decision flow
- Inter-agent message format specification
- Start-from-idea phase reference

Referenced by the `orchestrator` agent for coordinating all phases.

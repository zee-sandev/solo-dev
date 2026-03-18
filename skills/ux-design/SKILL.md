---
name: ux-design
description: UX design principles, SaaS-specific patterns, information architecture, and persona-driven design. Fallback for ui-ux-pro-max plugin. Use when designing user flows, navigation, or onboarding.
---

The ux-researcher and frontend-agent use this skill when the ui-ux-pro-max plugin is not installed. It provides UX design principles and information architecture patterns as a standalone fallback.

## When to Use
Invoke when designing user flows, information architecture, onboarding experiences, or evaluating UX decisions. This is the bundled fallback for `ui-ux-pro-max`.

## Information Architecture Principles

### Navigation Design
- Max 7 items in primary navigation (cognitive load limit)
- Group related items — don't let users hunt across nav sections
- Current location always visible (breadcrumbs or active state)
- Destructive/rare actions in secondary menus, not primary nav

### User Flow Design
Every user flow needs:
1. **Entry point** — how does the user start? (what triggers this flow?)
2. **Happy path** — fewest steps to complete the goal
3. **Error recovery** — what happens when things go wrong?
4. **Exit point** — what does success look like? What's next?

### Friction Audit
For each user action, ask:
- Is this step necessary? (remove if not)
- Can we default this? (smart defaults reduce cognitive load)
- Can this be done later? (defer non-critical choices)
- Can this be combined with another step? (consolidate)

## SaaS-Specific UX Patterns

### Onboarding (Critical Path)
Time-to-value must be under 5 minutes for B2B SaaS.

**Progressive disclosure**: Show one step at a time. Don't dump all settings on first login.

**Onboarding checklist pattern**:
- Show 3-5 setup actions
- Show % complete or X/Y done
- Let user skip items (they'll come back)
- Celebrate each completion (micro-animation, checkmark)

### Empty States
Three types:
1. **First-time empty** — "You haven't added any X yet" + primary CTA
2. **Zero-results empty** — "No results for X" + suggestion to adjust filters
3. **Error empty** — "Couldn't load X" + retry action

All empty states need: illustration/icon + message + call to action.

### Pricing/Upgrade Flows
- Show value before paywall (let user experience the benefit)
- Upgrade prompts must be contextual (triggered by hitting a limit, not random)
- Show exactly what they get by upgrading
- One-click upgrade from prompt (don't send them to settings)

### Dashboard Design
- Most important metric above the fold
- No more than 5-7 data points on primary dashboard
- Progressive disclosure: summary → drill-down
- Time range selector always present for analytics

## Persona-Driven Design
When designing for a specific persona (from persona-validator):

1. Identify their primary job-to-be-done in this feature
2. Identify their biggest fear or frustration related to this feature
3. Design the happy path for their job-to-be-done
4. Design the guardrails around their biggest fear

## UX Review Checklist
Before any UX deliverable:
- [ ] Can a user complete the primary task without instructions?
- [ ] Does every screen have one clear primary action?
- [ ] Are error messages actionable (not just "something went wrong")?
- [ ] Is the system state always visible (loading, saving, saved)?
- [ ] Are destructive actions protected (confirmation, undo option)?


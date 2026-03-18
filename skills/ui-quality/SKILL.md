---
name: ui-quality
description: UI quality framework for component polish, critique, hardening, and accessibility. Fallback for impeccable plugin. Use when building or reviewing any UI component.
---

The ui-agent and frontend-agent use this skill when the impeccable plugin is not installed. It provides the core UI quality framework as a standalone fallback.

## When to Use
Invoke when building UI components, reviewing design quality, or running quality passes on any frontend work. This is the bundled fallback for `impeccable:*` skills.

## Quality Pass Framework

### Polish Pass (replaces impeccable:polish)
Run this check before reporting DONE on any UI component:

**Alignment**
- All elements align to an invisible grid (4px or 8px base unit)
- Text baselines align across columns
- No element appears "floated" without visual anchor

**Spacing**
- Consistent spacing scale: 4, 8, 12, 16, 24, 32, 48px
- Padding inside containers is consistent (don't mix 12px and 14px)
- Visual breathing room between sections (min 24px separation)

**Consistency**
- Same component looks identical across all instances
- Interactive states (hover, focus, active, disabled) all defined
- Font sizes follow defined type scale

**Visual Hierarchy**
- Clear primary action per screen
- Secondary actions visually subordinate
- Destructive actions styled with caution (red, confirmation)

### Critique Pass (replaces impeccable:critique)
Honest self-evaluation — answer each question:

1. Does the layout communicate the hierarchy of information?
2. Would a first-time user understand what to do without instructions?
3. Does the visual design feel intentional or accidental?
4. Is there a clear visual center of gravity on each screen?
5. Do the animations/transitions serve the user or distract?

If any answer is "no" or "unsure" — fix before proceeding.

### Harden Pass (replaces impeccable:harden)
Verify all states exist and are handled:

| State | Required Elements |
|-------|-----------------|
| Loading | Skeleton or spinner, not blank screen |
| Empty | Illustration or message + CTA, not blank |
| Error | Clear message, not technical jargon, retry action |
| Success | Confirmation, clear next action |
| Disabled | Visually distinct, not just opacity:0.5 |

### Animation Guidelines (replaces impeccable:animate)
- Entrance: fade-in + translate (8-12px) over 200-300ms ease-out
- Exit: fade-out over 150-200ms ease-in
- Hover: 150ms transition on color/shadow
- Page transitions: 250ms ease-in-out
- Never animate layout properties (width/height) — use transform instead
- Reduced motion: respect `prefers-reduced-motion` media query

## Accessibility Requirements
- Color contrast: WCAG AA minimum (4.5:1 for normal text, 3:1 for large)
- All interactive elements: visible focus state (not just outline:none)
- Keyboard navigation: tab order logical, all actions keyboard-accessible
- Screen readers: meaningful alt text, aria-label on icon buttons
- Touch targets: min 44x44px on mobile


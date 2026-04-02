---
name: solo-dev:set-autonomy
description: Interactively configure which decisions are autonomous vs. require user approval. Edits .solo-dev/config.local.md.
argument-hint: "[optional: 'show' to display current settings]"
allowed-tools: Read, Write, Edit
---

Configure the autonomy levels for each decision type in the development workflow.

## Your Role
Present current settings clearly, ask what user wants to change, apply changes to .solo-dev/config.local.md.

## Process

### If argument is "show" or no argument:
Read .solo-dev/config.local.md and display current settings:

```
=== solo-dev: Autonomy Settings ===

Decision Type              | Current Setting
---------------------------|----------------
tech_stack_selection       | always-ask
boilerplate_generation     | always-auto
research_synthesis         | threshold:0.8
design_decisions           | always-ask
implementation             | always-auto
code_review_fixes          | threshold:0.9
deployment_config          | always-ask

Token Budget: {mode} ({details})
API Contracts: {enabled/disabled} ({mode})

To change: /solo-dev:set-autonomy
```

### Interactive configuration:

Show each decision type with its current value. Ask user what they want to change.

Explain each option:
- `always-auto`: plugin decides and acts without asking you
- `always-ask`: plugin always pauses and asks before proceeding
- `threshold:N`: plugin checks confidence — if ≥ N acts autonomously, else asks you

Common presets to offer:
- **Full auto**: all → always-auto (great for prototype/exploration)
- **Full control**: all → always-ask (careful, thorough mode)
- **Balanced** (default): mix as configured
- **Custom**: user chooses each

Also configure:
- Token budget mode (fixed / subscription / disabled)
- API contract documentation (enabled/disabled, markdown/custom)

Apply changes to .solo-dev/config.local.md and confirm.

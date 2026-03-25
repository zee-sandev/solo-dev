---
name: go
description: "solo-dev launcher — interactive menu for all commands. Type /go when you can't remember the exact command name or flags."
argument-hint: "[optional: command name or number from menu]"
allowed-tools: Read, Write, Edit, Bash, WebSearch, WebFetch
---

Show the solo-dev command menu and launch the chosen command.

## Your Role

Display a clean, scannable menu of all solo-dev commands with their key options. If the user already passed an argument matching a command name or number, skip the menu and launch directly.

## Step 1: Read current state

Read `.solo-dev/state.json` (if it exists). Use this to:
- Show the current feature and phase in the menu header
- Mark the most relevant next action with `→`

If state file doesn't exist, show onboarding-first menu layout.

## Step 2: Display the menu

Format:

```
╭─ solo-dev ──────────────────────────────────────────╮
│  Project: {project-name}  Phase: {phase}            │
│  Feature: {current-feature-name}                    │
╰─────────────────────────────────────────────────────╯

  BUILD
  1  next-feature          Build next roadmap feature
       --auto              Continue features without re-prompting
       --overnight --max N Run N features unattended
       --spike             30min feasibility check only
       --experiment        60min MVP only
→ 2  resume               Resume from paused/escalated state

  PLAN
  3  start-from-idea       Turn idea → validated roadmap
  4  init                  Set up project (new / existing / template)
  5  sprint                Plan sprint from roadmap
  6  decompose <id>        Break large feature into sub-features

  INSPECT
  7  status                Project dashboard
  8  rollback <id>         Revert a feature (git + state + memory)
  9  showcase              Compile feature demo videos

  CONSULT
  10 consult <agent>       Ask any agent a question (no init needed)
  11 handoff               Turn this conversation into a build
  12 set-autonomy          Configure how much Claude decides alone
  13 evolve                Improve agent strategies from past data
  14 migrate               Update project to current plugin version

Type a number, command name, or paste the full command:
```

Rules:
- The `→` arrow marks the most logical next action based on state
- If state is mid-feature (ESCALATED, BLOCKED, mid-phase): mark `resume`
- If no state file: mark `start-from-idea` or `init`
- If state is READY/COMPLETE: mark `next-feature`
- If argument was already provided: match it to a number/name and launch immediately without showing menu

## Step 3: Handle response

After the user responds:

- **Number (e.g. `1`)** → launch that command, ask for any required arguments
- **Number + args (e.g. `1 --auto`)** → launch with those flags
- **Command name (e.g. `next-feature`)** → launch it
- **Full command (e.g. `next-feature --overnight --max 5`)** → execute directly
- **`?` or `help`** → show extended help for a command: usage, flags, examples
- **`q` or `exit`** → cancel, do nothing

## Extended help format (when user types `? 1` or `help next-feature`)

```
next-feature — Build next roadmap feature
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Usage:
  next-feature                    Pick next QUEUED feature automatically
  next-feature <feature-id>       Run a specific feature by ID
  next-feature --auto             Run features back-to-back (checkpoint each)
  next-feature --overnight        Unattended run, auto-proceed checkpoints
  next-feature --overnight --max 5  Cap overnight run at 5 features
  next-feature --spike            30min feasibility check, no implementation
  next-feature --experiment       60min MVP, deployable to staging

When to use which:
  --auto      Daytime. You're watching but don't want to re-type the command.
  --overnight Sleep time. Safe guardrails, skips XL features, no push.
  --spike     Uncertain idea. Validate before committing to full lifecycle.
```

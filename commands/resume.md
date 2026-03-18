---
name: resume
description: Resume from an escalation, paused state, or human decision point. Use when the system is waiting for your input or after you've made a decision on an escalated conflict.
argument-hint: "[optional: your decision — e.g., 'A' or 'Use option B with WebSocket']"
allowed-tools: Read, Write, Edit, Bash
---

Resume the development workflow from wherever it was paused. Read the current state and pending escalation, then continue.

## Your Role
Read the current state, understand what decision is needed, present context to user if needed, then resume the workflow from the correct phase.

## Process

### Step 1: Check current state
Read .claude/solo-dev-state.json.

Look for:
- blocked_since → indicates a blocked state
- phase containing ESCALATED → waiting for human decision
- agents_status with BLOCKED or NEEDS_CLARIFICATION

Also check: docs/agents/memory/escalations.md (last entry)

Also read docs/yaml/features.yaml (if exists) for current feature status and dependency state.

### Step 2: Present pending decision (if no argument provided)

If there is a pending escalation or decision, show the CONFLICT_BRIEF or escalation context in full.

If argument was provided: use it as the user's decision and proceed immediately.

### Step 3: Resume from correct phase

**If ESCALATED (loop exceeded max retries):**
- Record user decision in decisions.md
- Resume the loop from the user's chosen option
- Clear escalation from escalations.md (mark RESOLVED)

**If BLOCKED (dependency missing):**
- Check if blocker is now resolved
- If resolved: resume Phase 0 of blocked feature
- If still blocked: report to user

**If NEEDS_CLARIFICATION (agent asked a question):**
- Present the agent's question
- Get user answer
- Resume agent with the answer

**If mid-feature (any active phase):**
- Read phase from state
- Resume from that exact phase
- Spawn the appropriate agents

### Phase Resume Map:
```
MARKET_VALIDATION    → spawn market-validator with feature spec
DESIGN_LOOP          → spawn R1+R2+R3 or persona-validator (check round)
IMPLEMENTATION       → check agents_status, re-spawn incomplete agents
CODE_REVIEW          → spawn code-reviewer with changed files
QA_SECURITY          → spawn qa-validator + security-reviewer
BUSINESS_VALIDATION  → spawn business-validator
FINAL_ACCEPTANCE     → spawn persona-validator with implementation
DEMO_GENERATION      → spawn test-agent for Playwright + demo.md
```

Print: "Resuming: {feature-name} at phase {phase} round {round}"

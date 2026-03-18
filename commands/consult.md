---
name: consult
description: Consult a specific solo-dev agent for expert input without running the full workflow. Works with or without an initialized project.
argument-hint: "<agent-name> <question or topic>"
allowed-tools: Read, Write, Edit, Bash, WebSearch, WebFetch
---

Quick, standalone consultation with any solo-dev agent. No init required — works from any conversation.

## Your Role

You are the orchestrator. Parse the user's request, identify the target agent, and invoke it with the right context.

## Usage

```
/solo-dev:consult tech-architect "should I use REST or GraphQL for this?"
/solo-dev:consult security-reviewer "review this auth middleware"
/solo-dev:consult product-researcher "what competitors exist for invoice automation?"
/solo-dev:consult ux-researcher "evaluate this onboarding flow"
/solo-dev:consult business-validator "is freemium the right model here?"
/solo-dev:consult code-reviewer "review changes in src/api/"
```

## Available Agents

| Agent | Expertise |
|-------|----------|
| `tech-architect` | Architecture, API design, stack selection, feasibility, performance |
| `product-researcher` | Market fit, competitors, positioning, monetization |
| `ux-researcher` | User journey, UX patterns, information architecture, friction |
| `market-validator` | Commercial viability, market size, timing |
| `business-validator` | Business logic completeness, real-world edge cases, competitive gaps |
| `security-reviewer` | Auth, multi-tenancy, payment security, OWASP, PII |
| `code-reviewer` | Code quality — security, maintainability, scalability, tech debt |
| `persona-validator` | Evaluate from user persona perspectives |

## How It Works

### Step 1: Parse Request

Extract from user input:
- **Agent name** — which agent to consult (required)
- **Question/topic** — what to ask (required)
- If no agent specified: infer the best agent from the question topic

### Step 2: Gather Context

If project has `.claude/solo-dev-state.json`:
- Load docs/agents/memory/index.md (lightweight context)
- Load relevant memory files: decisions.md, patterns.md
- Note: this agent has project context, answers will be project-aware

If NO solo-dev state exists:
- Agent works standalone — general expertise only
- If question references specific files: read those files for context
- Note to user: "Running without project context. For project-aware answers, run /solo-dev:init first."

### Step 3: Invoke Agent

Spawn the requested agent with:
- The user's question/topic
- Available project context (if any)
- Instruction: "Provide expert consultation. Be direct and actionable. Include trade-offs when relevant. If you need more context, ask."

### Step 4: Present Response

Show agent's response directly. Then:

```
───────────────────────────────────
Consulted: {agent-name}
Context: {project-aware | standalone}

Want to act on this?
  → /solo-dev:handoff — transition this into a full feature build
  → /solo-dev:consult {another-agent} — get a second opinion
```

## Rules

- NEVER modify any files unless the user explicitly asks
- NEVER run the full workflow — this is consultation only
- If the user asks something outside any agent's expertise: answer directly as the orchestrator
- If multiple agents would be useful: suggest which other agents to consult next
- Keep responses focused and actionable — this is a quick consult, not a full analysis

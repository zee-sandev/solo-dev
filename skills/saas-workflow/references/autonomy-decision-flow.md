# Autonomy Decision Flow

## Config Location
`.claude/solo-dev.local.md` — autonomy section

## Decision Logic

```
READ autonomy config for operation_type
  → "always-auto"     → proceed without asking
  → "always-ask"      → pause and show user a decision prompt
  → "threshold:N"     → check confidence score
      confidence >= N → proceed
      confidence < N  → pause and ask
  → not set           → default: always-ask
```

## Default Autonomy per Operation Type
| Operation | Default |
|-----------|---------|
| tech_stack_selection | always-ask |
| boilerplate_generation | always-auto |
| research_synthesis | threshold:0.8 |
| design_decisions | always-ask |
| implementation | always-auto |
| code_review_fixes | threshold:0.9 |
| deployment_config | always-ask |
| feature_scope_change | always-ask |

## When to Ask User (always-ask / low confidence)

Present a decision prompt:
```
DECISION REQUIRED: {operation description}

Context: {1-2 sentences on what is happening}
Recommendation: {what the agent suggests and why}
Confidence: {N}% based on {evidence}

Options:
A) {recommended option}
B) {alternative option}
C) Custom (describe below)

→ Your choice:
```

Log the decision and choice to docs/agents/memory/decisions.md.

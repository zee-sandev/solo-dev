# Configuration

All configuration lives in `.claude/solo-dev.local.md` in your project root.

---

## Autonomy

Control how much solo-dev asks vs. decides automatically.

```yaml
autonomy:
  tech_stack_selection: always-ask
  boilerplate_generation: always-auto
  research_synthesis: threshold:0.8
  design_decisions: always-ask
  implementation: always-auto
  code_review_fixes: threshold:0.9
  deployment_config: always-ask
```

### Values

| Value | Behavior |
|-------|---------|
| `always-auto` | Proceed without asking |
| `always-ask` | Prompt user every time |
| `threshold:N` | Auto if agent confidence >= N, else ask (N = 0.0 to 1.0) |

### Changing at Runtime

```
/solo-dev:set-autonomy
```

Interactive command to view and change settings. Changes are saved to `.claude/solo-dev.local.md`.

---

## Token Budget

Track and optionally limit token usage per feature.

```yaml
token_budget:
  mode: "disabled"    # "fixed" | "subscription" | "disabled"

  fixed:
    per_feature: 50000      # Hard cap per feature
    warning_threshold: 0.8  # Warn at 80% usage

  subscription:
    track_usage: true       # Track but don't cap
    warn_inefficiency: true # Alert on >3x average usage
    auto_compress: true     # Auto-compress context at 80%
    stall_detection: true   # Detect agent loops with no diff
```

### Modes

| Mode | Behavior |
|------|---------|
| `fixed` | Hard stop at limit. Warn at 80%. Pause + ask user at 100%. |
| `subscription` | No hard stop. Warn if feature uses >3x average. Auto-compress at context 80%. Detect stalls. |
| `disabled` | No tracking, no limits. |

---

## API Contract Auto-Documentation

Automatically generate API docs when `backend-agent` defines endpoints.

```yaml
api_contracts:
  enabled: true
  output:
    mode: "markdown"      # "markdown" | "custom"
    markdown:
      path: "docs/contracts"
    custom:
      prompt: |
        # Define your own documentation target:
        # "Add to docs/openapi.yaml under /paths"
        # "Update Notion API reference page via MCP"
        # "Write MDX file to src/docs/{endpoint-name}.mdx"
```

### Markdown Mode

Generates one file per feature: `docs/contracts/{feature}-api.md`

### Custom Mode

Provide a prompt describing where and how to write API docs. Supports any format.

---

## Foundation Settings

For projects initialized from a template (Foundation Mode).

```yaml
foundation:
  delegate_agents: true    # Use template's agents for implementation
  replace_examples: true   # Auto-replace example code during feature build
  final_cleanup: true      # Prompt to remove unused examples after roadmap complete
```

| Setting | Default | Behavior |
|---------|---------|---------|
| `delegate_agents` | `true` | Delegate implementation to template's agents when available. Set `false` to always use solo-dev agents. |
| `replace_examples` | `true` | Auto-replace tagged example code when building overlapping features. Set `false` to leave examples untouched. |
| `final_cleanup` | `true` | After all roadmap features complete, prompt to remove remaining unused examples. Set `false` to skip. |

These settings are only relevant when `onboarding_type` is `"foundation"` in the state file.

---

## Project State

State is automatically managed in `.claude/solo-dev-state.json`:

```json
{
  "project": "my-saas",
  "phase": "QA_LOOP",
  "current_feature": "A1_feature_id",
  "round": 2,
  "blocked_since": null,
  "agents_status": {
    "qa-validator": "IN_PROGRESS",
    "code-reviewer": "APPROVED"
  },
  "repomix_pack_id": "abc123",
  "stack": "nextjs",
  "last_updated": "2026-03-18T10:30:00Z"
}
```

The SessionStart hook reads this file and resumes from the exact phase/round automatically.

---

## Full Configuration Template

```yaml
---
# solo-dev Configuration

autonomy:
  tech_stack_selection: always-ask
  boilerplate_generation: always-auto
  research_synthesis: threshold:0.8
  design_decisions: always-ask
  implementation: always-auto
  code_review_fixes: threshold:0.9
  deployment_config: always-ask

token_budget:
  mode: "disabled"
  fixed:
    per_feature: 50000
    warning_threshold: 0.8

api_contracts:
  enabled: true
  output:
    mode: "markdown"
    markdown:
      path: "docs/contracts"

foundation:
  delegate_agents: true
  replace_examples: true
  final_cleanup: true
---
```

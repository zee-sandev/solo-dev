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

## Gap Check (Monorepo)

Control cross-package completeness validation for monorepo projects.

```yaml
gap_check:
  enabled: true       # set false to skip all gap checks
  min_rounds: 1        # minimum gap checks per feature (1-5)
  max_rounds: 3        # maximum before escalation (1-10)
```

### Settings

| Setting | Default | Range | Behavior |
|---------|---------|-------|---------|
| `enabled` | `true` | `true` / `false` | Master switch. Set `false` to disable all gap checks (useful for single-package projects). |
| `min_rounds` | `1` | 1-5 | Minimum gap checks per feature. At `1`, only post-implementation check runs. At `3`, forces re-check after CR and QA fixes too. |
| `max_rounds` | `3` | 1-10 | Maximum total gap check rounds before escalating to human. Counter is cumulative across all trigger points. |

### Trigger Points

Gap-checker runs at up to 3 points per feature. The round counter is shared across all triggers:

| Trigger | When | Why |
|---------|------|-----|
| **Post-Implementation** | After all impl agents DONE, before code review | Mandatory first check — catches missing packages |
| **Post-CR Fix** | After code-reviewer REJECT → agents fix | Catches accidental package removal during CR fixes |
| **Post-QA Fix** | After QA FAIL → agents fix | Catches broken cross-package completeness during QA fixes |

### Example Configurations

```yaml
# Conservative (check everything)
gap_check:
  enabled: true
  min_rounds: 3    # force all 3 trigger points
  max_rounds: 5    # allow more retries

# Minimal (post-impl only)
gap_check:
  enabled: true
  min_rounds: 1
  max_rounds: 2

# Disabled (single-package or non-monorepo)
gap_check:
  enabled: false
```

### Skip Conditions

Gap checks are automatically skipped when:
- No `workspace` field in `solo-dev-state.json` (not a monorepo)
- Impact map lists only 1 package (no cross-package gap possible)
- `gap_check.enabled: false`

---

## Smoke Test

Runtime verification after implementation — builds the project, starts the dev server, and tests critical endpoints before code review.

```yaml
smoke_test:
  enabled: true
  timeout: 30
  kill_port: false
  retry_server: 1
  error_paths: true
  max_rounds: 3
```

### Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `smoke_test.enabled` | `true` | Master switch |
| `smoke_test.timeout` | `30` | Seconds to wait for server start |
| `smoke_test.kill_port` | `false` | Auto-kill dev server on busy port (only known dev servers) |
| `smoke_test.retry_server` | `1` | Retries if server fails to start |
| `smoke_test.error_paths` | `true` | Test auth fail, invalid input, 404 |
| `smoke_test.max_rounds` | `3` | Max fix rounds before escalation |

---

## Drift Detection

Detects spec, contract, memory, and pattern drift across multiple pipeline phases.

```yaml
drift_detection:
  enabled: true
  spec_clarity: true
  contract_checksum: true
  memory_check: true
  pattern_proof: true
  vague_keywords: [fast, easy, secure, good, scalable, simple, clean]
```

### Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `drift_detection.enabled` | `true` | Master switch |
| `drift_detection.spec_clarity` | `true` | Check spec before implementation |
| `drift_detection.contract_checksum` | `true` | Track contract changes during impl |
| `drift_detection.memory_check` | `true` | Check stale patterns at session start |
| `drift_detection.pattern_proof` | `true` | Require proof before promoting patterns |
| `drift_detection.vague_keywords` | `[fast, easy, secure, good, scalable, simple, clean]` | Words flagged as vague |

---

## QA Runtime

Controls runtime API and E2E browser test execution during the QA phase.

```yaml
qa_runtime:
  api:
    enabled: true
    timeout_per_test: 10
    max_total_timeout: 300
  e2e:
    enabled: true
    framework: playwright
    browser: chromium
    headless: true
    timeout_per_test: 30
    max_total_timeout: 600
    retry_flaky: 1
```

### Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `qa_runtime.api.enabled` | `true` | Enable API runtime tests |
| `qa_runtime.api.timeout_per_test` | `10` | Seconds per test |
| `qa_runtime.api.max_total_timeout` | `300` | Total seconds for all API tests |
| `qa_runtime.e2e.enabled` | `true` | Enable E2E browser tests |
| `qa_runtime.e2e.framework` | `playwright` | E2E framework |
| `qa_runtime.e2e.browser` | `chromium` | Browser for E2E |
| `qa_runtime.e2e.headless` | `true` | Run headless |
| `qa_runtime.e2e.timeout_per_test` | `30` | Seconds per E2E test |
| `qa_runtime.e2e.max_total_timeout` | `600` | Total seconds for all E2E tests |
| `qa_runtime.e2e.retry_flaky` | `1` | Retry count for flaky tests |

---

## Runtime

Auto-detected by `init` from your project's stack. Override for custom frameworks.

```yaml
runtime:
  build_command: "npm run build"
  dev_command: "npm run dev"
  dev_port: 3000
  health_endpoint: "/"
```

| Setting | Default | Description |
|---------|---------|-------------|
| `runtime.build_command` | Auto-detected | Build command for smoke-tester. If empty, smoke-tester will prompt. |
| `runtime.dev_command` | Auto-detected | Dev server start command. If empty, smoke-tester will prompt. |
| `runtime.dev_port` | `3000` | Port the dev server listens on |
| `runtime.health_endpoint` | `"/"` | Endpoint to poll for server readiness |

**Auto-detection sources:**
- `package.json` → reads `scripts.build` and `scripts.dev`
- `Makefile` → looks for `build:` and `dev:` targets
- `go.mod` → defaults to `go build ./...` / `go run .`
- `Cargo.toml` → defaults to `cargo build` / `cargo run`
- `requirements.txt` / `pyproject.toml` → defaults to Python commands
- Port detected from scripts flags (`--port`, `-p`) or `.env` files

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
  "workspace": {
    "type": "pnpm",
    "packages": [
      {"name": "api", "path": "apps/api", "type": "app"},
      {"name": "web", "path": "apps/web", "type": "app"}
    ]
  },
  "gap_check_rounds": 0,
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

gap_check:
  enabled: true
  min_rounds: 1
  max_rounds: 3

smoke_test:
  enabled: true
  timeout: 30
  kill_port: false
  retry_server: 1
  error_paths: true
  max_rounds: 3

drift_detection:
  enabled: true
  spec_clarity: true
  contract_checksum: true
  memory_check: true
  pattern_proof: true
  vague_keywords: [fast, easy, secure, good, scalable, simple, clean]

qa_runtime:
  api:
    enabled: true
    timeout_per_test: 10
    max_total_timeout: 300
  e2e:
    enabled: true
    framework: playwright
    browser: chromium
    headless: true
    timeout_per_test: 30
    max_total_timeout: 600
    retry_flaky: 1

runtime:
  build_command: ""
  dev_command: ""
  dev_port: 3000
  health_endpoint: "/"

foundation:
  delegate_agents: true
  replace_examples: true
  final_cleanup: true
---
```

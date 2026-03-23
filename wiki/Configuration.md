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
  demo_freshness: true
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
| `drift_detection.demo_freshness` | `true` | Check if existing demos became stale after new features ship |
| `drift_detection.vague_keywords` | `[fast, easy, secure, good, scalable, simple, clean]` | Words flagged as vague |

---

## Self-Refinement

Controls internal quality improvement loops. Agents refine their own outputs before presenting to external reviewers or downstream agents.

```yaml
self_refinement:
  enabled: true
  intensity: standard        # light | standard | thorough
  max_rounds: 3
```

### Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `self_refinement.enabled` | `true` | Master switch |
| `self_refinement.intensity` | `standard` | Refinement depth (see below) |
| `self_refinement.max_rounds` | `3` | Maximum internal refinement rounds per output |

### Intensity Levels

| Intensity | Method | Rounds | Effect on Design Loop | S Effort |
|-----------|--------|--------|----------------------|----------|
| `light` | Self-critique checklist only | 1 | Design loop max: 3 (unchanged) | Skip refinement |
| `standard` | Cross-agent critique for critical outputs (spec, contracts), self-critique for rest | 2 | Design loop max: 2 (reduced) | Self-critique only (1 round) |
| `thorough` | Cross-agent critique for all critical outputs | 3 | Design loop max: 2 (reduced) | Self-critique only (1 round) |

### What Gets Refined

| Output | Intensity: light | Intensity: standard | Intensity: thorough |
|--------|-----------------|--------------------|--------------------|
| Design spec (R1+R2+R3) | Self-critique | Cross-agent (R agents critique each other) | Cross-agent |
| API contracts | Self-critique | Cross-agent (tech-architect reviews) | Cross-agent |
| Market analysis | Self-critique | Self-critique | Self-critique |
| Roadmap | — | Self-critique | Cross-agent |
| Demo scripts | — | — | — |

---

## Design Profile

Visual design preferences collected during `init`. Ensures all features ship with consistent, user-approved visual identity.

```yaml
design_profile:
  style: "modern-minimal"
  color_scheme: "neutral-warm"
  brand_colors:
    primary: "#2563EB"
    secondary: "#10B981"
    accent: "#F59E0B"
  typography: "clean-sans"
  density: "comfortable"
  border_radius: "rounded"
  animation: "subtle"
  dark_mode: "both"
  reference_sites: []
  navigation:
    pattern: "sidebar-collapsible"
    menu_structure: "feature-grouped"
    mobile_adaptation: "slide-over"
    breadcrumbs: true
    role_based_menu: true
    notification_badges: true
    search_spotlight: true
```

### Style Presets

| Preset | Description |
|--------|-------------|
| `modern-minimal` | Clean, airy, generous whitespace, rounded corners, subtle shadows |
| `corporate` | Structured, sharp edges, formal typography, dense information |
| `bold-creative` | Vibrant colors, expressive typography, gradient accents |
| `editorial` | Typography-focused, content-first, elegant serif headings |
| `brutalist` | Raw, high-contrast, monospace, bold borders |
| `custom` | User-defined via reference sites or manual specification |

### Navigation Settings

| Setting | Values | Description |
|---------|--------|-------------|
| `navigation.pattern` | `sidebar` / `top-nav-tabs` / `sidebar-collapsible` / `top-nav-side-sub` / `bottom-tab-bar` | Navigation layout pattern |
| `navigation.menu_structure` | `feature-grouped` / `workflow-ordered` / `flat-search` | How menu items are organized |
| `navigation.mobile_adaptation` | Auto-resolved from pattern | Mobile responsive behavior |
| `navigation.breadcrumbs` | `true` / `false` | Show breadcrumb navigation |
| `navigation.role_based_menu` | `true` / `false` | Filter menu items by user role |
| `navigation.notification_badges` | `true` / `false` | Show unread counts on menu items |
| `navigation.search_spotlight` | `true` / `false` | cmd+K global search overlay |

### Other Settings

| Setting | Default | Values | Description |
|---------|---------|--------|-------------|
| `style` | — | See presets above | Overall visual aesthetic |
| `color_scheme` | — | `neutral-warm` / `ocean` / `forest` / `monochrome` / `brand-colors` | Color palette |
| `brand_colors.*` | — | Hex colors | Custom brand colors (when color_scheme is `brand-colors`) |
| `typography` | `clean-sans` | `clean-sans` / `classic-serif` / `mixed` / `system` | Typography style |
| `density` | `comfortable` | `compact` / `comfortable` / `spacious` | UI density (affects spacing) |
| `border_radius` | `rounded` | `sharp` / `slightly-rounded` / `rounded` / `pill` | Corner radius style |
| `animation` | `subtle` | `none` / `subtle` / `expressive` | Animation intensity |
| `dark_mode` | `both` | `light-only` / `dark-only` / `both` | Dark mode support |
| `reference_sites` | `[]` | URLs | Sites the user likes the style of |

### How It Works

1. **During `init`:** Interactive visual preview on localhost — user sees rendered examples and picks choices
2. **During design (ux-researcher):** Reads `design_profile` → writes Visual Direction section in spec
3. **During implementation (ui-agent):** Generates design tokens from profile → enforces token usage
4. **During implementation (frontend-agent):** Implements navigation pattern from profile
5. **During Visual QA (Phase 2.8):** Verifies implementation matches profile

---

## Visual QA

Runtime visual quality verification after implementation — captures screenshots, checks design token usage, responsive behavior, and navigation consistency.

```yaml
visual_qa:
  enabled: true
  screenshot_states: ["empty", "loaded", "error", "mobile", "desktop"]
  checklist:
    design_tokens: true
    responsive: true
    dark_mode: true
    spacing_consistency: true
    typography_hierarchy: true
    interactive_states: true
    loading_empty_error: true
  user_preview: false
```

### Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `visual_qa.enabled` | `true` | Master switch |
| `visual_qa.screenshot_states` | `["empty", "loaded", "error", "mobile", "desktop"]` | States to capture |
| `visual_qa.checklist.design_tokens` | `true` | Verify no hardcoded colors/sizes |
| `visual_qa.checklist.responsive` | `true` | Check mobile/tablet/desktop |
| `visual_qa.checklist.dark_mode` | `true` | Check dark mode (if design_profile.dark_mode is "both") |
| `visual_qa.checklist.spacing_consistency` | `true` | Verify consistent spacing scale |
| `visual_qa.checklist.typography_hierarchy` | `true` | Verify heading/font hierarchy |
| `visual_qa.checklist.interactive_states` | `true` | Verify hover, focus, active, disabled |
| `visual_qa.checklist.loading_empty_error` | `true` | Verify all states exist |
| `visual_qa.user_preview` | `false` | Show screenshots to user before code review |

### Skip Conditions

Visual QA is automatically skipped when:
- `design_profile` is not configured
- `visual_qa.enabled: false`
- Feature effort is S (fast-track)
- Feature has no UI (API-only)

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
  demo_freshness: true
  vague_keywords: [fast, easy, secure, good, scalable, simple, clean]

self_refinement:
  enabled: true
  intensity: standard
  max_rounds: 3

design_profile:
  style: ""
  color_scheme: ""
  brand_colors:
    primary: ""
    secondary: ""
    accent: ""
  typography: "clean-sans"
  density: "comfortable"
  border_radius: "rounded"
  animation: "subtle"
  dark_mode: "both"
  reference_sites: []
  navigation:
    pattern: ""
    menu_structure: ""
    mobile_adaptation: ""
    breadcrumbs: true
    role_based_menu: false
    notification_badges: true
    search_spotlight: false

visual_qa:
  enabled: true
  screenshot_states: ["empty", "loaded", "error", "mobile", "desktop"]
  checklist:
    design_tokens: true
    responsive: true
    dark_mode: true
    spacing_consistency: true
    typography_hierarchy: true
    interactive_states: true
    loading_empty_error: true
  user_preview: false

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

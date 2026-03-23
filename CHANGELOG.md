# Changelog

All notable changes to this project will be documented in this file.

## [2026-03-23]

### Added

- New gap-checker agent validates cross-package implementation completeness in monorepo projects
- Monorepo workspace detection during project initialization
- Impact Map requirement in tech-architect specs for multi-package features
- Smoke-tester agent for runtime verification — builds project, starts server, tests endpoints against contracts
- Drift-detector agent for contract/memory/spec drift detection across 4 modes
- Phase 2.6 (Smoke Test) and Phase 2.7 (Contract Drift Check) in feature lifecycle
- Configuration options for smoke_test, drift_detection, and qa_runtime
- Visual quality system — design profile collection during init with live localhost preview, design token enforcement, and Phase 2.8 Visual QA gate
- Navigation/menu pattern selection during init — sidebar, top-nav, collapsible, role-based menus, breadcrumbs, cmd+K search
- Visual Direction section in ux-researcher output — translates design profile into concrete per-feature visual decisions
- Intelligent demo system — 3-level demos (clips, journeys, showcase), 7 demo types, demo staleness detection, 3 audience layers
- Self-refinement loops — cross-agent critique for critical outputs, self-critique checklists, 3 intensity levels (light/standard/thorough)
- Smart skill selection — stack-aware skill mapping per agent and orchestrator skill discovery before implementation

### Changed

- Workflow adds Phase 2.5 (Gap Check) between implementation and code review for monorepo projects
- QA validator enhanced with API runtime testing and E2E Playwright browser testing
- Gap-checker enhanced with content validation for all projects (not just monorepo)
- Code-reviewer enhanced with import chain check on re-review cycles
- Memory-curator requires proof (CR+QA pass) before promoting patterns
- Gap-checker, smoke-tester, and code-reviewer are now protocol-agnostic — support REST, GraphQL, gRPC, oRPC, tRPC, WebSocket
- Showcase command rewritten for journey demos and role-based capability views

## [2026-03-19]

### Added

- Trend prediction and disruption risk analysis in product research
- Compliance checklist (GDPR, data retention, PII) in business and data validation
- Build-vs-buy analysis as first step in technical architecture
- Post-ship user feedback template for measuring feature adoption

### Changed

- Market validator upgraded from advisory to 3-tier gatekeeper (VIABLE/HIGH_RISK/BLOCKER)
- Business validator now runs parallel with implementation for earlier feedback
- Orchestrator enhanced with DAG-based parallel dispatching and adaptive phase ordering
- Security reviewer is now sole owner of all security checks across the system
- All implementation agents now report structured completion status (DONE/BLOCKED/NEEDS_CLARIFICATION)
- Design loop reduced from 5 to 3 maximum rounds


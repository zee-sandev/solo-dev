# Changelog

All notable changes to this project will be documented in this file.

## [2026-03-23]

### Added

- New gap-checker agent validates cross-package implementation completeness in monorepo projects
- Monorepo workspace detection during project initialization
- Impact Map requirement in tech-architect specs for multi-package features

### Changed

- Workflow adds Phase 2.5 (Gap Check) between implementation and code review for monorepo projects

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


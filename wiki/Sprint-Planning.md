# Sprint Planning

Plan development sprints by selecting features from your roadmap.

## Quick Start

```
/solo-dev:sprint          # Start planning a new sprint
/solo-dev:sprint show     # View current active sprint
```

## How It Works

1. solo-dev reads your feature roadmap (`docs/yaml/features.yaml`)
2. Shows QUEUED features with dependencies resolved
3. Shows promotable backlog items
4. You select features for the sprint
5. Estimate effort per feature (S/M/L/XL)
6. Sprint saved to `docs/yaml/sprints.yaml`

## Sprint Lifecycle

| Status | Meaning |
|--------|---------|
| `planned` | Sprint defined, not yet started |
| `active` | Currently building features |
| `completed` | All sprint features shipped |

A sprint becomes `active` when you run `/solo-dev:next-feature` for a sprint feature.
A sprint becomes `completed` when all its features reach COMPLETE.

## Effort Estimates

| Size | Typical Scope |
|------|--------------|
| **S** | Single-layer change, clear spec |
| **M** | Multi-layer, moderate complexity |
| **L** | Full-stack feature, multiple agents |
| **XL** | Complex feature, consider decomposing |

Features estimated as XL may benefit from `/solo-dev:decompose` before building.

## Example

```
/solo-dev:sprint

=== solo-dev: Sprint Planning ===

Available features (QUEUED, dependencies met):
  1. [A2] Content Brief Generator     Priority: 1    Deps: A1 ✅
  2. [A3] Team Management             Priority: 2    Deps: none
  3. [B1] Advanced Analytics          Priority: 3    Deps: A2 ○ (NOT READY)

Select features for sprint (comma-separated): 1,2

Sprint Plan:
  [A2] Content Brief Generator    Effort: M
  [A3] Team Management            Effort: L
  Total: L

Sprint "Sprint 1" created. Run /solo-dev:next-feature to start.
```

## Data Storage

Sprint data lives in `docs/yaml/sprints.yaml` (YAML source of truth).
A readable view is generated at `docs/product/sprints.md`.

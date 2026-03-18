---
name: sprint
description: Plan a development sprint — select features, estimate effort, create sprint plan.
argument-hint: "[optional: 'show' to display current sprint]"
allowed-tools: Read, Write, Edit
---

Plan or view development sprints.

### Your Role
You are the orchestrator. Help the user plan sprints by selecting features from the roadmap.

### Process

#### If argument is "show":
1. Read `docs/yaml/sprints.yaml`
2. Find sprint with status "active" (or most recent "planned")
3. Read `docs/yaml/features.yaml` for feature statuses
4. Display:
```
=== solo-dev: Current Sprint ===

Sprint: {name} ({status})
Started: {date}

Features:
  [A1] Feature Name          Effort: S    COMPLETE
  [A2] Feature Name          Effort: M    IN_PROGRESS (Phase: DESIGN_LOOP)
  [A3] Feature Name          Effort: L    QUEUED

Progress: 1/3 features complete
```

#### If no argument (planning mode):
1. Read `docs/yaml/features.yaml` — filter features where `status == "QUEUED"`
2. Check dependencies: only show features where all `depends_on` feature IDs have `status == "COMPLETE"`
3. Read `docs/yaml/backlog.yaml` — show items that could be promoted to features
4. Read `docs/yaml/sprints.yaml` — get next sprint ID (S1, S2, etc.)

Present to user:
```
=== solo-dev: Sprint Planning ===

Available features (QUEUED, dependencies met):
  1. [A2] Feature Name          Priority: 1    Deps: A1
  2. [A3] Feature Name          Priority: 2    Deps: none
  3. [B1] Feature Name          Priority: 3    Deps: A2 (NOT READY)

Backlog items (can promote to features):
  4. [BL1] Item Name            Source: bv-suggestion
  5. [BL2] Item Name            Source: user

Select features for sprint (comma-separated numbers, e.g. 1,2):
```

Wait for user selection. Then for each selected feature, ask for effort estimate:
```
Effort estimate for [A2] Feature Name? (S/M/L/XL):
```

5. Create sprint entry in `docs/yaml/sprints.yaml`:
   - id: next sequential ID (S1, S2...)
   - name: "Sprint {N}" (or ask user for custom name)
   - status: "planned"
   - features: selected feature IDs
   - started_at: current date
   - estimated_effort: aggregate (use largest individual estimate)

6. Update each feature in `docs/yaml/features.yaml`: set `effort_estimate`

7. Regenerate markdown: `bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/yaml-to-markdown.sh docs/yaml/sprints.yaml` and `bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/yaml-to-markdown.sh docs/yaml/features.yaml`

8. If user selected a backlog item to promote:
   - Create feature entry in features.yaml from backlog item
   - Remove from backlog.yaml
   - Regenerate both markdown views

Print:
```
Sprint created: {name}
  Features: {N}
  Estimated effort: {aggregate}

  Run /solo-dev:next-feature to start building.
```

---
name: decompose
description: Break a large feature into smaller sub-features with dependency links. Useful after rollback or when a feature is too complex.
argument-hint: "<feature-id>"
allowed-tools: Read, Write, Edit, Bash
---

Break a large or complex feature into smaller, independently shippable sub-features.

### Your Role
Analyze the feature, propose a decomposition, and update the YAML indexes on approval.

### When To Use
- After a feature rollback (offered as option C by /solo-dev:rollback)
- When a feature fails multiple design or implementation rounds
- When the user realizes a feature is too large for a single cycle

### Process

1. **Parse argument** — require a feature-id. If missing, ask user.

2. **Read feature data:**
   - Read `docs/yaml/features.yaml` — find the target feature
   - Read `docs/yaml/specs.yaml` — check if a spec exists for this feature
   - If spec exists: read the spec file for detailed requirements
   - If no spec: use the feature name and value from features.yaml

3. **Analyze and propose decomposition:**
   - Break into 2-5 sub-features, each:
     - Independently shippable (can go through full 8-phase lifecycle alone)
     - Has clear scope boundaries
     - Has defined dependency relationships to sibling sub-features
   - Sub-feature IDs: `{original-id}.1`, `{original-id}.2`, etc.
   - First sub-feature should have no sibling dependencies (can start immediately)

4. **Present to user:**
```
=== solo-dev: Feature Decomposition ===

Original: [{id}] {name}
Status: {current status}
{If spec exists: "Spec: {spec path}"}

Proposed decomposition:

  1. [{id}.1] {sub-feature name}
     Scope: {what it covers}
     Deps: none (can start immediately)
     Effort: {S/M/L}

  2. [{id}.2] {sub-feature name}
     Scope: {what it covers}
     Deps: {id}.1
     Effort: {S/M/L}

  3. [{id}.3] {sub-feature name}
     Scope: {what it covers}
     Deps: {id}.1
     Effort: {S/M/L}

Approve? (Y/n/adjust)
```

5. **On approval:**
   - Update original feature in `features.yaml`: set `status: "DECOMPOSED"`
   - Add sub-features to `features.yaml`:
     - `parent_feature: "{original-id}"`
     - `source: "decompose"`
     - `status: "QUEUED"`
     - `depends_on` set per the proposed dependency chain
     - `blocks` updated to reflect what the original feature blocked
   - If original had a spec: create sub-specs in `docs/yaml/specs.yaml` pointing to new spec files
   - Write sub-feature spec drafts to `docs/specs/{sub-id}-draft.md`
   - Regenerate markdown views

6. **On "adjust":**
   - Ask what to change (add/remove/merge sub-features, change deps)
   - Re-present and ask again

7. **Print summary:**
```
Decomposition complete:
  [{id}] -> DECOMPOSED into {N} sub-features

  [{id}.1] {name}          QUEUED (ready to build)
  [{id}.2] {name}          QUEUED (depends on {id}.1)
  ...

  Sub-specs created: docs/specs/{id}.1-draft.md, ...

  Run /solo-dev:next-feature to start building [{id}.1].
```

### Rules
- ALWAYS update YAML files first, then regenerate markdown
- NEVER create more than 5 sub-features (decompose further if needed later)
- First sub-feature MUST have no sibling dependencies
- Preserve the original feature's `blocks` on the LAST sub-feature in the chain
- If the original feature was in a sprint (sprints.yaml): update the sprint to reference sub-features instead

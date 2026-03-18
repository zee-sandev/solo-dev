---
name: showcase
description: Compile all feature demos into a product showcase page with descriptions and demo links.
argument-hint: "[optional: 'html' for HTML output]"
allowed-tools: Read, Write, Bash
---

Generate a product showcase from all completed feature demos.

### Your Role
Read demo data from YAML indexes and compile into a single showcase page.

### Process
1. Read `docs/yaml/demos.yaml` — get all demo entries
2. Read `docs/yaml/features.yaml` — get feature context (name, value, completion date)
3. If no demos exist: tell user "No demos recorded yet. Complete features with /solo-dev:next-feature first."
4. For each demo (ordered by recorded_at):
   - Read the demo.md file at `doc_path` to extract "What is it?" and "Why it's useful" sections
5. Generate `docs/showcase/index.md` (create directory if needed)

### Output Format (docs/showcase/index.md)
```markdown
# {Project Name} — Product Showcase

> {N} features shipped

---

## {Feature Name}
{What is it — from demo.md}

**Why it's useful:**
{benefits list from demo.md}

[Watch demo](../demos/{feature-id}/demo.mp4) | [Full details](../demos/{feature-id}/demo.md)

---
(repeat for each feature)
```

If argument is `html`: generate `docs/showcase/index.html` with embedded video tags and styled layout instead of markdown.

### After Generation
```
Showcase generated: docs/showcase/index.md
  {N} features included
  View: open docs/showcase/index.md
```

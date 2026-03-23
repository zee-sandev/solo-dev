---
name: showcase
description: Compile all feature demos into a product showcase — timeline view with journeys, clips, and API demos grouped by sprint.
argument-hint: "[optional: 'html' for HTML output]"
allowed-tools: Read, Write, Bash, Glob
---

Generate a product showcase from all completed feature demos.

### Your Role
Read demo data from YAML indexes and compile into a comprehensive showcase with timeline view, journey highlights, and role-based perspectives.

### Process
1. Read `docs/yaml/demos.yaml` — get all demo entries (clips, journeys, API demos)
2. Read `docs/yaml/features.yaml` — get feature context (name, epic, sprint, completion date)
3. If no demos exist: tell user "No demos recorded yet. Complete features with /solo-dev:next-feature first."
4. Group demos by sprint (from features.yaml sprint field, or by recorded_at month)
5. Within each sprint, prioritize: journeys first (they tell the story), then clips, then API demos
6. For each demo: read its demo.md to extract "What is it?" and "Why it's useful"
7. Generate showcase output

### Output Format (docs/showcase/index.md)
```markdown
# {Project Name} — Product Showcase

> {N} features shipped across {M} sprints | {J} user journeys | {R} roles demonstrated

---

## Product Evolution

### Sprint 1: {Sprint Name} ({date range})
> "{1-sentence summary of what this sprint achieved}"

#### 🎬 Journey: {Journey Name}
{What this journey demonstrates — from journey.md}

**Roles:** {Owner, Member, Viewer}
**Features covered:** {A1, A2, A3}

[▶ Watch journey](../demos/journeys/{epic-id}/journey.webm) | [Step-by-step guide](../demos/journeys/{epic-id}/journey.md)

**Key moments:**
| Scene | Screenshot | Description |
|-------|-----------|-------------|
| {Scene 1} | ![](../demos/journeys/{epic-id}/screenshots/{step}.png) | {annotation text} |

#### 📎 {Feature Name} (clip)
{What is it — from demo.md}
[▶ Watch clip](../demos/clips/{feature-id}/clip.webm) | [Details](../demos/clips/{feature-id}/demo.md)

#### 🔌 {API Feature Name}
{What this API does — from api-demo.md}
[API documentation](../demos/api/{feature-id}/api-demo.md)

---

### Sprint 2: {Sprint Name} ({date range})
> "{summary} — builds on Sprint 1"
(repeat structure)

---

## By Role
What each user role can do across all features:

### Owner
- {capability 1} (from {feature})
- {capability 2} (from {feature})

### Member
- {capability 1} (from {feature})

### Viewer
- {capability 1} (from {feature})

---

## Demo Health
| Demo | Recorded | Status |
|------|----------|--------|
| {name} | {date} | ✅ Fresh / ⚠️ Stale (since {date}) |
```

### HTML Output
If argument is `html`: generate `docs/showcase/index.html` with:
- Responsive layout with sprint timeline
- Embedded `<video>` tags with poster images (first screenshot from each demo)
- Screenshot galleries per journey
- Role filter (show/hide demos by role)
- Collapsible sprint sections
- Stale demo indicators

### After Generation
```
Showcase generated: docs/showcase/index.md
  {N} features across {M} sprints
  {J} journey demos, {C} feature clips, {A} API demos
  {R} roles covered
  {S} stale demos (need re-recording)
  View: open docs/showcase/index.md
```

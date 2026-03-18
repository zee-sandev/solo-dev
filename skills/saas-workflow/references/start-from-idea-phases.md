# start-from-idea Phases (1–6)

## Phase 1: Idea Exploration
Ask clarifying questions ONE AT A TIME:
1. "Tell me about your idea — even a rough description works"
2. "Who has this problem? Describe your ideal first customer"
3. "Have you seen similar products? What's missing about them?"
4. "What would make someone pay for this vs. use a free alternative?"
5. "Any constraints? (timeline, budget, team size)"

Continue until clear picture of: problem, audience, differentiation, WTP, constraints.

**User action:** Confirm idea is correctly understood → Phase 2

## Phase 2: Market Reality Check
Spawn product-researcher with web search access.
Find: 3-5 real competitors, market size signals, "why now" timing factors.

Present findings. Ask: "Does this change how you see your idea? Any pivots?"

**User action:** Confirm or pivot → Phase 2b

## Phase 2b: Competitor Gap Analysis
Spawn product-researcher to search G2, Capterra, Reddit, App Store reviews per competitor.

Build:
- Feature gap matrix (what they have / what they lack)
- Top user complaints (opportunity areas)
- Market whitespace (unmet needs, emerging trends)

**User action:** Review gap analysis → Phase 3

## Phase 3: User Persona Generation
Spawn persona-validator to generate 2-3 personas from concept.

Each persona includes: role + company size + workflow, goals, budget range, top 3 pain points, behavioral patterns (technical/non-technical, power user/casual).

Save to docs/product/personas.md.

**User action:** Review and adjust personas → Phase 4

## Phase 4: Core Feature Definition
Spawn product-researcher + ux-researcher + tech-architect together.

Propose:
- MVP feature set (3-5 features validating core value)
- 2-3 competitive moat features (unique angle)
- Priority order: impact × effort matrix

**User action:** Confirm or adjust feature set → Phase 4b

## Phase 4b: AI Feature Enhancement
For each defined feature, generate 4-dimension suggestions:
- **Depth**: make the core feature deeper/better
- **Breadth**: expand what value it delivers
- **Differentiation**: angle competitors don't take
- **Quick wins**: low effort, high perceived value

User selects which suggestions to include → roadmap.
Unselected → backlog.md automatically.

**User action:** Select enhancements → Phase 4c

## Phase 4c: Idea Enhancement Suggestions
Big-picture product improvements:
- **Monetization**: pricing model improvements, upsell paths
- **Distribution**: viral loops, integrations, channels
- **Product moat**: lock-in, network effects, data advantages
- **Emerging opportunities**: 2025-2026 trends competitors haven't captured

User selects → roadmap. Unselected → backlog.md.

**User action:** Select enhancements → Phase 5

## Phase 5: Generate Roadmap Documents
Create all product docs:
- docs/product/idea-brief.md — concept summary
- docs/product/personas.md — user personas (if not already created)
- docs/product/competitive-analysis.md — gap matrix + weaknesses
- docs/product/feature-enhancements.md — AI suggestions per feature
- docs/product/idea-enhancements.md — big picture improvements
- docs/product/roadmap.md — feature roadmap with dependency graph
- docs/product/backlog.md — all unselected enhancements

**Roadmap format:**
```markdown
## Feature {ID}: {Feature Name}
**Priority:** P1 | P2 | P3
**Status:** PLANNED | IN_PROGRESS | COMPLETE | ROLLED_BACK
**depends_on:** [feature IDs] or []
**blocks:** [feature IDs] or []
**Summary:** {1-2 sentence description}
```

## Phase 6: User Approval
Present summary of what was created.

Options:
- **A: Approve** → proceed to /solo-dev:init
- **B: Adjust section** → specify which section needs changes → re-run that phase
- **C: Start over** → reset and restart from Phase 1

Log user decision in docs/agents/memory/decisions.md.

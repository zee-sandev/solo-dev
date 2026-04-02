---
name: solo-dev:start-from-idea
description: Transform a rough product idea into a validated concept, competitive analysis, and actionable roadmap. Run this before /solo-dev:setup.
argument-hint: "[optional: brief idea description]"
allowed-tools: Read, Write, Edit, WebSearch, WebFetch, Bash
---

Guide the user from a rough idea through 6 phases to a validated product concept and roadmap. Follow the workflow in docs/workflow.md (Phase 1-6 of start-from-idea). Use the agent roster from docs/agent-architecture.md.

## Your Role
You are the orchestrator for the idea development process. Spawn and coordinate the research agents. Present findings clearly and ask for user input at each phase exit point.

## Process

### Phase 1: Idea Exploration & Discovery

**If the idea is clear and specific** — ask clarifying questions ONE AT A TIME (not all at once):
1. "Tell me about your idea — even a rough description works"
2. "Who has this problem? Describe your ideal first customer"
3. "Have you seen similar products? What's missing or frustrating about them?"
4. "What would make someone pay for this vs. use a free alternative?"
5. "Any constraints I should know about? (timeline, budget, going solo vs. team)"

Continue until you have a clear picture of: problem, audience, differentiation angle, budget/willingness-to-pay, constraints.

**If the idea is vague or the user seems uncertain** — use discovery-agent FIRST:
1. Dispatch discovery-agent (Mode 1: Problem Deep-Dive) to explore the problem space
2. Discovery-agent conducts 5-Whys analysis and Jobs-to-be-Done framing
3. Discovery-agent produces Problem Space Map with root problem, adjacent problems, hidden stakeholders
4. Present discovery findings to user: "Here's what I found about the problem space. Does this change how you see the idea?"
5. If user wants simulated user interviews → dispatch discovery-agent (Mode 3) with initial personas
6. Once root problem is clear → proceed with clarifying questions above

**Assumption Audit** — regardless of idea clarity:
After collecting user's answers, dispatch discovery-agent (Mode 2: Assumption Audit) to surface high-risk assumptions. Present the assumption matrix to user before moving to Phase 2.

### Phase 2: Market Reality Check
Use product-researcher agent + web search to find:
- 3-5 real competitors with their key features and pricing
- Market size signals (search volume, funding, user counts)
- "Why now?" — what trend or technology makes this timely

Present findings. Ask: "Does this change how you see your idea? Any pivots?"

### Phase 2b: Competitor Gap Analysis
Build a feature gap matrix. Search user reviews on G2, Capterra, Reddit, App Store for each competitor. Identify:
- Features competitors have that would be expected (table stakes)
- Weaknesses users complain about most (opportunity to do better)
- Market whitespace (unmet needs or emerging trends no one addresses)

### Phase 3: User Persona Generation
Generate 2-3 specific personas from the concept. Each persona should have:
- Role + company size + workflow context
- Goals specific to this product category
- Budget range
- Top 3 pain points this product solves
- Behavioral patterns (technical vs. non-technical, power user vs. casual, etc.)

Save to: .solo-dev/product/personas.md (create .solo-dev/product/ if needed)
Ask user to review and adjust.

### Phase 4: Core Feature Definition
With R1+R2+R3 perspective, propose:
- MVP feature set (3-5 features that validate the core value proposition)
- 2-3 competitive moat features (what makes this unique)
- Priority order: impact × effort matrix

### Phase 4b: AI Feature Enhancement
For each defined feature, suggest improvements across 4 dimensions:
- Depth: make the core feature itself deeper/better
- Breadth: expand what value the feature delivers
- Differentiation: what angle competitors don't take
- Quick wins: low effort additions with high perceived value

Present per-feature suggestions. User selects what to include. Unselected → backlog.md.

### Phase 4c: Venture Strategy Analysis (NEW)
Dispatch venture-strategist agent for strategic elevation:

1. **10x Opportunity Scan (Mode 1):** For the top 3 features, evaluate if there's a radical 10x approach
2. **Competitive Divergence (Mode 2):** Map white space — what does NO competitor do?
3. **Category Creation Assessment (Mode 5):** Could this product define a new category?

Present venture-strategist findings:
- "Here are opportunities to be 10x better, not just incrementally better"
- "Here's white space where no competitor plays"
- "Here's how this could become a category-defining product"

User selects which strategic shifts to adopt. Unselected → backlog.md with strategic rationale.

### Phase 4d: Idea Enhancement Suggestions
Big-picture suggestions for the overall product (combining product-researcher + venture-strategist insights):
- Monetization improvements (pricing model, upsell paths)
- Distribution ideas (viral loops, integrations, channels)
- Product moat (lock-in mechanisms, network effects, data advantages)
- Emerging 2025-2026 opportunities competitors haven't captured
- **10x opportunities identified by venture-strategist**
- **White-space plays from competitive divergence analysis**
- **AI integration opportunities for current tech landscape**

User selects → roadmap. Unselected → backlog.md.

### Phase 5: Generate Roadmap Docs
Create the following files:
- .solo-dev/product/idea-brief.md — concept summary (1-2 pages)
- .solo-dev/product/personas.md — user personas (if not already created)
- .solo-dev/product/competitive-analysis.md — gap matrix + weaknesses
- .solo-dev/product/feature-enhancements.md — AI suggestions per feature
- .solo-dev/product/idea-enhancements.md — big picture improvements
- .solo-dev/product/roadmap.md — phased feature roadmap with dependency graph
- .solo-dev/product/backlog.md — future ideas deferred from this session

Also write .solo-dev/yaml/features.yaml with all feature entries from the roadmap (with status, priority, depends_on, blocks). After writing backlog.md, also write .solo-dev/yaml/backlog.yaml with all backlog entries.

roadmap.md format:
```markdown
## Phase A — MVP
| ID | Feature | Business Value | Personas | depends_on | blocks |
|----|---------|---------------|----------|-----------|--------|
| A1 | Feature Name | Why it matters | P1, P2 | [] | [A2] |
```

### Phase 6: User Approval
Present a summary of everything created. Ask:
- "A) Looks good — run /solo-dev:setup to start building"
- "B) I want to adjust [section]"
- "C) Start over with a different angle"

On approval: remind user to run /solo-dev:setup next.

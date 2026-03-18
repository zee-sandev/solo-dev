# Getting Started

## Installation

### From Claude Code Plugin Marketplace (recommended)

```bash
# Install from marketplace
claude plugin add solo-dev

# Install optional plugins for enhanced quality
claude plugin add impeccable
claude plugin add ui-ux-pro-max
claude plugin add everything-claude-code
```

### Manual Install

```bash
# Global install
cp -r solo-dev ~/.claude/plugins/solo-dev

# Or project-scoped
cp -r solo-dev .claude/plugins/solo-dev
```

## Three Entry Points

### 1. Starting from a new idea

```
/solo-dev:start-from-idea
```

Guides you through 6 phases:
1. Idea exploration (dialogue)
2. Market reality check (competitor research)
3. Competitor gap analysis (feature gaps, weaknesses, whitespace)
4. Persona generation (2-3 user personas)
5. AI-enhanced feature definition (depth, breadth, differentiation, quick wins)
6. Roadmap generation (prioritized, with dependency graph)

Output: `docs/product/` directory with idea-brief, personas, competitive analysis, roadmap, and backlog.

### 2. Starting from an existing concept

```
/solo-dev:init
```

If you already have notes, a spec, or requirements — `init` sets up the project structure and memory system.

### 3. Onboarding an existing codebase

```
/solo-dev:init
```

If solo-dev detects source files but no product docs, it automatically enters **onboarding mode**. See [Existing Project Onboarding](Existing-Project-Onboarding.md) for details.

## After Setup

```
/solo-dev:next-feature
```

Builds the next feature from your roadmap through the full [Feature Lifecycle](Feature-Lifecycle.md):
Market validation → Design loop → Parallel implementation → Code review → QA → Security → Business validation → Demo generation.

## First Run Example

```
> /solo-dev:start-from-idea

Orchestrator: Tell me about your idea — even a rough description works.

User: I want to build a tool that helps content teams track which blog posts
      are ranking on Google and get AI suggestions for improvement.

Orchestrator: Who has this problem? Describe your ideal first customer.

User: Marketing managers at B2B SaaS companies, 5–50 person teams.

[... questions continue one at a time ...]

✓  Idea captured
✓  4 competitors found — Clearscope, Surfer SEO, MarketMuse, Frase
✓  Gap matrix built — 3 whitespace opportunities identified
✓  2 personas generated — Content Manager Sarah, SEO Lead Marcus
✓  6 MVP features defined, 2 competitive moat features
✓  AI enhancements suggested — 4 selected, 3 moved to backlog
✓  Roadmap generated

Run /solo-dev:init to start building.
```

## Project Output Structure

Every project built with solo-dev follows this layout:

```
docs/
├── specs/          # Feature specifications
├── contracts/      # API contracts (auto-generated per feature)
├── demos/          # Demo videos + documentation per feature
│   └── {feature}/
│       ├── demo.mp4
│       └── demo.md
└── agents/
    └── memory/     # Agent learning memory
        ├── index.md
        ├── patterns.md
        ├── decisions.md
        ├── cr_learnings.md
        ├── bv_learnings.md
        ├── performance-log.md
        └── snapshots/
docs/product/
├── roadmap.md      # Feature roadmap with dependency graph
├── personas.md     # Generated user personas
├── competitive-analysis.md
└── backlog.md      # Unselected AI enhancement suggestions
```

---
name: evolve
description: Run the strategy-evolver agent to analyze agent performance and update strategies for future sessions. Run after completing multiple features.
argument-hint: ""
allowed-tools: Read, Write, Edit
---

Trigger the strategy-evolver agent to analyze performance and improve agent strategies. This is the self-improvement mechanism — run it after every 2-3 completed features.

## Your Role
Coordinate the evolution process. Spawn strategy-evolver, present findings to user, apply updates.

## Process

1. Check readiness: read docs/agents/memory/performance-log.md
   - If fewer than 2 completed features logged: "Not enough data yet. Complete at least 2 features before evolving."
   - Otherwise: proceed

2. Spawn strategy-evolver agent with:
   - docs/agents/memory/performance-log.md (full content)
   - ~/.claude/solo-dev/strategies/ (current strategy files)
   - docs/agents/memory/cr_learnings.md
   - docs/agents/memory/bv_learnings.md
   - docs/agents/memory/persona_insights.md

3. strategy-evolver produces EVOLUTION_REPORT:
   ```
   EVOLUTION_REPORT:

   Analyzed: {N} features, {M} agent cycles

   RESEARCH LAYER:
     - product-researcher: [what works, what to improve]
     - ux-researcher: [what works, what to improve]
     - tech-architect: [what works, what to improve]

   IMPLEMENTATION LAYER:
     - Common issues across features: [patterns]
     - backend-agent: [specific improvements]
     - test-agent: [specific improvements]

   QUALITY LAYER:
     - code-reviewer: [calibration adjustments]
     - qa-validator: [what to check earlier]
     - business-validator: [domain checklist updates]

   STRATEGY UPDATES:
     research.md: [proposed changes]
     implementation.md: [proposed changes]
     qa.md: [proposed changes]
   ```

4. Present EVOLUTION_REPORT to user. Ask:
   - "Apply all updates? (Y)"
   - "Review changes first? — show diff of each strategy file"
   - "Skip specific agents?"

5. On approval: write updated strategy files to ~/.claude/solo-dev/strategies/

6. Append evolution summary to docs/agents/memory/decisions.md:
   ```
   ## Evolution Run — {date}
   Analyzed {N} features. Key improvements: [summary]
   ```

7. Print:
   ```
   ✅ Strategies evolved
   Updated: research.md, implementation.md, qa.md
   Agents will load updated strategies in the next session.
   ```

# Inter-Agent Message Format

## Standard Message Structure (YAML)
```yaml
from: {agent-name}
to: {agent-name | orchestrator}
type: CONTRACT_UPDATE | CONTRACT_MISMATCH | CR_FEEDBACK | QA_FEEDBACK | PERSONA_REJECTION | SECURITY_FINDING | BV_FINDING | REVISION | RESOLVED
phase: DESIGN | IMPLEMENTATION | CODE_REVIEW | QA | SECURITY | BUSINESS_VALIDATION | FINAL_ACCEPTANCE
round: {N}
severity: BLOCKING | WARNING | INFO
summary: "{one-line description of the issue or update}"
artifacts:
  - type: spec | api_contract | report | diff
    path: docs/...
details: |
  {multi-line details if needed}
requires_ack: true | false
```

## Type Definitions

**CONTRACT_UPDATE** — backend-agent notifies dependent agents of API changes
**CONTRACT_MISMATCH** — frontend/data/test agent reports contract gap (blocking)
**CR_FEEDBACK** — code-reviewer sends targeted fix list to specific agent
**QA_FEEDBACK** — qa-validator sends targeted fix list
**PERSONA_REJECTION** — persona-validator sends specific rejection condition to ux-researcher
**SECURITY_FINDING** — security-reviewer sends finding to implementation agent
**BV_FINDING** — business-validator sends enhancement/gap to orchestrator
**REVISION** — agent reports it has made the requested fixes
**RESOLVED** — reviewing agent confirms the fix was accepted

## Targeting Rule
Never broadcast. Always specify exact `to:` agent.
If multiple agents have issues, send separate messages to each.

## ACK Protocol
If `requires_ack: true`:
- Receiver must reply with RESOLVED message after fixing
- Sender does not proceed until ACK received
- Timeout: if no ACK after 1 round, escalate to orchestrator

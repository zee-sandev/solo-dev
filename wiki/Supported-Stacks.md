# Supported Stacks

Stack detection is automatic — solo-dev reads your project files at session start and loads the appropriate skills.

## Detection

| Stack | Detected By | Extra Skills Loaded |
|-------|-------------|---------------------|
| Next.js / React | `package.json` | `ecc:frontend-patterns` |
| Django | `manage.py` | `ecc:django-patterns`, `ecc:django-security`, `ecc:django-tdd` |
| Spring Boot | `pom.xml` / `build.gradle` | `ecc:springboot-patterns`, `ecc:springboot-security`, `ecc:jpa-patterns` |
| Go | `go.mod` | `ecc:golang-patterns`, `ecc:golang-testing` |
| Python | `requirements.txt` / `pyproject.toml` | `ecc:python-patterns`, `ecc:python-testing` |

## Better Auth

If your project uses [Better Auth](https://www.better-auth.com/) for authentication, the `claude.ai Better Auth` MCP server is used automatically for accurate API patterns and best practices.

## Optional Domain Skills

Loaded based on project type, not tech stack:

| Domain | Skill |
|--------|-------|
| SEO SaaS | `seo-technical-optimization:*` |
| LLM features | `ecc:cost-aware-llm-pipeline` |
| On-device AI | `ecc:foundation-models-on-device` |

## How Stack Skills Are Used

Stack-specific skills are loaded by the SessionStart hook:

1. Detect stack from project files (package.json, go.mod, etc.)
2. Export `$SAAS_DEV_STACK` to `$CLAUDE_ENV_FILE`
3. Agents automatically load relevant stack skills

The `tech-architect` agent uses stack skills during design. Implementation agents (`backend-agent`, `data-agent`, etc.) use them during coding. The `security-reviewer` loads stack-specific security skills (e.g., `ecc:django-security`).

## Adding Custom Stack Support

solo-dev is designed to work with any stack. If your stack isn't auto-detected, you can:

1. Manually set the stack in `.claude/solo-dev-state.json`
2. Add relevant skills to your CLAUDE.md or project instructions
3. The agents adapt their patterns based on what they find in the codebase

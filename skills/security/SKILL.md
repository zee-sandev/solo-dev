---
name: security
description: SaaS security review checklists covering auth, multi-tenancy, injection, API security, payment, secrets, and PII. Fallback for everything-claude-code:security-review.
---

The security-reviewer and backend-agent use this skill when the everything-claude-code:security-review plugin is not installed. It provides SaaS security review checklists as a standalone fallback.

## When to Use
Invoke when reviewing security of any backend code, auth implementation, or API endpoints. This is the bundled fallback for `everything-claude-code:security-review`.

## SaaS Security Checklist

### Authentication & Identity
- [ ] Passwords: bcrypt/argon2 with cost factor ≥12 (never MD5/SHA1/plain)
- [ ] JWT: short expiry (15-60min), refresh tokens stored as httpOnly cookies
- [ ] OAuth: `state` parameter validated to prevent CSRF
- [ ] Session: new session ID after login (prevent session fixation)
- [ ] Token scope: tokens have minimum required permissions (principle of least privilege)
- [ ] MFA: available for sensitive operations (payments, admin actions)

### Multi-Tenancy Isolation
- [ ] Every query filtered by tenantId/orgId
- [ ] tenantId extracted from auth token (never from user input)
- [ ] Resource IDs are tenant-scoped UUIDs (not sequential integers)
- [ ] File uploads scoped to tenant storage paths
- [ ] Background jobs include tenantId in all operations

### Injection Prevention
- [ ] All database queries use parameterized statements / ORM (no string concat)
- [ ] All user input sanitized before HTML rendering (XSS prevention)
- [ ] File paths validated and sandboxed (no path traversal)
- [ ] Template engines use auto-escaping

### API Security
- [ ] Rate limiting on all endpoints (especially auth, payments, AI)
- [ ] CORS: whitelist specific origins (never `*` in production)
- [ ] HTTPS only (HSTS header set)
- [ ] No sensitive data in URL query params (use POST body or headers)
- [ ] No PII or tokens in server logs
- [ ] Request size limits set

### Payment Security
- [ ] No raw card data stored or logged anywhere
- [ ] Webhook signatures validated (Stripe `stripe-signature` header, etc.)
- [ ] Idempotency keys on payment operations
- [ ] Payment amounts validated server-side (never trust client-sent amounts)

### Secrets Management
- [ ] No hardcoded secrets in source code or config files committed to git
- [ ] Secrets in environment variables or secret manager
- [ ] .env files in .gitignore
- [ ] Different secrets per environment (dev/staging/prod)

### Error Handling
- [ ] Error responses don't leak stack traces in production
- [ ] Error messages don't reveal internal system details
- [ ] 404 vs 403: don't reveal existence of resources user can't access

### Data Protection
- [ ] PII encrypted at rest for sensitive fields
- [ ] Data retention policies enforced
- [ ] GDPR: user data deletion removes all related records
- [ ] Audit log for sensitive operations (payments, role changes, deletions)

## Severity Classification
| Severity | Examples | Action |
|----------|---------|--------|
| CRITICAL | SQL injection, auth bypass, data leakage across tenants | Block ship — fix now |
| HIGH | Hardcoded secrets, missing auth on protected routes, XSS | Fix before ship |
| MEDIUM | Missing rate limiting, weak input validation | Fix in next sprint |
| LOW | Missing audit log, suboptimal crypto | Track, fix later |

## Output Format
```
SECURITY_REPORT:
  CRITICAL:
    - [file:line]: [issue] — [specific fix]

  HIGH:
    - [file:line]: [issue] — [specific fix]

  MEDIUM:
    - [file:line]: [issue] — [specific fix]

  VERDICT: APPROVE | REJECT (REJECT if any CRITICAL or HIGH)
```


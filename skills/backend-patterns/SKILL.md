---
name: backend-patterns
description: Backend architecture patterns — REST API design, layered service architecture, multi-tenancy, input validation, and rate limiting. Fallback for everything-claude-code:backend-patterns.
---

The backend-agent uses this skill when the everything-claude-code:backend-patterns plugin is not installed. It provides backend architecture patterns and API design guidance as a standalone fallback.

## When to Use
Invoke when designing API endpoints, service layers, repository patterns, or middleware. This is the bundled fallback for `everything-claude-code:backend-patterns` and `everything-claude-code:api-design`.

## API Design Principles

### RESTful Resource Naming
```
GET    /api/v1/resources          → list (paginated)
GET    /api/v1/resources/:id      → get one
POST   /api/v1/resources          → create
PUT    /api/v1/resources/:id      → replace
PATCH  /api/v1/resources/:id      → partial update
DELETE /api/v1/resources/:id      → delete
```

Nested resources (use sparingly — max 2 levels deep):
```
GET /api/v1/orgs/:orgId/members   → members of a specific org
```

### Response Envelope
Always use consistent response format:
```json
{
  "success": true,
  "data": { ... },
  "error": null,
  "meta": {
    "total": 100,
    "page": 1,
    "limit": 20
  }
}
```

Error response:
```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "fields": { "email": "Invalid email format" }
  }
}
```

### HTTP Status Codes
| Situation | Code |
|-----------|------|
| Success (with data) | 200 |
| Created | 201 |
| No content (delete) | 204 |
| Bad request / validation | 400 |
| Unauthorized | 401 |
| Forbidden | 403 |
| Not found | 404 |
| Conflict | 409 |
| Validation error | 422 |
| Rate limited | 429 |
| Server error | 500 |

## Service Layer Architecture

### Layered Architecture
```
Controller/Route Handler
  → validates input (schema validation)
  → calls Service
  → returns HTTP response

Service
  → contains business logic
  → calls Repository
  → throws domain errors (not HTTP errors)
  → handles transactions

Repository
  → data access only (no business logic)
  → returns domain objects
  → abstracts ORM/query builder
```

### Error Handling Pattern
```typescript
// Service throws domain errors
class UserService {
  async createUser(data: CreateUserDto) {
    const existing = await this.userRepo.findByEmail(data.email)
    if (existing) throw new ConflictError('Email already in use')
    return this.userRepo.create(data)
  }
}

// Controller maps domain errors to HTTP
try {
  const user = await userService.createUser(body)
  return res.status(201).json({ success: true, data: user })
} catch (error) {
  if (error instanceof ConflictError) {
    return res.status(409).json({ success: false, error: { code: 'CONFLICT', message: error.message } })
  }
  throw error // let global handler catch unexpected errors
}
```

## Multi-Tenancy Pattern
Every database query on tenant-scoped data must include tenantId:

```typescript
// Repository — always scope by tenantId
async findAll(tenantId: string, options: PaginationOptions) {
  return this.db.resource.findMany({
    where: { tenantId, deletedAt: null },
    skip: options.offset,
    take: options.limit,
    orderBy: { createdAt: 'desc' }
  })
}

// Service — pass tenantId from auth context
async listResources(ctx: AuthContext, options: PaginationOptions) {
  return this.repo.findAll(ctx.tenantId, options)
}
```

**Never** pass tenantId from user input — always extract from auth token.

## Input Validation
Use schema validation at every API boundary:
```typescript
const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  role: z.enum(['admin', 'member'])
})

// In route handler
const result = createUserSchema.safeParse(req.body)
if (!result.success) {
  return res.status(422).json({ error: result.error.flatten() })
}
```

## Rate Limiting
Apply rate limiting to:
- Auth endpoints: 10 req/min per IP
- Payment endpoints: 10 req/min per user
- AI/expensive endpoints: 20 req/min per user
- General API: 100 req/min per user


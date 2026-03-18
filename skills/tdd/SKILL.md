---
name: tdd
description: Test-driven development workflow with unit, integration, and E2E patterns for SaaS features. Fallback for everything-claude-code:tdd and tdd-workflow.
---

The test-agent uses this skill when the everything-claude-code:tdd or everything-claude-code:tdd-workflow plugin is not installed. It provides test-driven development patterns for SaaS features as a standalone fallback.

## When to Use
Invoke when writing tests for any feature — unit, integration, or E2E. This is the bundled fallback for `everything-claude-code:tdd` and `everything-claude-code:tdd-workflow`.

## TDD Workflow

### The Loop
1. **RED**: Write a failing test that describes the expected behavior
2. **GREEN**: Write minimal implementation to make the test pass
3. **REFACTOR**: Clean up code while keeping tests green
4. Repeat for each behavior

Never write implementation before the test. Tests drive the design.

### Test Coverage Target
- New code: 80% minimum
- Business logic: 100% (every branch tested)
- Utility functions: 100%

## Unit Test Patterns

### Service Layer Tests
```typescript
describe('UserService.createUser', () => {
  it('creates a user with hashed password', async () => {
    const dto = { email: 'test@example.com', password: 'secure123', name: 'Test' }
    const result = await userService.createUser(dto)

    expect(result.email).toBe(dto.email)
    expect(result.password).not.toBe(dto.password) // must be hashed
    expect(result.tenantId).toBeDefined()
  })

  it('throws ConflictError for duplicate email', async () => {
    await userService.createUser({ email: 'dupe@example.com', ... })
    await expect(
      userService.createUser({ email: 'dupe@example.com', ... })
    ).rejects.toThrow(ConflictError)
  })

  it('throws ValidationError for invalid email', async () => {
    await expect(
      userService.createUser({ email: 'not-an-email', ... })
    ).rejects.toThrow(ValidationError)
  })
})
```

### Test Structure: AAA Pattern
```
Arrange — set up test data and dependencies
Act     — call the function under test
Assert  — verify the expected outcome
```

## Integration Test Patterns

### API Endpoint Tests
Test the full request → response cycle:

```typescript
describe('POST /api/v1/users', () => {
  it('201 creates user and returns user object', async () => {
    const response = await request(app)
      .post('/api/v1/users')
      .set('Authorization', `Bearer ${token}`)
      .send({ email: 'new@example.com', name: 'New User', role: 'member' })

    expect(response.status).toBe(201)
    expect(response.body.success).toBe(true)
    expect(response.body.data.email).toBe('new@example.com')
    expect(response.body.data.password).toBeUndefined() // never in response
  })

  it('401 without auth token', async () => {
    const response = await request(app).post('/api/v1/users').send({...})
    expect(response.status).toBe(401)
  })

  it('422 with invalid email', async () => {
    const response = await request(app)
      .post('/api/v1/users')
      .set('Authorization', `Bearer ${token}`)
      .send({ email: 'invalid' })

    expect(response.status).toBe(422)
    expect(response.body.error.fields.email).toBeDefined()
  })
})
```

### Multi-Tenancy Isolation Tests
```typescript
it('prevents cross-tenant data access', async () => {
  // Create resource as tenant A
  const resource = await createResource(tenantA)

  // Try to access as tenant B
  const response = await request(app)
    .get(`/api/v1/resources/${resource.id}`)
    .set('Authorization', `Bearer ${tenantBToken}`)

  expect(response.status).toBe(404) // not 403 — don't reveal existence
})
```

## E2E Test Patterns (Playwright)

### Page Object Model
```typescript
class DashboardPage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto('/dashboard')
  }

  async getMetricValue(metricName: string) {
    return this.page.locator(`[data-metric="${metricName}"]`).textContent()
  }

  async clickCreateButton() {
    await this.page.getByRole('button', { name: 'Create' }).click()
  }
}
```

### E2E Test Structure
```typescript
test('user can create and view a resource', async ({ page }) => {
  const dashboardPage = new DashboardPage(page)

  // Arrange
  await dashboardPage.goto()

  // Act
  await dashboardPage.clickCreateButton()
  await page.fill('[name=title]', 'My Resource')
  await page.click('[type=submit]')

  // Assert
  await expect(page.locator('text=My Resource')).toBeVisible()
})
```

## Test Isolation Rules
- Each test must be independent (no shared state between tests)
- Database: reset between tests (use transactions that rollback, or test DB seeding)
- External APIs: mock at integration level, test real at E2E level
- Time: mock `Date.now()` for deterministic time-dependent tests

## What to Test Per Feature
| Feature Layer | Test Type | What to Test |
|--------------|-----------|-------------|
| Service | Unit | Business logic, error cases, edge values |
| API endpoint | Integration | Happy path, auth, validation, error codes |
| Database | Integration | CRUD operations, migrations, constraints |
| User flow | E2E | Happy path from spec + main error scenario |
| Auth | Integration | Authenticated, unauthenticated, wrong permissions |
| Multi-tenancy | Integration | Tenant A cannot see Tenant B's data |

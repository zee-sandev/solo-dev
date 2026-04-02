---
name: solo-dev:migrate
description: "Apply plugin updates to an already-initialized project — updates state schema, config defaults, and YAML indexes to match the current plugin version."
argument-hint: "[--dry-run] [--from X.Y.Z] — migrate project to current plugin version"
allowed-tools: Read, Write, Edit, Bash
---

Apply all pending migrations from the project's current plugin version to the installed version. Safe to re-run — migrations are idempotent.

## Your Role
Read the project's recorded plugin version, find all migrations that have not yet been applied, apply each in order, and update the version marker.

## Process

### Step 1: Read versions

1. Read `.solo-dev/state.json` → get `plugin_version` field (the version the project was initialized with)
2. Read plugin's own `.claude-plugin/plugin.json` → get current `version`
3. If `plugin_version` is missing from state → set to `"0.0.0"` (pre-versioning project)
4. If versions match → print "Already up to date (v{version})" and exit

### Step 2: Find applicable migrations

Read `docs/migrations/` in the plugin directory. Each file is named `{version}.md` (e.g. `0.9.1.md`).

Collect all migration files where `{version} > project_plugin_version` AND `{version} <= current_plugin_version`, sorted ascending.

### Step 3: Dry run (if `--dry-run`)

Print what would change without applying:
```
Dry run — migrations that would apply:
  v0.9.1  Add XS effort tier fields to state.json
  v0.9.2  Add total_rounds counter to state.json
  v1.0.0  Rename phase MARKET_VALIDATION → PHASE_0

Run without --dry-run to apply.
```
Exit.

### Step 4: Apply migrations in order

For each migration:

1. Print `Applying v{version}: {title}`
2. Follow the migration instructions in the file exactly
3. On success → print `  ✅ v{version} applied`
4. On failure → print `  ❌ v{version} failed: {reason}` → stop, do not apply further migrations

### Step 5: Update version marker

After all migrations succeed:
1. Update `plugin_version` in `.solo-dev/state.json` to current plugin version
2. Append entry to `.solo-dev/memory/decisions.md`:
   ```
   ## Migration — {date}
   Applied migrations: {list of versions}. Project updated from v{from} to v{to}.
   ```

### Step 6: Print summary

```
✅ Migration complete
   From: v{from}
   To:   v{to}
   Applied: {N} migrations

   {If any warnings from migrations: list them here}

   Run /solo-dev:status to verify project state.
```

## Migration File Format

Each migration in `docs/migrations/{version}.md` follows this structure:

```markdown
# v{version} — {title}

## What changed
{Brief description of what changed in the plugin}

## Impact on existing projects
{What breaks or needs updating in projects already using the plugin}

## Migration steps
{Ordered list of changes to apply}

### State changes (`.solo-dev/state.json`)
{Field additions, renames, removals}

### Config changes (`.solo-dev/config.local.md`)
{New config options with defaults}

### YAML changes (`.solo-dev/yaml/`)
{Schema additions or renames}

### File changes
{Any files to create, move, or delete in the project}

## Verification
{How to verify the migration succeeded}
```

## Notes

- **Idempotent:** Running migrate twice is safe — each migration checks if it's already applied before making changes
- **No data loss:** Migrations only add new fields or rename fields — never delete existing project data
- **Partial failure:** If a migration fails mid-way, state is preserved at the last successful migration version — re-run to retry failed migration
- **Manual escape:** If `--from X.Y.Z` is passed, override the detected project version (useful if state is corrupt)

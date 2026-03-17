# Shared Context: E001 — User Authentication

---

## CONTEXT: users-table
**Agent:** db-engineer | **Date:** 2026-03-16 | **Story:** E001-S001

### Artifacts
| What | Where | Interface |
|------|-------|-----------|
| Users table | db/migrations/001_create_users.sql | see schema below |

### Schema
| Column | Type | Constraints | Default |
|--------|------|-------------|---------|
| id | uuid | PK | uuid_generate_v4() |
| email | varchar | UNIQUE, NOT NULL | — |
| name | varchar | NOT NULL | — |
| password_hash | varchar | NOT NULL | — |
| created_at | timestamptz | NOT NULL | now() |

---

## DECISION: no-soft-delete
**Agent:** db-engineer | **Story:** E001-S001

**Chose:** Hard delete (no deleted_at column)
**Over:** Soft delete with deleted_at timestamp
**Because:** Product has no undelete requirement yet. Adding a column
later is a non-breaking migration.
**Affects:** Any agent writing DELETE queries.
**Reversible:** Yes — add column + backfill NULL.

---

## DECISION: supabase-auth
**Agent:** backend-developer | **Story:** E001-S002

**Chose:** Supabase Auth for token management
**Over:** Custom JWT implementation
**Because:** Epic E001 scope says "use Supabase where possible."
**Affects:** All auth-related endpoints.
**Reversible:** No — would require full auth rewrite.

---

## CONTEXT: auth-api-contract
**Agent:** backend-developer | **Date:** 2026-03-16 | **Story:** E001-S002

### Artifacts
| What | Where | Interface |
|------|-------|-----------|
| API spec | docs/api/auth.yaml | OpenAPI 3.0 |

### Endpoints
| Method | Path | Request | Response (200) | Errors |
|--------|------|---------|----------------|--------|
| POST | /auth/login | `{email, password}` | `{token, user}` | 401, 422 |
| POST | /auth/register | `{email, password, name}` | `{user}` | 409, 422 |

### Error shape
All errors: `{code: string, message: string}`

---

## WARNING: duplicate-email-on-register
**Agent:** db-engineer | **Story:** E001-S001

**Trigger:** INSERT into users with existing email
**Symptom:** PostgreSQL unique_violation (23505)
**Fix:** Catch exception → return HTTP 409
`{code: "EMAIL_EXISTS", message: "An account with this email already exists"}`
**If ignored:** Raw 500 with stack trace leaks to client.

---

## CONTEXT: login-ui
**Agent:** flutter-developer | **Date:** 2026-03-16 | **Story:** E001-S004

### Artifacts
| What | Where | Interface |
|------|-------|-----------|
| Login screen | lib/features/auth/ui/login_screen.dart | LoginScreen widget |
| Form validation | (inline) | email: regex, password: min 8 chars |

### UI State
- Submit → shows CircularProgressIndicator
- Error → shows red SnackBar with message text
- Expects API to return `{code, message}` on error

---

---
id: E001-S003
title: "Implement auth API endpoints"
epic: E001
status: ready
priority: high
assigned_role: backend-developer
estimate: M
critical: true
depends_on:
  - E001-S001
  - E001-S002
---

# E001-S003 — Implement auth API endpoints

## REQUEST

### Input
- DB schema: `.ai/context/E001.md` → CONTEXT: users-table
- API contract: `docs/api/auth.yaml`
- Auth config: `.ai/context/E001.md` → DECISION: supabase-auth

### Output
- `lib/auth/routes.dart` — endpoint handlers
- `lib/auth/repository.dart` — data access (modified)
- `test/auth/routes_test.dart` — tests (min 4: 2 happy, 2 error)
- STATUS entry in `.ai/context/E001.md`

### Constraints
- Endpoints must match `docs/api/auth.yaml` exactly
- Repository pattern: no SQL in route handlers
- Handle: duplicate email → 409, invalid input → 422, wrong password → 401

### Not in scope
- Email verification flow
- Password reset flow
- Rate limiting
- Session/refresh token management

## Tasks
- [ ] Read `.ai/context/E001.md` for all CONTEXT and DECISION entries
- [ ] Implement POST /auth/login per contract
- [ ] Implement POST /auth/register per contract
- [ ] Error handling per WARNING entries in context
- [ ] Write tests (happy path + each error case)
- [ ] Append CONTEXT + DECISION entries to `.ai/context/E001.md`

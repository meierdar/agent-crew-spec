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

## A2A

@STORY E001-S003 backend-developer M critical

LOAD .ai/knowledge/auth.md
LOAD .ai/knowledge/api-style.md
LOAD .ai/knowledge/errors.md

IN .ai/bus/E001.bus @CTX:users-table
IN .ai/bus/E001.bus @CTX:auth-api-contract
IN .ai/bus/E001.bus @WARN:*
IN .ai/bus/E001.bus @DEC:auth-provider
IN docs/api/auth.yaml

OUT lib/auth/routes.dart NEW
OUT lib/auth/repository.dart MOD +signIn(email,pw)>Token +signUp(email,pw,name)>User
OUT test/auth/routes_test.dart NEW min:4(2_happy,2_error)

SCOPE +login_endpoint +register_endpoint +error_handling(409,422,401)
SCOPE -email_verification -password_reset -rate_limiting -refresh_tokens

DONE_WHEN
  tests_pass
  endpoints_match_contract
  errors_handled(duplicate_email>409, invalid_input>422, wrong_password>401)
  bus_appended(@CTX:auth-implementation, @DEC:*)

# E001-S003 — Implement auth API endpoints

## Description

Build the auth API: login and registration endpoints that match the
OpenAPI contract from E001-S002, wired to the users table from E001-S001.
Handle all error cases — especially the duplicate email scenario.

## Acceptance Criteria

- [ ] POST /auth/login returns token + user on valid credentials
- [ ] POST /auth/register creates user and returns user object
- [ ] Duplicate email returns 409 with EMAIL_EXISTS code
- [ ] Invalid input returns 422 with field-specific messages
- [ ] Wrong password returns 401

## Tasks

- [ ] Read context bus and dependency artifacts
- [ ] Implement POST /auth/login
- [ ] Implement POST /auth/register
- [ ] Error handling for all cases
- [ ] Write 4+ tests (happy paths + error cases)
- [ ] Append implementation context to bus

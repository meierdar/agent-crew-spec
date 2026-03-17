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

## Description
Build the actual API endpoints per the contract, wired to the database.
Supabase Auth is already configured (see E001-S001). The API contract
was defined in E001-S002 — make sure the endpoints match what was
specified there.

## Acceptance Criteria
- [ ] Login endpoint works with valid credentials
- [ ] Registration creates user in database
- [ ] Error handling for duplicates, invalid input

## Tasks
- [ ] Read shared context for schema + contract decisions
- [ ] Implement endpoints
- [ ] Write tests

## Technical Notes
Check the shared context file for details on the database schema
and API contract. Make sure to handle the edge case where someone
tries to register with an email that already exists.

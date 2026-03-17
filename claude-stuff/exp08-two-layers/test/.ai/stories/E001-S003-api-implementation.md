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
created: 2026-03-16
updated: 2026-03-16
---

## A2A

@STORY E001-S003 backend-developer M critical
IN .ai/bus/E001.bus @CTX:users-table
IN .ai/bus/E001.bus @CTX:auth-api-contract
IN .ai/bus/E001.bus @WARN:*
IN .ai/bus/E001.bus @DEC:no-soft-delete
IN .ai/bus/E001.bus @DEC:auth-provider


# E001-S003 — Implement auth API endpoints

## Description
Build the actual API endpoints per the contract, wired to the database.

## Acceptance Criteria
- [ ] Login endpoint works with valid credentials
- [ ] Registration creates user in database
- [ ] Error handling for duplicates, invalid input

## Tasks
- [ ] Read shared context for schema + contract decisions
- [ ] Implement endpoints
- [ ] Write tests

---
id: E001
title: "User Authentication"
status: active
priority: high
created: 2026-03-11
updated: 2026-03-11
---

# E001 — User Authentication

## Goal

Users can register, log in, and maintain a session. This is the foundation for all personalized features.

## Context

The app currently has no auth. We use Supabase Auth as the provider. Email/password first, social login later.

## Scope

### In Scope
- Email/password registration and login
- Session persistence across app restarts
- Password reset flow
- Basic profile screen (email, display name)

### Out of Scope
- Social login (Google, Apple) — separate epic
- Role-based access control — separate epic
- Two-factor authentication

## Stories

| ID | Title | Status | Role |
|----|-------|--------|------|
| E001-S001 | Supabase Auth setup | done | fullstack-developer |
| E001-S002 | Login & registration UI | ready | flutter-developer |
| E001-S003 | Session persistence | backlog | flutter-developer |
| E001-S004 | Password reset flow | backlog | flutter-developer |

## Open Questions

- Do we need email verification before first login? (Decision: yes, but allow grace period of 24h)

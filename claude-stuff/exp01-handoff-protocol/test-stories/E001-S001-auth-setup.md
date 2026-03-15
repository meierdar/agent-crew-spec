---
id: E001-S001
title: "Supabase Auth Setup"
status: review
assigned_role: backend-developer
---

# E001-S001 — Supabase Auth Setup

## Tasks
- [x] Configure Supabase project
- [x] Create auth repository

## Handoff

> Written by: backend-developer
> Completed: 2026-03-14

### What was built
- Auth repository at `lib/features/auth/data/auth_repository.dart`
- Exposes `signIn(email, password)` and `signUp(email, password)`

### Decisions made
- Supabase Auth chosen over custom JWT — aligns with epic E001 goals
- Passwords: minimum 8 chars, validated server-side

### What the next agent needs to know
- Auth repo methods return `AsyncValue` — handle loading/error in UI
- No email verification yet (deferred to E001-S005)

### Files touched
- `lib/features/auth/data/auth_repository.dart`
- `lib/features/auth/domain/auth_state.dart`
- `supabase/migrations/001_auth_setup.sql`

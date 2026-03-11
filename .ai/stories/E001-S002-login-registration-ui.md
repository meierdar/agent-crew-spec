---
id: E001-S002
title: "Login & Registration UI"
epic: E001
status: ready
priority: high
assigned_role: flutter-developer
estimate: M
created: 2026-03-11
updated: 2026-03-11
---

# E001-S002 — Login & Registration UI

## Description

Build the login and registration screens for email/password auth. Supabase Auth is already configured (see E001-S001). The screens should follow the existing app design system and connect to Supabase via the auth repository that already exists at `lib/features/auth/data/auth_repository.dart`.

## Acceptance Criteria

- [ ] User can register with email and password (minimum 8 chars)
- [ ] User can log in with existing credentials
- [ ] Validation errors shown inline (empty fields, invalid email format, password too short)
- [ ] Supabase error messages (e.g. "Email already registered") shown as snackbar
- [ ] After successful login, user is redirected to home screen
- [ ] Loading state shown during auth requests (no double-tap issues)

## Tasks

- [ ] Create `LoginScreen` widget at `lib/features/auth/presentation/login_screen.dart`
- [ ] Create `RegisterScreen` widget at `lib/features/auth/presentation/register_screen.dart`
- [ ] Add form validation logic (email regex, password length)
- [ ] Connect to existing `AuthRepository` via Riverpod provider
- [ ] Add routes in `go_router` config
- [ ] Write widget tests for both screens (happy path + validation errors)

## Technical Notes

- Use `TextFormField` with `Form` widget for validation
- Auth repository already exposes `signIn(email, password)` and `signUp(email, password)` as `AsyncValue`
- Design tokens are in `lib/core/theme/`
- See `lib/features/auth/data/auth_repository.dart` for the existing API

## Blockers

<!-- None currently -->

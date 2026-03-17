---
id: E001-S002
title: "Login & Registration UI"
epic: E001
status: in-progress
priority: high
assigned_role: flutter-developer
estimate: M
created: 2026-03-11
updated: 2026-03-17
depends_on: [E001-S001]
---

# E001-S002 — Login & Registration UI

## Description

Build the login and registration screens for email/password auth.
Supabase Auth is already configured (see E001-S001). Connect to the
auth repository at `lib/features/auth/data/auth_repository.dart`.

## Acceptance Criteria

### Verifiable (agent runs these)

```verify
# Registration flow
FILE_EXISTS lib/features/auth/presentation/register_screen.dart
TEST dart test test/features/auth/presentation/register_screen_test.dart
GREP lib/features/auth/presentation/register_screen.dart "signUp"
GREP lib/features/auth/presentation/register_screen.dart "TextFormField"
GREP lib/features/auth/presentation/register_screen.dart "validator"

# Login flow
FILE_EXISTS lib/features/auth/presentation/login_screen.dart
TEST dart test test/features/auth/presentation/login_screen_test.dart
GREP lib/features/auth/presentation/login_screen.dart "signIn"
GREP lib/features/auth/presentation/login_screen.dart "TextFormField"

# Form validation
GREP lib/features/auth/presentation/ "RegExp.*email\|email.*RegExp"
GREP lib/features/auth/presentation/ "length.*8\|8.*length\|minLength.*8"

# Error handling — snackbar for Supabase errors
GREP lib/features/auth/presentation/ "SnackBar\|ScaffoldMessenger"

# Loading state — no double-tap
GREP lib/features/auth/presentation/ "isLoading\|AsyncValue\|loading"

# Navigation — routes registered
GREP lib/ "LoginScreen\|login" --include="*router*"
GREP lib/ "RegisterScreen\|register" --include="*router*"

# Tests exist
FILE_EXISTS test/features/auth/presentation/login_screen_test.dart
FILE_EXISTS test/features/auth/presentation/register_screen_test.dart
TEST_COUNT test/features/auth/presentation/ >= 6
```

### Human-verified (reviewer checks these)

- [ ] Screens follow existing design system (tokens in `lib/core/theme/`)
- [ ] UX feels natural (tab order, keyboard dismiss, error placement)
- [ ] Edge cases: what happens with no network? Very long email?

## Boundary

```boundary
TOUCH lib/features/auth/presentation/**
TOUCH test/features/auth/presentation/**
TOUCH lib/app/router.dart
NO_TOUCH lib/features/auth/data/**
NO_TOUCH lib/features/home/**
NO_TOUCH lib/features/profile/**
NO_TOUCH lib/core/**
```

## Technical Notes

- Use `TextFormField` with `Form` widget for validation
- Auth repository already exposes `signIn(email, password)` and
  `signUp(email, password)` as `AsyncValue`
- Design tokens are in `lib/core/theme/`

## Progress

<!-- Agent writes here as it works. Do not pre-fill. -->
- [>] `08:28` Work started
- [x] `08:28` Created LoginScreen at lib/features/auth/presentation/login_screen.dart
- [x] `08:28` Created RegisterScreen at lib/features/auth/presentation/register_screen.dart
- [x] `08:28` Form validation: email regex, password min 8 chars
- [!] `08:28` Discovered AuthRepository.signUp throws untyped exception on duplicate — wrapped in AuthException
- [x] `08:28` Snackbar error handling for Supabase errors
- [ ] `08:28` Writing widget tests

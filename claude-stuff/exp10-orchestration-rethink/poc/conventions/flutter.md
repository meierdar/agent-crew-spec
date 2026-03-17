---
id: flutter
stack: [flutter:3.x, riverpod, go_router, supabase, freezed, dio]
---

# Conventions: flutter

## Patterns

- **Structure:** `lib/features/{feature}/` (feature-first)
- **State:** Riverpod providers (no raw setState except trivial)
- **Errors:** Result types or typed exceptions (never silent catch)
- **Strings:** Constants or enums (no magic strings)
- **Tests:** Widget tests for UI, unit tests for logic

## Verify Always

These checks run after EVERY story, regardless of content.
They are the executable Definition of Done.

```verify-always
# Build
RUN flutter build apk --debug

# Tests (all, not just story-specific)
RUN flutter test

# Static analysis
RUN dart analyze --fatal-infos

# No leftover TODOs without story reference
GREP_FAIL lib/ "//\s*(TODO|FIXME|HACK)(?!.*E\d{3}-S\d{3})"

# No hardcoded secrets
GREP_FAIL lib/ "(sk_live|pk_live|password\s*=\s*['\"]|api_key\s*=\s*['\"])"

# No .env committed
FILE_NOT_EXISTS .env
FILE_NOT_EXISTS .env.local
```

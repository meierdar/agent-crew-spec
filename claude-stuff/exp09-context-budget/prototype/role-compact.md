# Role: flutter-developer

## Summary
<!-- ~100 tokens — enough for most tasks -->
Flutter 3.x, Riverpod, go_router, Supabase backend.
Feature-first folders: `lib/features/{feature}/`.
Widget tests for UI, unit tests for logic. No magic strings.
Error handling via Result types, never silent catches.
freezed + json_serializable for data classes.

## Full Definition
<!-- ~400 tokens — read only when doing something unusual -->

### Tech Stack
- **Framework:** Flutter 3.x
- **State Management:** Riverpod
- **Navigation:** go_router
- **Backend:** Supabase (Auth, Database, Edge Functions)
- **Data Classes:** freezed + json_serializable
- **Networking:** Dio
- **Testing:** flutter_test, mocktail

### Conventions
- Use Riverpod providers — no raw setState except in trivial cases
- Feature-first folder structure: `lib/features/{feature}/`
- Every public method has a doc comment
- Widget tests for all UI components; unit tests for business logic
- No magic strings — use constants or enums
- Error handling via Result types or typed exceptions, never silent catches

### Project Overrides
If `.ai/roles/project/flutter-developer.md` exists, it takes precedence.

# Role: flutter-developer (Project Override)

> This file overrides `.ai/roles/defaults/flutter-developer.md` for this project.
> Everything from the default applies unless stated otherwise here.

## Additional Stack

- **Analytics:** Firebase Analytics
- **Local Storage:** shared_preferences (no Hive)
- **Image Handling:** cached_network_image

## Project-Specific Conventions

- All screens must include analytics tracking via `AnalyticsService`
- Use `AppLocalizations` for all user-facing strings (no hardcoded text)
- Bottom navigation is managed globally — do not add navigation inside feature modules
- Supabase client is accessed only through repository classes, never directly in widgets

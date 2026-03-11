---
name: new-epic
description: Create a new epic file in .ai/epics/ from the template. Use when the user wants to define a new feature goal or major work area.
argument-hint: "[title]  e.g. User Authentication"
---

Create a new epic file in `.ai/epics/` from the template at `.ai/templates/epic.md`.

Arguments: $ARGUMENTS

## Steps

1. The full `$ARGUMENTS` string is the epic title.
2. Read existing epics in `.ai/epics/` to find the next available epic number (e.g. if `E001` and `E002` exist, use `E003`).
3. Generate the epic filename in the format `{EPIC_ID}-{kebab-case-title}.md`.
4. Read `.ai/templates/epic.md` and fill in:
   - `id`: the new epic ID (e.g. `E003`)
   - `title`: the full title from arguments (in quotes)
   - `status`: `draft`
   - `created` and `updated`: today's date
5. Write the file to `.ai/epics/`.
6. Report the created file path and suggest next steps: add Goal, Context, and Scope sections, then create stories with `/new-story`.

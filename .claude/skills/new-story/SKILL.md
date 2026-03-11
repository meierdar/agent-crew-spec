---
name: new-story
description: Create a new story file in .ai/stories/ from the template. Use when the user wants to add a new story, task, or work item to the backlog.
argument-hint: "[epic-id] [title]  e.g. E001 Add login button"
---

Create a new story file in `.ai/stories/` from the template at `.ai/templates/story.md`.

Arguments: $ARGUMENTS

## Steps

1. Parse `$ARGUMENTS` — the first word is the epic ID (e.g. `E001`), the rest is the title.
2. Read the existing stories in `.ai/stories/` and find the next available story number for that epic (e.g. if `E001-S001` and `E001-S002` exist, use `S003`).
3. Generate the story filename in the format `{EPIC_ID}-{STORY_ID}-{kebab-case-title}.md`.
4. Read `.ai/templates/story.md` and fill in:
   - `id`: the new story ID (e.g. `E001-S003`)
   - `title`: the title from the arguments (in quotes)
   - `epic`: the epic ID
   - `status`: `backlog`
   - `created` and `updated`: today's date
   - Leave `assigned_role`, `priority`, `estimate` as placeholders
5. Write the file to `.ai/stories/`.
6. Report the created file path and remind the user to fill in the description, acceptance criteria, and tasks.

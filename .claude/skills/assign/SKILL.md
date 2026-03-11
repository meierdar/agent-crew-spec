---
name: assign
description: Generate an agent assignment prompt for a story. Use when the user wants to assign a story to an agent or knows which story to work on next.
argument-hint: "[story-path] [role]  e.g. .ai/stories/E001-S002-login-ui.md flutter-developer"
---

Generate a ready-to-use agent assignment prompt for the given story and role.

Arguments: $ARGUMENTS

## Steps

1. Parse `$ARGUMENTS`:
   - First token: path to the story file (e.g. `.ai/stories/E001-S002-login-ui.md`)
   - Second token: role name (e.g. `flutter-developer`)
   - If either is missing, look at the current backlog to find the next `ready` story and ask the user to confirm.

2. Read the story file. Verify it exists and its current status.

3. List available roles from `.ai/roles/defaults/` and `.ai/roles/project/` for reference.

4. Output the assignment prompt in a clearly visible code block:

```
Work on [story-path] as [role].
```

5. Also show a summary: story title, epic, priority, estimate, and current status.

6. Remind the user: the agent will set the story to `in-progress` when it starts, and `review` when done.

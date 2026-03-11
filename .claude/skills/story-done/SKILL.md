---
name: story-done
description: Mark a story as ready for review (status → review) after completing the work. Use when an agent has finished a story and wants to signal it's ready for human review.
argument-hint: "[story-path]  e.g. .ai/stories/E001-S002-login-ui.md"
---

Mark the given story as complete and ready for review.

Story path: $ARGUMENTS

## Steps

1. If no path in `$ARGUMENTS`, look for the currently `in-progress` story in `.ai/stories/` and use that.
2. Read the story file.
3. Run through the automated DoD checklist from `.ai/dod.md` — confirm each automated check passes:
   - Code compiles / builds without errors
   - Tests pass
   - No `// TODO` / `// FIXME` without a story reference
   - No hardcoded secrets
   - No unrelated changes
4. If any automated check fails, report it and do NOT change the status.
5. If all automated checks pass:
   - Set `status: review` in the frontmatter
   - Set `updated` to today's date
6. Show the human operator the **Manual Checks** section from `.ai/dod.md` that they need to verify.
7. Remind: the human operator sets `status: done` after review — never the agent.

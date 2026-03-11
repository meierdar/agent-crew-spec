# Project: [PROJECT_NAME]

> This project uses [agent-crew-spec](https://github.com/YOUR_USER/agent-crew-spec) for agent work management.

## Agent Working Protocol

Before starting any work, follow this sequence:

1. **Read your role definition** in `.ai/roles/` (project-specific overrides take precedence over defaults)
2. **Read the assigned story** you've been given (path will be provided in the prompt)
3. **Read the parent epic** linked in the story's `epic` field for broader context
4. **Check `.ai/dod.md`** to understand what "done" means
5. **Work the story**, checking off tasks as you go
6. **Self-verify** against the acceptance criteria and DoD before declaring done

## Backlog Location

All work items live in `.ai/`:
- **Epics:** `.ai/epics/` — high-level feature goals
- **Stories:** `.ai/stories/` — atomic units of work for a single agent session
- **Roles:** `.ai/roles/defaults/` (base) + `.ai/roles/project/` (overrides)

## Story Assignment

Stories are assigned by the human operator via prompt. The agent does NOT self-assign or browse the backlog for work. A typical prompt looks like:

```
Work on .ai/stories/E001-S003-auth-flow.md as flutter-developer.
```

## Conventions

- Never modify stories you haven't been assigned
- Update the story's `status` frontmatter to `in-progress` when you start
- Check off tasks (`- [x]`) as you complete them
- Do not mark status as `done` — the human operator does that after review
- If a story is blocked or unclear, document the blocker in the story file under `## Blockers` and stop

## Project-Specific Notes

<!-- Add project-specific context, architecture decisions, tech stack, etc. here -->

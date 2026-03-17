# Project: agent-crew-spec

> This project uses [agent-crew-spec](https://github.com/meierdar/agent-crew-spec) for agent work management.
>
> **What this repo is:** A zero-dependency, Git-native convention for managing AI coding agents.
> Tech stack: Bash scripts, Markdown, YAML frontmatter. No build step, no runtime.

## Agent Working Protocol

Before starting any work, follow this sequence:

1. **Read your role definition** in `.ai/roles/` (project-specific overrides take precedence over defaults)
2. **Read the assigned story** you've been given (path will be provided in the prompt)
3. **Read the parent epic** linked in the story's `epic` field for broader context
4. **Check `.ai/dod.md`** to understand what "done" means
5. **Start the story:** `./bin/ai-progress <story-file> started`
6. **Work the story**, logging progress as you go:
   - `./bin/ai-progress <story-file> done "completed step description"`
   - `./bin/ai-progress <story-file> fix "corrected something"`
   - `./bin/ai-progress <story-file> wip "currently working on..."`
7. **Verify your work:** `./bin/ai-verify <story-file>`
8. **If all checks pass:**
   - `./bin/ai-progress <story-file> verified`
   - `./bin/ai-progress <story-file> review`
9. **If blocked:** `./bin/ai-progress <story-file> blocked "reason"`

## Backlog Location

All work items live in `.ai/`:
- **Epics:** `.ai/epics/` — high-level feature goals
- **Stories:** `.ai/stories/` — atomic units of work for a single agent session
- **Roles:** `.ai/roles/defaults/` (base) + `.ai/roles/project/` (overrides)
- **Checkpoints:** `.ai/checkpoints/` — auto-generated progress timelines

## Story Assignment

Stories are assigned by the human operator via prompt. The agent does NOT self-assign or browse the backlog for work. A typical prompt looks like:

```
Work on .ai/stories/E001-S003-auth-flow.md as flutter-developer.
```

## Conventions

- Never modify stories you haven't been assigned
- Use `ai-progress` to update story status — do not edit frontmatter directly
- Log progress with `ai-progress` as you work — do not pre-plan tasks
- Run `ai-verify` before declaring review — verification is mechanical, not self-reported
- Do not mark status as `done` — the human operator does that after review
- If a story is blocked, use `ai-progress <story> blocked "reason"` and stop

## Tools

### `ai-verify` — Executable acceptance criteria + DoD checks

Parses `verify` blocks from stories and `verify-always` blocks from role
files or `dod.md`, then runs them.

```sh
./bin/ai-verify <story-file>                # Run story + DoD checks
./bin/ai-verify <story-file> --story-only   # Story checks only
./bin/ai-verify <story-file> --dod-only     # DoD checks only
./bin/ai-verify <story-file> --dry-run      # Show checks without running
./bin/ai-verify <story-file> --boundary     # Check file scope violations
```

Check types: `FILE_EXISTS`, `FILE_NOT_EXISTS`, `DIR_EXISTS`, `RUN`, `TEST`,
`GREP`, `GREP_FAIL`. See `bin/ai-verify` header for full documentation.

### `ai-progress` — Real-time progress logging

Records what the agent actually does, replacing pre-planned task checklists.
Writes to both the story's `## Progress` section and `.ai/checkpoints/`.

```sh
./bin/ai-progress <story-file> started           # Mark story in-progress
./bin/ai-progress <story-file> done "message"    # Completed step
./bin/ai-progress <story-file> fix "message"     # Corrected something
./bin/ai-progress <story-file> wip "message"     # Work in progress
./bin/ai-progress <story-file> blocked "message" # Record blocker
./bin/ai-progress <story-file> verified          # Verification passed
./bin/ai-progress <story-file> review            # Submit for review
./bin/ai-progress <story-file> show              # Show progress
```

### `ai-backlog` — Backlog queries

```sh
./bin/ai-backlog status                          # Kanban overview
./bin/ai-backlog list --epic E001 --status ready # Filter stories
./bin/ai-backlog assign <story-path> <role>      # Generate agent prompt
```

## Project-Specific Notes

- Scripts live in `bin/` — run them from the project root
- BOARD.md lives at the **project root** for GitHub visibility
- GitHub Pages board auto-deploys on pushes to `.ai/stories/` or `.ai/epics/`
- When adding a new role, add a default in `.ai/roles/defaults/` — project overrides go in `.ai/roles/project/`
- All Bash scripts must be POSIX-compatible with zero external dependencies

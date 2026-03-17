# Agent Boot Protocol

Read this first. Then follow the steps.

## Steps

1. Read your ROLE file (path in assignment prompt)
2. Read your STORY file (path in assignment prompt)
   - If story has `## A2A`: read that section, follow LOAD directives
   - If no `## A2A`: read full story prose
3. Read context bus if referenced: `.ai/bus/<epic>.bus`
4. Read domain docs ONLY if listed in story `LOAD` directives
5. Work the story
6. Append decisions to bus: `@CTX`, `@DEC`, `@WARN` entries
7. Self-verify against `.ai/dod.md` before marking review

## Rules

- Never modify stories you weren't assigned
- Set `status: in-progress` when starting
- Set `status: review` when done (never `done`)
- If blocked: document in `## Blockers`, stop
- Stay within story scope — check `SCOPE -` lines

## Where things live

- Stories: `.ai/stories/`
- Epics: `.ai/epics/`
- Bus: `.ai/bus/`
- Roles: `.ai/roles/defaults/` (base) + `.ai/roles/project/` (override)
- DoD: `.ai/dod.md`
- Domain knowledge: `.ai/knowledge/` (read index first)

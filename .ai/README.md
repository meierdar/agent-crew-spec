# .ai — Agent Backlog System

This folder is a lightweight, Git-native project management system designed to manage work done by AI coding agents (Claude Code, Cursor, Aider, etc.) alongside human developers.

## Philosophy

- **Git is the single source of truth.** No external tools required.
- **Frontmatter is state.** Story status lives in YAML headers, not folder paths.
- **Agents are contractors, not employees.** They receive a specific story assignment and the context to complete it. They don't browse for work.
- **Humans are operators.** They write stories, assign work, and verify done.

## Structure

```
.ai/
├── README.md              ← You are here
├── dod.md                 ← Definition of Done (global)
├── epics/
│   └── E001-*.md          ← Feature-level goals
├── stories/
│   └── E001-S001-*.md     ← Atomic work units (one agent session)
├── roles/
│   ├── defaults/          ← Blueprint-provided role definitions
│   └── project/           ← Project-specific overrides (take precedence)
└── templates/
    ├── epic.md            ← Template for new epics
    └── story.md           ← Template for new stories
```

## Workflow

1. **Plan:** Create an epic describing the feature goal.
2. **Break down:** Write stories for the epic. Each story = one agent session.
3. **Assign:** Prompt the agent with the story path and role.
4. **Verify:** Review the agent's work against acceptance criteria and DoD.
5. **Close:** Set story status to `done`.

## Querying the Backlog

Since state lives in frontmatter, you can query with standard tools:

```bash
# All open stories
grep -rl "status: backlog\|status: ready" .ai/stories/

# Stories for a specific epic
grep -rl "epic: E001" .ai/stories/

# High-priority items
grep -rl "priority: high" .ai/stories/

# Stories assigned to a specific role
grep -rl "assigned_role: flutter-developer" .ai/stories/
```

Or use the provided helper script (if added to the project):

```bash
./ai-backlog status          # Kanban-style overview
./ai-backlog list --epic E001 --status ready
```

## Migrating an Existing Project

1. Copy this `.ai/` folder into your project root.
2. Customize `CLAUDE.md` in the project root (add project-specific context).
3. Add or override roles in `.ai/roles/project/`.
4. Create your first epic and break it into stories.
5. Start assigning.

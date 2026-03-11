# Claude Code Skills

Custom slash commands for this project. Invoke them in Claude Code with `/skill-name`.

## Agent-Crew-Spec Skills

| Command | Arguments | Description |
|---------|-----------|-------------|
| `/new-story` | `[epic-id] [title]` | Scaffold a new story file from template |
| `/new-epic` | `[title]` | Scaffold a new epic file from template |
| `/assign` | `[story-path] [role]` | Generate an agent assignment prompt |
| `/board` | — | Show current Kanban board status |
| `/story-done` | `[story-path]` | Verify DoD and mark story as `review` |
| `/standup` | `[today\|week]` | Summarize recent work from git + board |

## General Project Skills

| Command | Arguments | Description |
|---------|-----------|-------------|
| `/commit` | `[hint]` | Create a Conventional Commit for current changes |
| `/pr` | `[title hint]` | Create a GitHub Pull Request |
| `/fix-issue` | `[issue-number]` | Fetch a GitHub issue and implement the fix |
| `/review` | — | Review current changes for bugs and quality |

## Adding New Skills

Create a new directory under `.claude/skills/` with a `SKILL.md` file:

```
.claude/skills/
└── my-skill/
    └── SKILL.md
```

See the [Claude Code docs](https://code.claude.com/docs/en/skills.md) for the full format reference.

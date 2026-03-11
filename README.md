# agent-crew-spec

A zero-dependency, Git-native convention for managing AI coding agents like a team. No CLI to install. No runtime. Just Markdown files and a folder structure that any agent can read.

## The Problem

AI coding agents (Claude Code, Cursor, Copilot, Codex, Aider…) are powerful but chaotic. Without structure, you end up with:

- Agents doing work you didn't ask for
- No clear definition of "done"
- No way to track what's been completed
- Context lost between sessions
- Every project reinventing how to talk to agents

## The Idea

Treat AI agents like contractors on a team. Give them a **briefing** (story), a **role** (skill definition), and **acceptance criteria** (DoD) — then let them work.

Everything lives in a `.ai/` folder inside your repo. Agents read it. Humans write it. Git tracks it.

```
your-project/
├── CLAUDE.md              ← Entry point for Claude Code
├── .cursorrules           ← Entry point for Cursor
├── .ai/
│   ├── README.md          ← How this system works
│   ├── dod.md             ← Definition of Done (automated + manual checks)
│   ├── BOARD.md           ← Auto-generated Kanban view (see below)
│   ├── epics/
│   │   └── E001-*.md      ← Feature-level goals
│   ├── stories/
│   │   └── E001-S001-*.md ← Atomic work units (one agent session)
│   ├── roles/
│   │   ├── defaults/      ← Blueprint-provided role definitions
│   │   └── project/       ← Project-specific overrides
│   └── templates/
│       ├── epic.md
│       └── story.md
├── ai-backlog             ← Optional: CLI for terminal Kanban
└── ai-board-gen           ← Optional: generates BOARD.md from frontmatter
```

## How It Works

### 1. You write stories

Stories are Markdown files with YAML frontmatter:

```yaml
---
id: E001-S002
title: "Login & Registration UI"
epic: E001
status: ready
priority: high
assigned_role: flutter-developer
estimate: M
---
```

Followed by a description, acceptance criteria, tasks, and technical notes. See [templates/story.md](.ai/templates/story.md) for the full format.

### 2. You define roles

Roles describe *how* an agent should work — tech stack, conventions, quality expectations:

```
.ai/roles/defaults/flutter-developer.md   ← ships with the blueprint
.ai/roles/project/flutter-developer.md    ← your project overrides
```

Project overrides take precedence. This means the blueprint gives you sensible defaults, but every project can customize.

### 3. You assign work via prompt

```
Work on .ai/stories/E001-S002-login-registration-ui.md as flutter-developer.
```

The agent reads CLAUDE.md → finds the story → reads the role → checks the DoD → works.

### 4. The agent updates progress

- Sets `status: in-progress` in frontmatter
- Checks off tasks as it completes them
- Documents blockers if stuck
- Does **not** mark the story as `done` — that's your job after review

### 5. You review and close

Check the acceptance criteria. Verify the DoD. Set `status: done`.

## Kanban Board on GitHub

Since status lives in YAML frontmatter, a simple bash script can generate a readable `BOARD.md`:

```bash
./ai-board-gen > .ai/BOARD.md
```

A GitHub Action (`.github/workflows/update-board.yml`) runs this automatically on every push to `.ai/stories/` or `.ai/epics/`. The result is a Kanban-style view rendered directly on GitHub — no external tools needed.

You can also query the backlog from your terminal:

```bash
./ai-backlog status              # Kanban overview
./ai-backlog list --epic E001    # Filter by epic
./ai-backlog list --status ready # Filter by status
```

## What This Is (and What It Isn't)

**This is a convention.** A set of files, folders, and naming rules that structure how you work with AI agents. Like `.editorconfig` for editor settings or `conventional-commits` for commit messages.

**This is not a tool.** No npm install. No MCP server. No database. No vendor lock-in. If you stop using it, you still have readable Markdown files in your repo.

### How it compares

| | agent-crew-spec | Backlog.md | GitHub Issues |
|---|---|---|---|
| Installation required | No | Yes (npm/bun) | No |
| Agent roles/skills | Yes | No | No |
| Epic → Story hierarchy | Yes | No | Labels only |
| Definition of Done | Automated + manual | Per-task | No |
| Kanban view | Generated MD + terminal | CLI + web UI | Projects board |
| MCP integration | Not needed | Yes | Via Copilot |
| Works offline | Yes | Yes | No |

## Getting Started

### Option A: Clone into existing project

```bash
# From your project root
git clone https://github.com/YOUR_USER/agent-crew-spec.git .ai-setup
cp -r .ai-setup/.ai .
cp .ai-setup/CLAUDE.md .
cp .ai-setup/.cursorrules .
cp .ai-setup/ai-backlog .
cp .ai-setup/ai-board-gen .
cp -r .ai-setup/.github .
rm -rf .ai-setup
```

### Option B: Start from template

Use this repo as a GitHub template, then add your project code.

### After setup

1. Edit `CLAUDE.md` — add your project-specific context
2. Create or modify roles in `.ai/roles/project/`
3. Write your first epic in `.ai/epics/`
4. Break it into stories in `.ai/stories/`
5. Assign a story to your agent

## Design Decisions

- **Frontmatter over folders for state.** Moving files between folders creates noisy git history and breaks links. Status in YAML is grep-able, script-friendly, and diffable.
- **Two-part DoD.** Agents can self-verify some things (tests pass, lint clean). Humans verify others (acceptance criteria met, no unnecessary complexity). Separating them makes both sides accountable.
- **Stories, not tasks.** A story is the smallest unit of work that produces a reviewable outcome. Tasks are a checklist *within* a story, not separate files.
- **Roles are conventions, not permissions.** A role file doesn't restrict an agent — it tells the agent what standards to follow and what stack to use.
- **Agents don't self-assign.** This is deliberate. You prompt the agent with a specific story. The agent is a contractor, not an autonomous employee browsing a task board.

## Contributing

Contributions are welcome. This project is most useful if it reflects how different people actually work with AI agents.

### What we're looking for

- **New default roles** — supabase-backend, ui-designer, devops-engineer, data-engineer…
- **Better templates** — improvements to epic/story templates based on real usage
- **Agent entry points** — equivalents of CLAUDE.md/.cursorrules for other agents (Aider, Codex, Windsurf…)
- **Board improvements** — better visualization, filtering, or GitHub Action enhancements
- **Real-world examples** — show how you've used this on an actual project

### How to contribute

1. Fork the repo
2. Create a feature branch
3. Make your changes
4. Submit a PR with a clear description of what you changed and why

### What we won't merge

- Features that require a runtime or installation step (this stays zero-dependency)
- Vendor-specific integrations that break the agent-agnostic principle
- Complexity that doesn't earn its keep

## License

[MIT](LICENSE) — do anything, just give credit.

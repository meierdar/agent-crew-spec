# agent-crew-spec

[![Board](https://img.shields.io/badge/Board-View%20Kanban-0d1117?style=flat&logo=github)](./BOARD.md)
[![GitHub Pages](https://img.shields.io/badge/Live%20Board-GitHub%20Pages-blue?style=flat&logo=github)](https://meierdar.github.io/agent-crew-spec)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=flat)](./LICENSE)

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
├── BOARD.md               ← Auto-generated Kanban view (root = visible on GitHub)
├── bin/
│   ├── ai-backlog         ← CLI for terminal Kanban queries
│   ├── ai-board-gen       ← Generates BOARD.md from frontmatter
│   ├── ai-board-html      ← Generates HTML board for GitHub Pages
│   └── ai-init            ← Bootstrap agent-crew-spec into a new project
├── .github/workflows/
│   ├── update-board.yml   ← Auto-updates BOARD.md on push
│   └── pages.yml          ← Deploys HTML board to GitHub Pages
└── .ai/
    ├── README.md          ← How this system works
    ├── dod.md             ← Definition of Done (automated + manual checks)
    ├── epics/
    │   └── E001-*.md      ← Feature-level goals
    ├── stories/
    │   └── E001-S001-*.md ← Atomic work units (one agent session)
    ├── roles/
    │   ├── defaults/      ← Blueprint-provided role definitions
    │   └── project/       ← Project-specific overrides
    └── templates/
        ├── epic.md
        └── story.md
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
./bin/ai-board-gen > BOARD.md
```

`BOARD.md` lives at the **project root** so GitHub renders a link to it directly in the file browser, alongside README, Contributing, and License.

A GitHub Action (`.github/workflows/update-board.yml`) runs this automatically on every push to `.ai/stories/` or `.ai/epics/` — no manual step needed.

## Live HTML Board (GitHub Pages)

In addition to the Markdown board, a second Action (`.github/workflows/pages.yml`) generates a full HTML Kanban board and deploys it to GitHub Pages:

```bash
./bin/ai-board-html > _site/index.html
```

To enable:
1. Go to **Settings → Pages → Source** and select **GitHub Actions**
2. Set `REPO_URL` in `.github/workflows/pages.yml` to your repo URL for clickable story links
3. Push a story change — the board deploys automatically

You can also query the backlog from your terminal:

```bash
./bin/ai-backlog status              # Kanban overview
./bin/ai-backlog list --epic E001    # Filter by epic
./bin/ai-backlog list --status ready # Filter by status
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
| Kanban view | BOARD.md + HTML Pages + terminal | CLI + web UI | Projects board |
| MCP integration | Not needed | Yes | Via Copilot |
| Works offline | Yes | Yes | No |

## Getting Started

### Option A: One-line init (recommended)

```bash
# From your project root
bash <(curl -fsSL https://raw.githubusercontent.com/meierdar/agent-crew-spec/main/bin/ai-init)
```

The script creates the full `.ai/` structure, copies all scripts to `bin/`, writes `CLAUDE.md` and `.cursorrules`, and generates the initial `BOARD.md`. Interactive prompts guide you through the setup.

### Option B: Clone into existing project

```bash
# From your project root
git clone https://github.com/meierdar/agent-crew-spec.git .ai-setup
cp -r .ai-setup/.ai .
cp .ai-setup/CLAUDE.md .
cp .ai-setup/.cursorrules .
cp -r .ai-setup/bin .
cp -r .ai-setup/.github .
rm -rf .ai-setup
chmod +x bin/ai-backlog bin/ai-board-gen bin/ai-board-html bin/ai-init
./bin/ai-board-gen > BOARD.md
```

### Option C: Start from template

Use this repo as a GitHub template (click **Use this template** on GitHub), then add your project code.

### After setup

1. Edit `CLAUDE.md` — add your project-specific context
2. Create or modify roles in `.ai/roles/project/`
3. Write your first epic in `.ai/epics/`
4. Break it into stories in `.ai/stories/`
5. Assign a story: `./bin/ai-backlog assign .ai/stories/E001-S001-my-task.md <role>`
6. Enable GitHub Pages: **Settings → Pages → Source → GitHub Actions**

## Claude Code Skills

The repo ships with custom slash commands in `.claude/skills/`. Open Claude Code in any project that uses agent-crew-spec and use them directly:

| Command | What it does |
|---------|-------------|
| `/new-story E001 Add login button` | Scaffold a story from template |
| `/new-epic User Authentication` | Scaffold an epic from template |
| `/assign .ai/stories/E001-S002.md flutter-developer` | Generate an agent prompt |
| `/board` | Show Kanban status |
| `/story-done` | Verify DoD, set status → review |
| `/standup` | Summarize today's work from git + board |
| `/commit` | Conventional Commit for current changes |
| `/pr` | Create a GitHub Pull Request |
| `/fix-issue 42` | Fetch issue #42 and implement the fix |
| `/review` | Code review of current changes |

See [`.claude/skills/README.md`](.claude/skills/README.md) for the full list.

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

# Contributing to agent-crew-spec

Thanks for your interest in contributing. This project stays useful by reflecting how people actually work with AI agents.

## Principles

1. **Zero dependencies.** No npm, no pip, no runtime. If your contribution requires installing something, it doesn't belong here.
2. **Agent-agnostic.** Works with Claude Code, Cursor, Copilot, Aider, Codex, and anything that reads files. No vendor lock-in.
3. **Convention over configuration.** Sensible defaults that work out of the box. Override only when needed.
4. **Simplicity earns its place.** Every file in the blueprint must justify its existence. If it doesn't help the human or the agent, remove it.

## What to contribute

### High-value contributions

- New **default roles** (e.g. `supabase-backend`, `devops-engineer`, `data-engineer`, `technical-writer`)
- **Agent entry points** for tools beyond Claude Code and Cursor (Aider, Codex, Windsurf, Copilot…)
- Improvements to **epic/story templates** based on real-world usage
- Enhancements to **`bin/ai-board-gen`**, **`bin/ai-board-html`**, or **`bin/ai-backlog`** scripts
- **Documentation** — clearer README, better examples, translations
- **Real-world case studies** — how you used this on a project (add to `examples/`)

### What won't be merged

- Anything that adds a runtime dependency
- Vendor-specific features that break agent-agnosticism
- Changes that make the system harder to understand for newcomers
- AI-generated PRs without human review and testing

## How to submit

1. Fork the repository
2. Create a branch: `git checkout -b feature/my-contribution`
3. Make your changes
4. Test: if you changed a script in `bin/`, run it. If you changed a template, use it.
5. Submit a PR with:
   - **What** you changed
   - **Why** (what problem it solves or what it improves)
   - **How you tested** it

## Style

- Markdown files: use YAML frontmatter where appropriate
- Shell scripts: POSIX-compatible bash, no exotic dependencies
- Naming: `kebab-case` for files, `UPPER_CASE` for template placeholders
- Keep lines under 100 characters in documentation

## Code of Conduct

Be respectful. Be constructive. Assume good intent. This is a small project with big ambitions — let's keep it welcoming.

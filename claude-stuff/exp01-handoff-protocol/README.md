# Experiment 01: Agent Handoff Protocol

## Problem

Stories reference other stories informally ("see E001-S001"). When Agent A
finishes work that Agent B needs, the context transfer is lossy — Agent B
has to re-discover what Agent A actually built, where files landed, what
decisions were made.

## Hypothesis

A structured `## Handoff` section in completed stories could carry forward
the context that the next agent actually needs, without requiring agents to
read each other's full codebases.

## Design

A handoff block is a fenced section at the bottom of a story, written by
the completing agent, read by any downstream agent whose story lists it
as a dependency.

```markdown
## Handoff

> Written by: backend-developer
> Completed: 2026-03-14

### What was built
- Auth API at `lib/features/auth/data/auth_repository.dart`
- Exposes `signIn(email, password)` and `signUp(email, password)`

### Decisions made
- Used Supabase Auth (not custom JWT) — see epic E001 for rationale
- Passwords validated server-side, minimum 8 chars

### What the next agent needs to know
- Auth repo returns `AsyncValue` — handle loading/error states in UI
- No email verification flow yet (out of scope, see E001-S005)

### Files touched
- `lib/features/auth/data/auth_repository.dart` (new)
- `lib/features/auth/domain/auth_state.dart` (new)
- `supabase/migrations/001_auth_setup.sql` (new)
```

## Why this shape

1. **"What was built"** — saves the next agent from grepping blindly.
2. **"Decisions made"** — prevents the next agent from re-litigating or
   contradicting choices.
3. **"What the next agent needs to know"** — the actual handoff. Only
   things that affect downstream work, not a full changelog.
4. **"Files touched"** — concrete paths. Agents work in files, not concepts.

## What I'd add to story frontmatter

```yaml
depends_on:
  - E001-S001  # Must be status: review or done before this starts
```

An agent picking up a story with `depends_on` would:
1. Read each dependency story
2. Look for the `## Handoff` section
3. If no handoff exists and status isn't done/review — block and document why

## Open questions

- Should handoffs be in the story file itself, or in a separate
  `.ai/handoffs/E001-S001.md` file? Inline is simpler. Separate file
  avoids bloating stories and lets multiple downstream stories reference
  the same handoff without path gymnastics.
- Should the handoff format be validated by `ai-backlog`? Probably yes
  for `depends_on` resolution, probably no for handoff content (too
  free-form to lint usefully).

# Findings: What Happens When Knowledge Files Grow Big

## I was wrong in Exp 08

I said "CLAUDE.md, roles, skills, domain docs — read once, low cost,
don't bother translating." That's true at 2,000 tokens total. It's
disastrously wrong at 42,000 tokens total.

The problem isn't format. **The problem is loading strategy.**

## The math

A 200K context window sounds huge. But:
- ~100K goes to conversation, reasoning, and tool descriptions
- ~30K goes to actual source files being edited
- That leaves ~70K for project knowledge

At scale (mature project, rich domain docs, many skills):
- Without progressive loading: **42K of knowledge** → 11K left for code → 3 files
- With progressive loading: **9K of knowledge** → 44K left for code → 13 files

That's a 3.2x improvement in the agent's working memory for code.
It's the difference between "can edit one file" and "can see the
whole feature."

## The solution: three tiers, not two layers

Exp 08 proposed two layers (human + agent format). That was the wrong
framing. The right framing is three **loading tiers**:

### Tier 1: Kernel (~200 tokens, always loaded)

A minimal boot file. Contains: who you are, what to do, where to
find more, core rules. That's it.

This replaces the 5,000-token CLAUDE.md as the agent's entry point.
CLAUDE.md still exists for humans and for deep reference, but the
agent starts with the kernel.

### Tier 2: Task-relevant (~3-9K tokens, loaded per story)

Guided by the story's `## A2A` section:
- `LOAD .ai/knowledge/auth.md` — load this domain doc
- `IN .ai/bus/E001.bus @CTX:users-table` — load this bus entry
- Role summary (not full definition)
- DoD

Only knowledge relevant to THIS task gets loaded. The A2A section
acts as a **loading manifest** — it tells the agent exactly what
context it needs.

### Tier 3: Reference (0 tokens upfront, loaded on demand)

Everything else stays on disk:
- Full role definitions (agent reads summary in Tier 2)
- Domain docs not listed in LOAD directives
- Architecture decision records
- Other teams' knowledge

The agent can still read these files if it discovers it needs them
during work. But it doesn't load them upfront.

## What this changes about format

**Tier 1 (kernel):** Agent-optimized. Short, structured, no prose.
Every token counts because this is the one file every agent loads
every time.

**Tier 2 (task-relevant):** Agent-optimized for bus and A2A.
Human-readable for domain docs (they're long enough that format
waste is noise compared to content). The bus entries and A2A section
use compact DSL. The domain knowledge docs can stay markdown.

**Tier 3 (reference):** Human-readable. Format doesn't matter
because these are loaded selectively and infrequently.

## The A2A section becomes a loading manifest

This is the key conceptual shift. The `## A2A` section in a story
isn't just "instructions in agent format." It's a **loading manifest**
that tells the agent what knowledge to pull into context:

```
## A2A

@STORY E001-S003 backend-developer M critical

LOAD .ai/knowledge/auth.md        ← domain knowledge
LOAD .ai/knowledge/api-style.md   ← domain knowledge
LOAD .ai/knowledge/errors.md      ← domain knowledge

IN .ai/bus/E001.bus @CTX:users-table       ← specific bus entry
IN .ai/bus/E001.bus @CTX:auth-api-contract ← specific bus entry
IN .ai/bus/E001.bus @WARN:*                ← all warnings
IN docs/api/auth.yaml                      ← artifact

OUT lib/auth/routes.dart NEW
SCOPE +login -password_reset
```

`ai-prep` generates this from the story's dependencies, role, and
keywords. The LOAD directives can be hand-tuned if the auto-generation
misses something.

## What this means for your setup

### Now (zero effort)

Write stories with `## A2A` sections. Even without the LOAD directive,
the structured IN/OUT/SCOPE saves tokens on disambiguation.

### When knowledge grows (medium effort)

1. Create `.ai/boot.md` — the 200-token kernel
2. Add Summary sections to role files
3. Create `.ai/knowledge/index.md` — topic → file mapping
4. Add LOAD directives to the A2A section

### When it really scales (continuous)

- `ai-prep` auto-generates LOAD directives based on story keywords
  and role
- Bus entries get scoped queries (already supported)
- Knowledge docs get split into smaller, focused files
- Context budget becomes a tracked metric

## The real lesson

The question was "should skill files and domain knowledge have an
agent layer?" The answer is: **at small scale, no. At large scale,
the question itself is wrong.**

The right question is: **"which knowledge should be loaded for
THIS specific task?"** Not "how should knowledge be formatted"
but "should this knowledge be in the agent's context at all?"

Format optimization (Exp 06-08) saves 25-50% per file.
Loading optimization (this experiment) saves 76% by not loading
files that aren't needed.

The loading strategy dominates. Format is a refinement.

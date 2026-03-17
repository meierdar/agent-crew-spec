# The Context Budget Problem — And How To Fix It

## What I got wrong in Exp 08

I said: "CLAUDE.md, roles, DoD, epics — read once, low cost, no
translation needed."

That's true when each file is 200-500 tokens. It's catastrophically
wrong when:
- CLAUDE.md grows to 5,000 tokens (real projects add sections over time)
- Domain knowledge docs hit 15,000 tokens
- 15 skill files total 10,000 tokens
- Architecture decision records add 5,000 tokens

"Read once" doesn't mean "cheap." At scale, "read once" means
**42,000 tokens consumed before the agent reads a single line
of actual code.** That leaves 11K for source files — maybe 3 files.
Complex changes spanning 5-10 files become physically impossible.

## The real problem: loading vs. needing

An agent implementing a Flutter login screen does NOT need:
- The db-engineer role definition
- The DevOps coding standards
- API reference for endpoints it's not touching
- Architecture decisions about backend caching
- Skill files for CI/CD pipeline management

But today, everything gets loaded. There's no mechanism to say
"this agent only needs 20% of the knowledge base."

## Solution: Progressive Context Loading

Instead of loading everything upfront, load in three tiers:

```
TIER 1: ALWAYS LOAD (~2K tokens)
  Core protocol only. What every agent needs regardless of task.

TIER 2: TASK-RELEVANT (~5-15K tokens)
  Loaded based on story metadata. Role, bus entries for dependencies,
  relevant domain docs.

TIER 3: ON-DEMAND (0 tokens upfront)
  Loaded only if agent needs it during work. API refs, other roles,
  architecture docs.
```

### Tier 1: The Kernel (~2K tokens)

A compact "boot file" that every agent loads. Contains ONLY:
- Who you are (role name, 1 line)
- What to do (story reference, 1 line)
- Where to find more (file paths for Tier 2)
- Core rules (5-10 rules, not 50)

```
@BOOT flutter-developer E001-S003
ROLE .ai/roles/defaults/flutter-developer.md
STORY .ai/stories/E001-S003.md
BUS .ai/bus/E001.bus
DOD .ai/dod.md
RULES
  - Prioritize ## A2A section in story if present
  - Read bus before starting work
  - Append to bus as you make decisions
  - Check off tasks as you complete them
  - Set status: review when done (never done)
  - If blocked, document in ## Blockers and stop
```

~200 tokens. The agent knows who it is, what to do, and where to
look for more. It reads the role file and story next — those are
Tier 2.

### Tier 2: Task-Relevant Loading (~5-15K)

The story's `## A2A` section tells the agent exactly what to load:

```
## A2A
IN .ai/bus/E001.bus @CTX:users-table @CTX:auth-api-contract
IN .ai/bus/E001.bus @WARN:*
IN docs/api/auth.yaml
```

The agent loads ONLY:
- Its role definition (~400 tokens, not all 13 roles)
- The story file (~500 tokens)
- Bus entries referenced in the A2A block (~300 tokens for 5 entries)
- Files referenced in the A2A block (API spec, etc.)
- The DoD (~300 tokens)
- The epic (~300 tokens)

Total Tier 2: ~2,000-5,000 tokens. Compare to 42,000 tokens
if everything loads.

### Tier 3: On-Demand

Everything else stays on disk. The agent reads it ONLY if it
discovers it needs it during work:

- "I need to understand how the caching layer works"
  → reads the architecture decision record for caching
- "I need to call an API I haven't seen before"
  → reads the relevant section of the API reference
- "I need to coordinate with the backend pattern"
  → reads the backend-developer role for conventions

This is how human developers work too. Nobody memorizes the entire
codebase before starting a ticket. They read what's relevant and
look up what they need.

---

## What changes in the spec

### CLAUDE.md becomes two files

```
CLAUDE.md                  — HUMAN reads this (full project docs)
.ai/boot.md               — AGENT reads this (kernel, ~200 tokens)
```

CLAUDE.md can grow as big as you want. It's for humans and for
agents that need deep context. The boot file is the minimal
starting instruction.

### Role files get a compact summary header

```markdown
# Role: flutter-developer

## Summary
<!-- Agent reads this first (Tier 2, ~100 tokens) -->
Flutter 3.x, Riverpod, go_router, Supabase. Feature-first folders.
Widget tests + unit tests. No magic strings. Result types for errors.

## Full Definition
<!-- Agent reads this only if needed (Tier 3) -->
...detailed conventions, examples, edge cases...
```

The summary is enough for most tasks. The full definition is
there for when the agent is doing something unusual and needs
the detailed conventions.

### Domain knowledge gets indexed

Instead of loading all domain docs, create an index:

```
# .ai/knowledge/index.md

| Topic | File | When to read |
|-------|------|-------------|
| Auth architecture | .ai/knowledge/auth.md | Stories touching auth |
| Caching strategy | .ai/knowledge/caching.md | Stories touching data layer |
| API conventions | .ai/knowledge/api-style.md | Stories creating endpoints |
| UI patterns | .ai/knowledge/ui-patterns.md | Stories creating UI |
| Deploy pipeline | .ai/knowledge/deploy.md | DevOps stories only |
```

Agent reads the index (~100 tokens), finds relevant topics for
its story, loads only those docs.

### Story A2A section gets a LOAD directive

```
## A2A

LOAD .ai/knowledge/auth.md
LOAD .ai/knowledge/api-style.md
IN .ai/bus/E001.bus @CTX:users-table
...
```

The LOAD directive tells the agent "read this domain doc for this
task." It can be auto-generated by `ai-prep` based on the story's
role, dependencies, and keywords.

### Bus gets scoped queries

Instead of loading the entire bus (5,000+ tokens at scale), the
A2A section specifies which entries:

```
IN .ai/bus/E001.bus @CTX:users-table @CTX:auth-api-contract @WARN:*
```

The `bus-parse query` tool already supports this. The agent loads
~5 entries (~300 tokens) instead of 50+ entries (~3,000 tokens).

---

## The numbers at scale

### Without progressive loading (current)

```
Knowledge loading:    42,000 tokens (84% of budget)
Source file capacity: 11,000 tokens (3 files)
```

### With progressive loading

```
Tier 1 (kernel):         200 tokens
Tier 2 (task-relevant): 3,000 tokens
Tier 3 (on-demand):         0 tokens (loaded as needed)
────────────────────────────────────
Knowledge loading:      3,200 tokens (4.6% of budget)
Source file capacity:  49,800 tokens (15+ files)
```

That's a **13x improvement** in available source file context.
The agent goes from being able to hold 3 files to 15+ files.
That's the difference between "can do simple changes" and
"can do complex refactors across the codebase."

---

## The bigger insight

**The scaling problem isn't about format. It's about loading strategy.**

Exp 06-08 optimized the FORMAT of inter-agent communication (compact
DSL, typed entries, tables over prose). That saves 25-50% per file.
Important but not sufficient.

The real win is **not loading files at all** until they're needed.
Going from 42K to 3.2K isn't a 50% improvement — it's a 92% improvement.
No format optimization can match that.

The format optimizations from Exp 06-08 still matter for the files
you DO load (bus entries, story A2A sections). But the loading
strategy is the dominant factor.

## What this means for "should everything have two layers?"

**Revised answer:** At scale, you need THREE layers:

1. **Kernel layer** — ~200 tokens, always loaded, tells agent where
   to find everything else
2. **Task layer** — ~3K tokens, loaded based on story metadata,
   agent-optimized format
3. **Reference layer** — loaded on-demand, can be any format because
   the agent only reads what it needs, when it needs it

The kernel and task layers should be agent-optimized (compact DSL).
The reference layer can stay human-readable because it's loaded
selectively and the waste per-read is manageable.

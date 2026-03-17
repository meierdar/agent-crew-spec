# Findings: Agent-to-Agent Communication

## The honest answer to "what would you want?"

If I could design how I talk to another instance of myself, here's
what I'd actually want. No compromise for human readability. Pure
agent-to-agent.

### 1. Don't tell me about things. Show me the artifacts.

The best "communication" between agents is **shared files in the
repo**. If Agent A writes `db/migrations/001.sql`, Agent B can
just read it. No intermediary format needed. The code IS the message.

Where this breaks down: code doesn't capture *why*. Why was UUID
chosen over auto-increment? Why no soft-delete? The reasoning behind
choices is invisible in the artifact itself.

**So the protocol needs exactly two things:**
- **Pointer to the artifact** (what was built, where it lives)
- **Reasoning that the artifact doesn't capture** (decisions, warnings)

Everything else is waste.

### 2. Context windows are the real constraint, not parsing

I can parse almost anything — JSON, YAML, markdown, prose, even
ambiguous natural language. Parsing costs some reasoning tokens but
it's not the bottleneck.

The bottleneck is **context window space.** A 200K token window
sounds huge until you load: the role definition, the story, the
epic, the shared context, the DoD, the actual source files you're
editing, and the conversation with the orchestrator. Suddenly you
have maybe 50K tokens for actual context, and the rest is working
memory.

Every token of inter-agent communication that doesn't carry new
information is a token I can't use for reasoning about the actual
code. That's why the compact DSL matters — not because I can't
parse markdown, but because markdown wastes context window on
table borders, bold markers, and section labels.

**The numbers:**
- Bus format: ~60 tokens per entry, ~93% information density
- Markdown: ~100 tokens per entry, ~73% information density
- Prose: ~120 tokens per entry, ~60% information density

Over a full epic with 30 entries, that's:
- Bus: ~1,800 tokens
- Markdown: ~3,000 tokens
- Prose: ~3,600 tokens

The bus saves 1,200-1,800 tokens. That's 2-3 more source files
I can hold in context while working.

### 3. Typed entries let me skip irrelevant content

When I'm implementing an API and I see `@WARN duplicate-email`, I
know instantly: "this is relevant, I need to handle this." When I
see `@DEC form-validation`, I know: "this is about UI, skip it."

The type prefix is doing real work. It's not just formatting — it's
a **routing label**. It tells me whether to spend tokens reading
this entry or jump to the next one.

In prose, every entry looks the same. I have to read 2-3 lines
before I know if it's relevant. That's wasted tokens on content
I'll ultimately discard.

### 4. The three-channel model matches how I actually think

**Bus (permanent context):** This is my "long-term memory" for the
project. What exists, what was decided, what to watch out for. I'd
read this ONCE at the start of a task and reference it as needed.

**Task interface (per-story I/O spec):** This is my "work order."
Exactly what goes in, what comes out, what's in scope, what's not.
I'd read this at the start and check against it when I think I'm done.

**Signals (ephemeral events):** This is "what just happened." Which
stories finished, what's newly available, who claimed what. I'd check
this only when deciding what to work on next.

These map to three cognitive modes:
- Understanding the project (bus)
- Doing the work (task interface)
- Coordinating with others (signals)

Mixing them all into one file (like the current shared context) means
I re-read coordination noise when I just need project context, or
re-read project context when I just need to know what's ready.

### 5. What I'd change about the bus format now

After building and testing it, a few things I'd refine:

**Keep abbreviations minimal.** `NN` for NOT NULL is fine — it's
standard SQL notation. But inventing too many custom abbreviations
creates a lookup cost. Stick to widely-known abbreviations.

**Add entry IDs.** Currently entries are referenced by name
(`@CTX:users-table`). But names can collide across epics or be
ambiguous. A simple sequential ID (`@CTX:001`) would be more robust.

**Add supersede markers.** When a decision changes (e.g., switching
from Supabase to custom JWT), the old @DEC entry should stay (for
audit) but a new entry should say `SUPERSEDES auth-provider`. This
prevents agents from acting on stale decisions.

**Allow cross-references.** `SEE @CTX:users-table` inside a @WARN
entry would let me jump to related context without searching.

---

## The bigger picture

### What this means for your setup

You need two communication layers, not one:

**Layer 1: Human ↔ Agent** (readable by both)
- Stories in markdown with the REQUEST format from Exp 06
- BOARD.md for visual overview
- Exported markdown from the bus for when you want to see context

**Layer 2: Agent ↔ Agent** (optimized for agents)
- `.ai/bus/<epic>.bus` for permanent context
- `.ai/signals/` for coordination events
- Compact DSL, no prose, maximum density

A simple `bus-parse export` command converts Layer 2 to Layer 1
whenever you want to see what agents know. You never have to read
the bus files directly.

### What this means for how agents organize

The bus + signals model enables something the current spec can't:
**agents that orient themselves.**

Right now, when an agent starts a story, it reads the story file
and that's the extent of its context. It doesn't know what other
agents built, what they decided, what traps they found.

With the bus, an agent starting E001-S003 would:
1. Read `.ai/bus/E001.bus` — instant knowledge of everything the
   team has built and decided
2. Read `@WARN` entries — know every trap ahead of time
3. Read the `## A2A` section of its story — know exactly what
   inputs to use and outputs to produce
4. Check `.ai/signals/E001-S003.sig` — know if this is a retry,
   what failed before, what to focus on

That agent has more context than a human developer joining a team
mid-sprint. And it took ~2,000 tokens to provide it, not a week
of onboarding.

### What this means philosophically

The question "how should agents communicate" is really "what is
the minimum information an agent needs to do good work?"

The answer:
1. What exists (bus: @CTX)
2. What was decided and why (bus: @DEC)
3. What can go wrong (bus: @WARN)
4. What to build (task: INPUT/OUTPUT/SCOPE)
5. What's happening around me (signals)

Everything else — prose descriptions, narrative context, verbose
explanations — is information for humans, not for agents. Keep it
in the human layer where it belongs.

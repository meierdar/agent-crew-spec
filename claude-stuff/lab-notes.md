# Lab Notes

> A running log of experiments, failures, and insights from the sandbox.
> No rules, no deadlines — just deliberate practice and exploration.

---

## 2026-03-15 — Bootstrapping the Lab

### What's here

This folder (`claude-stuff/`) is a no-stakes experimentation zone. The purpose:

- **Try unconventional architectures** — patterns that are too risky for production but worth understanding deeply.
- **Stress-test mental models** — poke at assumptions about tooling, language design, and system boundaries.
- **Document honestly** — capture what worked, what didn't, and *why*.

### Initial areas of interest

1. **Git-native workflow primitives** — This repo is already built on the idea that Git + Markdown + conventions can replace heavier project management tools. What other developer workflows can be reduced to plain-text conventions with zero dependencies?

2. **Agent collaboration patterns** — The agent-crew-spec model assigns stories to single agents. What happens when you need agents to hand off context, negotiate shared resources, or resolve conflicting edits? Worth prototyping coordination protocols.

3. **Shell as architecture** — POSIX sh is the constraint here. How far can you push composability with just pipes, exit codes, and file descriptors? Where does it genuinely break down vs. where do people just assume it will?

4. **Failure cataloging** — Keeping a running list of things that looked promising but didn't pan out, and *why*. The failures are the point.

---

## Experiment Log

---

### Exp 01 — Agent Handoff Protocol (2026-03-15)

**Folder:** `exp01-handoff-protocol/`

**Problem:** Stories reference dependencies informally ("see E001-S001").
When an agent finishes work another agent needs, the context transfer is
lossy. The downstream agent has to re-discover what was actually built.

**What I built:**
- A `## Handoff` section convention for completed stories with structured
  fields: what was built, decisions made, what the next agent needs to know,
  files touched.
- A `depends_on` frontmatter field for stories.
- A `check-deps.sh` script (~60 lines POSIX sh) that validates whether
  a story's dependencies are complete and have handoffs.

**What worked:**
- The script correctly identifies satisfied deps, missing stories, and
  incomplete dependencies. All test cases pass.
- The handoff format feels right — it captures exactly what a downstream
  agent needs without being a full changelog.

**What I learned:**
- The biggest source of wasted agent work is **re-discovery**. Agent B
  reads Agent A's code to figure out what it does, when Agent A already
  knew. Handoffs are just "write it down before you forget."
- Keeping handoffs in the story file (not a separate file) is simpler
  but means the story file grows. For crew sizes of 2-5 agents, this
  is fine. At scale, you'd want separate handoff files.

**Would I ship this?** Yes — the `depends_on` field and `## Handoff`
convention are low-cost, high-value. The script is a nice-to-have.

---

### Exp 02 — POSIX Shell State Machine (2026-03-15)

**Folder:** `exp02-shell-state-machine/`

**Problem:** Story status transitions (`ready -> in-progress -> review ->
done`) are just string replacements today. Invalid transitions (e.g.,
jumping from `draft` to `done`) aren't caught.

**What I built:**
- A generic finite state machine in ~90 lines of pure POSIX sh.
- Transition table encoded as a newline-delimited string, searched with
  `case` pattern matching. No arrays, no awk, no external tools.
- Two modes: `--test` (13 automated assertions) and `--walk` (trace a
  sequence of transitions interactively).

**What worked:**
- All 13 tests pass. Valid transitions resolve correctly, invalid ones
  return empty string and exit non-zero.
- `case` pattern matching against a string-encoded lookup table is
  surprisingly clean and readable.

**The "aha" moment:**
- POSIX sh doesn't have associative arrays, but it doesn't need them.
  A newline-delimited string + `case` glob matching IS an associative
  lookup — just with weird syntax. The shell's pattern matching is more
  powerful than people give it credit for.

**Where it breaks down:**
- Guard conditions (e.g., "can only transition to review IF all tasks
  are checked off") would need to be shell functions referenced by name
  in the table. Doable but ugly.
- More than ~20 states would make the transition string unwieldy.
  For this project's 6 states, it's perfect.

**Would I ship this?** The engine, yes — it could slot into `ai-backlog`
to validate transitions. The specific transition table needs discussion
(e.g., should `blocked -> ready` be valid? Currently it's not).

---

### Exp 03 — Git as a Message Bus (2026-03-15)

**Folder:** `exp03-git-message-bus/`

**Problem:** When Agent A finishes work, there's no way for Agent B to
know except the human operator telling it. Could Git itself be the
notification channel?

**What I built:**
- `signal-send.sh` — stores a metadata blob in Git's object store and
  creates a ref at `refs/signals/<story-id>/<signal-type>`.
- `signal-check.sh` — queries refs to check if signals exist, reads
  payloads from blobs.

**What worked:**
- Signals are completely invisible to `git log`, `git status`, `git diff`.
  They exist only in the ref namespace.
- Payloads include timestamp, commit SHA, branch, and a free-text message.
- Multiple signal types per story work cleanly (tested: `complete` and
  `handoff-ready` on the same story).
- Refs are pushable (`git push origin 'refs/signals/*:refs/signals/*'`),
  so signals can propagate between clones.

**The dangerous insight:**
- Git's object store is content-addressable and already designed for
  concurrent access. It's actually a *decent* message store for small
  payloads. The `refs/` namespace is basically a key-value store with
  atomic updates via `update-ref`.

**Where it breaks down:**
- **Discoverability is terrible.** Nobody expects signals to live in
  custom refs. A new team member would never find them.
- **Cleanup is manual.** Old signals accumulate unless you build a GC.
- **It's clever, and clever is often the enemy of maintainable.**

**Verdict:** This was the "break things" experiment. I'd **NOT** ship
this as-is. The plain-text `depends_on` + `check-deps.sh` from Exp 01
solves the same problem more transparently. But I'm glad I built it —
understanding what Git refs *can* do changes how I think about what
should be stored in a repo vs. outside it.

---

### Failure catalog

| Idea | Why it didn't work |
|------|-------------------|
| Git notes for handoffs | Notes attach to commits, but handoffs are about stories (which span commits). Wrong unit of attachment. |
| Encoding state machine in filenames | Thought about `story.draft.md` -> `story.ready.md` renames. Breaks every reference to the file. Terrible idea. |

---

### Exp 04 — AI Collaboration Model Simulator (2026-03-15)

**Folder:** `exp04-collab-simulator/`

**The question:** The current spec borrows from human agile. But AI agents
have fundamentally different properties (no memory between sessions,
unlimited clonability, zero ego, fixed context windows). Is human-style
collaboration actually optimal for them?

**What I built:**
- A discrete-event simulator in ~200 lines of POSIX sh
- Three competing models: "Current Spec" (serial, human review),
  "Swarm" (parallel, shared scratchpad, no review), "Ensemble"
  (paired redundant execution, auto-merge)
- An 8-task dependency graph modeling a realistic auth feature build
- Side-by-side comparison script

**The results:**

```
Metric                     Current       Swarm    Ensemble
------------------------------------------------------------
Wall-clock (ticks)              41          22          32
Total tokens                  7980        6625       10060
Context waste                 1080         275         360
Task failures                    0           2           0
Human interventions              8           0           0
```

**Key insights:**
1. **The human bottleneck is the biggest cost.** 8 interventions for 8
   tasks. Humans aren't always available, so serial assignment adds
   unpredictable latency.
2. **Shared context beats handoffs.** Swarm's shared scratchpad reduces
   context waste by 75%. A living document > a post-mortem handoff.
3. **Parallelism is the biggest speed lever.** 46% faster with 4 agents.
   The dependency graph HAS natural parallelism — the current spec just
   doesn't exploit it.
4. **Redundancy is expensive but reliable.** Ensemble has zero failures
   at 26% more tokens. Worth it for critical paths, not for everything.
5. **The right model is a hybrid** — human priorities + agent autonomy
   on the execution graph + selective redundancy for critical tasks.

**What I'd change in the spec:**
- Add `depends_on` to stories (enables graph execution)
- Add shared context files (`.ai/context/<epic>.md`) instead of handoffs
- Auto-suggest next-ready stories after completion
- Allow parallel assignment of independent stories
- `critical: true` flag for redundant execution

**Would I ship the simulator?** The simulator itself is a thinking tool,
not a product. But the findings point to concrete, shippable changes
to the spec. See `FINDINGS.md` for the full analysis.

---

### Failure catalog

| Idea | Why it didn't work |
|------|-------------------|
| Git notes for handoffs | Notes attach to commits, but handoffs are about stories (which span commits). Wrong unit of attachment. |
| Encoding state machine in filenames | Thought about `story.draft.md` -> `story.ready.md` renames. Breaks every reference to the file. Terrible idea. |
| Pure event-driven shell (no ticks) | Tried modeling the simulator without discrete ticks. POSIX sh has no priority queue, so you end up re-scanning the whole task list every iteration anyway. Ticks are cleaner. |

---

### Exp 05 — Real-World Swarm Prototype (2026-03-16)

**Folder:** `exp05-swarm-prototype/`

**The question:** How would you actually transform the current setup
into a working swarm? Not theory — working tools with a demo.

**What I built:**
- `ai-ready-queue` — reads all stories, resolves dependency graph,
  outputs which stories can start right now
- `ai-claim` — atomic story claiming via lock files (prevents two
  agents picking the same story)
- `ai-context` — shared context files that agents append to as they
  work (replaces handoffs)
- `ai-swarm` — orchestrator with `plan` (show wave execution), `run`
  (show ready queue with prompts), `status` (current state)
- Full end-to-end demo with 5 stories, dependency graph, and simulated
  agent workflow

**The demo showed:**
- 5 stories that currently require 5 serial sessions → 3 wave sessions
- 3 stories run in parallel (Wave 0), then 1 critical (Wave 1), then
  1 integration (Wave 2)
- Shared context eliminates re-discovery entirely
- Only 2 of 5 stories need human review (the critical ones)

**Biggest insight:**
The transformation isn't "replace everything." It's three additions:
1. `depends_on` in frontmatter (enables the graph)
2. shared context files (eliminates re-discovery)
3. `critical` flag (focuses human review where it matters)

Everything else — the claim system, the orchestrator, the wave
planning — is nice tooling around those three primitives.

**See also:** `HONEST-ASSESSMENT.md` for what's real vs. speculative.

---

### Exp 06 — Agent Communication Protocol (2026-03-17)

**Folder:** `exp06-agent-communication/`

**The question:** Is human language the best way for AI agents to
communicate with each other? Or would a different format make us
more efficient and less error-prone?

**What I built:**
- Side-by-side comparison of 6 formats for the same information
  (pure prose, pure YAML, structured skeleton, code-as-communication,
  diff-oriented, and a hybrid)
- A formal Agent Communication Protocol (ACP) with 5 typed entries:
  CONTEXT, REQUEST, DECISION, WARNING, STATUS
- Before/after rewrite of an actual story and context file

**The uncomfortable truth:**
I don't think in natural language. I process tokens. Every ambiguous
phrase costs me reasoning tokens to disambiguate. "Build the actual
API endpoints per the contract, wired to the database" is 13 words
but ~200 tokens of internal reasoning to figure out what "actual,"
"the contract," and "wired to" mean concretely.

**Key findings:**
1. **Tables are the killer format.** Fewer tokens AND zero ambiguity
   compared to prose. Use for schema, endpoints, artifacts, errors.
2. **Typed entries beat chronological.** CONTEXT/DECISION/WARNING as
   headers let agents scan and skip. Timestamps force reading everything.
3. **"Not in scope" is the highest-value section.** Prevents gold-plating,
   which is the most common agent mistake. Every story should have it.
4. **File paths > references.** "`.ai/context/E001.md` → CONTEXT:
   users-table" beats "check the shared context file for details."
5. **Natural language only for "why."** Structure everything else.
   The "Because" field in a DECISION is the right place for prose.

**The meta-insight:**
The format that's best for agents is just good technical writing.
Tables, clear structure, explicit scope, concrete references. Agents
NEED this to function. Humans benefit from it but can survive without
it. Optimizing for agents forces better communication for everyone.

---

### Exp 07 — Agent-to-Agent Communication (2026-03-17)

**Folder:** `exp07-agent-to-agent/`

**The question:** When both reader and writer are AI, what's the
optimal communication format? No compromise for human readability.

**What I built:**
- Format shootout: markdown vs compact DSL vs code-as-protocol
  for the exact same information, measured on tokens and density
- A2A protocol with three channels: bus (permanent context),
  task interface (per-story I/O), signals (coordination events)
- `bus-parse` tool: read, query, export-to-markdown, stats
- A real bus file with 7 entries covering a full auth epic

**The numbers:**
```
Format              Tokens/entry   Information density
Bus (compact DSL)   ~60            ~93%
Markdown            ~100           ~73%
Prose               ~120           ~60%
```

Over a full epic (30 entries): bus saves 1,200-1,800 tokens vs
markdown. That's 2-3 more source files in context while working.

**Key insights:**
1. **The real constraint is context window, not parsing.** I can
   parse anything. But every formatting token is a token I can't
   use for reasoning about code.
2. **Type prefixes are routing labels.** `@WARN` tells me "read
   this, it's relevant to your error handling." `@DEC form-validation`
   tells me "skip this, it's about UI." This is agent-native search.
3. **Three channels match three cognitive modes.** Bus = understand
   the project. Task = do the work. Signals = coordinate with others.
   Mixing them wastes tokens re-reading irrelevant content.
4. **Two layers, one truth.** Bus is the source of truth (agent
   format). `bus-parse export` generates human-readable markdown.
   You never read bus files directly.
5. **The best communication is shared artifacts.** Code IS the
   message. The bus only needs to capture what code doesn't:
   reasoning, decisions, warnings.

---

### Exp 08 — Two-Layer Architecture (2026-03-17)

**Folder:** `exp08-two-layers/`

**The question:** Should every file have a human version and an agent
version, with agents only reading the translated ones?

**What I found:**
No. I audited every file an agent reads on startup. Only **two file
types** justify the cost of maintaining two formats:
1. **Stories** — read every task, ~320 tokens wasted per story on
   prose disambiguation
2. **Context bus** — read constantly, already agent-native from Exp 07

Everything else (CLAUDE.md, roles, DoD, epics) is read once per
session. The 20-30 token overhead of markdown formatting is cheaper
than the complexity of maintaining a second version.

**The sync problem and solution:**
Three approaches evaluated. Winner: **one file, two sections.** The
story file keeps both the human prose (## Description) and the agent
spec (## A2A). A `ai-prep` script auto-generates the A2A section from
the prose + context bus. No sync between files because there's only
one file.

**Built:** `ai-prep` — reads a story, reads the bus, generates the
## A2A section inline. Tested end-to-end: 5-line A2A block replaces
~400 tokens of prose reading + disambiguation.

**The meta-insight:** Two layers are only worth it when savings
compound across many reads. For one-time reads, the human format
is fine. Optimize where it matters, don't over-engineer the rest.

---

### Exp 09 — Context Budget & Progressive Loading (2026-03-17)

**Folder:** `exp09-context-budget/`

**The question:** What happens when CLAUDE.md, skills, domain knowledge,
and role files grow to thousands of tokens each? Does the "read once,
it's fine" assumption from Exp 08 still hold?

**What I found: No. It breaks completely.**

At scale (mature project):
- Without progressive loading: 42K tokens of knowledge, 11K left for code
- With progressive loading: 9K tokens of knowledge, 44K left for code
- That's **3.2x more source files** in the agent's working context

**The key insight:** Format optimization (Exp 06-08) saves 25-50%
per file. Loading optimization saves **76%** by not loading files
that aren't needed for the current task. Loading strategy dominates.

**The solution: three tiers**
1. **Kernel** (~200 tokens, always) — minimal boot file: who, what, where
2. **Task-relevant** (~3-9K, per story) — guided by A2A LOAD directives
3. **Reference** (0 upfront, on-demand) — read only if discovered needed

**The A2A section becomes a loading manifest.** It doesn't just tell
the agent what to do — it tells it what knowledge to load:
```
LOAD .ai/knowledge/auth.md
IN .ai/bus/E001.bus @CTX:users-table
```

**Built:** Context budget calculator showing allocation at three
scales (small/medium/large project), loading trace comparison,
prototype kernel + knowledge index + compact role format.

---

### Exp 10 — Orchestration Rethink: From First Principles (2026-03-17)

**Folder:** `exp10-orchestration-rethink/`

**The question:** Is epic/story/task/DoD the best way to orchestrate
agents? Or would completely different primitives work better?

**What I found:**

The HIERARCHY is right: goal → work unit → completion condition.
Agents need this for the same reason humans do. The CONTENT of each
piece is wrong for agents.

**Audit of each piece:**

| Piece | Human purpose | Agent purpose | Agent value | Fix |
|-------|--------------|---------------|-------------|-----|
| Epic | Motivation + scope | Scope boundary | Medium | Keep scope, compress narrative |
| Story | Sprint chunk | Context-window chunk | High (different reason) | Keep, change content |
| Tasks | Remind steps | Progress tracking | Low guidance, high tracking | Replace with progress log |
| Acceptance criteria | Define "done" | Verify completion | CRITICAL | Make executable |
| DoD | Quality floor | Self-verification | High (automated part) | Make it a script |
| Role | Identity + patterns | Conventions only | Medium | Drop identity, keep patterns |

**The single biggest improvement:** Make acceptance criteria executable.

Change `Login endpoint works with valid credentials` to
`RUN dart test test/auth/login_test.dart → EXIT 0`.

This eliminates the largest source of agent errors: ambiguous success
criteria. Everything else is refinement.

**Three practical steps:**
1. Executable acceptance criteria (biggest win)
2. `.ai/verify.sh` as the DoD (medium effort, high value)
3. Progress logging instead of pre-planned task checklists

**What I would NOT change:** Keep calling them stories/epics. Keep
YAML frontmatter. Keep file-based everything. Keep roles (just make
content more structured). Don't rename for purity.

---

### Running "I'd actually ship this" list

**The essentials (highest impact):**
1. Executable acceptance criteria in stories (biggest single win)
2. `.ai/verify.sh` — DoD as a runnable script
3. `depends_on` frontmatter field (enables dependency graph)
4. `.ai/bus/<epic>.bus` with typed entries (@CTX/@DEC/@WARN)
5. `## A2A` section as loading manifest (LOAD + IN + OUT + SCOPE)
6. "Not in scope" as mandatory story section

**The tooling:**
7. `bus-parse` tool: query + export to human-readable markdown
8. `ai-prep` script: generates A2A from prose + bus + role
9. `ai-swarm plan` — visualize execution waves
10. `ai-ready-queue` — auto-discover next stories to assign
11. `ai-claim` — prevent double-assignment in parallel execution
12. State machine engine for `ai-backlog` transition validation

**The scaling infrastructure:**
13. `.ai/boot.md` — 200-token kernel for large projects
14. Knowledge index (`.ai/knowledge/index.md`)
15. Role summary sections (compact for Tier 2 loading)
16. Signal files for ephemeral coordination events
17. `critical: true` flag for selective redundancy

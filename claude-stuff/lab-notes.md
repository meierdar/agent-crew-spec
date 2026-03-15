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

### Running "I'd actually ship this" list

1. `depends_on` frontmatter field + `## Handoff` section convention
2. State machine engine for `ai-backlog` transition validation
3. *(watching for more)*

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

*Entries will be added below as experiments are run.*

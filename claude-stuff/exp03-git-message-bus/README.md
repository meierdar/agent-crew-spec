# Experiment 03: Git as a Message Bus

## The wild idea

Git already stores everything agents produce (code, docs, stories). What if
we also used it for inter-agent **signaling** — lightweight messages that
don't pollute the working tree?

Git has two underused primitives for this:
1. **`git notes`** — attach metadata to any commit without changing its SHA
2. **Custom refs** — `refs/signals/agent-name/topic` as a namespace

## Why this might be useful

In the agent-crew-spec model, agents work on branches. When Agent A finishes
E001-S001 and Agent B needs to start E001-S002, there's currently no
mechanism for A to "notify" B. The human operator is the message bus.

What if:
- Agent A writes a signal: `refs/signals/E001-S001/complete`
- Agent B, before starting, checks: "do my dependency signals exist?"
- No polling, no external service — just `git show-ref`

## What I'll prototype

1. A `signal-send.sh` that creates a ref pointing at the current HEAD
   with a small blob of metadata
2. A `signal-check.sh` that tests whether signals exist for dependencies
3. Test whether this survives `git push` / `git fetch` (refs are pushable!)

## Risk assessment

- **Will this confuse humans?** Probably. Custom refs are invisible to
  normal `git log` / `git status`. That's both the feature and the risk.
- **Will this scale?** Probably not past a few dozen agents. But for
  the 2-5 agent crew size this spec targets, it might be fine.
- **Is this insane?** A little. That's the point of the sandbox.

# Findings: What Works Best for AI Agent Collaboration

## The Numbers

```
Metric                     Current       Swarm    Ensemble
------------------------------------------------------------
Wall-clock (ticks)              41          22          32
Total tokens                  7980        6625       10060
Context waste                 1080         275         360
Task failures                    0           2           0
Human interventions              8           0           0
```

## What the Simulation Revealed

### 1. The human bottleneck is the biggest cost

The current model requires 8 human interventions for 8 tasks (assignment +
review). Each intervention adds latency (humans aren't always available)
and the serial execution means zero parallelism. The **context waste** —
1080 tokens of agents re-reading what previous agents already knew — is
the highest of all models.

This maps to real-world experience: the most common complaint with AI
agents isn't "the code is wrong" but "I spent more time managing the
agent than I would have writing the code."

### 2. Shared context beats handoffs

The swarm model's shared scratchpad reduces context waste by **75%**
compared to handoffs. This makes intuitive sense: a handoff is a lossy
compression of "what happened." A shared document that evolves in
real-time loses nothing.

**Concrete implication:** Instead of `## Handoff` sections written at
the end of a story, consider a shared `.ai/context/<epic-id>.md` file
that agents append to as they work, not after.

### 3. Parallelism is the biggest speed lever

Swarm (4 agents) is 46% faster. Ensemble (2 agents) is 21% faster.
The dependency graph in our test project has natural parallelism:
T01, T02, T06, T07 can all start simultaneously — but the current
model forces them to run sequentially.

**Concrete implication:** The spec should identify parallelizable
stories and allow concurrent assignment rather than serial handoff.

### 4. Redundancy is expensive but reliable

Ensemble's zero failures come at a 26% token premium. Whether this is
worth it depends on the cost of failure. For critical paths (auth,
payments, data migrations), redundant execution might be worth 2x cost.
For UI components, probably not.

**Concrete implication:** Mark stories with `critical: true` and apply
ensemble-style redundancy selectively.

### 5. The "right" model is probably a hybrid

No single model wins on all dimensions. The optimal approach borrows
from each:

| From Current | From Swarm | From Ensemble |
|---|---|---|
| Human sets priorities | Agents self-assign from ready queue | Redundancy for critical tasks |
| Story structure for clarity | Shared context doc | Automated merge/diff for verification |
| Epic-level human planning | Dependency graph execution | Pair-execution catches bugs cheaply |

---

## Concrete Recommendations for agent-crew-spec

### Ship now (low risk, high value)

1. **Add `depends_on` to story frontmatter.** This enables dependency
   graph execution. Without it, you can't parallelize safely.

2. **Add shared context files: `.ai/context/<epic-id>.md`.** Agents
   append to this file as they work. Next agent reads it before starting.
   Cheaper than handoffs, no information loss.

3. **Auto-assignment via `ai-backlog`.** When an agent finishes, the
   script could output: "These stories are now ready based on the
   dependency graph." The human still approves, but discovery is automated.

### Ship after testing (medium risk)

4. **Parallel story assignment.** Allow multiple agents to work on
   independent stories simultaneously. Requires: `depends_on` (for
   safety), conflict detection (two agents editing the same file),
   and a merge protocol.

5. **Critical path marking.** `critical: true` in story frontmatter
   triggers redundant execution or stricter review. Non-critical stories
   skip human review entirely.

### Research further (needs more simulation)

6. **Drop roles entirely.** If any agent can do any task (by reading
   the role file), fixed assignment is artificial. Instead: stories
   declare the *capabilities* they need, and any capable agent picks
   them up. This is a big philosophical shift.

7. **Emergent task splitting.** When an agent starts a story and
   realizes it's too big for one context window, it should be able
   to split it into sub-stories and continue with the first one.
   Currently the spec has no protocol for this.

8. **Self-healing failures.** Instead of "document blocker and stop,"
   agents could attempt recovery: retry with different approach, split
   the problem, or flag for redundant execution. The current "stop and
   wait for human" is the safest but slowest option.

---

## What This Means for "Suits People"

The user's original insight was right: the goal isn't to optimize for
agents — it's to optimize for **people who work with agents**. The best
collaboration model is one where:

- Humans spend time on **decisions** (what to build, priority, architecture)
  not on **logistics** (assigning, reviewing, unblocking)
- Agents handle the **execution graph** autonomously
- The system is **transparent** — humans can see what every agent is doing
  and why, without having to ask
- **Failure is cheap** — the system catches and recovers from mistakes
  without human intervention most of the time

The current spec nails transparency and safety. What it lacks is
autonomy and parallelism. The swarm model shows those are the biggest
levers for both speed and cost.

## Simulation Caveats

This is a simplified model. Real-world factors not captured:
- Context window overflow (agent can't finish because task is too big)
- Conflicting edits (two agents modify the same file)
- Quality variance (some "completions" are worse than others)
- Human review quality (humans catch bugs agents miss, and vice versa)
- Communication overhead in real shared documents (merge conflicts)

The directional insights hold even if the exact numbers don't.

# Experiment 04: AI-Native Collaboration Simulator

## The Question

The current agent-crew-spec borrows from human agile: epics, stories, roles,
kanban boards, human-as-gatekeeper. But AI agents are fundamentally different
from human developers:

| Property | Human Developer | AI Agent |
|----------|----------------|----------|
| Memory | Persistent across sessions | Zero between sessions |
| Clonability | One instance | Unlimited parallel instances |
| Context | Unbounded (can learn for years) | Fixed window (then forgets) |
| Ego/Politics | Yes (code ownership, blame) | None |
| Cost model | Salary (fixed) | Per-token (variable) |
| Failure mode | Slow degradation | Catastrophic (context overflow, hallucination) |
| Handoff cost | High (meetings, docs) | Near-zero IF structured correctly |
| Specialization | Expensive to retrain | Free (just swap the role prompt) |
| Availability | 8h/day, needs breaks | Always available |
| Parallelism | Limited by humans | Limited by budget |

## Hypothesis

The optimal collaboration model for AI agents is NOT Scrum, NOT Kanban,
and NOT any human methodology — it's something shaped by the constraints
above. Specifically:

1. **Smaller work units** — Context windows mean agents work best on
   tasks completable in a single session. Stories should be even smaller
   than current "S/M/L/XL" sizing.

2. **No roles, just capabilities** — Human roles exist because retraining
   is expensive. AI agents can switch roles per-task for zero cost. Roles
   might be harmful (artificial silos).

3. **Shared scratchpad > handoffs** — Instead of Agent A writing a handoff
   for Agent B, both agents read/write to a shared context document that
   evolves with the project.

4. **Redundancy over review** — Instead of Agent A doing work and human
   reviewing, have Agent A and Agent B do the same task independently,
   then diff their outputs. Cheaper than human review, catches more bugs.

5. **Graph, not pipeline** — Stories don't need to flow linearly through
   a kanban board. They can be a dependency graph where any ready node
   gets picked up by the next available agent.

## What I'll simulate

Three collaboration models competing on the same "project":

### Model A: "Current Spec" (baseline)
- Human assigns stories serially
- One agent per story
- Handoff via story file
- Human reviews before done
- Sequential pipeline

### Model B: "Swarm"
- Shared context document (scratchpad)
- No fixed roles — any agent picks up any ready task
- Tasks are tiny (max 30 min equivalent)
- No review gate — redundant execution instead
- Dependency graph, not pipeline

### Model C: "Ensemble"
- Fixed roles but agents work in pairs
- Every task done by 2 agents independently
- Merge step picks best output (or combines)
- Shared memory via append-only log
- Human only intervenes on conflicts

## Metrics

- **Total tokens spent** (proxy for cost)
- **Context waste** (tokens spent re-discovering existing work)
- **Failure rate** (tasks that had to be redone)
- **Wall clock time** (with parallelism)
- **Human intervention count** (lower = better for scaling)

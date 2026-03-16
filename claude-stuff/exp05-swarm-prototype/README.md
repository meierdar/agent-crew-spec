# Experiment 05: Real-World AI Swarm — Working Prototype

## The Transformation

### What changes (your role)

**Before (dispatcher):**
```
You write story → you assign agent → agent works → you review → you assign next
     ^                                                              |
     |______________________________________________________________|
                        YOU are the loop
```

**After (strategist):**
```
You write epic + stories with dependencies → swarm runs the graph → you review results
     ^                                                                      |
     |______________________________________________________________________|
                        YOU set direction, agents execute
```

Your job changes from "project manager" to "architect + product owner."
You decide *what* to build and *why*. The swarm figures out *who does what
when*.

### What changes (agent side)

| Current | Swarm |
|---------|-------|
| Wait for human to assign | Check ready queue, self-assign |
| One agent works at a time | All independent stories run in parallel |
| Write handoff after done | Write to shared context file as you go |
| Document blocker and stop | Try recovery, then escalate |
| Human reviews everything | Only `critical` stories get review |

## How it actually works in practice

### Step 1: You write stories with dependencies

```yaml
---
id: E001-S001
title: "Database schema"
status: ready
depends_on: []        # <-- no deps, can start immediately
critical: false
---
```

```yaml
---
id: E001-S003
title: "Wire API to database"
status: ready
depends_on:
  - E001-S001         # <-- blocked until S001 is done
  - E001-S002
critical: true        # <-- will be double-checked
---
```

### Step 2: Run the swarm

```sh
./bin/ai-swarm run --epic E001 --agents 3
```

This would:
1. Build the dependency graph from all stories in the epic
2. Find stories with no unmet dependencies → these are the "ready queue"
3. Assign up to 3 agents to ready stories (one per story)
4. As each finishes, re-check the graph for newly unblocked stories
5. For `critical: true` stories, run a second agent and diff the outputs
6. Produce a summary when all stories are done

### Step 3: You review what matters

Instead of reviewing every task, you get a report:
- Which stories completed cleanly
- Which had conflicts or failures
- What the agents decided (from the shared context log)
- Only `critical` stories need your sign-off

## What I'm building here

Three pieces that make this real:

1. **`ai-ready-queue`** — reads all stories, resolves dependency graph,
   outputs which stories can start right now
2. **`ai-claim`** — atomic story claiming (prevents two agents picking
   the same story)
3. **`ai-swarm`** — orchestrator that ties it together: runs the loop
   of check-ready → assign → wait → check-ready until done

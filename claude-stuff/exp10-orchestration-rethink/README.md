# Experiment 10: Is Epic/Story/Task/DoD the Right Structure?

## The uncomfortable exercise

Let me strip away the Agile terminology and ask: what does an AI
agent ACTUALLY need to do good work and not forget things?

### What does "not forget" mean for an agent?

Humans forget because memory degrades. Agents "forget" for entirely
different reasons:

1. **Context window overflow** — information loaded but pushed out
   by newer content during a long session
2. **Session boundary** — zero memory between sessions; everything
   must be re-loaded from files
3. **Scope drift** — agent starts doing something it wasn't asked to
   do, effectively "forgetting" the original task
4. **Decision amnesia** — agent makes a choice, doesn't record it,
   then a later agent contradicts it

These are NOT the same failure modes that epics/stories/tasks were
designed to prevent. Agile ceremonies prevent HUMAN failures:
- Humans forget priorities → sprint planning
- Humans forget commitments → standups
- Humans forget quality standards → DoD
- Humans lose context → story descriptions
- Humans scope creep → acceptance criteria

Some of these transfer to agents. Some don't. And agents have
failure modes that humans don't have at all (context overflow,
session boundaries).

## Audit: What each piece does for agents

### Epic
**For humans:** Big-picture goal, prevents losing sight of the forest.
**For agents:** Scope boundary ("Out of Scope" list prevents gold-plating).
  Also provides WHY context for decision-making.
**Agent-specific value:** MEDIUM. The scope boundary is valuable.
  The narrative goal is less useful — agents don't need motivation.
**Could be replaced by:** A scope document without the narrative.

### Story
**For humans:** A chunk of work one person can do in a sprint.
**For agents:** A chunk of work that fits in one context window.
**Agent-specific value:** HIGH — but for a different reason than
  humans. Stories exist because agents need a scope boundary that
  fits their memory limit, not because of sprint time-boxing.
**Could be replaced by:** A work unit defined by context window
  budget, not by human time estimates.

### Task (checklist within story)
**For humans:** Reminds them of implementation steps.
**For agents:** Mixed value. Agents can derive implementation steps
  from acceptance criteria. BUT: checked-off tasks serve as progress
  markers for the human and for resumption after a crash.
**Agent-specific value:** LOW for guidance, HIGH for progress tracking.
**Could be replaced by:** Auto-generated from acceptance criteria,
  with progress tracked via commits or bus entries.

### Acceptance Criteria
**For humans:** Define "done" for this specific story.
**For agents:** THE most valuable part of the story. Unambiguous,
  checkable conditions that the agent can verify.
**Agent-specific value:** CRITICAL. This is what prevents scope drift.
**Could be replaced by:** Nothing. This is the right primitive.

### Definition of Done
**For humans:** Quality floor across all stories.
**For agents:** Self-verification checklist before declaring review.
**Agent-specific value:** HIGH — but mostly the automated checks.
  The manual checks are for the human reviewer, not the agent.
**Could be replaced by:** A verification script the agent runs,
  plus a lighter human-review checklist.

### Roles
**For humans:** Specialization, team structure.
**For agents:** Tech stack + conventions + quality patterns.
**Agent-specific value:** MEDIUM. The patterns matter. The "identity"
  ("you are a senior developer") is anthropomorphic theater.
**Could be replaced by:** A conventions file without the roleplay.

## What's missing for agents

Things agents need that the current structure doesn't provide:

1. **Context budget awareness** — no story knows how much context
   window it will consume. An XL story might overflow.

2. **Dependency graph** — stories don't declare what they depend on.
   (We added this in Exp 05, but it's not in the original spec.)

3. **Shared knowledge** — no mechanism for agents to share what they
   learned. (We added the bus in Exp 07, but it's not original.)

4. **Verification scripts** — the DoD says "tests pass" but doesn't
   run them. The agent has to know HOW to run tests for this project.

5. **Recovery protocol** — what to do when things go wrong. The
   current spec says "document blocker and stop." That's the most
   conservative option but wastes an entire agent session.

6. **Progress persistence** — if an agent crashes mid-story, how
   does the next agent know what was done? Checked-off tasks help,
   but they're coarse-grained.

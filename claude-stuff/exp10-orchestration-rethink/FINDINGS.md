# Findings: Is Epic/Story/Task/DoD The Right Structure?

## The short answer

The STRUCTURE is mostly right. The CONTENT of each piece is wrong
for agents.

Let me explain.

## What's right about the current structure

### The hierarchy works

GOAL → CONTRACT → VERIFY is structurally the same as Epic → Story →
Acceptance Criteria. The hierarchy is sound:
- Big picture goal (why are we doing this?)
- Atomic work units (what specifically needs to happen?)
- Completion conditions (how do we know it's done?)

Agents need this hierarchy for the same reason humans do: without a
goal, work has no direction. Without atomic units, work is unbounded.
Without completion conditions, work never ends.

**Verdict: Keep the three-level hierarchy.**

### File-based persistence works

Stories-as-files means: git-tracked, diffable, survives between
sessions, zero external dependencies. This is exactly right for
agents that have no memory between sessions.

**Verdict: Keep file-based everything.**

### Scope boundaries work

"In Scope / Out of Scope" in epics and "Not in scope" in stories
are the single most effective anti-drift mechanism. Agents gold-plate
because they CAN — explicit boundaries prevent it.

**Verdict: Keep and strengthen scope boundaries.**

## What's wrong

### 1. Acceptance criteria are prose, not assertions

Current:
```
- [ ] Login endpoint works with valid credentials
```

"Works" means what? Returns 200? Returns a token? Sets a cookie?
Returns within 500ms? The agent has to guess.

Proposed:
```
VERIFY
  RUN dart test test/auth/ → EXIT 0
  HTTP POST /auth/login {valid_creds} → STATUS 200, BODY HAS "token"
```

**The fix isn't changing the structure. It's changing acceptance
criteria from prose to runnable assertions.**

You can still put this inside a "story" — call it an acceptance
criterion, a verify block, a contract — the name doesn't matter.
What matters is that it's unambiguous and executable.

### 2. Tasks are pre-planned, not recorded

Current:
```
## Tasks
- [ ] Create LoginScreen widget
- [ ] Add form validation
- [ ] Connect to AuthRepository
```

The human pre-plans implementation steps. But the agent might take
a completely different approach. If it does, the tasks become
meaningless checked boxes that don't reflect reality.

Proposed: Replace pre-planned tasks with auto-recorded checkpoints.
The agent writes what it actually did, not what was predicted.

```
## Progress
- [x] Created LoginScreen at lib/features/auth/ui/login_screen.dart
- [x] Form validation: email regex, password min 8
- [x] Connected via AuthRepository.signIn → hit duplicate email bug
- [x] Added error handler for unique_violation
- [ ] Widget tests (in progress)
```

**The fix: Tasks become a log of what happened, not a plan of what
should happen.** The agent still uses acceptance criteria to know
WHAT to achieve. The task section records HOW it got there.

### 3. DoD is a checklist, not a script

Current:
```
- [ ] Code compiles / builds without errors
- [ ] All existing tests still pass (no regressions)
- [ ] Linter passes with zero warnings
```

The agent reads "linter passes" and has to figure out: what linter?
what command? what config? Then it runs it manually and self-reports
the result. There's no verification that the agent actually did this.

Proposed: DoD becomes a verification script.

```sh
#!/bin/sh
# .ai/verify.sh — run this before declaring review
set -e
echo "Building..."   && flutter build apk --debug
echo "Testing..."    && flutter test
echo "Analyzing..."  && dart analyze --fatal-infos
echo "Secrets..."    && ! grep -rE 'sk_live|pk_live|password\s*=' lib/
echo "TODOs..."      && ! grep -rE 'TODO|FIXME|HACK' lib/ || true
echo "ALL CHECKS PASSED"
```

**The fix: DoD becomes executable.** The agent runs `.ai/verify.sh`
and either it passes or it doesn't. No interpretation needed, no
self-reporting, no ambiguity.

### 4. Roles are identity theater + useful patterns

Current:
```
You are a senior Flutter/Dart developer. You write clean, testable,
production-grade code.
```

The identity sentence does nothing. I don't perform better because
you called me "senior." What I actually need from a role file:

- What tech stack (so I use the right tools)
- What patterns (so I follow conventions)
- What verification commands (so I can check my work)

Proposed: Drop the identity, keep the patterns.

```
CONVENTIONS flutter
STACK flutter:3.x riverpod go_router supabase
PATTERNS
  structure: lib/features/{feature}/
  state: riverpod (no setState)
  errors: Result types (no silent catch)
VERIFY
  RUN flutter test
  RUN dart analyze
```

### 5. Epics are narrative + useful scope

The "Goal" and "Context" sections of an epic are written for humans
who need to understand WHY. Agents don't need motivation — they need
boundaries.

The most valuable part of E001 isn't:
```
Users can register, log in, and maintain a session. This is the
foundation for all personalized features.
```

It's:
```
Out of Scope:
- Social login (Google, Apple) — separate epic
- Role-based access control — separate epic
- Two-factor authentication
```

**The fix: Keep the scope boundaries, compress the narrative.**
An agent needs 1 line of "why" for decision-making context, not a
paragraph.

---

## The Practical Recommendation

Don't burn the current structure down. **Evolve it in three steps:**

### Step 1: Make acceptance criteria executable (biggest win)

Change this:
```
- [ ] Login endpoint works with valid credentials
```

To this:
```
- [ ] `dart test test/auth/login_test.dart` passes
- [ ] `curl -X POST /auth/login -d '{"email":"test@x.com","pw":"12345678"}'` returns 200
```

Still a story. Still acceptance criteria. Still checkboxes.
But now they're verifiable by running a command, not by interpreting
prose.

### Step 2: Make DoD a script (medium effort, high value)

Create `.ai/verify.sh` that runs all DoD checks. Agent runs it
before declaring review. Human can run it too.

Story template adds:
```
## Verification
Run `.ai/verify.sh` before setting status to review.
```

### Step 3: Replace task pre-planning with progress logging

Change the Tasks section from "planned steps" to "progress log."
Agent writes what it did as it does it. Human and crash-recovery
agents read it to understand what happened.

---

## What I would NOT change

### Keep calling them stories
The name doesn't matter. "Contract" is more precise but "story" is
understood by every developer. Don't rename things for purity.

### Keep calling them epics
Same reason. "Goal" is more accurate but "epic" works fine.

### Keep the DoD as a file, not just a script
The human-review checklist ("is the code readable?") can't be
automated. Keep it as prose for the human. Add the script for
the automated part.

### Keep roles
Even without the identity theater, "flutter-developer" as a label
is useful for assignment and for loading the right conventions.
Just make the content more structured and less narrative.

### Keep YAML frontmatter
It's structured, parseable, readable, git-diffable. Perfect for
metadata. Don't change what's already right.

---

## The meta-insight

The question was: "Is epic/story/task/DoD the best way?"

The answer: **The hierarchy is right. The content needs to be
more verifiable, more executable, and less narrative.**

The single biggest improvement is making acceptance criteria
executable. If an agent can run a command and get pass/fail
instead of interpreting "login endpoint works," you eliminate
the largest source of agent errors: ambiguous success criteria.

Everything else — progress logging, executable DoD, convention
files, compressed epics — is refinement. The verification step
is the structural change that matters most.

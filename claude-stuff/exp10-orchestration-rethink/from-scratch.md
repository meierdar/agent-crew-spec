# Designing Agent Orchestration From Scratch

If I forget everything about Agile and start from what agents actually
need, what structure emerges?

## The Five Agent Failure Modes

Every orchestration decision should prevent one of these:

| # | Failure mode | Description | Current fix | Sufficient? |
|---|-------------|-------------|-------------|-------------|
| F1 | Scope drift | Agent builds more than asked | Acceptance criteria | Partially — AC is vague |
| F2 | Decision amnesia | Agent contradicts prior choices | Nothing (now: bus) | Bus fixes this |
| F3 | Context overflow | Agent can't hold enough info | Nothing (now: tiers) | Tiers fix this |
| F4 | Session boundary | Zero memory between sessions | Story files persist | Yes, but coarse |
| F5 | Cascade failure | One mistake propagates to all | Human review gate | Slow, not scalable |

## The Primitives Agents Actually Need

### 1. CONTRACT (replaces: story + acceptance criteria)

The agent needs an unambiguous **contract**: what goes in, what
comes out, what conditions must hold.

This is the acceptance criteria, but formalized as verifiable
assertions — not prose descriptions.

```
CONTRACT E001-C003

GIVEN
  db/migrations/001.sql EXISTS
  docs/api/auth.yaml EXISTS
  .ai/bus/E001.bus HAS @CTX:users-table
  .ai/bus/E001.bus HAS @CTX:auth-api-contract

PRODUCE
  lib/auth/routes.dart
  lib/auth/repository.dart MODIFIED
  test/auth/routes_test.dart

VERIFY
  RUN dart test test/auth/routes_test.dart → EXIT 0
  RUN dart analyze lib/auth/ → EXIT 0
  HTTP POST /auth/login {email:"test@x.com",pw:"12345678"} → STATUS 401
  HTTP POST /auth/register {email:"new@x.com",pw:"12345678",name:"A"} → STATUS 200
  HTTP POST /auth/register {email:"new@x.com",pw:"12345678",name:"A"} → STATUS 409
  FILE lib/auth/routes.dart CONTAINS "signIn"
  FILE lib/auth/routes.dart CONTAINS "signUp"
  FILE lib/auth/routes.dart NOT_CONTAINS "TODO"

BOUNDARY
  TOUCH lib/auth/** lib/core/errors/** test/auth/**
  NO_TOUCH lib/features/home/** lib/features/profile/**
```

**Why this is better than stories for agents:**

- **GIVEN** — explicit preconditions the agent can check before
  starting. If any GIVEN fails, the agent knows it's blocked without
  guessing.
- **PRODUCE** — exact files to create/modify. The agent can verify
  completion: "do these files exist?"
- **VERIFY** — runnable assertions. Not "login endpoint works with
  valid credentials" (what does "works" mean?) but `RUN dart test →
  EXIT 0` (unambiguous).
- **BOUNDARY** — which files the agent may touch. Prevents scope
  drift mechanically, not by willpower. An agent that modifies a
  file outside BOUNDARY has violated its contract.

### 2. GOAL (replaces: epic)

The agent doesn't need a motivational narrative. It needs:
- What user-facing outcome are we building toward?
- What's IN scope and what's OUT?
- What contracts exist and how do they connect?

```
GOAL E001 "User Authentication"

OUTCOME users can register, login, and stay logged in

SCOPE_IN email_password_auth, session_persistence, password_reset
SCOPE_OUT social_login, RBAC, 2FA

CONTRACTS
  E001-C001 → E001-C002 → E001-C003 → E001-C005
                                    ↗
              E001-C004 ───────────┘

DECISIONS .ai/bus/E001.bus
```

The dependency graph IS the goal structure. No need for a
narrative epic — the connections between contracts tell the
story.

### 3. CONVENTIONS (replaces: roles + DoD)

Roles are a bundle of two things: tech stack and quality patterns.
The "identity" is anthropomorphic theater. The DoD is another set
of quality patterns. Merge them.

```
CONVENTIONS flutter

STACK flutter:3.x riverpod go_router supabase freezed dio
PATTERNS
  structure: lib/features/{feature}/
  state: riverpod_providers (no raw setState)
  errors: Result_types (no silent catches)
  strings: constants_or_enums (no magic strings)

VERIFY_ALWAYS
  RUN flutter test → EXIT 0
  RUN dart analyze → EXIT 0
  RUN grep -r "TODO\|FIXME\|HACK" lib/ → EXIT 1 (should find nothing)
  RUN grep -r "sk_live\|pk_live\|password.*=" lib/ → EXIT 1 (no secrets)
```

**VERIFY_ALWAYS** runs after every contract completion. It's the
DoD, but executable. Not "linter passes with zero warnings" (the
agent has to figure out how to run the linter). Instead:
`RUN dart analyze → EXIT 0` (unambiguous).

### 4. BUS (replaces: handoffs, shared context)

Already designed in Exp 07. The bus is the agent's shared memory.
No changes needed — it's already the right primitive.

### 5. CHECKPOINT (replaces: task checklists, progress tracking)

Agents don't need task checklists as guidance — they can derive
steps from the contract. But they DO need progress markers for
crash recovery and for the human to track progress.

```
CHECKPOINT E001-C003

2026-03-17T10:00 STARTED by backend-dev-1
2026-03-17T10:05 GIVEN_VERIFIED all preconditions met
2026-03-17T10:15 PRODUCED lib/auth/routes.dart (new, 120 lines)
2026-03-17T10:25 PRODUCED lib/auth/repository.dart (modified, +signIn +signUp)
2026-03-17T10:30 PRODUCED test/auth/routes_test.dart (new, 4 tests)
2026-03-17T10:32 VERIFY_RUN dart test → EXIT 0
2026-03-17T10:33 VERIFY_RUN dart analyze → EXIT 0
2026-03-17T10:34 VERIFY_HTTP POST /auth/login → FAIL (expected 401, got 500)
2026-03-17T10:40 FIX error handler missing for wrong password
2026-03-17T10:42 VERIFY_HTTP POST /auth/login → PASS
2026-03-17T10:43 VERIFY_ALL PASS
2026-03-17T10:43 COMPLETED
```

**Why this is better than task checklists:**

- **It's auto-generated**, not hand-written. The agent doesn't need
  a human to pre-plan implementation steps.
- **It records what actually happened**, not what was planned to happen.
  If the agent took a detour, you see it.
- **Crash recovery is trivial.** A new agent reads the checkpoint,
  sees "PRODUCED lib/auth/routes.dart" and "VERIFY_HTTP FAIL", knows
  exactly where to resume.
- **The human sees progress in real-time**, not just checked-off boxes.

---

## Side-By-Side: Current vs. Proposed

| Current | Proposed | Why the change |
|---------|----------|---------------|
| Epic | GOAL | Drop narrative, keep scope + graph |
| Story | CONTRACT | Verifiable assertions, not prose |
| Task checklist | CHECKPOINT | Auto-generated, records reality |
| DoD | VERIFY_ALWAYS (in CONVENTIONS) | Executable, not a checklist |
| Role | CONVENTIONS | Drop identity theater, keep patterns |
| Acceptance criteria | VERIFY (in CONTRACT) | Runnable, not prose |
| Handoff | BUS | Already designed (Exp 07) |
| Status field | CHECKPOINT state | Derived from last entry |

## What the human workflow looks like

### Before (current)
```
1. Human writes epic (narrative goal, scope)
2. Human breaks into stories (prose description, acceptance criteria)
3. Human adds tasks to each story (implementation steps)
4. Human assigns story to agent
5. Agent works
6. Human reviews
```

### After (proposed)
```
1. Human writes GOAL (scope, outcomes)
2. Human writes CONTRACTs with VERIFY assertions
   (or: agent proposes contracts, human approves)
3. Dependency graph auto-computed from GIVEN/PRODUCE
4. Swarm assigns contracts from ready queue
5. Agent works, writes checkpoints
6. VERIFY runs automatically — human reviews only failures + criticals
```

The big shift: **step 2 changes from writing prose to writing
verifiable assertions.** This is harder for the human. But it
produces better results because:

- Agents can't misinterpret a runnable assertion
- Verification is automated (no human review for passing contracts)
- The dependency graph is computable (GIVEN references PRODUCE of
  previous contract)
- Progress is trackable via checkpoints (not manual task checking)

### Making step 2 easier

The human shouldn't have to write `RUN dart test → EXIT 0` by hand.
A prep tool can generate VERIFY blocks from conventions + contract
structure:

```sh
# Human writes the minimal contract:
ai-contract create E001-C003 \
  --given "users table, auth API contract" \
  --produce "auth endpoints, tests" \
  --verify "login works, register works, duplicates rejected"

# Tool generates the full CONTRACT with runnable VERIFY blocks
# based on CONVENTIONS (knows how to run tests, what stack is used)
```

The human's job stays natural-language. The tooling translates to
verifiable assertions.

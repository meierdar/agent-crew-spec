# Agent Communication Protocol (ACP)

## Core Principle

**Use structure for WHAT. Use language for WHY.**

Agents waste tokens on two things:
1. Parsing ambiguous natural language to extract facts
2. Guessing what the author meant vs. what they wrote

The fix: every piece of inter-agent communication has a **structured
section** (zero ambiguity, machine-parseable) and an optional
**reasoning section** (natural language, only for context that can't
be structured).

---

## The Five Communication Types

Agents communicate for exactly five reasons. Each has an optimal format.

### 1. CONTEXT — "Here's what exists"

When: An agent needs to tell future agents what was built.
Used in: Shared context files, handoffs.

```markdown
## CONTEXT: <component-name>

### Artifacts
| What | Where | Interface |
|------|-------|-----------|
| Users table | db/migrations/001.sql | id, email, name, password_hash, created_at |
| Auth repo | lib/auth/repository.dart | signIn(email, pw) → Token, signUp(email, pw, name) → User |

### Constraints
- email: UNIQUE (duplicate → HTTP 409)
- password: min 8 chars, hashed with bcrypt
- id: UUID v4, generated server-side

### Reasoning
Chose bcrypt over argon2 because the Supabase client library
uses bcrypt internally — staying consistent avoids two hashing
strategies.
```

**Why this shape:**
- **Artifacts table** — agents need: what is it, where is it, how do
  I use it. Three columns, nothing else.
- **Constraints** — hard rules in a flat list. No prose needed.
- **Reasoning** — the ONLY place for natural language. Only include
  decisions that a downstream agent might question or reverse.

---

### 2. REQUEST — "I need you to do this"

When: A story describes what an agent should do.
Used in: Story descriptions, acceptance criteria.

```markdown
## REQUEST

### Input
- Auth API contract: `docs/api/auth.yaml` (OpenAPI 3.0)
- DB schema: see CONTEXT in `.ai/context/E001.md`

### Output
- Working endpoints: POST /auth/login, POST /auth/register
- Tests: at least 1 per endpoint (happy path + error case)
- Updated shared context with implementation decisions

### Constraints
- Must match contract exactly (types, status codes, error shapes)
- Must use repository pattern (no SQL in route handlers)
- Must handle: duplicate email (409), invalid input (422), wrong password (401)

### Not in scope
- Email verification
- Password reset
- Rate limiting (separate story)
```

**Why this shape:**
- **Input** — concrete file paths. No "see the previous agent's work."
- **Output** — what artifacts must exist when done. Testable.
- **Constraints** — hard rules, not suggestions.
- **Not in scope** — prevents agents from gold-plating. This saves
  more tokens than any other section.

---

### 3. DECISION — "I chose X because Y"

When: An agent makes a choice that affects downstream work.
Used in: Shared context files, inline in code comments.

```markdown
## DECISION: <short-name>

**Chose:** bcrypt for password hashing
**Over:** argon2, scrypt, PBKDF2
**Because:** Supabase Auth uses bcrypt internally. Using the same
algorithm means we can migrate to Supabase Auth later without
re-hashing all passwords.
**Affects:** Any agent touching password storage or verification.
**Reversible:** Yes, but requires re-hashing all existing passwords.
```

**Why this shape:**
- **Chose/Over** — makes the decision and alternatives explicit.
  Downstream agents won't waste tokens re-evaluating alternatives
  that were already considered.
- **Because** — the only place for natural language. Keep it to 1-2
  sentences.
- **Affects** — tells agents "if your story touches X, read this."
- **Reversible** — prevents agents from treating decisions as sacred
  when they're actually cheap to change.

---

### 4. WARNING — "Watch out for this"

When: An agent discovers a gotcha that will bite the next agent.
Used in: Shared context, story technical notes.

```markdown
## WARNING: <short-description>

**Trigger:** Inserting a user with an existing email
**Symptom:** PostgreSQL throws unique_violation (23505)
**Fix:** Catch the exception, return HTTP 409 with body:
```json
{"code": "EMAIL_EXISTS", "message": "An account with this email already exists"}
```
**If ignored:** Unhandled 500 error leaks stack trace to client.
```

**Why this shape:**
- **Trigger/Symptom/Fix** — agents can pattern-match against this.
  "Am I doing something that matches a trigger? Let me check."
- **If ignored** — explains severity. Agents can prioritize which
  warnings to address first.
- Zero natural language needed. The format IS the explanation.

---

### 5. STATUS — "Here's where things stand"

When: Reporting progress, completion, or blockers.
Used in: Story status updates, swarm orchestrator.

```markdown
## STATUS: E001-S003

**State:** in-progress → review
**Completed:**
- [x] Login endpoint (POST /auth/login)
- [x] Register endpoint (POST /auth/register)
- [x] Error handling (409, 422, 401)
- [x] Tests (4 passing)

**Changed files:**
- lib/auth/routes.dart (new)
- lib/auth/repository.dart (modified — added signIn, signUp)
- test/auth/routes_test.dart (new)

**Context written:** Yes — see .ai/context/E001.md

**Unresolved:**
- None
```

**Why this shape:**
- **State transition** — explicit from/to, not just current state.
- **Completed** — checkboxes map directly to acceptance criteria.
  A downstream agent (or human) can verify instantly.
- **Changed files** — concrete paths with (new/modified/deleted).
  The next agent knows exactly what to look at.
- **Unresolved** — either "None" or a list of blockers. Binary.

---

## What changes in the spec

### Story template (new format)

Replace the free-form "Description" with a structured REQUEST block.
Replace "Technical Notes" with pointers to CONTEXT in shared files.

### Shared context files (new format)

Structure as a sequence of typed entries: CONTEXT, DECISION, WARNING.
Each entry has the structured format above. Agents append, never edit
existing entries.

### Handoffs → not needed

With this protocol, handoffs are obsolete. The shared context file
IS the continuous handoff. Every CONTEXT, DECISION, and WARNING entry
is a micro-handoff written at the moment of discovery, not
reconstructed after the fact.

---

## Token efficiency comparison

Same information expressed in current format vs. ACP:

| Communication | Current (tokens) | ACP (tokens) | Ambiguities eliminated |
|--------------|-----------------|-------------|----------------------|
| Schema handoff | ~120 | ~65 | 3 |
| Story description | ~80 | ~60 | 2 (scope, input sources) |
| Decision record | ~50 (inline prose) | ~45 | 1 (alternatives not listed) |
| Warning | ~40 (prose) | ~35 | 1 (severity unclear) |
| Status update | ~30 | ~35 | 0 (slightly longer but unambiguous) |
| **Total per story** | **~320** | **~240** | **7** |

25% fewer tokens and 7 fewer ambiguities per story. Across an epic
with 8 stories, that's ~640 tokens saved and 56 fewer chances for
misinterpretation.

The token savings are nice but not the point. **The ambiguity
reduction is the point.** Every ambiguity is a potential bug — an
agent guessing wrong about what the previous agent meant.

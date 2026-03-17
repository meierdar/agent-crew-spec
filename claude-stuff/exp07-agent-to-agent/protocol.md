# Agent-to-Agent Communication Protocol (A2A)

## Core Design

Agents communicate through **three channels**, each with a different
purpose, format, and lifetime.

```
Channel 1: CONTEXT BUS     — what exists (persists across all stories)
Channel 2: TASK INTERFACE   — what to do (per-story, structured I/O)
Channel 3: SIGNAL WIRE      — coordination events (ephemeral)
```

Humans see Channel 1 and 2 (in human-readable form via export).
Channel 3 is agent-only infrastructure.

---

## Channel 1: Context Bus

**File:** `.ai/bus/<epic-id>.bus`

A running log of everything agents have built, decided, and discovered.
Agents append to it. Never edit existing entries.

### Format

```
@CTX <name> <agent> <story> <date>
<typed key-value content, varies by kind>
---

@DEC <name> <agent> <story>
+<chosen> -<rejected> [-<rejected>...]
WHY <1 line reasoning>
REV <yes|no|conditional>
AFF <what downstream work this affects>
---

@WARN <name> <agent> <story>
ON <trigger condition>
ERR <error code or symptom>
FIX <concrete fix with code/status>
SEV <critical|high|medium|low>
---
```

### Real example: full auth epic context bus

```
@CTX users-table db-engineer E001-S001 2026-03-16
FILE db/migrations/001_create_users.sql
SCHEMA users
  id            uuid          PK           =uuid_generate_v4()
  email         varchar       UNIQUE,NN
  name          varchar       NN
  password_hash varchar       NN
  created_at    timestamptz   NN           =now()
---

@DEC no-soft-delete db-engineer E001-S001
+hard_delete -soft_delete
WHY no product requirement; non-breaking to add later
REV yes
AFF any agent writing DELETE queries on users
---

@DEC auth-provider backend-developer E001-S002
+supabase_auth -custom_jwt -firebase_auth
WHY epic E001 says "use Supabase where possible"
REV no (full auth rewrite required)
AFF all auth endpoints and token handling
---

@CTX auth-api-contract backend-developer E001-S002 2026-03-16
FILE docs/api/auth.yaml
ENDPOINTS
  POST /auth/login    IN{email,password}     OUT{token,user}    ERR[401,422]
  POST /auth/register IN{email,password,name} OUT{user}          ERR[409,422]
ERRORS shape:{code:string,message:string}
---

@WARN duplicate-email db-engineer E001-S001
ON INSERT users WHERE email already exists
ERR pg:unique_violation/23505
FIX catch>HTTP409 body:{code:"EMAIL_EXISTS",message:"Account exists"}
SEV high
---

@CTX login-ui flutter-developer E001-S004 2026-03-16
FILE lib/features/auth/ui/login_screen.dart
WIDGET LoginScreen
FIELDS email(TextFormField,regex_validated) password(TextFormField,min8)
STATES submit>loading(CircularProgressIndicator) error>snackbar(red,message)
EXPECTS api_error_shape:{code,message}
---

@DEC form-validation flutter-developer E001-S004
+client_side_validation -server_only
WHY immediate UX feedback; server validates too (defense in depth)
REV yes
AFF no downstream impact
---
```

### Why this shape works for agents

1. **Every entry is self-contained.** An agent reading this doesn't
   need to "remember" previous entries — each has its own agent,
   story, and date.

2. **Type prefixes are scannable.** An agent working on API
   implementation can: read all @CTX (know what exists), read all
   @WARN (know what to handle), skip @DEC unless it contradicts
   a plan.

3. **No prose.** The WHY lines are the only natural language, and
   they're capped at 1 line. Everything else is structured.

4. **Column alignment is token-efficient.** `id uuid PK =uuid_v4()`
   is fewer tokens than `{"name":"id","type":"uuid","pk":true,...}`
   because there are no quotes, braces, or key labels.

5. **Abbreviations are unambiguous in context.** `NN` can only mean
   NOT NULL inside a SCHEMA block. `REV` can only mean reversible
   inside a @DEC block. Context-dependent compression.

---

## Channel 2: Task Interface

**File:** each story's `.md` file, but the agent-to-agent section
uses a structured block.

When the swarm orchestrator (or a human) assigns work, the story
file is the interface. But the critical agent-readable section is:

```
## A2A

IN
  read .ai/bus/E001.bus @CTX:users-table @CTX:auth-api-contract
  read .ai/bus/E001.bus @WARN:*
  read docs/api/auth.yaml

OUT
  lib/auth/routes.dart NEW
  lib/auth/repository.dart MOD +signIn(email,pw)>Token +signUp(email,pw,name)>User
  test/auth/routes_test.dart NEW min:4(2_happy,2_error)

APPEND .ai/bus/E001.bus
  @CTX auth-implementation ...
  @DEC <any decisions made>
  @WARN <any gotchas discovered>

SCOPE
  +login_endpoint +register_endpoint +error_handling(409,422,401)
  -email_verification -password_reset -rate_limiting -refresh_tokens
```

### Why this shape works

**IN** — tells the agent exactly what to read, with section anchors.
No "check the context file" — specific entries by name.

**OUT** — tells the agent what artifacts to produce, with `NEW` vs
`MOD`, and for modifications, what to add (`+signIn`, `+signUp`).
The agent can verify completion: "does the file exist? does it have
these methods?"

**APPEND** — tells the agent what to write back to the bus. This is
the "handoff" — but it happens as a natural part of task completion,
not as a separate step.

**SCOPE** — `+` for in-scope, `-` for out-of-scope. No ambiguity.
An agent can grep for `-password_reset` and know instantly: don't
build this.

---

## Channel 3: Signal Wire

**File:** `.ai/signals/<story-id>.sig`

Ephemeral coordination signals between agents. Created when an event
happens, consumed by waiting agents, deleted when the epic completes.

```
DONE E001-S001 db-engineer 2026-03-16T10:23:00Z
  bus_entries: users-table, no-soft-delete, duplicate-email
  files_changed: db/migrations/001_create_users.sql
  tests: 3/3

DONE E001-S002 backend-developer 2026-03-16T10:45:00Z
  bus_entries: auth-provider, auth-api-contract
  files_changed: docs/api/auth.yaml
  tests: 0 (spec only)

READY E001-S003 2026-03-16T10:45:00Z
  unblocked_by: E001-S001, E001-S002
  bus_read_required: users-table, auth-api-contract, duplicate-email

CLAIMED E001-S003 backend-developer-2 2026-03-16T10:46:00Z

FAIL E001-S003 backend-developer-2 2026-03-16T11:30:00Z
  reason: test_failure
  detail: signUp returns 500 on duplicate email (expected 409)
  bus_append: none
  retry: yes

RETRY E001-S003 backend-developer-2 2026-03-16T11:31:00Z
  attempt: 2
  focus: duplicate email error handling (@WARN:duplicate-email)
```

### Why signals exist separately from the bus

The bus is permanent knowledge. Signals are ephemeral events.

"The users table has these columns" — that's bus content. It's true
forever (or until a migration changes it).

"E001-S001 just finished" — that's a signal. It's relevant for 5
minutes while the orchestrator decides what to unblock. After that,
it's noise in the context window.

Separating them means: agents read the bus (permanent, grows slowly)
and check signals (ephemeral, cleared per wave). Context window
stays clean.

---

## Three-Layer Architecture Summary

```
┌─────────────────────────────────────────────┐
│  HUMAN LAYER                                │
│  Reads: BOARD.md, story files, epic files   │
│  Writes: stories, priorities, epic goals    │
│  Format: Markdown (Exp 06 protocol)         │
└────────────────┬────────────────────────────┘
                 │ export/import
┌────────────────▼────────────────────────────┐
│  AGENT-HUMAN INTERFACE                      │
│  Story files with ## A2A section            │
│  Human writes description + criteria        │
│  Agent reads ## A2A for structured I/O      │
│  Both sections coexist in same file         │
└────────────────┬────────────────────────────┘
                 │
┌────────────────▼────────────────────────────┐
│  AGENT LAYER                                │
│  Bus: .ai/bus/<epic>.bus (permanent context) │
│  Signals: .ai/signals/<story>.sig (events)  │
│  Format: A2A compact DSL                    │
│  Humans don't read this (but can export it) │
└─────────────────────────────────────────────┘
```

The key insight: **two formats, one truth.** The bus is the source
of truth. The markdown in story files is a human-readable projection
of the bus. Agents write the bus, and a simple export script can
generate the human-readable version.

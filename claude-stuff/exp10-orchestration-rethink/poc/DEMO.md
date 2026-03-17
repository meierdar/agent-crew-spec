# PoC Demo: Evolved Agent Orchestration

## What this demonstrates

Three changes to the existing structure that make agents work better
without burning down what already works.

## The Tools

### `ai-verify` — Executable acceptance criteria + DoD

Parses `\`\`\`verify` blocks from stories and `\`\`\`verify-always`
blocks from convention files, then runs them.

```sh
# Dry run — show what would be checked
ai-verify stories/E001-S002.md --dry-run

# Story checks only
ai-verify stories/E001-S002.md --story-only

# DoD checks only
ai-verify stories/E001-S002.md --dod-only

# Everything (story + DoD)
ai-verify stories/E001-S002.md
```

### `ai-progress` — Progress logging (replaces pre-planned tasks)

Agent records what it actually does, building a real-time log.

```sh
# Agent starts working
ai-progress stories/E001-S002.md started

# Agent records progress
ai-progress stories/E001-S002.md done "Created LoginScreen"
ai-progress stories/E001-S002.md fix "Found bug in AuthRepository"
ai-progress stories/E001-S002.md wip "Writing widget tests"
ai-progress stories/E001-S002.md blocked "Supabase down"

# Agent finishes
ai-progress stories/E001-S002.md verified
ai-progress stories/E001-S002.md review

# View progress
ai-progress stories/E001-S002.md show
```

## Before / After Comparison

### Acceptance Criteria

**BEFORE (prose):**
```markdown
## Acceptance Criteria
- [ ] User can register with email and password (minimum 8 chars)
- [ ] User can log in with existing credentials
- [ ] Validation errors shown inline
- [ ] Supabase error messages shown as snackbar
- [ ] After successful login, user is redirected to home screen
- [ ] Loading state shown during auth requests
```

Problems:
- "User can register" — what does "can" mean? How do I verify?
- "Validation errors shown inline" — which errors? What constitutes "inline"?
- "Loading state shown" — how do I check this programmatically?

**AFTER (executable):**
```markdown
## Acceptance Criteria

### Verifiable (agent runs these)

\`\`\`verify
FILE_EXISTS lib/features/auth/presentation/register_screen.dart
TEST dart test test/features/auth/presentation/register_screen_test.dart
GREP lib/features/auth/presentation/register_screen.dart "signUp"
GREP lib/features/auth/presentation/register_screen.dart "validator"
GREP lib/features/auth/presentation/ "RegExp.*email|email.*RegExp"
GREP lib/features/auth/presentation/ "length.*8|8.*length"
GREP lib/features/auth/presentation/ "SnackBar|ScaffoldMessenger"
GREP lib/features/auth/presentation/ "isLoading|AsyncValue|loading"
\`\`\`

### Human-verified (reviewer checks these)

- [ ] Screens follow existing design system
- [ ] UX feels natural
```

What changed:
- Each criterion maps to a runnable check
- Agent runs `ai-verify` and gets pass/fail — no interpretation
- Visual/UX criteria stay as prose for human review
- The split is explicit: "agent verifies X, human verifies Y"

---

### Definition of Done

**BEFORE (checklist for agent to self-report):**
```markdown
# Definition of Done
- [ ] Code compiles / builds without errors
- [ ] All existing tests still pass
- [ ] Linter passes with zero warnings
- [ ] No TODO/FIXME/HACK without a story reference
- [ ] No hardcoded secrets
```

Problems:
- Agent has to figure out: what command builds? What linter? What config?
- Agent self-reports results — no independent verification
- "No hardcoded secrets" — agent says "I didn't add any" but how
  would a reviewer verify this quickly?

**AFTER (executable script in conventions):**
```markdown
\`\`\`verify-always
RUN flutter build apk --debug
RUN flutter test
RUN dart analyze --fatal-infos
GREP_FAIL lib/ "//\s*(TODO|FIXME|HACK)(?!.*E\d{3}-S\d{3})"
GREP_FAIL lib/ "(sk_live|pk_live|password\s*=|api_key\s*=)"
FILE_NOT_EXISTS .env
FILE_NOT_EXISTS .env.local
\`\`\`
```

What changed:
- Every check is a runnable command with a clear pass/fail condition
- Agent doesn't figure out "what linter" — the convention tells it
- `GREP_FAIL` mechanically catches secrets, not by trust
- Runs automatically via `ai-verify` — no self-reporting

---

### Tasks

**BEFORE (pre-planned by human):**
```markdown
## Tasks
- [ ] Create `LoginScreen` widget
- [ ] Create `RegisterScreen` widget
- [ ] Add form validation logic
- [ ] Connect to existing `AuthRepository` via Riverpod
- [ ] Add routes in `go_router` config
- [ ] Write widget tests for both screens
```

Problems:
- Human guesses implementation steps before agent starts
- Agent might take a different path — tasks become fiction
- If agent crashes, tasks are either all unchecked (no info) or
  partially checked (coarse, possibly inaccurate)

**AFTER (progress log written by agent as it works):**
```markdown
## Progress

<!-- Agent writes here as it works. Do not pre-fill. -->
- [>] `08:28` Work started
- [x] `08:28` Created LoginScreen at lib/features/auth/presentation/login_screen.dart
- [x] `08:28` Created RegisterScreen at lib/features/auth/presentation/register_screen.dart
- [x] `08:28` Form validation: email regex, password min 8 chars
- [!] `08:28` Discovered AuthRepository.signUp throws untyped exception on duplicate — wrapped in AuthException
- [x] `08:28` Snackbar error handling for Supabase errors
- [ ] `08:28` Writing widget tests
```

What changed:
- Agent records what ACTUALLY happened, not what was planned
- Surprises are captured (the `[!]` fix entry)
- Crash recovery: next agent reads exactly where work stopped
- Checkpoint file has machine-readable timeline for tooling

---

## The Agent Workflow (New)

```
1. Receive story assignment
2. ai-progress <story> started           # mark in-progress
3. Read story: description, verify block, boundary, technical notes
4. Work the story, calling ai-progress after each milestone:
   - ai-progress <story> done "..."      # completed step
   - ai-progress <story> fix "..."       # corrected something
   - ai-progress <story> wip "..."       # currently working on
5. ai-verify <story> --story-only        # run story checks
6. Fix any failures, repeat step 5
7. ai-verify <story>                     # run story + DoD checks
8. If all pass:
   - ai-progress <story> verified
   - ai-progress <story> review          # set status: review
9. If blocked:
   - ai-progress <story> blocked "..."   # record blocker, stop
```

The key shift: **verification is mechanical, not interpretive.**
The agent doesn't decide whether "login works" — it runs a test
and gets pass/fail.

## File Layout

```
poc/
├── bin/
│   ├── ai-verify          # Executable AC + DoD checker
│   └── ai-progress        # Progress logging tool
├── conventions/
│   └── flutter.md         # Stack + patterns + verify-always
├── stories/
│   └── E001-S002-*.md     # Converted story with verify block
├── checkpoints/
│   └── E001-S002.checkpoint  # Auto-generated timeline
└── DEMO.md                # This file
```

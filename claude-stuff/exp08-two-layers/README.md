# Experiment 08: Two-Layer Architecture — Does Every File Need It?

## The instinct vs. the reality

The instinct: "Translate everything to agent format! Maximum efficiency!"

The reality: Not every file costs the same number of wasted tokens.
Let me actually measure where the waste is.

## Waste audit: every file an agent reads on startup

When an agent starts a story, CLAUDE.md tells it to read:
1. Role definition
2. Story file
3. Parent epic
4. DoD

Let me score each file type on: how much is wasted on human-readable
formatting, how much carries unique information, and whether a
translation would actually help.

### 1. CLAUDE.md — the entry point

```markdown
Before starting any work, follow this sequence:

1. **Read your role definition** in `.ai/roles/`
   (project-specific overrides take precedence over defaults)
2. **Read the assigned story** you've been given
   (path will be provided in the prompt)
3. **Check `.ai/dod.md`** to understand what "done" means
```

**Token count:** ~250 total
**Waste:** ~30 tokens of bold markers, backtick formatting
**Unique info:** Procedural steps (read role, read story, etc.)
**Would translation help?** BARELY. This file is read once per
session. 30 tokens saved. Not worth maintaining two versions.

**Verdict: NO TRANSLATION. Keep as-is.**

### 2. Role definition (e.g., flutter-developer.md)

```markdown
- **Framework:** Flutter 3.x
- **State Management:** Riverpod
- **Navigation:** go_router
```

**Token count:** ~150 total
**Waste:** ~20 tokens of bold/list formatting
**Unique info:** Tech stack, conventions, all essential
**Would translation help?** BARELY. Read once, small file.

**Verdict: NO TRANSLATION. Keep as-is.**

### 3. Story file (e.g., E001-S003)

```markdown
## Description
Build the actual API endpoints per the contract, wired to the
database. Supabase Auth is already configured (see E001-S001).

## Acceptance Criteria
- [ ] Login endpoint works with valid credentials
- [ ] Registration creates user in database

## Technical Notes
Check the shared context file for details on the database schema
```

**Token count:** ~200 total
**Waste:** ~40 tokens of section headers, prose description
**Ambiguity cost:** ~200 tokens of reasoning to disambiguate
  "per the contract," "wired to," "see E001-S001," "check the
  shared context file for details"
**TOTAL real cost:** ~400 tokens (200 reading + 200 disambiguating)

**Equivalent in agent format:**
```
@STORY E001-S003 backend-developer M critical
IN .ai/bus/E001.bus @CTX:users-table @CTX:auth-api-contract @WARN:*
IN docs/api/auth.yaml
OUT lib/auth/routes.dart NEW
OUT lib/auth/repository.dart MOD +signIn +signUp
OUT test/auth/routes_test.dart NEW min:4
SCOPE +login +register +errors(409,422,401)
SCOPE -email_verify -password_reset -rate_limit -refresh_tokens
DONE_WHEN tests_pass AND endpoints_match_contract AND errors_handled
```

**Token count:** ~80
**Waste:** ~0
**Ambiguity cost:** ~0

**Savings: ~320 tokens per story. THIS IS SIGNIFICANT.**
Over 8 stories in an epic: ~2,560 tokens saved.

**Verdict: YES, TRANSLATE. Stories are the biggest win.**

### 4. Epic file

```markdown
## Goal
What is the user-facing outcome when this epic is complete?

## Context
Why are we doing this? What problem does it solve?

## Scope
### In Scope
- ...
### Out of Scope
- ...
```

**Token count:** ~200 total
**Waste:** ~30 tokens of section headers, prose
**Unique info:** Goal, scope boundaries — actually useful prose
**Would translation help?** MODERATELY. The scope section could
be compressed. But the Goal section is genuinely natural language
that serves agents well (understanding the WHY).

**Verdict: PARTIAL. Translate scope to +/- notation. Keep goal as prose.**

### 5. Shared context (currently markdown)

**Already covered in Exp 07.** This is the BIGGEST win for
translation. Bus format saves ~40 tokens per entry × 30 entries
= ~1,200 tokens.

**Verdict: YES, TRANSLATE. Already done (bus format).**

### 6. DoD (dod.md)

**Token count:** ~200
**Waste:** ~30 tokens
**Read frequency:** Once per session
**Would translation help?** NOT WORTH IT. Read once, low waste.
Could be a checklist the agent internalizes.

**Verdict: NO TRANSLATION. Keep as-is.**

---

## The actual answer

NOT everything should be translated. Only two file types justify
the maintenance cost of two versions:

| File type | Translate? | Why |
|-----------|-----------|-----|
| CLAUDE.md | No | Read once, low waste, procedural |
| Role definitions | No | Read once, small, already structured |
| **Stories** | **YES** | Read every task, high ambiguity cost, biggest win |
| Epics | Partial | Scope yes, goal no |
| **Context/Bus** | **YES** | Read constantly, huge cumulative savings |
| DoD | No | Read once, short, already a checklist |
| Signals | Agent-only | Already in agent format (no human version needed) |

The dual-layer architecture makes sense for **stories and context**.
Everything else should stay single-layer (human-readable, which
agents handle fine for one-time reads).

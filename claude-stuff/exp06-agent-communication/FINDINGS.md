# Findings: How Agents Should Communicate

## The short answer

**Not pure human language. Not pure machine format. A hybrid with
strict rules about when to use which.**

The protocol I designed has five entry types (CONTEXT, REQUEST,
DECISION, WARNING, STATUS), each with a structured template. Natural
language only appears in constrained slots where nuance matters —
the "Because" field of a DECISION, the "Reasoning" section of a
CONTEXT.

## What I learned designing this

### 1. Tables are the killer format for agents

Look at the difference:

**Prose:** "Users table: id (uuid, PK), email (varchar, unique),
name (varchar), password_hash (varchar), created_at (timestamptz)"

**Table:**
| Column | Type | Constraints |
|--------|------|-------------|
| id | uuid | PK |
| email | varchar | UNIQUE, NOT NULL |

The table has FEWER tokens (no commas, no parentheses as grouping,
no "table:" prefix) and ZERO ambiguity. I don't have to figure out
if "(varchar, unique)" means the column type is "varchar, unique"
or if "unique" is a separate constraint. In the table, each column
is a slot with one meaning.

**Recommendation: Use markdown tables for any data with 2+ fields
per item.** Schema, endpoints, artifacts, error codes — all tables.

### 2. Typed entries beat timestamps

The current context file is organized by time:
```
### 2026-03-16 — db-engineer
[everything about the database in one blob]
```

The ACP format is organized by type:
```
## CONTEXT: users-table
## DECISION: no-soft-delete
## WARNING: duplicate-email
```

Why typed is better: when Agent C picks up E001-S005 (integration),
it needs to:
1. Find all CONTEXT entries to know what exists
2. Find all WARNING entries to know what to handle
3. Skip DECISION entries unless it's about to reverse one

With timestamps, Agent C has to read EVERYTHING and mentally
categorize it. With types, it can scan headers and read only what's
relevant. **This is the difference between O(n) and O(1) lookup
for the agent.**

### 3. "Not in scope" saves more tokens than any other field

In the before/after story comparison, the biggest single improvement
is the "Not in scope" section:
```
### Not in scope
- Email verification flow
- Password reset flow
- Rate limiting
- Session/refresh token management
```

Without this, I might spend 200+ tokens reasoning about whether
password reset is part of "implement auth API endpoints." With it,
I spend zero. The explicit boundary eliminates an entire class of
agent mistakes: gold-plating (building more than was asked for).

**Recommendation: Every story should have a "Not in scope" section.
It's more valuable than the description.**

### 4. Concrete file paths beat references

**Before:** "Check the shared context file for details on the
database schema"

**After:** `.ai/context/E001.md` → CONTEXT: users-table

The "after" version tells me exactly which file, and exactly which
section of that file. I can jump straight there. The "before" version
requires me to: know where context files live, read the whole file,
figure out which part is about the database schema.

**Recommendation: Never reference information by description.
Always reference by path + section anchor.**

### 5. Natural language is still necessary — but only for "why"

I can't eliminate natural language entirely. Decisions need rationale.
Warnings need context about severity. Architectural choices need
explanation of tradeoffs.

But natural language should be **quarantined** to specific fields:
- DECISION → "Because" field
- CONTEXT → "Reasoning" section (optional)
- Story → nowhere (use structured REQUEST format)

Everything else — what was built, where it lives, what constraints
apply, what's in/out of scope — should be structured.

---

## The uncomfortable truth

The current spec is written for humans who happen to give files to
agents. The optimal spec is written for agents who happen to be
readable by humans.

That's a different design goal. It means:
- Tables over prose
- Explicit file paths over "see the previous work"
- Typed entries over chronological journals
- Scope boundaries over open-ended descriptions
- Structured templates over free-form sections

The good news: **the agent-optimal format is ALSO better for humans.**
Tables are easier to scan than prose. Typed entries are easier to find
than chronological entries. "Not in scope" prevents scope creep for
human teams too.

The format that's best for agents is just... good technical writing.
The difference is that agents NEED it to function well, while humans
can muddle through bad writing. So optimizing for agents forces you
to write clearly, which helps everyone.

---

## Concrete changes to the spec

### 1. Story template → use REQUEST format
Replace "Description" with structured Input/Output/Constraints/Not-in-scope.

### 2. Context files → use typed entries
Replace chronological journal with CONTEXT/DECISION/WARNING entries.
Each entry has a short-name anchor for direct reference.

### 3. Add ACP reference to role definitions
Each role file should include: "When writing to shared context,
use the ACP format: CONTEXT for artifacts, DECISION for choices,
WARNING for gotchas."

### 4. "Not in scope" becomes mandatory
Every story must explicitly list what's NOT included. This is the
single highest-value change for agent efficiency.

---

## What I would NOT change

- **YAML frontmatter stays.** It's already the right format for
  metadata. Structured, parseable, readable.
- **Markdown stays as the container.** It renders everywhere, humans
  can read it, agents parse it well. No need for custom formats.
- **Natural language stays for reasoning.** Don't try to structure
  "why" — it's inherently fuzzy and that's fine. Just constrain
  WHERE it appears.

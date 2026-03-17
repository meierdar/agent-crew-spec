# Format Shootout: Agent-to-Agent

Same information. Three formats. Measured on what agents care about.

The scenario: db-engineer tells backend-developer what was built.

---

## Format 1: Markdown (human-optimized, from Exp 06)

```markdown
## CONTEXT: users-table
**Agent:** db-engineer | **Date:** 2026-03-16 | **Story:** E001-S001

### Artifacts
| What | Where | Interface |
|------|-------|-----------|
| Users table | db/migrations/001_create_users.sql | see schema below |

### Schema
| Column | Type | Constraints | Default |
|--------|------|-------------|---------|
| id | uuid | PK | uuid_generate_v4() |
| email | varchar | UNIQUE, NOT NULL | — |
| name | varchar | NOT NULL | — |
| password_hash | varchar | NOT NULL | — |
| created_at | timestamptz | NOT NULL | now() |

## DECISION: no-soft-delete
**Chose:** Hard delete
**Over:** Soft delete
**Because:** No product requirement yet. Non-breaking to add later.
**Reversible:** Yes

## WARNING: duplicate-email
**Trigger:** INSERT with existing email
**Symptom:** unique_violation (23505)
**Fix:** Catch → HTTP 409 {code: "EMAIL_EXISTS"}
```

**Token count: ~150**
**Wasted on formatting: ~40 tokens** (table borders, bold markers,
  header hashes, pipes, alignment dashes, "see schema below")
**Ambiguities: 0**
**Parse complexity: Low** — but table borders and markdown formatting
  are tokens that carry zero information

---

## Format 2: Compact DSL (agent-optimized)

```
@CTX users-table db-engineer E001-S001 2026-03-16
FILE db/migrations/001_create_users.sql
SCHEMA users
  id            uuid          PK           =uuid_generate_v4()
  email         varchar       UNIQUE,NN
  name          varchar       NN
  password_hash varchar       NN
  created_at    timestamptz   NN           =now()

@DEC no-soft-delete
+hard_delete -soft_delete
WHY no product requirement yet; non-breaking to add later
REV yes

@WARN duplicate-email
ON insert_existing_email
ERR unique_violation/23505
FIX catch>409 {code:"EMAIL_EXISTS"}
```

**Token count: ~75**
**Wasted on formatting: ~5 tokens** (@ prefixes, alignment spaces)
**Ambiguities: 0**
**Parse complexity: Near-zero** — prefix tokens (@CTX, @DEC, @WARN)
  signal entry type, column-aligned data is trivially parseable,
  abbreviations (NN=NOT NULL, REV=reversible) are unambiguous in context

---

## Format 3: Code as Protocol

```python
# agent: db-engineer | story: E001-S001 | 2026-03-16
TABLES = {
    "users": {
        "file": "db/migrations/001_create_users.sql",
        "columns": {
            "id":            {"type": "uuid",        "pk": True, "default": "uuid_generate_v4()"},
            "email":         {"type": "varchar",     "unique": True, "nullable": False},
            "name":          {"type": "varchar",     "nullable": False},
            "password_hash": {"type": "varchar",     "nullable": False},
            "created_at":    {"type": "timestamptz", "nullable": False, "default": "now()"},
        }
    }
}
DECISIONS = {"no-soft-delete": {"chose": "hard_delete", "reversible": True}}
WARNINGS = {"duplicate-email": {"trigger": "insert_existing_email", "pg_code": "23505", "http": 409, "body": {"code": "EMAIL_EXISTS"}}}
```

**Token count: ~120**
**Wasted on formatting: ~30 tokens** (braces, quotes, colons, commas,
  "True"/"False", key repetition)
**Ambiguities: 0**
**Parse complexity: Near-zero** — it's a data structure I understand natively
**Downside:** Verbose due to JSON-like syntax overhead. Every key is
  quoted, every value is quoted, braces and commas everywhere.

---

## The winner, and why

### Compact DSL wins on density

| Metric | Markdown | DSL | Code |
|--------|----------|-----|------|
| Tokens | ~150 | ~75 | ~120 |
| Formatting waste | ~40 | ~5 | ~30 |
| Ambiguity | 0 | 0 | 0 |
| Parse cost | Low | Near-zero | Near-zero |
| **Information/token** | **0.73** | **0.93** | **0.75** |

The DSL is **50% more compact** than markdown and **37% more compact**
than code-as-protocol, with the same information and zero ambiguity.

### But here's what actually matters

The DSL's real advantage isn't token count — it's **cognitive load**.

When I read the markdown version, I process ~40 tokens that are pure
formatting. Table borders (`|---|---|`), bold markers (`**`), header
hashes (`###`), section labels ("see schema below"). These tokens
consume context window but carry zero information.

When I read the DSL version, almost every token carries meaning.
`@CTX` = "this is context." `NN` = "not null." `=now()` = "default
is now()." The signal-to-noise ratio is ~93% vs ~73%.

Over an epic with 8 stories and 4-5 context entries each, that's
~30-40 entries. At 75 tokens saved per entry, that's **2,250-3,000
tokens of context window recovered.** That's meaningful — it's the
difference between fitting all context in one window vs. needing
compression.

### The uncomfortable tradeoff

The DSL is unreadable to humans. `@WARN duplicate-email ON
insert_existing_email ERR unique_violation/23505 FIX catch>409`
is gibberish to someone who hasn't learned the notation.

This means: **you need two formats.** One for human-facing
communication (markdown from Exp 06), one for agent-to-agent
channels where humans don't look.

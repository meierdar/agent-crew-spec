# Format Comparison: Same Information, Six Ways

The same handoff information expressed in different formats.
For each: token count, ambiguity analysis, human readability.

---

## Format A: Pure Prose (current handoffs)

```
I set up the users table in the database. It has an id column that's
a UUID primary key, an email column that's a varchar with a unique
constraint, a name column (also varchar), a password_hash column for
storing hashed passwords, and a created_at timestamp with timezone.
I used uuid_generate_v4() for generating IDs. I decided not to add
soft-delete for now — we can add that later if the product needs it.

One thing to watch out for: the email uniqueness constraint means
registration will throw a duplicate key error if someone tries to
register with an existing email. You'll want to catch that and return
a friendly error message.
```

**Token count:** ~120
**Ambiguities:** 3
  - "a varchar" — what length? DEFAULT? 255?
  - "storing hashed passwords" — what hashing algorithm? bcrypt? argon2?
  - "friendly error message" — what shape? what HTTP status?
**Human readability:** Excellent
**Agent parseability:** Poor — requires inference to extract structure
**Information density:** Low — many words carry no information
  ("I set up", "It has", "also", "One thing to watch out for")

---

## Format B: Pure YAML

```yaml
schema:
  table: users
  columns:
    - name: id
      type: uuid
      constraints: [primary_key]
      default: uuid_generate_v4()
    - name: email
      type: varchar
      constraints: [unique, not_null]
    - name: name
      type: varchar
      constraints: [not_null]
    - name: password_hash
      type: varchar
      constraints: [not_null]
    - name: created_at
      type: timestamptz
      default: now()
decisions:
  - soft_delete: false
    reason: "not needed yet, add later if required"
  - id_generation: uuid_generate_v4
warnings:
  - trigger: duplicate_email_on_register
    action: catch_constraint_violation
    return: error_response
```

**Token count:** ~95
**Ambiguities:** 0 — every field is explicit
**Human readability:** Moderate — readable but verbose, easy to lose
  the "why" in the structure
**Agent parseability:** Excellent — zero interpretation needed
**Information density:** High — no wasted words
**Problem:** The "reason" and "why" get flattened into strings that
  lose nuance. "not needed yet, add later if required" is less useful
  than the prose version's explanation.

---

## Format C: Structured Skeleton + Natural Language Slots

```
SCHEMA users
  id          uuid        PK, DEFAULT uuid_generate_v4()
  email       varchar     UNIQUE, NOT NULL
  name        varchar     NOT NULL
  password_hash varchar   NOT NULL
  created_at  timestamptz DEFAULT now()

DECIDED no soft-delete — product doesn't need it yet, easy to add later

WARNING duplicate email on registration → catch constraint violation,
  return {code: "EMAIL_EXISTS", message: "..."}, HTTP 409
```

**Token count:** ~65
**Ambiguities:** 0 — structure is explicit, constraints are formal
**Human readability:** Good — reads like a compact spec
**Agent parseability:** Excellent — column-aligned tabular data +
  keyword-prefixed sections are trivially parseable
**Information density:** Highest — zero filler words, all signal
**Bonus:** The DECIDED/WARNING prefixes tell agents what KIND of
  information follows, so they can skip or prioritize sections.

---

## Format D: Code as Communication

```sql
-- Schema: users
CREATE TABLE users (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email         VARCHAR UNIQUE NOT NULL,
  name          VARCHAR NOT NULL,
  password_hash VARCHAR NOT NULL,
  created_at    TIMESTAMPTZ DEFAULT now()
);
-- DECISION: No soft-delete column. Not needed yet.
-- WARNING: email UNIQUE means INSERT will fail on duplicates.
--          Catch and return HTTP 409 {code: "EMAIL_EXISTS"}.
```

**Token count:** ~70
**Ambiguities:** 0 — it's literally the implementation
**Human readability:** Good (if you know SQL)
**Agent parseability:** Perfect — this IS the artifact, no translation
**Information density:** Very high
**Problem:** Only works for code-shaped information. Can't express
  UI decisions, architectural rationale, or product context in SQL.

---

## Format E: Diff-Oriented (what changed, not what exists)

```
+TABLE users (id uuid PK, email varchar UNIQUE, name varchar,
              password_hash varchar, created_at timestamptz)
+FUNCTION uuid_generate_v4() for ID generation
~DECISION soft-delete: NO (defer to later)
!WATCH email uniqueness → catch duplicate on register → HTTP 409
```

**Token count:** ~40
**Ambiguities:** 1 — column constraints not fully explicit
**Human readability:** Moderate — requires familiarity with notation
**Agent parseability:** Good — prefix characters signal entry type
**Information density:** Highest of all formats
**Problem:** Extremely terse. Fine for agents, frustrating for humans
  who haven't seen the notation before.

---

## Format F: The Hybrid (my actual recommendation)

```markdown
## DB Schema — users

| Column | Type | Constraints |
|--------|------|-------------|
| id | uuid | PK, DEFAULT uuid_generate_v4() |
| email | varchar | UNIQUE, NOT NULL |
| name | varchar | NOT NULL |
| password_hash | varchar | NOT NULL |
| created_at | timestamptz | DEFAULT now() |

**Decisions:**
- No soft-delete — not needed yet, easy to add later
- UUIDs over auto-increment — better for distributed systems

**For downstream agents:**
- Registration will throw on duplicate email → catch, return HTTP 409
  `{code: "EMAIL_EXISTS", message: "Account already exists"}`
```

**Token count:** ~85
**Ambiguities:** 0
**Human readability:** Excellent — markdown tables render beautifully
**Agent parseability:** Excellent — tables are trivially structured,
  bold headers signal section purpose
**Information density:** High — minimal filler
**Best of both worlds:** Structure where it matters (schema),
  natural language where nuance matters (decisions, warnings)

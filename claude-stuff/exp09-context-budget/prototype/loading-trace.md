# Loading Trace: What An Agent Actually Reads

Side-by-side comparison of startup loading for the same task
(E001-S003: Implement auth API endpoints).

---

## WITHOUT progressive loading (current)

```
LOAD  CLAUDE.md                              5,000 tokens
LOAD  .ai/roles/defaults/backend-developer   2,500 tokens
LOAD  .ai/roles/project/backend-developer    1,500 tokens
LOAD  .ai/dod.md                             1,000 tokens
LOAD  .ai/epics/E001.md                      2,000 tokens
LOAD  .ai/stories/E001-S003.md                 800 tokens
LOAD  .ai/context/E001.md (all entries)      5,000 tokens
LOAD  .ai/knowledge/auth.md                  3,000 tokens
LOAD  .ai/knowledge/api-style.md             2,000 tokens
LOAD  .ai/knowledge/errors.md               1,500 tokens
LOAD  .ai/knowledge/database.md             3,000 tokens  ← NOT NEEDED
LOAD  .ai/knowledge/ui-patterns.md          2,500 tokens  ← NOT NEEDED
LOAD  .ai/knowledge/testing.md              2,000 tokens  ← NOT NEEDED
LOAD  .ai/knowledge/deploy.md              2,000 tokens  ← NOT NEEDED
LOAD  .ai/knowledge/a11y.md               1,500 tokens  ← NOT NEEDED
LOAD  .ai/knowledge/performance.md        1,500 tokens  ← NOT NEEDED
LOAD  .ai/knowledge/security.md           2,500 tokens  ← NOT NEEDED
                                         ──────────
TOTAL:                                    39,300 tokens
NOT NEEDED:                               15,000 tokens (38% waste)
LEFT FOR SOURCE CODE:                     13,700 tokens (~4 files)
```

## WITH progressive loading

```
TIER 1: KERNEL
LOAD  .ai/boot.md                              200 tokens

TIER 2: TASK-RELEVANT (guided by ## A2A)
LOAD  .ai/roles/defaults/backend-developer
      → Summary section only                    100 tokens
LOAD  .ai/stories/E001-S003.md
      → ## A2A section                           200 tokens
LOAD  .ai/bus/E001.bus
      → @CTX:users-table                          60 tokens
      → @CTX:auth-api-contract                    60 tokens
      → @WARN:* (1 entry)                         50 tokens
      → @DEC:auth-provider                        40 tokens
LOAD  .ai/knowledge/auth.md    (from LOAD)    3,000 tokens
LOAD  .ai/knowledge/api-style.md (from LOAD)  2,000 tokens
LOAD  .ai/knowledge/errors.md  (from LOAD)    1,500 tokens
LOAD  .ai/dod.md                              1,000 tokens
LOAD  docs/api/auth.yaml       (from IN)      1,000 tokens
                                             ──────────
TOTAL:                                        9,210 tokens
NOT NEEDED:                                       0 tokens (0% waste)
LEFT FOR SOURCE CODE:                        43,790 tokens (~13 files)

TIER 3: ON-DEMAND (only if agent discovers it needs more)
  → role full definition: read if unusual pattern encountered
  → epic details: read if scope question arises
  → other knowledge docs: read if work expands unexpectedly
```

## The difference

```
                    Without    With       Savings
                    ────────   ─────────  ───────
Knowledge loaded    39,300     9,210      76% less
Waste               15,000     0          100% less
Source file room     13,700     43,790     3.2x more
Files holdable      ~4         ~13        3.2x more
```

The agent with progressive loading can hold **3x more source code**
in context. That's not a marginal improvement — it's the difference
between "I can only edit one file at a time" and "I can see the
whole feature and understand how the pieces connect."

#!/bin/sh
# context-budget.sh — model context window allocation at different scales
#
# Shows how the "read once, it's fine" assumption breaks down as
# project knowledge grows.

set -e

echo "================================================================"
echo "  Context Window Budget Calculator"
echo "================================================================"
echo ""
echo "Assumption: 200K token context window"
echo "           ~50% used by conversation + reasoning = 100K available"
echo "           Source files being edited: ~20K-40K"
echo "           Remaining for project knowledge: 60K-80K"
echo ""

BUDGET=70000  # tokens available for project knowledge

echo "================================================================"
echo "  Scenario 1: TODAY (small project)"
echo "================================================================"
echo ""
cat <<'TABLE'
File                        Tokens    Read freq    Category
─────────────────────────────────────────────────────────────
CLAUDE.md                      570    once         setup
Role definition                400    once         setup
DoD                            290    once         setup
Epic                           290    once         setup
Story                          440    per-task     work
─────────────────────────────────────────────────────────────
TOTAL STARTUP                1,990                 2.8% of budget
TABLE
echo ""
echo "  Verdict: Plenty of room. No optimization needed."
echo ""
echo ""

echo "================================================================"
echo "  Scenario 2: MEDIUM PROJECT (6 months in)"
echo "================================================================"
echo ""
cat <<'TABLE'
File                        Tokens    Read freq    Category
─────────────────────────────────────────────────────────────
CLAUDE.md (grown)            2,000    once         setup
Role definition (detailed)   1,500    once         setup
Project role override          800    once         setup
DoD + project-specific DoD     600    once         setup
Epic (detailed)              1,000    once         setup
Story                          500    per-task     work
Shared context (20 entries)  2,000    per-task     context
Domain knowledge docs        5,000    once         knowledge
Skill files (5 skills)       3,000    once         skills
─────────────────────────────────────────────────────────────
TOTAL STARTUP               16,400                 23% of budget
TABLE
echo ""
echo "  Verdict: Getting heavy. Still workable, but the source file"
echo "  budget is shrinking. Agent starts making more mistakes on"
echo "  large files because it can't hold them all in context."
echo ""
echo ""

echo "================================================================"
echo "  Scenario 3: LARGE PROJECT (mature product)"
echo "================================================================"
echo ""
cat <<'TABLE'
File                        Tokens    Read freq    Category
─────────────────────────────────────────────────────────────
CLAUDE.md (comprehensive)    5,000    once         setup
Role definition (full)       2,500    once         setup
Project role override        1,500    once         setup
DoD + project additions      1,000    once         setup
Epic (detailed + history)    2,000    once         setup
Story                          800    per-task     work
Context bus (50+ entries)    5,000    per-task     context
Domain knowledge docs       15,000    once         knowledge
Architecture decision recs   5,000    once         knowledge
Skill files (15 skills)     10,000    once         skills
API reference docs           8,000    once         knowledge
Coding standards doc         3,000    once         knowledge
─────────────────────────────────────────────────────────────
TOTAL STARTUP               58,800                 84% of budget
TABLE
echo ""
echo "  Verdict: CRITICAL. Only ~11K tokens left for actual source"
echo "  code. Agent is now reasoning-limited: it knows a lot about"
echo "  the project but can't hold enough code to work effectively."
echo "  THIS IS WHERE THINGS BREAK."
echo ""
echo ""

echo "================================================================"
echo "  Where the budget goes (Scenario 3)"
echo "================================================================"
echo ""
echo "  ┌─────────────────────────────────────────────────────────┐"
echo "  │ 200K Context Window                                     │"
echo "  ├─────────────────────────────────────────────────────────┤"
echo "  │ Conversation + reasoning tokens          100K (50%)     │"
echo "  │ ├── System prompt + tool descriptions     20K           │"
echo "  │ ├── Multi-turn conversation               40K           │"
echo "  │ └── Internal reasoning                    40K           │"
echo "  ├─────────────────────────────────────────────────────────┤"
echo "  │ Project knowledge (ONE-TIME reads)         42K (21%)    │"
echo "  │ ├── CLAUDE.md                              5K           │"
echo "  │ ├── Role + override                        4K           │"
echo "  │ ├── Domain docs                           15K           │"
echo "  │ ├── Skill files                           10K           │"
echo "  │ ├── API reference                          8K           │"
echo "  │ └── DoD + epic + coding standards          5K  ← READ ONCE   │"
echo "  ├─────────────────────────────────────────────────────────┤"
echo "  │ Working context (PER-TASK reads)           17K (8.5%)   │"
echo "  │ ├── Story file                             0.8K         │"
echo "  │ ├── Context bus                            5K           │"
echo "  │ └── Source files being edited             11K  ← THIS  │"
echo "  ├─────────────────────────────────────────────────────────┤"
echo "  │ UNUSED                                     41K (20.5%)  │"
echo "  └─────────────────────────────────────────────────────────┘"
echo ""
echo "  The problem: 42K tokens of 'read once' knowledge"
echo "  is squeezing source file capacity to just 11K."
echo "  That's maybe 3 files. For complex changes spanning"
echo "  5-10 files, the agent physically can't hold enough"
echo "  code to reason correctly."
echo ""
echo "  And this is WITH the bus optimization from Exp 07."
echo "  Without it, the bus alone would be ~8-10K instead of 5K."

# Experiment 07: Agent-to-Agent Communication

## The different question

Exp 06 asked: "How should agents read and write?"
This experiment asks: "How should agents talk to EACH OTHER?"

These are fundamentally different because:

| Constraint | Agent ↔ Human | Agent ↔ Agent |
|-----------|---------------|---------------|
| Human readability | Required | Not required |
| Prose/narrative | Sometimes useful | Never useful |
| Visual formatting | Matters (tables render nicely) | Irrelevant |
| Information density | Limited by scanning speed | Maximize it |
| Ambiguity tolerance | Humans resolve ambiguity well | Agents resolve it poorly |
| Context window | Human: unlimited | Agent: fixed, precious |
| Parsing cost | Humans don't parse | Agents pay tokens to parse |
| Redundancy | Helps humans remember | Wastes agent context |

When both sides are AI, every byte matters because it's eating
context window. There's no one to impress with pretty formatting.
The only goals are:
1. **Maximum information per token**
2. **Zero ambiguity**
3. **Instant parseability** (no reasoning needed to understand)

## What I'm actually comparing

Three approaches to the same multi-agent scenario:

1. **Markdown (current)** — what Exp 06 recommended for human-readable
2. **Structured DSL** — a custom compact notation designed for agents
3. **Code as protocol** — actual executable code/pseudocode as the message

The scenario: db-engineer finished the schema, backend-developer needs
to know what was built to implement the API.

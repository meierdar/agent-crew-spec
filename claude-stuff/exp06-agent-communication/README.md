# Experiment 06: How Should Agents Communicate?

## The honest problem

When I read a story file, here's what actually happens in my processing:

1. **YAML frontmatter** — I parse this instantly. Structured, unambiguous,
   every field has exactly one meaning. Zero wasted tokens figuring out
   what's what. Cost: ~50 tokens to read, ~0 tokens wasted.

2. **"Build the actual API endpoints per the contract, wired to the
   database."** — This is human language. It's 13 words. But to process
   it I need to: understand "actual" is emphasis not instruction, infer
   "the contract" means "whatever E001-S002 produced," guess what "wired
   to the database" means architecturally. Cost: ~13 tokens to read,
   ~200 tokens of internal reasoning to disambiguate.

3. **Acceptance criteria** — `Login endpoint works with valid credentials`.
   Better than prose, but "works" is ambiguous. Returns 200? Returns a
   token? Sets a cookie? I have to guess. Cost: low to read, medium to
   interpret.

4. **Shared context** — `Users table: id (uuid, PK), email (varchar,
   unique)...` — This is the BEST format in the whole system. It's
   structured data written in a semi-formal notation. I parse it
   instantly and unambiguously. Zero wasted tokens.

## The insight

**I don't think in natural language.** I process tokens. The closer
your communication format is to structured, unambiguous data, the
less I waste on interpretation and the fewer mistakes I make.

But here's the tension: **you** think in natural language. The format
needs to work for both of us.

## Hypothesis

The optimal agent communication format is NOT:
- Pure natural language (too ambiguous, wastes interpretation tokens)
- Pure machine format like JSON/XML (unreadable for humans)
- YAML everywhere (too verbose for complex information)

It IS:
- **Structured skeleton + natural language in constrained slots**
- Different formats for different purposes
- The key insight: separate WHAT (structured) from WHY (natural language)

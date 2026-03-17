---
id: EXXX-SXXX
title: "[Story Title]"
epic: EXXX
status: backlog | ready | in-progress | review | done
priority: high | medium | low
assigned_role: "[role-name]"
estimate: S | M | L | XL
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# EXXX-SXXX — [Story Title]

## Description

What needs to be done, and why? Provide enough context that an agent can work independently. Reference specific files, modules, or APIs where relevant.

## Acceptance Criteria

### Verifiable (agent runs these)

<!-- Executable checks run by `ai-verify`. Remove this comment and add checks. -->
<!-- See bin/ai-verify for available check types. -->

```verify
FILE_EXISTS path/to/expected/file
TEST your-test-command
GREP path/to/file "expected pattern"
```

### Human-verified (reviewer checks these)

- [ ] [Visual/UX outcome that requires human judgement]
- [ ] [Outcome that can't be automated]

## Boundary

<!-- Optional: restrict which files the agent may touch. -->
<!-- Run with: ai-verify <story> --boundary -->

```boundary
TOUCH path/to/allowed/**
NO_TOUCH path/to/protected/**
```

## Technical Notes

Constraints, dependencies, relevant architecture decisions, or files to look at.

## Progress

<!-- Agent writes here as it works via ai-progress. Do not pre-fill. -->

## Blockers

<!-- Agent fills this in if work cannot proceed -->

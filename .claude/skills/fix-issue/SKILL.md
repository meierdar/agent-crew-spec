---
name: fix-issue
description: Fetch a GitHub issue and implement the fix. Use when the user provides an issue number to work on.
argument-hint: "[issue-number]  e.g. 42"
---

Fetch and fix GitHub issue number $ARGUMENTS.

## Issue details

```
!`gh issue view $ARGUMENTS 2>/dev/null || echo "Issue not found. Make sure gh is authenticated and the issue number is correct."`
```

## Steps

1. Read the issue title, body, and any comments shown above.
2. Understand the problem. If anything is unclear, ask the user before writing code.
3. Create a feature branch: `git checkout -b fix/issue-$ARGUMENTS-<short-description>`.
4. Explore the relevant code — search for files, functions, or patterns mentioned in the issue.
5. Implement the fix. Keep the change minimal and focused on the issue.
6. Verify the fix doesn't break anything (run tests if available).
7. Commit with message: `fix: <description> (closes #$ARGUMENTS)`.
8. Offer to create a PR with `/pr`.

## Rules
- Stay within the scope of the issue — don't refactor unrelated code
- If the fix requires a design decision, document it in the commit message
- If the issue is unclear or too large, break it into smaller pieces and discuss with the user

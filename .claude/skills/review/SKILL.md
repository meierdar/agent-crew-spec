---
name: review
description: Review the current uncommitted or branch changes for code quality, bugs, and potential issues. Use when the user asks for a code review, "review my changes", or "check my code".
---

Review the current changes for code quality, correctness, and potential issues.

## Changes to review

Staged and unstaged diff:
```
!`git diff HEAD 2>/dev/null | head -500`
```

If reviewing a branch vs main:
```
!`git diff $(git merge-base HEAD origin/main 2>/dev/null)..HEAD 2>/dev/null | head -500`
```

Changed files:
```
!`git diff --stat HEAD 2>/dev/null`
```

## Review checklist

Go through the diff and check for:

**Correctness**
- Logic errors or edge cases not handled
- Off-by-one errors, null/undefined issues
- Race conditions or state management bugs

**Security**
- SQL injection, XSS, command injection risks
- Hardcoded secrets or credentials
- Unsafe use of user input

**Code quality**
- Unused variables, dead code, or debug statements left in
- Functions that are too long or do too much
- Magic numbers or strings that should be constants

**Tests**
- Are new features covered by tests?
- Are edge cases tested?

**Consistency**
- Does it follow the patterns already in the codebase?
- Naming consistent with the rest of the project?

## Output format

Provide feedback as:
- **Must fix** — bugs, security issues, broken functionality
- **Should fix** — code quality issues, missing tests
- **Consider** — style suggestions, minor improvements

End with a short overall assessment and whether you'd approve the changes.

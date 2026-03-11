---
name: pr
description: Create a GitHub Pull Request for the current branch with a clear title and summary. Use when the user says "create a PR", "open a pull request", or "submit my changes".
argument-hint: "[optional title hint]"
---

Create a GitHub Pull Request for the current branch.

Optional hint: $ARGUMENTS

## Current branch context

Branch:
```
!`git branch --show-current`
```

Commits vs main/master:
```
!`git log --oneline $(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD origin/master 2>/dev/null)..HEAD 2>/dev/null | head -20`
```

Changed files:
```
!`git diff --stat $(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD origin/master 2>/dev/null)..HEAD 2>/dev/null`
```

Full diff:
```
!`git diff $(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD origin/master 2>/dev/null)..HEAD 2>/dev/null | head -300`
```

## Steps

1. Analyze all commits and the diff to understand the full scope of changes.
2. Push the branch to remote if not already pushed: `git push -u origin <branch>`.
3. Write a PR title: short (≤70 chars), imperative, describes *what* changed.
4. Write a PR body with:
   - **Summary**: 2–4 bullets of what changed and why
   - **Test plan**: checklist of how to verify the changes
5. Create the PR with `gh pr create`.
6. Return the PR URL.

## Rules
- Never push directly to `main` or `master`
- If the branch has no commits vs base, stop and tell the user
- If `$ARGUMENTS` provides a title hint, use it

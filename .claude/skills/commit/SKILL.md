---
name: commit
description: Create a well-formatted git commit following Conventional Commits. Use when the user says "commit", "commit my changes", or asks to save their work.
argument-hint: "[optional hint]  e.g. fix login redirect"
disable-model-invocation: false
---

Create a git commit for the current staged and unstaged changes.

Optional hint: $ARGUMENTS

## Steps

1. Run the following to understand the current state:

Current git status:
```
!`git status --short`
```

Recent commits (for style reference):
```
!`git log --oneline -8`
```

Full diff of changes:
```
!`git diff HEAD`
```

2. Analyze all changes. Determine the commit type:
   - `feat`: new feature or capability
   - `fix`: bug fix
   - `refactor`: restructuring without behavior change
   - `docs`: documentation only
   - `chore`: tooling, configs, scripts
   - `test`: adding or fixing tests
   - `style`: formatting, whitespace

3. Write a commit message following Conventional Commits:
   - Format: `type(optional-scope): short description`
   - Subject line: max 72 chars, imperative mood ("add" not "added")
   - Body (if needed): explain the *why*, not the *what*

4. Stage all relevant changed files (be specific — avoid `git add .` if there are unrelated files).

5. Create the commit. If the user provided a hint in `$ARGUMENTS`, use it to inform the message.

6. Show the final commit hash and message.

## Rules
- Never include secrets, credentials, or `.env` files
- Do not use `--no-verify`
- If there's nothing to commit, say so clearly

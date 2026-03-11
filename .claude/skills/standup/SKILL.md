---
name: standup
description: Generate a standup summary of recent work based on git history and current board state. Use when the user asks "what did I do today/this week", "standup", or "summarize my progress".
argument-hint: "[optional: today | week]  default: today"
---

Generate a standup summary of recent work.

Period: $ARGUMENTS (default: today)

## Recent commits

Today's commits:
```
!`git log --oneline --since="yesterday" --author="$(git config user.name)" 2>/dev/null | head -20`
```

This week's commits:
```
!`git log --oneline --since="1 week ago" --author="$(git config user.name)" 2>/dev/null | head -30`
```

## Current board state

```
!`./bin/ai-backlog status 2>/dev/null || echo "No backlog found"`
```

## Steps

1. Analyze the commits and board state.
2. Write a standup in this format:

**✅ Done**
- What was completed (from commits and `done`/`review` stories)

**🔧 In Progress**
- What's currently being worked on

**⏭ Next**
- What's planned next (from `ready` stories)

**🚧 Blockers**
- Any blocked stories or issues (if any)

Keep it concise — 3–5 bullets per section max. Skip sections that are empty.

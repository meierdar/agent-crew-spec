---
name: board
description: Show the current project board — all stories grouped by status. Use when the user asks about progress, what's in progress, what's ready, or the current state of the backlog.
---

Show the current state of the project board.

Current backlog status:
```
!`./bin/ai-backlog status 2>/dev/null || echo "Run from project root. No stories found yet."`
```

After showing the output:
- Highlight any stories in `in-progress` or `review` state as they need attention
- If nothing is `in-progress`, suggest the next `ready` story to assign
- Offer to run `/assign` for a specific story if the user wants to proceed

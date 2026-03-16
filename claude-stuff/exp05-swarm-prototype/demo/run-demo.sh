#!/bin/sh
# Demo: walk through the full swarm workflow step by step
#
# This simulates what you'd actually do with a team of AI agents.
# Run from the demo/ directory.

set -e

PROTO_BIN="$(cd "$(dirname "$0")/../bin" && pwd)"
DEMO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Point the tools at our demo stories
export STORIES_DIR="$DEMO_DIR/stories"
mkdir -p "$DEMO_DIR/.ai/claims" "$DEMO_DIR/.ai/context"

# Override stories dir in scripts by cd-ing to demo
cd "$DEMO_DIR"
mkdir -p .ai
ln -sf "$DEMO_DIR/stories" .ai/stories 2>/dev/null || true

echo "============================================================"
echo "  DEMO: AI Swarm Workflow"
echo "============================================================"
echo ""

echo "STEP 1: You've written 5 stories with dependencies."
echo "        Let's see the execution plan."
echo ""
"$PROTO_BIN/ai-swarm" plan

echo ""
echo "------------------------------------------------------------"
echo ""
echo "STEP 2: What can agents start RIGHT NOW?"
echo ""
"$PROTO_BIN/ai-swarm" run

echo ""
echo "------------------------------------------------------------"
echo ""
echo "STEP 3: Three agents start working simultaneously."
echo "        Agent 1: db-engineer on S001"
echo "        Agent 2: backend-developer on S002"
echo "        Agent 3: flutter-developer on S004"
echo ""

# Simulate claiming
"$PROTO_BIN/ai-claim" lock E001-S001 "agent-1-db-engineer"
"$PROTO_BIN/ai-claim" lock E001-S002 "agent-2-backend-dev"
"$PROTO_BIN/ai-claim" lock E001-S004 "agent-3-flutter-dev"

echo ""
echo "Active claims:"
"$PROTO_BIN/ai-claim" list

echo ""
echo "------------------------------------------------------------"
echo ""
echo "STEP 4: Agents write to shared context as they work."
echo ""

"$PROTO_BIN/ai-context" init E001
"$PROTO_BIN/ai-context" write E001 "db-engineer" "Users table: id (uuid, PK), email (varchar, unique), name (varchar), password_hash (varchar), created_at (timestamptz). Using uuid_generate_v4() for IDs. No soft-delete — we'll add that later if needed."
"$PROTO_BIN/ai-context" write E001 "backend-developer" "API contract decided: POST /auth/login takes {email, password}, returns {token, user}. POST /auth/register takes {email, password, name}, returns {user}. All errors use {code, message} shape. Rate limit: 5 attempts per minute on login."
"$PROTO_BIN/ai-context" write E001 "flutter-developer" "Login UI built with email + password TextFormField. Using Form with GlobalKey for validation. Email regex validation, password min 8 chars. Submit button shows CircularProgressIndicator during loading."

echo ""
echo "Current shared context:"
echo ""
"$PROTO_BIN/ai-context" read E001

echo "------------------------------------------------------------"
echo ""
echo "STEP 5: Agents finish. Mark stories as done, release claims."
echo ""

# Simulate completion
sed -i 's/^status: .*/status: done/' stories/E001-S001-db-schema.md
sed -i 's/^status: .*/status: done/' stories/E001-S002-api-contract.md
sed -i 's/^status: .*/status: done/' stories/E001-S004-login-ui.md

"$PROTO_BIN/ai-claim" unlock E001-S001
"$PROTO_BIN/ai-claim" unlock E001-S002
"$PROTO_BIN/ai-claim" unlock E001-S004

echo ""
echo "------------------------------------------------------------"
echo ""
echo "STEP 6: Run the swarm again. What's ready now?"
echo ""

"$PROTO_BIN/ai-swarm" run

echo ""
echo "------------------------------------------------------------"
echo ""
echo "STEP 7: S003 is CRITICAL — you'd run two agents on it."
echo "        S003 also has access to ALL the context from S001+S002."
echo "        No handoff needed. It just reads the shared context file."
echo ""
echo "============================================================"
echo "  KEY DIFFERENCE FROM CURRENT SETUP"
echo "============================================================"
echo ""
echo "  Current:  You assigned 5 stories one at a time = 5 sessions"
echo "  Swarm:    Wave 0 (3 stories parallel) + Wave 1 (1 critical)"
echo "            + Wave 2 (1 integration) = 3 sessions"
echo ""
echo "  Current:  You reviewed all 5 stories"
echo "  Swarm:    You review only 2 (the critical ones)"
echo ""
echo "  Current:  Each agent re-reads prior work (context waste)"
echo "  Swarm:    Shared context file — zero re-discovery"
echo "============================================================"

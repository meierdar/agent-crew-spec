#!/bin/sh
# signal-send.sh — send an inter-agent signal via git refs
#
# Usage: ./signal-send.sh <story-id> <signal-type> [message]
# Example: ./signal-send.sh E001-S001 complete "Auth repo ready"
#
# Creates: refs/signals/<story-id>/<signal-type>
# Pointing at: a blob containing the message + metadata

set -e

STORY_ID="${1:?Usage: $0 <story-id> <signal-type> [message]}"
SIGNAL_TYPE="${2:?Usage: $0 <story-id> <signal-type> [message]}"
MESSAGE="${3:-}"

REF_PATH="refs/signals/${STORY_ID}/${SIGNAL_TYPE}"

# Build the signal payload
PAYLOAD="$(cat <<SIGNAL
signal: ${SIGNAL_TYPE}
story: ${STORY_ID}
timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
commit: $(git rev-parse HEAD)
branch: $(git rev-parse --abbrev-ref HEAD)
---
${MESSAGE}
SIGNAL
)"

# Store the payload as a git blob
BLOB_SHA="$(printf '%s' "$PAYLOAD" | git hash-object -w --stdin)"

# Create the ref pointing at the blob
git update-ref "$REF_PATH" "$BLOB_SHA"

echo "Signal sent: ${REF_PATH}"
echo "  blob: ${BLOB_SHA}"
echo "  payload:"
echo "$PAYLOAD" | sed 's/^/    /'

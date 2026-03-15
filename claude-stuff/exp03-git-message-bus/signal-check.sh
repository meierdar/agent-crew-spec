#!/bin/sh
# signal-check.sh — check if inter-agent signals exist
#
# Usage: ./signal-check.sh <story-id> [signal-type]
#
# With signal-type: exits 0 if that specific signal exists, 1 if not
# Without signal-type: lists all signals for the story

set -e

STORY_ID="${1:?Usage: $0 <story-id> [signal-type]}"
SIGNAL_TYPE="${2:-}"

if [ -n "$SIGNAL_TYPE" ]; then
    # Check for a specific signal
    REF_PATH="refs/signals/${STORY_ID}/${SIGNAL_TYPE}"

    if git show-ref --verify --quiet "$REF_PATH" 2>/dev/null; then
        echo "Signal EXISTS: ${REF_PATH}"
        echo "  payload:"
        git cat-file blob "$(git show-ref --hash "$REF_PATH")" | sed 's/^/    /'
        exit 0
    else
        echo "Signal NOT FOUND: ${REF_PATH}"
        exit 1
    fi
else
    # List all signals for this story
    SIGNALS="$(git show-ref | grep "refs/signals/${STORY_ID}/" 2>/dev/null || true)"

    if [ -z "$SIGNALS" ]; then
        echo "No signals for ${STORY_ID}"
        exit 0
    fi

    echo "Signals for ${STORY_ID}:"
    echo "$SIGNALS" | while IFS= read -r line; do
        _sha="${line%% *}"
        _ref="${line#* }"
        _type="${_ref##*/}"
        echo "  ${_type}:"
        git cat-file blob "$_sha" | sed 's/^/    /'
        echo ""
    done
fi

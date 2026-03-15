#!/bin/sh
# check-deps.sh — validate that a story's dependencies have handoffs
# Usage: ./check-deps.sh path/to/story.md
# Exit 0 = all deps satisfied, Exit 1 = blocked
#
# This is a prototype. It parses YAML frontmatter with sed/grep
# (fragile on purpose — testing how far we can get without yq).

set -e

STORY_FILE="${1:?Usage: $0 <story.md>}"
STORIES_DIR="$(dirname "$STORY_FILE")"

# Extract depends_on values from frontmatter
# Looks for lines like "  - E001-S001" between --- fences
extract_deps() {
    sed -n '/^---$/,/^---$/p' "$1" \
        | grep '^ *- *E[0-9]' \
        | sed 's/^ *- *//' \
        | sed 's/ *#.*//'
}

# Extract a frontmatter field value (single-line only)
frontmatter_field() {
    sed -n '/^---$/,/^---$/p' "$1" \
        | grep "^${2}:" \
        | head -1 \
        | sed "s/^${2}: *//" \
        | tr -d '"' \
        | tr -d "'"
}

# Check if a story file contains a ## Handoff section
has_handoff() {
    grep -q '^## Handoff' "$1" 2>/dev/null
}

DEPS="$(extract_deps "$STORY_FILE")"

if [ -z "$DEPS" ]; then
    echo "No dependencies declared. Ready to start."
    exit 0
fi

BLOCKED=0

for dep_id in $DEPS; do
    # Find the story file for this dependency
    dep_file="$(find "$STORIES_DIR" -name "${dep_id}*" -type f 2>/dev/null | head -1)"

    if [ -z "$dep_file" ]; then
        echo "BLOCKED: Dependency $dep_id — story file not found"
        BLOCKED=1
        continue
    fi

    dep_status="$(frontmatter_field "$dep_file" "status")"

    case "$dep_status" in
        done|review)
            if has_handoff "$dep_file"; then
                echo "OK: $dep_id (status: $dep_status, handoff: present)"
            else
                echo "WARN: $dep_id (status: $dep_status, handoff: MISSING)"
                echo "  -> Downstream agent will lack structured context"
            fi
            ;;
        *)
            echo "BLOCKED: $dep_id (status: ${dep_status:-unknown}) — not yet complete"
            BLOCKED=1
            ;;
    esac
done

if [ "$BLOCKED" -eq 1 ]; then
    echo ""
    echo "Story is BLOCKED on unfinished dependencies."
    exit 1
else
    echo ""
    echo "All dependencies satisfied. Ready to start."
    exit 0
fi

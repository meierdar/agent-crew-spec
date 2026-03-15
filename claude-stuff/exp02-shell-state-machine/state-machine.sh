#!/bin/sh
# state-machine.sh — a generic finite state machine in pure POSIX sh
#
# The insight: encode the transition table as a simple lookup string.
# No arrays, no associative arrays, no external tools.
# Format: "current_state:event->next_state"
#
# This prototype models the story lifecycle from agent-crew-spec.

set -e

# --- Transition table ---
# Each rule: "from:event->to"
# Separated by newlines, searched with grep-like shell matching.

TRANSITIONS="
draft:refine->ready
ready:assign->in-progress
in-progress:complete->review
in-progress:block->blocked
blocked:unblock->in-progress
review:approve->done
review:reject->in-progress
"

# --- Engine ---

# Lookup: given current state and event, return next state (or empty)
transition() {
    _state="$1"
    _event="$2"

    # Walk the table line by line (no grep, no external tools)
    _result=""
    _oldIFS="$IFS"
    IFS='
'
    for _rule in $TRANSITIONS; do
        case "$_rule" in
            "${_state}:${_event}->"*)
                # Extract the target state after ->
                _result="${_rule#*->}"
                break
                ;;
        esac
    done
    IFS="$_oldIFS"

    printf '%s' "$_result"
}

# List valid events from a given state
valid_events() {
    _state="$1"
    _events=""
    _oldIFS="$IFS"
    IFS='
'
    for _rule in $TRANSITIONS; do
        case "$_rule" in
            "${_state}:"*)
                # Extract event (between : and ->)
                _evt="${_rule#*:}"
                _evt="${_evt%%->*}"
                _events="${_events} ${_evt}"
                ;;
        esac
    done
    IFS="$_oldIFS"

    printf '%s' "$_events" | sed 's/^ //'
}

# --- Interactive runner ---

if [ "${1:-}" = "--test" ]; then
    # Run automated tests
    echo "Running state machine tests..."

    assert_eq() {
        if [ "$2" = "$3" ]; then
            echo "  PASS: $1"
        else
            echo "  FAIL: $1 (expected '$3', got '$2')"
            FAILURES=$((${FAILURES:-0} + 1))
        fi
    }

    FAILURES=0

    # Valid transitions
    assert_eq "draft->ready"        "$(transition draft refine)"        "ready"
    assert_eq "ready->in-progress"  "$(transition ready assign)"        "in-progress"
    assert_eq "in-progress->review" "$(transition in-progress complete)" "review"
    assert_eq "in-progress->blocked" "$(transition in-progress block)"  "blocked"
    assert_eq "blocked->in-progress" "$(transition blocked unblock)"    "in-progress"
    assert_eq "review->done"        "$(transition review approve)"      "done"
    assert_eq "review->in-progress" "$(transition review reject)"       "in-progress"

    # Invalid transitions (should return empty)
    assert_eq "draft+complete=empty"  "$(transition draft complete)"    ""
    assert_eq "done+anything=empty"   "$(transition done assign)"      ""
    assert_eq "review+block=empty"    "$(transition review block)"     ""

    # Valid events listing
    assert_eq "in-progress events" "$(valid_events in-progress)" "complete block"
    assert_eq "review events"      "$(valid_events review)"      "approve reject"
    assert_eq "done events"        "$(valid_events done)"         ""

    echo ""
    if [ "${FAILURES}" -eq 0 ]; then
        echo "All tests passed."
    else
        echo "${FAILURES} test(s) failed."
        exit 1
    fi

elif [ "${1:-}" = "--walk" ]; then
    # Walk through a sequence of events
    shift
    STATE="${1:?Usage: $0 --walk <initial-state> <event1> <event2> ...}"
    shift
    echo "Start: $STATE"
    for EVENT in "$@"; do
        NEXT="$(transition "$STATE" "$EVENT")"
        if [ -z "$NEXT" ]; then
            echo "  $STATE --[$EVENT]--> INVALID (valid: $(valid_events "$STATE"))"
            exit 1
        fi
        echo "  $STATE --[$EVENT]--> $NEXT"
        STATE="$NEXT"
    done
    echo "Final: $STATE"

else
    echo "Usage:"
    echo "  $0 --test           Run automated tests"
    echo "  $0 --walk <state> <event> [event...]  Walk a state sequence"
    echo ""
    echo "Example:"
    echo "  $0 --walk draft refine assign complete approve"
fi

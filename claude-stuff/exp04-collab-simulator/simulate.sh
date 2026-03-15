#!/bin/sh
# simulate.sh — discrete-event simulator for AI agent collaboration models
#
# Usage: ./simulate.sh <model> [project-file]
#   Models: current | swarm | ensemble
#
# Simulates agents working through a task dependency graph under different
# collaboration rules. Tracks: tokens, time, context waste, failures,
# human interventions.

set -e

MODEL="${1:?Usage: $0 <current|swarm|ensemble> [project.def]}"
PROJECT="${2:-$(dirname "$0")/project.def}"

# --- Configuration per model ---

case "$MODEL" in
    current)
        MAX_AGENTS=1           # One agent at a time (serial)
        HANDOFF_COST=200       # Tokens to write/read handoff per dependency
        REVIEW_COST=150        # Tokens for human review step
        FAILURE_RATE=10        # % chance a task needs redo (caught in review)
        REDISCOVERY_RATE=30    # % of dependency complexity re-read by next agent
        HUMAN_INTERVENTIONS=0  # Counter
        REVIEW_TIME=2          # Ticks for human to review
        DESC="Current Spec (serial, human review, handoffs)"
        ;;
    swarm)
        MAX_AGENTS=4           # Up to 4 agents in parallel
        HANDOFF_COST=50        # Low — shared scratchpad is always current
        REVIEW_COST=0          # No human review
        FAILURE_RATE=15        # Slightly higher without review gate
        REDISCOVERY_RATE=5     # Shared scratchpad = low rediscovery
        HUMAN_INTERVENTIONS=0
        REVIEW_TIME=0
        DESC="Swarm (parallel, no review, shared scratchpad)"
        ;;
    ensemble)
        MAX_AGENTS=2           # Paired agents
        HANDOFF_COST=100       # Moderate — append-only log
        REVIEW_COST=50         # Merge step (automated, not human)
        FAILURE_RATE=3         # Very low — redundant execution catches bugs
        REDISCOVERY_RATE=10    # Some shared context via log
        HUMAN_INTERVENTIONS=0
        REVIEW_TIME=1          # Merge step takes 1 tick
        # Ensemble runs each task TWICE (2 agents), so double base tokens
        ENSEMBLE_MULTIPLIER=2
        DESC="Ensemble (paired, redundant execution, auto-merge)"
        ;;
    *)
        echo "Unknown model: $MODEL"
        echo "Valid models: current, swarm, ensemble"
        exit 1
        ;;
esac

# --- Parse project definition ---

TASKS=""
TASK_COUNT=0

while IFS='|' read -r tid deps complexity desc; do
    # Skip comments and blank lines
    case "$tid" in
        '#'*|'') continue ;;
    esac
    TASKS="${TASKS}${tid}|${deps}|${complexity}|${desc}
"
    TASK_COUNT=$((TASK_COUNT + 1))
done < "$PROJECT"

# --- Helper functions ---

# Get a field from a task line: get_field "T01|none|500|desc" 3 -> "500"
get_field() {
    echo "$1" | cut -d'|' -f"$2"
}

# Look up a task by ID
get_task() {
    _search_id="$1"
    echo "$TASKS" | while IFS= read -r line; do
        case "$line" in
            "${_search_id}|"*) echo "$line"; break ;;
        esac
    done
}

# Check if a task ID is in a space-separated list
in_list() {
    _needle="$1"
    _haystack="$2"
    case " ${_haystack} " in
        *" ${_needle} "*) return 0 ;;
    esac
    return 1
}

# Simple pseudo-random: hash-based deterministic "random" for reproducibility
# Returns 0-99
pseudo_random() {
    _seed="$1"
    # Use the seed string to generate a number
    _hash=$(printf '%s' "$_seed" | cksum | cut -d' ' -f1)
    echo $((_hash % 100))
}

# --- Simulation engine ---

TICK=0
TOTAL_TOKENS=0
CONTEXT_WASTE=0
FAILURES=0
COMPLETED=""
IN_PROGRESS=""        # "task_id:finish_tick" pairs, space-separated
ACTIVE_AGENTS=0

# Log with timestamp
log() {
    printf "  [t=%03d] %s\n" "$TICK" "$1"
}

# Check if all dependencies of a task are completed
deps_met() {
    _task_line="$(get_task "$1")"
    _deps="$(get_field "$_task_line" 2)"

    if [ "$_deps" = "none" ]; then
        return 0
    fi

    _oldIFS="$IFS"
    IFS=','
    for _dep in $_deps; do
        if ! in_list "$_dep" "$COMPLETED"; then
            IFS="$_oldIFS"
            return 1
        fi
    done
    IFS="$_oldIFS"
    return 0
}

# Count dependencies of a task
count_deps() {
    _task_line="$(get_task "$1")"
    _deps="$(get_field "$_task_line" 2)"
    if [ "$_deps" = "none" ]; then
        echo 0
        return
    fi
    echo "$_deps" | tr ',' '\n' | wc -l | tr -d ' '
}

# Calculate actual cost for a task under current model
calc_cost() {
    _tid="$1"
    _task_line="$(get_task "$_tid")"
    _base_complexity="$(get_field "$_task_line" 3)"
    _num_deps="$(count_deps "$_tid")"

    # Handoff cost: per dependency
    _handoff_total=$((_num_deps * HANDOFF_COST))

    # Rediscovery waste: percentage of each dependency's complexity
    _rediscovery=0
    _deps_field="$(get_field "$_task_line" 2)"
    if [ "$_deps_field" != "none" ]; then
        _oldIFS="$IFS"
        IFS=','
        for _dep in $_deps_field; do
            _dep_line="$(get_task "$_dep")"
            _dep_complexity="$(get_field "$_dep_line" 3)"
            _waste=$((_dep_complexity * REDISCOVERY_RATE / 100))
            _rediscovery=$((_rediscovery + _waste))
        done
        IFS="$_oldIFS"
    fi

    # Ensemble doubles base work
    if [ "${ENSEMBLE_MULTIPLIER:-1}" -gt 1 ]; then
        _base_complexity=$((_base_complexity * ENSEMBLE_MULTIPLIER))
    fi

    # Total
    _total=$((_base_complexity + _handoff_total + REVIEW_COST + _rediscovery))
    echo "$_total|$_base_complexity|$_handoff_total|$_rediscovery|$REVIEW_COST"
}

# Calculate time (ticks) for a task
calc_time() {
    _tid="$1"
    _task_line="$(get_task "$_tid")"
    _complexity="$(get_field "$_task_line" 3)"

    if [ "${ENSEMBLE_MULTIPLIER:-1}" -gt 1 ]; then
        _complexity=$((_complexity * ENSEMBLE_MULTIPLIER))
    fi

    # 1 tick per 200 tokens of work + review time
    _work_ticks=$(( (_complexity + 199) / 200 ))
    echo $((_work_ticks + REVIEW_TIME))
}

echo "=========================================="
echo "  AI Collaboration Simulator"
echo "=========================================="
echo "Model:    $MODEL"
echo "Config:   $DESC"
echo "Tasks:    $TASK_COUNT"
echo "Agents:   $MAX_AGENTS (max parallel)"
echo "=========================================="
echo ""
echo "Simulation log:"

# Main simulation loop
MAX_TICKS=200  # Safety limit

while [ "$(echo "$COMPLETED" | wc -w | tr -d ' ')" -lt "$TASK_COUNT" ] && [ "$TICK" -lt "$MAX_TICKS" ]; do

    # Phase 1: Check for completed in-progress tasks
    NEW_IN_PROGRESS=""
    _oldIFS="$IFS"
    IFS=' '
    for entry in $IN_PROGRESS; do
        _ip_tid="${entry%%:*}"
        _ip_finish="${entry##*:}"

        if [ "$TICK" -ge "$_ip_finish" ]; then
            # Task finished this tick — check for failure
            _rand="$(pseudo_random "${_ip_tid}_fail_${TICK}")"
            if [ "$_rand" -lt "$FAILURE_RATE" ]; then
                log "FAIL: $_ip_tid needs redo (failure detected)"
                FAILURES=$((FAILURES + 1))
                ACTIVE_AGENTS=$((ACTIVE_AGENTS - 1))

                if [ "$MODEL" = "current" ]; then
                    HUMAN_INTERVENTIONS=$((HUMAN_INTERVENTIONS + 1))
                fi
                # Don't add to COMPLETED — it'll be re-picked-up
            else
                log "DONE: $_ip_tid completed"
                COMPLETED="${COMPLETED} ${_ip_tid}"
                ACTIVE_AGENTS=$((ACTIVE_AGENTS - 1))
            fi
        else
            NEW_IN_PROGRESS="${NEW_IN_PROGRESS} ${entry}"
        fi
    done
    IFS="$_oldIFS"
    IN_PROGRESS="$NEW_IN_PROGRESS"

    # Phase 2: Start new tasks if agents available
    echo "$TASKS" | while IFS= read -r task_line; do
        [ -z "$task_line" ] && continue
        _tid="$(get_field "$task_line" 1)"

        # Skip if already completed or in progress
        in_list "$_tid" "$COMPLETED" && continue

        _in_prog_ids=""
        for _e in $IN_PROGRESS; do
            _in_prog_ids="${_in_prog_ids} ${_e%%:*}"
        done
        in_list "$_tid" "$_in_prog_ids" && continue

        # Check agent availability
        if [ "$ACTIVE_AGENTS" -ge "$MAX_AGENTS" ]; then
            break
        fi

        # Check dependencies
        if deps_met "$_tid"; then
            echo "START:$_tid"
        fi
    done > /tmp/sim_starts_$$

    # Process starts (can't modify vars in subshell, so we read from temp)
    while IFS= read -r start_cmd; do
        [ -z "$start_cmd" ] && continue
        _start_tid="${start_cmd#START:}"

        if [ "$ACTIVE_AGENTS" -ge "$MAX_AGENTS" ]; then
            break
        fi

        # Skip if already picked up this tick
        _in_prog_ids=""
        for _e in $IN_PROGRESS; do
            _in_prog_ids="${_in_prog_ids} ${_e%%:*}"
        done
        in_list "$_start_tid" "$_in_prog_ids" && continue
        in_list "$_start_tid" "$COMPLETED" && continue

        _cost_info="$(calc_cost "$_start_tid")"
        _total_cost="$(echo "$_cost_info" | cut -d'|' -f1)"
        _base="$(echo "$_cost_info" | cut -d'|' -f2)"
        _handoff="$(echo "$_cost_info" | cut -d'|' -f3)"
        _rediscovery="$(echo "$_cost_info" | cut -d'|' -f4)"
        _review="$(echo "$_cost_info" | cut -d'|' -f5)"

        _duration="$(calc_time "$_start_tid")"
        _finish_tick=$((TICK + _duration))

        log "START: $_start_tid (cost: ${_total_cost} tokens = ${_base} base + ${_handoff} handoff + ${_rediscovery} rediscovery + ${_review} review, done at t=$(printf '%03d' "$_finish_tick"))"

        TOTAL_TOKENS=$((TOTAL_TOKENS + _total_cost))
        CONTEXT_WASTE=$((CONTEXT_WASTE + _rediscovery))

        if [ "$MODEL" = "current" ]; then
            HUMAN_INTERVENTIONS=$((HUMAN_INTERVENTIONS + 1))  # Assignment
        fi

        IN_PROGRESS="${IN_PROGRESS} ${_start_tid}:${_finish_tick}"
        ACTIVE_AGENTS=$((ACTIVE_AGENTS + 1))
    done < /tmp/sim_starts_$$
    rm -f /tmp/sim_starts_$$

    TICK=$((TICK + 1))
done

echo ""
echo "=========================================="
echo "  Results: $MODEL"
echo "=========================================="
echo "Wall-clock time:      $TICK ticks"
echo "Total tokens:         $TOTAL_TOKENS"
echo "Context waste:        $CONTEXT_WASTE tokens (${CONTEXT_WASTE} rediscovery)"
echo "Task failures:        $FAILURES (required redo)"
echo "Human interventions:  $HUMAN_INTERVENTIONS"
echo "Tasks completed:      $(echo "$COMPLETED" | wc -w | tr -d ' ') / $TASK_COUNT"
echo "=========================================="

# Output machine-readable summary for comparison
echo ""
echo "CSV: $MODEL,$TICK,$TOTAL_TOKENS,$CONTEXT_WASTE,$FAILURES,$HUMAN_INTERVENTIONS"

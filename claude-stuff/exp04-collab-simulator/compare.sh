#!/bin/sh
# compare.sh — run all three models and display side-by-side comparison
set -e

DIR="$(dirname "$0")"

echo "Running all three models..."
echo ""

# Capture CSV lines
CSV_CURRENT="$(  "$DIR/simulate.sh" current  2>/dev/null | grep '^CSV:')"
CSV_SWARM="$(    "$DIR/simulate.sh" swarm    2>/dev/null | grep '^CSV:')"
CSV_ENSEMBLE="$( "$DIR/simulate.sh" ensemble 2>/dev/null | grep '^CSV:')"

# Parse CSV: model,ticks,tokens,waste,failures,human
parse() { echo "$1" | sed 's/^CSV: //' | cut -d',' -f"$2"; }

echo "============================================================"
echo "  SIDE-BY-SIDE COMPARISON"
echo "============================================================"
printf "%-22s  %10s  %10s  %10s\n" "Metric" "Current" "Swarm" "Ensemble"
echo "------------------------------------------------------------"
printf "%-22s  %10s  %10s  %10s\n" "Wall-clock (ticks)" \
    "$(parse "$CSV_CURRENT" 2)" "$(parse "$CSV_SWARM" 2)" "$(parse "$CSV_ENSEMBLE" 2)"
printf "%-22s  %10s  %10s  %10s\n" "Total tokens" \
    "$(parse "$CSV_CURRENT" 3)" "$(parse "$CSV_SWARM" 3)" "$(parse "$CSV_ENSEMBLE" 3)"
printf "%-22s  %10s  %10s  %10s\n" "Context waste" \
    "$(parse "$CSV_CURRENT" 4)" "$(parse "$CSV_SWARM" 4)" "$(parse "$CSV_ENSEMBLE" 4)"
printf "%-22s  %10s  %10s  %10s\n" "Task failures" \
    "$(parse "$CSV_CURRENT" 5)" "$(parse "$CSV_SWARM" 5)" "$(parse "$CSV_ENSEMBLE" 5)"
printf "%-22s  %10s  %10s  %10s\n" "Human interventions" \
    "$(parse "$CSV_CURRENT" 6)" "$(parse "$CSV_SWARM" 6)" "$(parse "$CSV_ENSEMBLE" 6)"
echo "============================================================"

# Derived metrics
C_TOK="$(parse "$CSV_CURRENT" 3)"
C_TIME="$(parse "$CSV_CURRENT" 2)"
S_TOK="$(parse "$CSV_SWARM" 3)"
S_TIME="$(parse "$CSV_SWARM" 2)"
E_TOK="$(parse "$CSV_ENSEMBLE" 3)"
E_TIME="$(parse "$CSV_ENSEMBLE" 2)"

echo ""
echo "Derived insights:"
echo "  Swarm vs Current:"
echo "    Speed:  $(( (C_TIME - S_TIME) * 100 / C_TIME ))% faster"
echo "    Cost:   $(( (C_TOK - S_TOK) * 100 / C_TOK ))% cheaper"
echo "  Ensemble vs Current:"
echo "    Speed:  $(( (C_TIME - E_TIME) * 100 / C_TIME ))% faster"
echo "    Cost:   $(( (E_TOK - C_TOK) * 100 / C_TOK ))% more expensive"
echo ""
echo "  Swarm wins on: speed, cost, zero human intervention"
echo "  Swarm risks:   higher failure rate (no review gate)"
echo "  Ensemble wins:  zero failures, zero human intervention"
echo "  Ensemble risks: highest token cost (2x base work)"
echo "  Current wins:   predictable, human-controlled"
echo "  Current risks:  slowest, most context waste, human bottleneck"

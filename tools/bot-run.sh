#!/bin/bash
# A skeleton of a bot run: the development player plays one full game alone, headless and silent, with a bot that
# your game supplies. Adapt it to your game (the TODO lines). See docs/test-tiers.md, section 6.
#
# Usage: tools/unity-lock.sh tools/bot-run.sh [seed] [scenario] [more player arguments]
#   Default: seed 1, scenario "default".
# Build the development player first: tools/unity-lock.sh --exclusive tools/batch.sh BuildTools.BuildDevMac
#
# The contract with the game (the sample driver: templates/unity/Assets/Scripts/Testing/CommandLineDriver.cs):
#   -bot                     start the bot
#   -bot-seed <n>            the seed of the game
#   -bot-scenario <name>     the start place, the goal, the difficulty: your own names
#   -bot-report <file>       the report of the run. Its last line is "Result: PASS" or "Result: FAIL <reason>".
#   The player quits with exit code 0 at the end of the run.
#
# The report goes to Logs/Bot/<seed>_<scenario>.txt. The exit code is 0 when the report says "Result: PASS".
# Read the reports of many seeds together: a bot that fails often shows a weak part of the bot or of the game.

source "$(dirname "$0")/lib/common.sh"
require_lock
cd "$PROJECT_DIR" || exit 2
SEED=${1:-1}
SCENARIO=${2:-default}
shift 2 2>/dev/null || shift $#
BIN="$PROJECT_DIR/$DEV_PLAYER"
[ -x "$BIN" ] || die "no development player at $BIN (build it first; DEV_PLAYER in sessions.conf)"
OUT="$PROJECT_DIR/Logs/Bot/${SEED}_$SCENARIO"
REPORT="$OUT/BotReport.txt"
mkdir -p "$OUT"
rm -f "$REPORT"
start=$(date +%s)
# TODO: add the arguments of your game.
"$BIN" -batchmode -nographics -logFile "$OUT/Player.log" -bot -bot-seed "$SEED" -bot-scenario "$SCENARIO" \
  -bot-report "$REPORT" "$@" </dev/null >/dev/null 2>&1 &
pid=$!
# The watchdog stops a player that hangs.
( sleep $((BOT_TIMEOUT_MIN * 60)) >/dev/null 2>&1 </dev/null
  if kill -0 $pid 2>/dev/null; then echo "bot-run: the player passed $BOT_TIMEOUT_MIN min: stopped" >&2; kill $pid; fi ) &
watchdog=$!
wait $pid
code=$?
kill $watchdog 2>/dev/null
echo "bot-run: $(( $(date +%s) - start )) s, exit code $code"
if [ ! -f "$REPORT" ]; then
  echo "bot-run: no report (see $OUT/Player.log)"
  grep -E "Exception|\[Bot\]" "$OUT/Player.log" | tail -20
  exit 1
fi
cp "$REPORT" "$PROJECT_DIR/Logs/Bot/${SEED}_$SCENARIO.txt"
sed -n '1,30p' "$REPORT"
grep -q "^Result: PASS$" "$REPORT"

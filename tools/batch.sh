#!/bin/bash
# Run Unity in batch mode (no window) for one job: a compile, or an Editor method (a build, a level build, a check).
# Usage: tools/unity-lock.sh tools/batch.sh compile
#        tools/unity-lock.sh tools/batch.sh <Class.Method> [more Unity arguments]
#        tools/unity-lock.sh --exclusive tools/batch.sh BuildTools.BuildDevMac
# The log goes to Logs/batch.log. The exit code is the exit code of Unity.
# The Editor window and a batch job cannot have the project open at the same time.

source "$(dirname "$0")/lib/common.sh"
require_lock
cd "$PROJECT_DIR" || exit 2
UNITY="$(unity_bin)"
[ -x "$UNITY" ] || die "no Unity Editor at $UNITY"
LOG="$PROJECT_DIR/Logs/batch.log"
mkdir -p "$PROJECT_DIR/Logs"
project_wait "$LOCK_WAIT_MIN" batch || exit 2
what="${1:?compile or Class.Method}"
shift
args=(-batchmode -projectPath "$PROJECT_DIR" -logFile "$LOG" -acceptSoftwareTermsForThisRunOnly -mute)
if [ "$what" != "compile" ]; then
  args+=(-executeMethod "$what")
fi
"$UNITY" "${args[@]}" "$@" -quit
code=$?
errors=$(grep -E "error CS[0-9]+" "$LOG" | sort -u)
if [ -n "$errors" ]; then
  echo "batch: compile errors:"
  echo "$errors" | head -30
fi
# Your Editor methods can write lines that start with "[Batch]"; the script shows the last ones.
grep -E "^\[Batch\]" "$LOG" | tail -20
echo "batch: exit code $code (log: Logs/batch.log)"
exit $code

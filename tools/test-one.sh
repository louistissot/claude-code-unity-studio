#!/bin/bash
# Run selected test classes in batch mode (the Editor window must be closed).
# Usage: tools/unity-lock.sh tools/test-one.sh EditMode|PlayMode "ClassA|ClassB" [more Unity arguments]
# The filter is a regular expression on the full test names. The results go to TestResults/one-<platform>.xml, the log
# to Logs/one-<platform>.log. The exit code is 1 when a test failed or there are no results.

source "$(dirname "$0")/lib/common.sh"
require_lock
cd "$PROJECT_DIR" || exit 2
PLATFORM=${1:?EditMode or PlayMode}
FILTER=${2:?a test filter}
shift 2
UNITY="$(unity_bin)"
[ -x "$UNITY" ] || die "no Unity Editor at $UNITY"
mkdir -p TestResults Logs
project_wait "$LOCK_WAIT_MIN" test-one || exit 2
OUT="TestResults/one-$PLATFORM.xml"
rm -f "$OUT"
"$UNITY" -batchmode -projectPath "$PROJECT_DIR" -runTests -testPlatform "$PLATFORM" -testFilter "$FILTER" \
  -testResults "$PROJECT_DIR/$OUT" -logFile "$PROJECT_DIR/Logs/one-$PLATFORM.log" -acceptSoftwareTermsForThisRunOnly \
  -mute "$@" >/dev/null 2>&1
if [ ! -f "$OUT" ]; then
  echo "test-one: no results (Logs/one-$PLATFORM.log)"
  grep -E "error CS[0-9]+" "Logs/one-$PLATFORM.log" | sort -u | head -10
  exit 1
fi
python3 "$TOOLS_DIR/test-summary.py" "$OUT"

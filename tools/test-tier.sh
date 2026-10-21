#!/bin/bash
# One script for each test tier (docs/test-tiers.md). Sessions, the pre-commit hook, and a nightly job use it.
#
# Usage: tools/unity-lock.sh tools/test-tier.sh smoke|quick|full|nightly [more Unity arguments]
#   smoke    the compile, EditMode
#   quick    the compile, EditMode, PlayMode without the categories of TIER_QUICK_EXCLUDE
#   full     EditMode, PlayMode without the categories of TIER_FULL_EXCLUDE
#   nightly  EditMode, PlayMode without the categories of TIER_NIGHTLY_EXCLUDE
# Environment: ORDER_SEED=N runs the PlayMode tests in a random order with that seed (the history records the seed).
#
# The Editor window must be closed (the run opens the project in batch mode). A watchdog stops a run that goes past the
# limit of its tier (a hung run can last hours while the machine sleeps). Each run adds a line to
# TestResults/history.csv: the time, the commit, the tier, the platform, the counts, and the names of the failed tests.
# A test that fails and then passes on the same commit is flaky (docs/test-tiers.md, section 5).
# The exit code is 1 when a test failed, the run hung, or there are no results.

source "$(dirname "$0")/lib/common.sh"
require_lock
cd "$PROJECT_DIR" || exit 2
TIER=${1:-quick}
shift || true
UNITY="$(unity_bin)"
[ -x "$UNITY" ] || die "no Unity Editor at $UNITY"
mkdir -p TestResults Logs
HISTORY=TestResults/history.csv
[ -f "$HISTORY" ] || echo "time,commit,tier,platform,total,passed,failed,skipped,seconds,order_seed,failed_tests" > "$HISTORY"
STATUS=0
project_wait "$LOCK_WAIT_MIN" test-tier || exit 2
COMMIT="$(git rev-parse --short HEAD 2>/dev/null || echo none)"

# Run one platform with a category filter and a time limit in minutes.
run() {
  local platform=$1 categories=$2 minutes=$3
  shift 3
  local out="TestResults/$platform.xml" log="Logs/tier-$TIER-$platform.log"
  rm -f "$out"
  local args=(-batchmode -projectPath "$PROJECT_DIR" -runTests -testPlatform "$platform"
              -testResults "$PROJECT_DIR/$out" -logFile "$PROJECT_DIR/$log" -acceptSoftwareTermsForThisRunOnly -mute)
  [ -n "$categories" ] && args+=(-testCategory "$categories")
  [ -n "${ORDER_SEED:-}" ] && [ "$platform" = "PlayMode" ] && args+=(-randomOrderSeed "$ORDER_SEED")
  echo "== $TIER: $platform${categories:+ ($categories)}, limit $minutes min"
  local start=$SECONDS
  "$UNITY" "${args[@]}" "$@" &
  local pid=$!
  # The watchdog. Its sleep has no output: a sleep that keeps the output pipe open makes "test-tier.sh | tail" wait for
  # the full limit.
  ( sleep $((minutes * 60)) >/dev/null 2>&1 </dev/null
    if kill -0 $pid 2>/dev/null; then
      echo "test-tier: $platform passed its limit of $minutes min: stopped" >&2
      kill $pid; sleep 10; kill -9 $pid 2>/dev/null
    fi ) &
  local watchdog=$!
  wait $pid
  kill $watchdog 2>/dev/null
  wait $watchdog 2>/dev/null
  local seconds=$((SECONDS - start))
  if [ ! -f "$out" ]; then
    echo "  no results ($log): the run did not finish"
    grep -E "error CS[0-9]+" "$log" 2>/dev/null | sort -u | head -10
    echo "$(date '+%Y-%m-%d %H:%M'),$COMMIT,$TIER,$platform,0,0,0,0,$seconds,${ORDER_SEED:-},NO RESULTS" >> "$HISTORY"
    STATUS=1
    return
  fi
  python3 "$TOOLS_DIR/test-summary.py" "$out" || STATUS=1
  python3 - "$out" "$TIER" "$platform" "$seconds" "$COMMIT" "${ORDER_SEED:-}" >> "$HISTORY" <<'PY'
import sys, time, xml.etree.ElementTree as ET
out, tier, platform, seconds, commit, seed = sys.argv[1:7]
r = ET.parse(out).getroot()
failed = [c.get("fullname") for c in r.iter("test-case") if c.get("result") == "Failed"]
print(",".join([time.strftime("%Y-%m-%d %H:%M"), commit, tier, platform, r.get("total"), r.get("passed"),
                r.get("failed"), r.get("skipped"), seconds, seed, ";".join(failed)]))
PY
}

compile_first() {
  "$TOOLS_DIR/batch.sh" compile >/dev/null 2>&1 || {
    echo "test-tier: the compile failed (Logs/batch.log)"
    grep -E "error CS[0-9]+" Logs/batch.log | sort -u | head -20
    exit 1
  }
}

case "$TIER" in
  smoke)
    compile_first
    run EditMode "" "$TIER_LIMIT_EDITMODE_MIN" "$@"
    ;;
  quick)
    compile_first
    run EditMode "" "$TIER_LIMIT_EDITMODE_MIN" "$@"
    run PlayMode "$TIER_QUICK_EXCLUDE" "$TIER_LIMIT_QUICK_MIN" "$@"
    ;;
  full)
    run EditMode "" "$TIER_LIMIT_EDITMODE_MIN" "$@"
    run PlayMode "$TIER_FULL_EXCLUDE" "$TIER_LIMIT_FULL_MIN" "$@"
    ;;
  nightly)
    run EditMode "" "$TIER_LIMIT_EDITMODE_MIN" "$@"
    run PlayMode "$TIER_NIGHTLY_EXCLUDE" "$TIER_LIMIT_NIGHTLY_MIN" "$@"
    ;;
  *)
    die "usage: tools/test-tier.sh smoke|quick|full|nightly"
    ;;
esac
echo "test-tier: $TIER $([ $STATUS -eq 0 ] && echo PASS || echo FAIL) (history: $HISTORY)"
exit $STATUS

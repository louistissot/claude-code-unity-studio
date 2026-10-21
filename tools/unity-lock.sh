#!/bin/bash
# The Unity lock: each Unity batch job (a compile, a test run, a level build, a player build) goes through this script,
# so that many sessions on one machine do not use all the memory or all the disk. See docs/unity-runner.md.
#
# Usage:   tools/unity-lock.sh [--exclusive] <command and arguments>
# Example: tools/unity-lock.sh tools/test-one.sh PlayMode "MyTests"
#          tools/unity-lock.sh --exclusive tools/release.sh
# Run it from the project folder of your worktree.
#
# The rules:
# - The runner check: when NOTES_DIR/runner-worktrees.txt exists, only the worktrees on that list (one physical path on
#   each line; a line that starts with "#" is a comment) can start a job. A job from another worktree stops with exit
#   code 3 and a REFUSED line in jobs.log. That session sends its branch and its jobs to the runner session instead.
# - Two slots. A plain job takes one slot. --exclusive (a level build, a light bake, a player build) takes both slots,
#   so that nothing else runs at the same time.
# - A slot whose owner process is gone becomes free.
# - First come, first served. Each job that waits writes a file wait.<seconds>.<pid>.<x or p>. An exclusive job takes slot1
#   only when no older job waits; then it marks slot1/exclusive and waits for slot2, and no newer plain job takes a slot.
#   A plain job waits only for the older exclusive jobs, and it takes a slot only when fewer older plain jobs wait than
#   slots are free, so that the oldest jobs go first and two jobs can start together.
# - The disk guard: a plain job waits until the disk has DISK_MIN_GB_PLAIN free, an exclusive job DISK_MIN_GB_EXCLUSIVE.
# - Each job writes a START line and an END line to NOTES_DIR/jobs.log.
# - The job gets UNITY_LOCK_HELD=1 in its environment. The tools that start Unity refuse to run without it
#   (require_lock in tools/lib/common.sh), so that no tool goes past the lock by mistake.

source "$(dirname "$0")/lib/common.sh"

mkdir -p "$SLOTS_DIR" "$NOTES_DIR"
JOBS_LOG="$NOTES_DIR/jobs.log"
EXCLUSIVE=0
if [ "$1" = "--exclusive" ]; then
  EXCLUSIVE=1
  shift
fi
[ $# -gt 0 ] || die "no command"
WHO="$(basename "$PWD")"

if ! unity_allowed .; then
  echo "unity-lock: $(pwd -P) has no Unity turn. Only $RUNNER_NAME starts Unity jobs. Send it your branch, your commit, and the jobs to run (docs/unity-runner.md; the queue: $NOTES_DIR/unity-runner.md)." >&2
  echo "$(date '+%m-%d %H:%M') REFUSED $WHO $*" >> "$JOBS_LOG"
  exit 3
fi

if [ $EXCLUSIVE -eq 1 ]; then NEED_GB=$DISK_MIN_GB_EXCLUSIVE; else NEED_GB=$DISK_MIN_GB_PLAIN; fi
HELD=()
MYTIME=$(date +%s)
MYWAIT="$SLOTS_DIR/wait.$MYTIME.$$.$([ $EXCLUSIVE -eq 1 ] && echo x || echo p)"

# True when a live older job blocks this one: for an exclusive job, each older job that waits; for a plain job, each older
# exclusive job that waits.
older_blocking() {
  local w name rest wt pid kind
  for w in "$SLOTS_DIR"/wait.*; do
    [ -e "$w" ] || continue
    name="${w##*/}"
    rest="${name#wait.}"; wt="${rest%%.*}"; rest="${rest#*.}"; pid="${rest%%.*}"; kind="${rest##*.}"
    [ "$pid" = "$$" ] && continue
    if ! kill -0 "$pid" 2>/dev/null; then
      rm -f "$w"
      continue
    fi
    if [ "$wt" -lt "$MYTIME" ] || { [ "$wt" -eq "$MYTIME" ] && [ "$pid" -lt "$$" ]; }; then
      if [ $EXCLUSIVE -eq 1 ] || [ "$kind" = "x" ]; then
        return 0
      fi
    fi
  done
  return 1
}

# The count of live older plain jobs that still wait.
older_plain_count() {
  local n=0 w rest wt pid
  for w in "$SLOTS_DIR"/wait.*.p; do
    [ -e "$w" ] || continue
    rest="${w##*/wait.}"; wt="${rest%%.*}"; rest="${rest#*.}"; pid="${rest%%.*}"
    [ "$pid" = "$$" ] && continue
    kill -0 "$pid" 2>/dev/null || { rm -f "$w"; continue; }
    if [ "$wt" -lt "$MYTIME" ] || { [ "$wt" -eq "$MYTIME" ] && [ "$pid" -lt "$$" ]; }; then
      n=$((n + 1))
    fi
  done
  echo $n
}

free_slots() {
  local n=0
  [ -d "$SLOTS_DIR/slot1" ] || n=$((n + 1))
  [ -d "$SLOTS_DIR/slot2" ] || n=$((n + 1))
  echo $n
}

# Free the slots whose owner process is gone.
clear_stale() {
  local s pid age
  for s in "$SLOTS_DIR"/slot1 "$SLOTS_DIR"/slot2; do
    [ -d "$s" ] || continue
    pid=$(cut -d' ' -f1 "$s/owner" 2>/dev/null)
    if [ -z "$pid" ]; then
      # A slot with no owner file yet: another job is between its mkdir and the write of the owner. Leave it for 30 s.
      age=$(( $(date +%s) - $(mtime "$s") ))
      [ "$age" -gt 30 ] && rm -rf "$s"
    elif ! kill -0 "$pid" 2>/dev/null; then
      rm -rf "$s"
    fi
  done
}

# Take a slot. mkdir is atomic: only one process can make the folder.
take() {
  local slot=$1
  shift
  if mkdir "$SLOTS_DIR/$slot" 2>/dev/null; then
    echo "$$ $WHO $(date '+%H:%M') $*" > "$SLOTS_DIR/$slot/owner"
    HELD+=("$slot")
    return 0
  fi
  return 1
}

release() {
  local s
  for s in "${HELD[@]}"; do
    rm -rf "${SLOTS_DIR:?}/$s"
  done
  HELD=()
  rm -f "$MYWAIT"
}
# A job that waits for a slot also stops on INT or TERM (without this trap, the wait loop went on).
trap release EXIT
trap 'release; exit 143' INT TERM

waited=0
touch "$MYWAIT"
while true; do
  clear_stale
  if [ "$(free_gb)" -lt "$NEED_GB" ]; then
    [ $((waited % 300)) -eq 0 ] && echo "unity-lock: wait for $NEED_GB GB of free disk ($(free_gb) GB now). Delete your own Logs, Temp, and Builds outputs." >&2
  elif [ $EXCLUSIVE -eq 1 ]; then
    # Always slot1 first, so there is no deadlock with a plain job (a plain job never waits while it holds a slot).
    if ! older_blocking && take slot1 "$@"; then
      touch "$SLOTS_DIR/slot1/exclusive"
      lost=0
      while ! take slot2 "$@"; do
        clear_stale
        # Is this job still the owner of slot1? If not, go back to the queue.
        if [ "$(cut -d' ' -f1 "$SLOTS_DIR/slot1/owner" 2>/dev/null)" != "$$" ]; then
          HELD=()
          lost=1
          break
        fi
        sleep 10
      done
      [ $lost -eq 1 ] && continue
      rm -f "$MYWAIT"
      break
    fi
  elif ! older_blocking && [ ! -f "$SLOTS_DIR/slot1/exclusive" ] && [ "$(older_plain_count)" -lt "$(free_slots)" ]; then
    take slot2 "$@" && { rm -f "$MYWAIT"; break; }
    take slot1 "$@" && { rm -f "$MYWAIT"; break; }
  fi
  [ $((waited % 300)) -eq 0 ] && echo "unity-lock: wait for a Unity slot ($(cat "$SLOTS_DIR"/slot*/owner 2>/dev/null | tr '\n' ';'))" >&2
  sleep 15
  waited=$((waited + 15))
done

start=$(date +%s)
echo "$(date '+%m-%d %H:%M') START $WHO $([ $EXCLUSIVE -eq 1 ] && echo exclusive || echo plain) $*" >> "$JOBS_LOG"
UNITY_LOCK_HELD=1 "$@"
code=$?
echo "$(date '+%m-%d %H:%M') END   $WHO exit $code after $(( ($(date +%s) - start) / 60 )) min: $*" >> "$JOBS_LOG"
exit $code

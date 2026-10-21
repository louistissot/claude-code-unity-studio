#!/bin/bash
# Show each worktree of the repository: the branch, the Unity turn (on the runner list or not), a Library or not, and
# a Unity process or not. Then the free disk. The coordinator uses it before it starts a new session.
# Usage: tools/worktrees.sh
#
# Do not use "du" to find the cost of a worktree: du counts the shared blocks of an APFS clone in each copy. The true
# cost shows only in the free disk (df), before and after.

source "$(dirname "$0")/lib/common.sh"
cd "$PROJECT_DIR" || exit 2
printf '%-50s %-28s %-6s %-8s %s\n' "WORKTREE" "BRANCH" "UNITY" "LIBRARY" "OPEN"
git worktree list --porcelain | awk '/^worktree /{p=substr($0,10)} /^branch /{b=substr($0,8)} /^detached/{b="(detached)"} /^$/{print p "\t" b; p=""; b=""} END{if(p!="") print p "\t" b}' |
while IFS=$'\t' read -r path branch; do
  [ -d "$path" ] || continue
  turn="no"; unity_allowed "$path" && turn="yes"
  lib="no"; [ -d "$path/Library" ] && lib="yes"
  open="no"; [ -f "$path/Temp/UnityLockfile" ] && lsof "$path/Temp/UnityLockfile" >/dev/null 2>&1 && open="yes"
  printf '%-50s %-28s %-6s %-8s %s\n' "$path" "${branch#refs/heads/}" "$turn" "$lib" "$open"
done
echo "Free disk: $(free_gb "$WORKTREE_ROOT") GB (plain Unity jobs need $DISK_MIN_GB_PLAIN GB, exclusive jobs $DISK_MIN_GB_EXCLUSIVE GB)."

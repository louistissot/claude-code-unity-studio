#!/bin/bash
# Make a new worktree for a session as an APFS clone of the main checkout (docs/disk-and-worktrees.md).
#
# Usage: tools/new-worktree.sh <area> [<base>]
#   It makes <WORKTREE_ROOT>/<WORKTREE_PREFIX>-<area> on the new branch <BRANCH_PREFIX><area>, from <base>
#   (default: BASE_BRANCH). All values come from sessions.conf.
#
# Why a clone: a plain "git worktree add" writes each file again and has no Library. The first Unity import of such a
# worktree writes the full Library (about 20 GB for a large project). An APFS clone (cp -c) shares the blocks of the
# files with the main checkout, so a new worktree costs almost no disk until its files change. A clone of the Library
# also lets tools/quick-compile.sh work at once.
#
# Steps: (1) git worktree add --no-checkout, (2) cp -c of each entry of the main checkout except .git and CLONE_EXCLUDE,
# (3) git reset --mixed (the index of the branch, no file writes), (4) git checkout of the tracked files that differ
# from the branch (only these files get new blocks).
#
# Caution: the clone is only cheap while Unity does not run in the new worktree. A Unity import or compile there writes
# a new Library (10 to 25 GB). Only the runner worktrees run Unity (docs/unity-runner.md).

source "$(dirname "$0")/lib/common.sh"
set -u
AREA="${1:-}"
[ -n "$AREA" ] || die "usage: tools/new-worktree.sh <area> [<base>]"
BASE="${2:-$BASE_BRANCH}"
BRANCH="$BRANCH_PREFIX$AREA"
DEST="$WORKTREE_ROOT/$WORKTREE_PREFIX-$AREA"
MAIN="$MAIN_CHECKOUT"

[ -d "$MAIN" ] && git -C "$MAIN" rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "no git checkout at MAIN_CHECKOUT ($MAIN)"
[ ! -e "$DEST" ] || die "$DEST exists"
git -C "$MAIN" rev-parse --verify --quiet "$BASE^{commit}" >/dev/null || die "no commit or branch $BASE"
if git -C "$MAIN" rev-parse --verify --quiet "refs/heads/$BRANCH" >/dev/null; then
  die "the branch $BRANCH exists; select another area name"
fi
before=$(free_gb "$WORKTREE_ROOT")
[ "$before" -ge "$DISK_MIN_GB_CLONE" ] || die "only $before GB of free disk (the minimum is $DISK_MIN_GB_CLONE GB, sessions.conf)"

# A Unity process that writes the Library of the main checkout during the copy gives a broken Library in the clone.
if [ -f "$MAIN/Temp/UnityLockfile" ] && lsof "$MAIN/Temp/UnityLockfile" >/dev/null 2>&1; then
  [ "${FORCE:-0}" = "1" ] || die "Unity has the main checkout open. Wait for the end of its job, or set FORCE=1."
fi

# The volume must support clones; else each file is a full copy.
probe="$WORKTREE_ROOT/.clone-probe.$$"
if ! cp -c "$SESSIONS_CONF" "$probe" 2>/dev/null; then
  rm -f "$probe"
  [ "${ALLOW_FULL_COPY:-0}" = "1" ] || die "this volume does not support clones (cp -c). A full copy costs the full size of the checkout. Set ALLOW_FULL_COPY=1 to copy anyway."
  CP=(cp -R)
else
  rm -f "$probe"
  CP=(cp -cR)
fi

git -C "$MAIN" worktree add --no-checkout -b "$BRANCH" "$DEST" "$BASE" || die "git worktree add failed"

read -ra EXCLUDE <<< "$CLONE_EXCLUDE"
shopt -s dotglob nullglob
for item in "$MAIN"/*; do
  name="${item##*/}"
  [ "$name" = ".git" ] && continue
  for x in "${EXCLUDE[@]}"; do
    [ "$name" = "$x" ] && continue 2
  done
  "${CP[@]}" "$item" "$DEST/" || die "the copy of $name failed"
done
shopt -u dotglob nullglob

cd "$DEST" || exit 2
git reset --quiet --mixed
git update-index -q --refresh >/dev/null 2>&1
# The tracked files that differ from the branch (another commit in the main checkout, or changes there).
changed=$(git diff --name-only | wc -l | tr -d ' ')
if [ "$changed" -gt 0 ]; then
  echo "new-worktree: $changed tracked files differ from $BASE; checkout of these files only"
  git diff -z --name-only | xargs -0 git checkout --
fi
extra=$(git ls-files --others --exclude-standard | head -20)
if [ -n "$extra" ]; then
  echo "new-worktree: untracked files from the main checkout (not on the branch; delete them if you do not need them):"
  echo "$extra"
fi

after=$(free_gb "$WORKTREE_ROOT")
echo "new-worktree: $DEST on branch $BRANCH (from $BASE). Free disk: $before GB before, $after GB after."
if unity_allowed "$DEST"; then
  echo "new-worktree: this worktree can start Unity jobs (no runner list, or it is on the list)."
else
  echo "new-worktree: this worktree is code only: no Unity. Check the C# with tools/quick-compile.sh and send Unity jobs to $RUNNER_NAME."
fi

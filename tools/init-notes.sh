#!/bin/bash
# Make the shared notes folder of the sessions (NOTES_DIR in sessions.conf), with the runner list and the queue.
# Usage: tools/init-notes.sh
# It does not change a file that exists. The folder is outside all worktrees, so that each session reads the same files.

source "$(dirname "$0")/lib/common.sh"
mkdir -p "$NOTES_DIR" || die "cannot make $NOTES_DIR"
TEMPLATES="$PROJECT_DIR/templates/notes"

physical() { (cd "$1" 2>/dev/null && pwd -P) || echo "$1"; }

if [ ! -f "$NOTES_DIR/runner-worktrees.txt" ]; then
  {
    echo "# The worktrees that can start Unity jobs through tools/unity-lock.sh: one physical path on each line."
    echo "# A line that starts with \"#\" is a comment. Without this file, each worktree can start Unity jobs."
    echo "# The runner worktree: the jobs of the queue (unity-runner.md)."
    physical "$RUNNER_WORKTREE"
    echo "# The main checkout: the merge checks and the release builds (also done by the runner)."
    physical "$MAIN_CHECKOUT"
  } > "$NOTES_DIR/runner-worktrees.txt"
  echo "init-notes: $NOTES_DIR/runner-worktrees.txt"
fi
for f in unity-runner.md rules.md README.md; do
  if [ ! -f "$NOTES_DIR/$f" ]; then
    cp "$TEMPLATES/$f" "$NOTES_DIR/$f"
    echo "init-notes: $NOTES_DIR/$f"
  fi
done
touch "$NOTES_DIR/jobs.log"
echo "init-notes: the shared notes folder is $NOTES_DIR"

#!/bin/bash
# The shared part of the tools. Each tool sources this file:
#   source "$(dirname "$0")/lib/common.sh"
# It finds the project folder (the parent of tools/), reads sessions.conf, and gives small helpers.
# The tools need bash and the system tools of macOS. Most helpers also work on Linux.

TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_DIR="$(cd "$TOOLS_DIR/.." && pwd)"
SESSIONS_CONF="${SESSIONS_CONF:-$PROJECT_DIR/sessions.conf}"
if [ ! -f "$SESSIONS_CONF" ]; then
  echo "$(basename "$0"): no config file at $SESSIONS_CONF" >&2
  exit 2
fi
# shellcheck source=../../sessions.conf
source "$SESSIONS_CONF"

# Print a message on stderr and stop with exit code 2 (or the code in DIE_CODE).
die() {
  echo "$(basename "$0"): $*" >&2
  exit "${DIE_CODE:-2}"
}

# The free disk in whole GB of the volume that holds a path (default: the project folder).
free_gb() {
  df -Pk "${1:-$PROJECT_DIR}" | awk 'NR == 2 { print int($4 / 1048576) }'
}

# The change time of a file in seconds since 1970 (macOS, then Linux).
mtime() {
  stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null || echo 0
}

# The size of a file in bytes (macOS, then Linux).
file_size() {
  stat -f %z "$1" 2>/dev/null || stat -c %s "$1"
}

# The SHA-256 of a file (macOS, then Linux).
sha256_of() {
  if command -v shasum >/dev/null; then shasum -a 256 "$1" | cut -d' ' -f1; else sha256sum "$1" | cut -d' ' -f1; fi
}

# The Unity version of the project, from ProjectSettings/ProjectVersion.txt.
project_unity_version() {
  sed -n 's/^m_EditorVersion: //p' "$PROJECT_DIR/ProjectSettings/ProjectVersion.txt" 2>/dev/null
}

# The Editor binary for a version (default: the version of the project). UNITY_BIN in sessions.conf wins.
unity_bin() {
  if [ -n "$UNITY_BIN" ]; then
    echo "$UNITY_BIN"
    return
  fi
  local v="${1:-$(project_unity_version)}"
  case "$(uname -s)" in
    Darwin) echo "$UNITY_EDITORS_DIR/$v/Unity.app/Contents/MacOS/Unity" ;;
    *) echo "$UNITY_EDITORS_DIR/$v/Editor/Unity" ;;
  esac
}

# True when a Unity process (the Editor window or a batch job) has this project open.
project_open() {
  [ -f "$PROJECT_DIR/Temp/UnityLockfile" ] && lsof "$PROJECT_DIR/Temp/UnityLockfile" >/dev/null 2>&1
}

# Wait until no Unity process has this project open, for at most <minutes>. The exit code is 1 when the time ends.
# Usage: project_wait <minutes> <name of the caller>
project_wait() {
  local minutes=${1:-$LOCK_WAIT_MIN} name=${2:-batch} waited=0
  while project_open; do
    [ $waited -eq 0 ] && echo "$name: another Unity process has the project open: wait up to $minutes min" >&2
    if [ $waited -ge $((minutes * 60)) ]; then
      echo "$name: the project is still open after $minutes min" >&2
      return 1
    fi
    sleep 30
    waited=$((waited + 30))
  done
  return 0
}

# True when a worktree can start Unity jobs: there is no allow list, or the physical path of the worktree is a line
# of the list. Usage: unity_allowed [folder]   (default: the current folder)
unity_allowed() {
  local list="$NOTES_DIR/runner-worktrees.txt" here
  [ -f "$list" ] || return 0
  here="$(cd "${1:-.}" && pwd -P)"
  grep -v '^#' "$list" | grep -qxF "$here"
}

# Stop when a tool that starts Unity runs outside tools/unity-lock.sh. UNITY_LOCK=off in sessions.conf turns the
# check off (one session on the machine). The lock script sets UNITY_LOCK_HELD=1 for its job.
require_lock() {
  [ "$UNITY_LOCK" = "off" ] && return 0
  [ "${UNITY_LOCK_HELD:-0}" = "1" ] && return 0
  die "this tool starts Unity. Start it through the lock: tools/unity-lock.sh tools/$(basename "$0") ... (docs/unity-runner.md)"
}

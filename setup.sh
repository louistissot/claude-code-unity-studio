#!/bin/bash
# Make an empty Unity 6 project in this repository with the Unity CLI, then add the sample assemblies, the sample
# tests, the build methods, and the hooks. The repository holds no Unity files before this step.
#
# Usage: ./setup.sh
# Before: set GAME_NAME, ZIP_NAME, UNITY_VERSION, and the paths in sessions.conf. Install the Unity CLI and the Unity
# Editor of UNITY_VERSION (for example: unity install 6000.0.58f1).
#
# Caution: this script starts Unity one time (the project import; about 1 to 3 GB of new disk for the Library). Run it
# one time, in the main checkout, before you start other sessions. On a machine with a Unity runner rule, only the
# runner session runs it (docs/unity-runner.md).
#
# The steps:
# 1. Make the project in a temporary folder with "unity projects create" and UNITY_TEMPLATE (or with the Editor and
#    -createProject when the CLI is not there or fails).
# 2. Move Assets, Packages, ProjectSettings, and the Library into this folder. The tools, docs, and templates stay.
# 3. Copy templates/unity/Assets into Assets (the assemblies Game, Game.Editor, Game.Tests.EditMode,
#    Game.Tests.PlayMode, the build methods, the command-line driver, the report key).
# 4. Write CLAUDE.md from templates/CLAUDE.md (only when there is no CLAUDE.md), and copy the starting documents of
#    the game (decisions, session log, milestones, pillars, story bible, AI record) into docs/.
# 5. Make the shared notes folder and install the pre-commit hook.

set -u
cd "$(dirname "$0")" || exit 2
ROOT="$(pwd)"
source "$ROOT/tools/lib/common.sh"

[ ! -d "$ROOT/Assets" ] || die "Assets exists: this folder has a Unity project already"
FREE=$(free_gb "$ROOT")
[ "$FREE" -ge "$DISK_MIN_GB_PLAIN" ] || die "only $FREE GB of free disk (the minimum is $DISK_MIN_GB_PLAIN GB)"
NAME="$(basename "$ROOT")"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/unity-setup.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

export PATH="$HOME/.unity/bin:$PATH"

# Make the project with the Editor itself (-createProject). The result has the default packages of the Editor, not the
# packages of a template. The fall-back when the Unity CLI is not there or fails.
create_with_editor() {
  [ -n "$UNITY_VERSION" ] || die "$1 Set UNITY_VERSION (and UNITY_TEMPLATE) in sessions.conf."
  local unity
  unity="$(unity_bin "$UNITY_VERSION")"
  [ -x "$unity" ] || die "$1 No Editor at $unity either (install it: unity install $UNITY_VERSION)."
  rm -rf "${TMP:?}/$NAME"
  echo "setup: $1 Fall-back: $unity -createProject (no template; the default packages of the Editor)."
  "$unity" -batchmode -quit -createProject "$TMP/$NAME" -logFile "$TMP/create.log" \
    || die "the Editor could not make the project ($TMP/create.log)"
}

if command -v "$UNITY_CLI" >/dev/null 2>&1; then
  # A check before the CLI: does the Editor of UNITY_VERSION have the template? (macOS install layout.)
  if [ -n "$UNITY_VERSION" ] && [ -n "$UNITY_TEMPLATE" ]; then
    tdir="$UNITY_EDITORS_DIR/$UNITY_VERSION/Unity.app/Contents/Resources/PackageManager/ProjectTemplates"
    if [ -d "$tdir" ] && ! ls "$tdir" | grep -q "^$UNITY_TEMPLATE"; then
      echo "setup: caution: the Editor $UNITY_VERSION has no template $UNITY_TEMPLATE. It has:" >&2
      ls "$tdir" | sed 's/^/  /' >&2
    fi
  fi
  args=(projects create "$NAME" --path "$TMP" --no-cloud --non-interactive)
  [ -n "$UNITY_VERSION" ] && args+=(--editor-version "$UNITY_VERSION")
  [ -n "$UNITY_TEMPLATE" ] && args+=(--template "$UNITY_TEMPLATE")
  echo "setup: $UNITY_CLI ${args[*]}"
  if ! "$UNITY_CLI" "${args[@]}"; then
    create_with_editor "The Unity CLI could not make the project (check UNITY_TEMPLATE: unity templates list)."
  fi
else
  create_with_editor "No Unity CLI ($UNITY_CLI)."
fi
[ -d "$TMP/$NAME/Assets" ] && [ -f "$TMP/$NAME/ProjectSettings/ProjectVersion.txt" ] || die "no project in $TMP/$NAME"

for d in Assets Packages ProjectSettings Library; do
  [ -e "$TMP/$NAME/$d" ] && mv "$TMP/$NAME/$d" "$ROOT/$d"
done
echo "setup: the Unity project is in $ROOT (Unity $(project_unity_version))."
# The Product Name gives the name of the Mac executable and of the Windows program: keep it equal to GAME_NAME.
PS="$ROOT/ProjectSettings/ProjectSettings.asset"
if grep -q '^  productName: ' "$PS" 2>/dev/null; then
  NAME_SED="$(printf '%s' "$GAME_NAME" | sed -e 's/[\\|&]/\\&/g')"
  sed -i '' -e "s|^  productName: .*|  productName: $NAME_SED|" "$PS" 2>/dev/null || sed -i -e "s|^  productName: .*|  productName: $NAME_SED|" "$PS"
  echo "setup: the Product Name is now \"$GAME_NAME\"."
else
  echo "setup: caution: no productName line in $PS; set the Product Name to \"$GAME_NAME\" in the Player settings."
fi
echo "setup: the Unity Hub lists the temporary folder of the creation; remove that entry in the Hub if you like."

cp -R "$ROOT/templates/unity/Assets/." "$ROOT/Assets/"
echo "setup: the sample assemblies, tests, build methods, and drivers are in Assets."

if [ ! -f "$ROOT/CLAUDE.md" ]; then
  NAME_SED="$(printf '%s' "$GAME_NAME" | sed -e 's/[\\|&]/\\&/g')"
  sed -e "s|{{GAME_NAME}}|$NAME_SED|g" -e "s|{{UNITY_VERSION}}|$(project_unity_version)|g" \
    "$ROOT/templates/CLAUDE.md" > "$ROOT/CLAUDE.md"
  echo "setup: CLAUDE.md from templates/CLAUDE.md (edit the parts in angle brackets)."
fi

# The starting documents of the game. CLAUDE.md and the briefs refer to them. A file that exists stays as it is.
for f in decisions session-log milestones pillars story-bible ai-record; do
  if [ ! -f "$ROOT/docs/$f.md" ]; then
    cp "$ROOT/templates/$f.md" "$ROOT/docs/$f.md"
    echo "setup: docs/$f.md from templates/$f.md"
  fi
done

"$ROOT/tools/init-notes.sh"
if git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  "$ROOT/tools/install-hooks.sh"
fi
chmod +x "$ROOT"/tools/*.sh "$ROOT"/tools/hooks/pre-commit "$ROOT"/setup.sh

cat <<EOF

setup: done. The next steps:
  1. Open the project one time in batch mode to import the new files and run the first checks:
       UNITY_LOCK=off tools/test-tier.sh smoke
     (the first compile also writes the files that tools/quick-compile.sh needs)
  2. Read docs/README.md, then edit CLAUDE.md for your game.
  3. Commit the project files (Assets, Packages, ProjectSettings). The Library stays out of Git (.gitignore).
EOF

#!/bin/bash
# Make a release for the players: one zip for Windows and one zip for Mac, never parts (docs/release-rules.md).
#
# Usage: tools/unity-lock.sh --exclusive tools/release.sh [--no-upload] [--skip-build]
#   --skip-build  use the players that are already in RELEASE_DIR (no Unity, no lock needed)
#   --no-upload   make and check the zips, but do not make a GitHub release
#
# The steps:
# 1. Stop when the work tree has changes in Assets, Packages, or ProjectSettings (a release is a commit), or when the
#    commit is not on the remote (for an upload).
# 2. Build the Windows and the Mac players (BUILD_METHOD_WINDOWS, BUILD_METHOD_MAC) into RELEASE_DIR.
# 3. Make <ZIP_NAME>-Windows.zip and <ZIP_NAME>-Mac.zip with the highest compression. Never split a zip.
# 4. Check each zip before the upload: the size is below RELEASE_MAX_BYTES, "unzip -t" passes, and the Mac zip opens
#    with ditto into a test folder and has the executable of the app.
# 5. Write SHA256SUMS.txt.
# 6. Upload to the GitHub release <RELEASE_TAG_PREFIX>-<date>-<commit> (a pre-release) with the gh CLI.
# 7. Check after the upload: each file of the release has the size of the local file, and (RELEASE_VERIFY_DOWNLOAD=1)
#    a download of each file has the SHA-256 of the local file.
# macOS only (ditto and the Mac app).

source "$(dirname "$0")/lib/common.sh"
cd "$PROJECT_DIR" || exit 2
set -o pipefail
UPLOAD=1
BUILD=1
for a in "$@"; do
  case "$a" in
    --no-upload) UPLOAD=0 ;;
    --skip-build) BUILD=0 ;;
    *) die "unknown option $a" ;;
  esac
done
[ "$(uname -s)" = "Darwin" ] || die "this script needs macOS (ditto, the Mac app)"
OUT="$PROJECT_DIR/$RELEASE_DIR"
COMMIT=$(git rev-parse --short HEAD)
TAG="$RELEASE_TAG_PREFIX-$(date +%Y%m%d)-$COMMIT"
WIN_ZIP="$OUT/$ZIP_NAME-Windows.zip"
MAC_ZIP="$OUT/$ZIP_NAME-Mac.zip"

# Put back the files that a build changes and that nobody commits, so that they do not stop the release.
read -ra RESTORE <<< "$RELEASE_RESTORE_FILES"
restore_files() {
  [ ${#RESTORE[@]} -gt 0 ] && git checkout -- "${RESTORE[@]}" 2>/dev/null
  return 0
}
restore_files
if [ -n "$(git status --porcelain --untracked-files=no -- Assets Packages ProjectSettings)" ]; then
  die "the work tree has changes in Assets, Packages, or ProjectSettings; commit them first"
fi
if [ $UPLOAD -eq 1 ]; then
  command -v gh >/dev/null || die "no gh CLI (GitHub); install it, or use --no-upload"
  git branch -r --contains HEAD | grep -q . || die "the commit $COMMIT is not on the remote; push it first"
fi

if [ $BUILD -eq 1 ]; then
  require_lock
  mkdir -p "$OUT"
  rm -rf "$OUT/Win" "$OUT/Mac"
  "$TOOLS_DIR/batch.sh" "$BUILD_METHOD_WINDOWS" -out "$OUT/Win/$GAME_NAME.exe" || die "the Windows build failed"
  "$TOOLS_DIR/batch.sh" "$BUILD_METHOD_MAC" -out "$OUT/Mac/$GAME_NAME.app" || die "the Mac build failed"
  restore_files
fi
[ -f "$OUT/Win/$GAME_NAME.exe" ] && [ -d "$OUT/Mac/$GAME_NAME.app" ] || die "no players in $OUT (Win/$GAME_NAME.exe, Mac/$GAME_NAME.app)"

echo "$COMMIT $(date '+%Y-%m-%d %H:%M')" > "$OUT/Win/BUILD.txt"
rm -f "$OUT"/*.zip "$OUT/SHA256SUMS.txt"
# One zip for each system, never parts: a Mac app in parts did not open for a player. The highest compression keeps a
# zip below the limit of GitHub as long as possible. The Burst debug folders do not go to the players.
( cd "$OUT/Win" && zip -q -9 -r -X "$WIN_ZIP" . -x "*_BurstDebugInformation_DoNotShip/*" -x "*_BackUpThisFolder_ButDontShipItWithYourGame/*" ) || die "zip of Windows failed"
ditto -c -k --norsrc --noextattr --zlibCompressionLevel 9 --keepParent "$OUT/Mac/$GAME_NAME.app" "$MAC_ZIP" || die "zip of Mac failed"
ls -lh "$WIN_ZIP" "$MAC_ZIP"

# Checks before the upload.
for f in "$WIN_ZIP" "$MAC_ZIP"; do
  size=$(file_size "$f")
  if [ "$size" -ge "$RELEASE_MAX_BYTES" ]; then
    die "$(basename "$f") is $((size / 1048576)) MB; the limit is $((RELEASE_MAX_BYTES / 1048576)) MB. Make the build smaller. Do not split the zip."
  fi
  unzip -tq "$f" >/dev/null || die "$(basename "$f") does not pass unzip -t"
done
probe="$(mktemp -d)"
ditto -x -k "$MAC_ZIP" "$probe" || die "the Mac zip does not open with ditto"
[ -x "$probe/$GAME_NAME.app/Contents/MacOS/$GAME_NAME" ] || die "the Mac zip has no executable $GAME_NAME.app/Contents/MacOS/$GAME_NAME"
rm -rf "$probe"
( cd "$OUT" && for f in "$(basename "$WIN_ZIP")" "$(basename "$MAC_ZIP")"; do echo "$(sha256_of "$f")  $f"; done ) > "$OUT/SHA256SUMS.txt"
cat "$OUT/SHA256SUMS.txt"
echo "release: the zips pass the checks before the upload"
[ $UPLOAD -eq 1 ] || exit 0

NOTES="Test build of commit $COMMIT ($(date '+%Y-%m-%d')).
Windows: right-click $ZIP_NAME-Windows.zip, Extract All, then start \"$GAME_NAME.exe\".
Mac: double-click $ZIP_NAME-Mac.zip, then right-click \"$GAME_NAME.app\" and select Open.
All players must use the files of this release. SHA256SUMS.txt gives the checksum of each zip."
LABELED=("$WIN_ZIP#$GAME_NAME for Windows (zip)" "$MAC_ZIP#$GAME_NAME for Mac (zip)" "$OUT/SHA256SUMS.txt")
if gh release view "$TAG" >/dev/null 2>&1; then
  gh release upload "$TAG" "${LABELED[@]}" --clobber || die "the upload failed"
else
  gh release create "$TAG" "${LABELED[@]}" --target "$(git rev-parse HEAD)" --prerelease \
    --title "Test build $(date '+%Y-%m-%d') ($COMMIT)" --notes "$NOTES" || die "the release failed"
fi

# Checks after the upload.
DIE_CODE=1
for f in "$WIN_ZIP" "$MAC_ZIP"; do
  name="$(basename "$f")"
  remote=$(gh release view "$TAG" --json assets --jq ".assets[] | select(.name == \"$name\") | .size")
  [ "$remote" = "$(file_size "$f")" ] || die "after the upload: $name has the size ${remote:-none} on GitHub, $(file_size "$f") here"
done
if [ "$RELEASE_VERIFY_DOWNLOAD" = "1" ]; then
  check="$(mktemp -d)"
  gh release download "$TAG" --dir "$check" --pattern "$ZIP_NAME-*.zip" || die "the download of the release failed"
  for f in "$WIN_ZIP" "$MAC_ZIP"; do
    name="$(basename "$f")"
    [ "$(sha256_of "$check/$name")" = "$(sha256_of "$f")" ] || die "after the upload: the SHA-256 of $name is not the same"
  done
  rm -rf "$check"
fi
gh release view "$TAG" --json url,assets --jq '.url, (.assets[] | "\(.name) \(.size / 1048576 | floor) MB")'
echo "release: $TAG passes the checks after the upload"

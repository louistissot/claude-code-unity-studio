#!/bin/bash
# A compile check of the C# code without Unity: about 5 s, no Unity process, no slot of the lock.
#
# It uses the C# compiler of the Unity install and the response files (.rsp) of the last Unity compile of this worktree
# (Library/Bee/artifacts/<id>E.dag). It compiles the assemblies of QUICK_COMPILE_ASSEMBLIES (sessions.conf), in that
# order, with the source files of now: all .cs files under the folder of the .asmdef, without the subfolders that have
# their own .asmdef or .asmref.
#
# It finds compile errors only: no import, no tests, no code weavers, no Burst. A pass is not a full Unity pass; an error
# is a real error. It reads the files of the work tree, not the staged files.
#
# Usage: tools/quick-compile.sh
# It needs one Unity compile of this worktree first, or a Library from an APFS clone of a checkout that has one
# (tools/new-worktree.sh). Code that is not in an assembly definition (Assembly-CSharp) is not checked.
# Tested on macOS only. On another system, set DOTNET_SDK_DIR in sessions.conf.

source "$(dirname "$0")/lib/common.sh"
set -u
cd "$PROJECT_DIR" || exit 2
OUT="$PROJECT_DIR/Temp/quick-compile"
read -ra ASSEMBLIES <<< "$QUICK_COMPILE_ASSEMBLIES"
[ ${#ASSEMBLIES[@]} -gt 0 ] || die "QUICK_COMPILE_ASSEMBLIES is empty (sessions.conf)"

# The Editor build folder of Bee with the newest response file of the first assembly.
DAG=""
for d in Library/Bee/artifacts/*E.dag; do
  [ -f "$d/${ASSEMBLIES[0]}.rsp" ] || continue
  if [ -z "$DAG" ] || [ "$(mtime "$d/${ASSEMBLIES[0]}.rsp")" -gt "$(mtime "$DAG/${ASSEMBLIES[0]}.rsp")" ]; then
    DAG="$d"
  fi
done
[ -n "$DAG" ] || die "no Library/Bee/artifacts/*E.dag/${ASSEMBLIES[0]}.rsp: one Unity compile of this worktree must come first"

VERSION="$(project_unity_version)"
SDK="${DOTNET_SDK_DIR:-$UNITY_EDITORS_DIR/$VERSION/Unity.app/Contents/Resources/Scripting/DotNetSdk}"
CSC="$(ls "$SDK"/sdk/*/Roslyn/bincore/csc.dll 2>/dev/null | tail -1)"
[ -x "$SDK/dotnet" ] && [ -n "$CSC" ] || die "no dotnet and csc.dll in $SDK (set DOTNET_SDK_DIR in sessions.conf)"

mkdir -p "$OUT/refs"
# The reference assemblies of the other assemblies (packages, plugins), in a copy: while Unity compiles in this
# worktree, it writes them again and the compiler cannot read them. The copy is made again when no Unity has the project.
if ! project_open || [ -z "$(ls "$OUT/refs" 2>/dev/null)" ]; then
  cp -p "$DAG"/*.ref.dll "$OUT/refs/" 2>/dev/null
fi

# The folder of an assembly: the folder of its .asmdef.
asm_dir() {
  local f
  f="$(find Assets Packages -name "$1.asmdef" -not -path "*/Library/*" 2>/dev/null | head -1)"
  [ -n "$f" ] && dirname "$f"
}

# The source files of an assembly: the .cs files under its folder, without the subfolders of other assemblies.
asm_sources() {
  local dir=$1 sub
  local skip=()
  while IFS= read -r sub; do
    [ "$sub" = "$dir" ] && continue
    skip+=(-not -path "$sub/*")
  done < <(find "$dir" \( -name "*.asmdef" -o -name "*.asmref" \) -exec dirname {} \; | sort -u)
  # The form ${a[@]+"${a[@]}"} keeps an empty list safe under "set -u" in bash 3.2 (macOS).
  find "$dir" -name "*.cs" ${skip[@]+"${skip[@]}"}
}

# A text for sed: the characters that are special in a sed pattern get a backslash.
sed_quote() {
  printf '%s' "$1" | sed -e 's/[]\/$*.^[]/\\&/g' -e 's/#/\\#/g'
}

status=0
done_list=()
DAG_Q="$(sed_quote "$DAG")"
OUT_Q="$(printf '%s' "$OUT" | sed -e 's/[\/&#]/\\&/g')"
for name in "${ASSEMBLIES[@]}"; do
  dir="$(asm_dir "$name")"
  if [ -z "$dir" ] || [ ! -f "$DAG/$name.rsp" ]; then
    echo "== $name: skipped (no .asmdef, or no response file of the last Unity compile)"
    continue
  fi
  rsp="$OUT/$name.rsp"
  # The options and references of Unity. The references to the assemblies of this run go to the new outputs in OUT;
  # the other references go to the copy in OUT/refs.
  expr=()
  for done_name in "${done_list[@]+"${done_list[@]}"}"; do
    expr+=(-e "s#-r:\"$DAG_Q/$(sed_quote "$done_name")\\.ref\\.dll\"#-r:\"$OUT_Q/$done_name.dll\"#")
  done
  expr+=(-e "s#-r:\"$DAG_Q/\\([^\"]*\\.ref\\.dll\\)\"#-r:\"$OUT_Q/refs/\\1\"#")
  grep -v '\.cs"$' "$DAG/$name.rsp" | grep -v '^-out:' | grep -v '^-refout:' | sed "${expr[@]}" > "$rsp"
  echo "-out:\"$OUT/$name.dll\"" >> "$rsp"
  sources="$(asm_sources "$dir")"
  if [ -z "$sources" ]; then
    echo "== $name: ERRORS"
    echo "no .cs files found under $dir"
    status=1
    continue
  fi
  printf '%s\n' "$sources" | sed 's/.*/"&"/' >> "$rsp"
  "$SDK/dotnet" "$CSC" -nologo @"$rsp" > "$OUT/$name.log" 2>&1
  errs="$(grep -E "error CS" "$OUT/$name.log" | sort -u)"
  if [ -n "$errs" ]; then
    echo "== $name: ERRORS"
    echo "$errs" | head -30
    status=1
  else
    echo "== $name: ok ($(grep -c 'warning CS' "$OUT/$name.log") warnings)"
  fi
  done_list+=("$name")
done
exit $status

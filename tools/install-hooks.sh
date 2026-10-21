#!/bin/bash
# Install the pre-commit hook of the project (docs/test-tiers.md, section 4).
# Usage: tools/install-hooks.sh
#
# All worktrees of a repository share one hooks folder. So the installed hook is small: it starts tools/hooks/pre-commit
# of the worktree of the commit. A change to tools/hooks/pre-commit needs no new install.
# Other hooks (for example the hooks of Git LFS) stay as they are. An old pre-commit hook goes to pre-commit.old.

source "$(dirname "$0")/lib/common.sh"
cd "$PROJECT_DIR" || exit 2
HOOKS="$(git rev-parse --git-path hooks)" || die "not a git repository"
case "$HOOKS" in
  /*) ;;
  *) HOOKS="$PROJECT_DIR/$HOOKS" ;;
esac
custom="$(git config --get core.hooksPath)"
[ -z "$custom" ] || echo "install-hooks: caution: core.hooksPath is $custom; Git reads the hooks from there."
mkdir -p "$HOOKS"
HOOK="$HOOKS/pre-commit"
MARK="installed by tools/install-hooks.sh"
if [ -f "$HOOK" ] && ! grep -q "$MARK" "$HOOK"; then
  mv "$HOOK" "$HOOK.old"
  echo "install-hooks: the old hook is now $HOOK.old"
fi
cat > "$HOOK" <<HOOKEOF
#!/bin/bash
# $MARK: start the hook of the worktree of this commit.
ROOT="\$(git rev-parse --show-toplevel)" || exit 0
[ -x "\$ROOT/tools/hooks/pre-commit" ] || exit 0
exec "\$ROOT/tools/hooks/pre-commit" "\$@"
HOOKEOF
chmod +x "$HOOK" "$PROJECT_DIR/tools/hooks/pre-commit"
echo "install-hooks: $HOOK"

# Rules for the sessions of <run name> (<start> to <end>)

The coordinator writes this file and keeps it current. Each session reads it at the start and at each milestone. When
the messages between sessions stop, this file is the channel.

## 1. The goal and the limits

- The goal of this run (the words of the human): "<quote>".
- Keep the game what it is: <the parts that must not change>.
- Questions: <do not ask the human; decide, and record the decision and the reason in your report / ask the
  coordinator>.
- Language: <rule>.

## 2. Worktrees and branches

- Work only in your worktree, on your branch. Do not switch branches, do not merge other branches, and do not touch other
  worktrees or the main checkout.
- Commit often, with clear messages. Push your branch at each milestone. Never push the integration branch.
- Never commit: <the side-effect files> and the outputs of a level build: <list>.

## 3. Unity

- Only the runner runs Unity. Check your C# with `tools/quick-compile.sh`. Send your Unity jobs to the runner
  (`unity-runner.md` in this folder).
- Delete your own large outputs (Logs, Temp, Builds) when you do not need them.

## 4. Who owns what

| Session | Worktree, branch | Owns |
|---|---|---|
| <area> | <path>, <branch> | <files and systems> |

A change outside your area: small, with a comment, in `cross-<area>.md`, and one short message to the owner.

## 5. Times

- Milestones: commit and push a tested milestone every <4 to 6> hours, with your report current.
- Final: all work committed and pushed, the report complete, by <time>. Then end your work.
- The coordinator merges after the checks and reports to the human at <time>.

## 6. Notes of the coordinator

- <time>: <note>

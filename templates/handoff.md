# Handoff: the <role> (<date>, <time>)

From the old <role> (`<old session id>`) to the new one. The human approved the rotation: "<the exact words of the
human>". Read this file first. Then read `docs/operating-model.md`, the rules of the runner (`unity-runner.md` in the
notes folder), and in the game repository `CLAUDE.md`, `docs/milestones.md`, and `docs/decisions.md`.
Write in <language rule>.

Write this file so that a session with no memory of the old conversation can work from it. Give facts, paths, commits,
and ids, not a story. Mark each fact that is easy to get wrong.

## 1. The game and the dates

- The game, the engine version, the repository, the integration branch.
- The next milestones and their dates (from `docs/milestones.md`): <feature complete, freeze, release, event>.

## 2. Git state (<date>, <time>)

| Ref | Commit | Note |
|---|---|---|
| <integration branch> (main checkout) | <commit> | <the last merge; pushed or not> |
| last-good (tag) | <commit> | Set by the runner after green merge checks |
| <release branch or tag> | <commit> | <when it moves, and who decides> |
| <other branches in work> | <commit> | <owner, state> |

## 3. Releases

| Release | Commit | State | Note |
|---|---|---|---|
| <tag> | <commit> | <candidate / released / previous good release> | <what it fixes; known problems> |

## 4. The sessions (the ids are needed for messages)

| Role | Session id | Worktree, branch | State |
|---|---|---|---|
| The top session of the human | <id> | <folder> | <it started the old coordinator, or not> |
| Old <role> | <id> | <folder> | Idle after the handoff; do not archive it while its side sessions work |
| Runner | <id> | <runner worktree> | <the queue now> |
| <owner: World / Art / Gameplay / Mechanics> | <id> | <worktree, branch> | <the item now> |
| <specialist or task session> | <id> | <worktree, branch> | <the job, the pull request> |

## 5. Decisions that the human must make

1. <a decision, with the options and the recommendation>
2. <a purchase, a test date, a name>

## 6. Rules (the ones that are easy to forget)

- Merge into the integration branch only after the yes of the human, then push it at once. Other pushes need a
  request. Never force a push.
- Only the runner runs Unity. Other sessions use `tools/quick-compile.sh` and send their jobs to the runner queue.
- <the files that nobody commits>
- <the rules of the human for this project: language, assets, sound in automatic runs, questions>
- <facts that are easy to get wrong: names, paths, numbers, the last decisions that replaced older ones>

## 7. Open problems

- <problem, its owner, the next step, the bug ID or the backlog number>
- <large outputs to delete (worktrees, caches), with their size>
- <stale memory entries to clean up>

## 8. At the takeover

1. Set the daily triage reminder in your own session (for example a job that repeats, "2 18 * * *"); renew it every 7 days
   until <date>. The old reminder ends with the old session.
2. Tell each active session your id (section 4), and ask each one to send its reports to you by message: the end-of-turn
   notes of side sessions still go to the session that started them.
3. With more than one team: update the board (the coordinator of your team, and a log line).
4. Give the human the first daily summary: what changed, at most three decisions, and the focus list for the newest
   build.
5. Leave the old <role> idle. Do not archive it while its side sessions work: the app archives the idle side sessions of
   an archived session.
6. Clean up the memory index: one line for each memory, no stale facts.

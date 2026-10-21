# The documents

Read them in this order. Each document is short and gives the rule first, then the reason.

| No. | Document | Contents |
|---|---|---|
| 1 | [guide.md](guide.md) | Start here: the order of the work from the first idea to the release, the phases and their gates, who does what. |
| 2 | [ai-pitfalls.md](ai-pitfalls.md) | What to avoid: clones, average ideas, taste given away, half-built games, generic writing; the countermeasure for each. |
| 3 | [concept-phase.md](concept-phase.md) | From your own ideas to one concept: past the first ideas, comparables, the challenger, the originality gate, key risks. |
| 4 | [narrative.md](narrative.md) | The story and the script: the order of the work, who writes what, the story bible, what AI does well here. |
| 5 | [studio-model.md](studio-model.md) | The sessions as a game studio: the roles, the practices, the milestones, the rhythm, the gaps, the sources. |
| 6 | [roles.md](roles.md) | The human (creative director), the coordinator (producer), the runner (build and QA engineer), owners, specialists on demand, task sessions. |
| 7 | [operating-model.md](operating-model.md) | Who talks to whom, the daily rhythm (summary, playtest, split, tests, triage), session rotation with handoff files. |
| 8 | [session-lifecycle.md](session-lifecycle.md) | From the decision to start a session to its final report. Messages and the shared notes folder. |
| 9 | [merge-rule.md](merge-rule.md) | Branches with a team prefix, pull requests, review, a merge only after the human says yes, the push. |
| 10 | [file-ownership.md](file-ownership.md) | One owner for each file. Generated files. Files that nobody commits. Binary locks. |
| 11 | [disk-and-worktrees.md](disk-and-worktrees.md) | The disk budget. APFS clone worktrees. |
| 12 | [unity-runner.md](unity-runner.md) | One session runs Unity, from a queue. The lock with two slots and a disk guard. |
| 13 | [test-tiers.md](test-tiers.md) | The compile check without Unity, the test tiers, the hook, flaky tests, bots, network tests, the build verification test. |
| 14 | [play-report-loop.md](play-report-loop.md) | Numbered play reports, the report key, the 10-minute focus list, playtests with new players. |
| 15 | [release-rules.md](release-rules.md) | Release candidates, one zip for each system, checks before and after the upload, a way back. |
| 16 | [lessons.md](lessons.md) | What went wrong, and the fix for each problem. |
| 17 | [blender-assets.md](blender-assets.md) | 3D models from Blender scripts in batch mode. |
| 18 | [photo-pairs.md](photo-pairs.md) | Compare the game with photos of the real place, from the same point and direction. |
| 19 | [multi-team.md](multi-team.md) | More than one team on one game: claims, messages, the shared board, the protocol for each coordinator. |

The templates for these documents are in [../templates](../templates). The tools are in [../tools](../tools); each
tool has its usage in the comment at its top.

## Words in these documents

| Word | What it means |
|---|---|
| session | One Claude Code conversation with its own task. It runs in the Claude desktop app or in a terminal. |
| coordinator | The one session that plans, starts the other sessions, and merges. |
| specialist | A session that owns one area of the game (for example combat or sound). |
| runner | The one session that runs Unity jobs for all sessions. |
| worktree | A Git worktree: one more folder of the same repository, on its own branch. |
| main checkout | The worktree of the integration branch. It has the Library that the clones share. |
| clone | An APFS clone of a file or folder (`cp -c`). It shares the disk blocks with the original until one copy changes. |
| job | One Unity batch process: a compile, a test run, a build. |
| tier | A named group of tests with a time limit (smoke, quick, full, nightly). |
| play report | The numbered list of points that the human writes after a game. |
| reading | The written interpretation of one point of a play report: the result that the human expects to see. |
| notes folder | The shared folder outside all worktrees (`NOTES_DIR`). |

# The Unity runner and the queue

Only one session runs Unity: **the runner** (`<the name of the runner session>`). All other sessions work without Unity
and send their Unity jobs to the runner. Reason: each worktree that runs Unity writes its own Library (10 to 25 GB for a
large project). A worktree that only holds code shares its files with the main checkout (an APFS clone) and uses almost
no disk. The full rules: `docs/unity-runner.md` of the repository.

## The rules

1. Only the worktrees in `runner-worktrees.txt` can start a Unity job. `tools/unity-lock.sh` refuses a job from any
   other worktree (exit code 3, a `REFUSED` line in `jobs.log`).
2. A session that is not the runner:
   - plans, writes code, docs, tests (not run), Python tools, and Blender scripts;
   - checks the C# with `tools/quick-compile.sh` (about 5 s, no Unity);
   - commits; the pre-commit hook runs the quick compile in its worktree;
   - never opens the Unity Editor, and never starts a tool that starts Unity;
   - makes a new worktree only with `tools/new-worktree.sh` (an APFS clone of the main checkout).
3. The runner runs the jobs of the queue in its worktree (`git checkout --detach <commit>` for each request), and the
   merge checks and the release builds in the main checkout.
4. The runner fixes small problems itself (a compile error, a wrong test value, a reference that is not set). It commits each
   fix on a branch `run/<branch>` from the head of the author, and tells the author to merge it
   (`git merge --ff-only run/<branch>`). For a larger problem, it sends the author the failed log lines and waits for a
   new commit.
5. When all requested jobs pass, the runner reviews the branch diff (the review command, or a fresh review session),
   sends findings of high severity back to the author, and then tells the coordinator "ready to merge", with the commit,
   the results, and the other findings. The coordinator merges only after the human says yes, and pushes the
   integration branch. Then the runner runs the merge checks in the main checkout.
6. The order of the queue: (1) the fixes of the human play reports; (2) the work that the human approved for the next
   milestone; (3) the rest, first come, first served.
7. Last good build: when the merge checks of a commit pass, the runner sets the tag `last-good` on it and tells the
   coordinator. Play-report fixes start from `last-good`.
8. Releases: each release starts as a candidate from `last-good`, goes through the release checklist, and has release
   notes with the play-report points and the bug IDs that it fixes. The previous good release stays.
9. Bugs: each open bug has a severity (S1 to S4) and a priority (P1 to P4). The runner and the coordinator triage the new
   bugs once a day at a fixed time. Each fix of an S1 or S2 bug comes with a regression test.

## A request to the runner

Send one short message to the runner, and add one line to the queue below:

- the branch and the commit (the runner reads it from the shared repository);
- the jobs, for example `tools/test-one.sh PlayMode "ClassA|ClassB"`, `tools/test-tier.sh quick`, a level build,
  `tools/net-test.sh 90 1 walk`, `tools/bot-run.sh 7 default`;
- what to check, and what a pass is;
- the files that the commit changes, and who owns them now.

## The queue

The runner keeps this list current: one line for each request, the oldest first.

| Time | Session | Branch and commit | Jobs | State |
|---|---|---|---|---|
| | | | | |

## The runner state

- `<time>`: the commit of the runner worktree; the commit of the main checkout and its last merge checks; the free disk.

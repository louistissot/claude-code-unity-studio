# The single Unity runner and the queue

**One session runs Unity: the runner. The other sessions send their Unity jobs to it.**

## 1. Why

Each worktree that runs Unity writes its own Library (10 to 25 GB in the tested game), and each Unity process needs
several GB of memory. With six to twelve sessions on one machine, each with its own Unity jobs, the free disk fell to
7 GB and builds failed. With one runner, the other worktrees stay clones that cost almost no disk
([disk-and-worktrees.md](disk-and-worktrees.md)).

The cost: the runner is a queue. A session waits for its test results. The rules below keep the wait short.

## 2. The lock

`tools/unity-lock.sh` starts each Unity job. Other tools that start Unity (`batch.sh`, `test-tier.sh`, `test-one.sh`,
`net-test.sh`, `bot-run.sh`, `release.sh`) refuse to run outside the lock, unless `UNITY_LOCK=off` in `sessions.conf`.

```bash
tools/unity-lock.sh tools/test-tier.sh quick
```

```bash
tools/unity-lock.sh --exclusive tools/batch.sh BuildTools.BuildDevMac
```

| Rule | Detail |
|---|---|
| The runner check | When `NOTES_DIR/runner-worktrees.txt` exists, only the worktrees on that list can start a job. A job from another worktree stops with exit code 3 and a `REFUSED` line in `jobs.log`. |
| Two slots | A plain job (a compile, a test run) takes one slot. An exclusive job (a level build, a light bake, a player build) takes both slots. |
| First come, first served | Each job that waits writes a wait file with its start time. An exclusive job does not start while an older job waits. A plain job does not start while an older exclusive job waits. |
| The disk guard | A plain job waits for `DISK_MIN_GB_PLAIN` of free disk, an exclusive job for `DISK_MIN_GB_EXCLUSIVE`. |
| Stale slots | A slot whose owner process is gone becomes free. A slot with no owner file is left alone for 30 s (another job is between its `mkdir` and the write of its owner). |
| The log | Each job writes a `START` and an `END` line (exit code and minutes) to `NOTES_DIR/jobs.log`. |

The lock has two slots because two plain jobs fit in the memory of the tested machine (24 GB). With more memory, you
can change the script to more slots; test the order rules again after that change.

## 3. The work of the other sessions

A session that is not the runner:

1. Plans, writes code, docs, tests (not run), Python tools, and Blender scripts.
2. Checks the C# with `tools/quick-compile.sh` (about 5 s, no Unity, [test-tiers.md](test-tiers.md)).
3. Commits. The pre-commit hook runs the quick compile in a worktree that cannot run Unity.
4. Never opens the Unity Editor, and never starts a tool that starts Unity.
5. Groups its Unity jobs and sends them to the runner in one request.

## 4. A request to the runner

Send the runner one short message, and add one line to the queue in `NOTES_DIR/unity-runner.md`:

- the branch and the commit;
- the jobs (for example `tools/test-one.sh PlayMode "ClassA|ClassB"`, `tools/test-tier.sh quick`, a level build, a bot
  run, a network test);
- what to check, and what a pass is;
- the files that the commit changes, and who owns them.

## 5. The work of the runner

1. Takes the oldest request with the highest priority: (1) the fixes of a human play report; (2) the work that the
   human approved for the next release; (3) the rest.
2. Checks out the commit in its own worktree: `git checkout --detach <commit>`.
3. Runs the jobs through the lock, and reads the results.
4. Fixes a small problem itself (a compile error, a wrong test value, a reference that is not set): it commits the fix on a
   branch `run/<branch>` from the head of the author, and tells the author to merge it with
   `git merge --ff-only run/<branch>`.
5. Sends a larger problem back to the author: the failed log lines and the test names. The author sends a new commit.
6. Reviews the diff when the jobs pass (the review command, or a fresh review session), sends findings of high
   severity back to the author, and then tells the coordinator "ready to merge" with the commit, the results, and the
   other findings ([merge-rule.md](merge-rule.md)).
7. After a merge, runs the merge checks and the build verification test in the main checkout: the rebuild of generated
   content, the full tier, the bots, the network test. When they pass, it moves the tag `last-good`.
8. Keeps the bug list with severity and priority, and triages the new bugs each day with the coordinator
   (`templates/bugs.md`). In studio terms, the runner is the build engineer and the QA engineer.
9. Builds the release candidates from `last-good` in the main checkout ([release-rules.md](release-rules.md)).
10. Keeps the queue and its state in `NOTES_DIR/unity-runner.md` current (with more than one team, also the Unity queue
    of its team on the board).

## 6. Change to the runner rule

The coordinator changes `runner-worktrees.txt`. When the rule starts, the jobs that other sessions run now can finish
first: put their worktrees on the list for a short grace time, and remove the lines when their jobs end.

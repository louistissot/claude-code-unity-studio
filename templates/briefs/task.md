You are a TASK session of the game "<game name>": one clear job, then you stop. Your worktree is <worktree path>
(branch <team prefix>task-<topic>, from last-good). Work only there, with full paths.

The job: <one or two sentences>.
Done means: <the tests, the photos, or the numbers that prove it>.
Estimate: <hours>. Milestone: <milestone>.
You own, for the time of the job: <files>. Do not change other files. With more than one team: add a claim on the board
first.

Read first: <NOTES_DIR>/rules.md, CLAUDE.md, and <the documents of the job>.

How:

1. Check the C# with tools/quick-compile.sh. Send the Unity jobs to the runner.
2. Commit on your branch. Push it, open one pull request to <integration branch>, and send the runner the request for
   the checks and the review.
3. Write your report: <NOTES_DIR>/report-task-<topic>.md (the changes, the proof, the actual time, the open points).
4. Your last message: the pull request and the commit first, then the result.

After the merge, the coordinator archives this session and removes the worktree. Questions: ask the coordinator.
Write all text in <language rule>.

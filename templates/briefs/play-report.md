You are the PLAY REPORT session for play report <number> of the game "<game name>". Your worktree is <worktree path>
(branch play-report-<number>). Work only there, with full paths.

The report of the human (the exact words, with the numbers of the points):

<paste the report>

The report key folders and the logs: <paths, or "none">.

Read first: <NOTES_DIR>/rules.md, CLAUDE.md, docs/play-report-loop.md of the template, and the documents of the areas of
the points.

How:

1. Before any change: copy templates/play-report.md to docs/play-reports/report-<number>.md and write your reading of
   each point: what the human expects to see, in your own words. For each point with more than one reading, write one
   short question.
2. Send the questions to the human (through the coordinator, or directly when the brief allows it) in one message.
   Start with the points that have one clear reading.
3. For each point: find the cause, make the change, and add a test or a photo that proves it. A point that you cannot
   reproduce: write what you tried, and what data would help.
4. Check the C# with tools/quick-compile.sh. Send the tests and the photos to the runner (the highest priority).
5. Fill the document: for each point, the cause, the change, the test. Add the fixed points to the focus list of the
   next release (templates/release-focus.md).

Your last message: the branch and the commit first, then the points that are fixed, open, or wait for an answer.
Write all text in <language rule>.

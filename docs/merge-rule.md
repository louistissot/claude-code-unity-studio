# The merge rule

**Each change goes into the integration branch by a pull request, after a review, the checks, and the yes of the
human. The coordinator merges it and pushes the integration branch.** No other session merges into the integration
branch or pushes it.

## 1. Branches

- Each team has a branch prefix, for example `alpha/`. Each branch is `<team prefix><topic>`, for example
  `alpha/world-harbour` or `alpha/task-report-key` (`BRANCH_PREFIX` in `sessions.conf`).
- A session works on one branch in its own worktree. It pulls the integration branch before new work. A fix of a play
  report starts from the tag `last-good`.
- The runner commits its small fixes on `run/<branch>`; the author merges them with `git merge --ff-only`.

## 2. The steps

1. The session finishes its piece: all work is committed and pushed, the report is complete. It opens a pull request to
   the integration branch (`gh pr create`), with the report link and the tests.
2. The coordinator reads the report and the diff, and checks the ownership: each changed file belongs to the area of
   the session, or is in `cross-<area>.md`. With more than one team, the claim is "in review" on the board.
3. The coordinator sends the runner a request: the pull request, the commit, and the jobs (the quick tier, the tests of
   the area, the bots or the network test when the change touches them).
4. **Review.** When the jobs pass, the runner reviews the diff, as a lead in a studio does: the review command of Claude
   Code on `<integration>...<commit>`, or a fresh review session. The checklist: the change does what the one-page
   design says; each rule has a test; no work in each frame that makes garbage; no change to files of other areas
   without a `cross-<area>.md` line; no generated files; the risks for the network and for the save data. Findings of
   high severity go back to the author first.
5. The runner tells the coordinator "ready to merge", with the commit, the results, and the other findings.
6. The coordinator asks the human, in one message: the pull request, what changes for the player, the tests and their
   results, the review findings, the risks.
7. The human says yes (in the chat, or with an approval of the pull request on GitHub), or no, or "later".
8. The coordinator merges the pull request with a merge commit (`gh pr merge <number> --merge`, or `git merge --no-ff`
   and then `git push`), and pushes the integration branch at once. With more than one team, it tells all teams the
   commit on the board.
9. The runner runs the merge checks in the main checkout: a rebuild of the generated content when the change needs it,
   the full tier, the bots, the network test, and the build verification test. When they pass, it moves the tag
   `last-good` to the merge commit ([test-tiers.md](test-tiers.md), section 7).
10. A task session is archived after its merge, and its worktree is removed.

## 3. Details

- One yes covers one merge (and the push of the integration branch after it). A yes for one pull request is not a yes
  for the next one.
- After the feature freeze, only fixes and the features on the milestone list enter; after the content lock, only
  fixes. An exception needs the yes of the human (`templates/milestones.md`).
- A rule in advance (for example "merge the night work of the specialists after the checks pass") is valid only with
  its limits. Write it in the rules file: the branches, the checks, the end time.
- Conflicts: the coordinator solves them. The owner of the file decides the content. When the owner is not sure, the
  coordinator asks the human.
- Generated files (for example a level scene that a builder writes) are not merged as text. The runner builds them
  again one time after the merge ([file-ownership.md](file-ownership.md)).
- When the checks after a merge fail: the coordinator tells the human at once, and reverts the merge
  (`git revert -m 1 <merge commit>`, then a push) or asks the owner for a fix, with the yes of the human.

## 4. Why

- The human keeps control of what goes into the game. The sessions can work fast because the merge is the gate.
- A bad merge costs more than a slow merge: each session starts its next work from the integration branch.
- A pull request keeps the review, the checks, and the yes in one place, also for other teams.
- A merge commit for each pull request makes a revert simple.

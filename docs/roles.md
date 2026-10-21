# The roles

One human and many Claude Code sessions make the game. The roles copy the roles of a game studio
([studio-model.md](studio-model.md)). Each session has one role, and it keeps that role for its life. For a new role,
the coordinator starts a new session.

| Role | Studio name | Sessions | Life |
|---|---|---|---|
| The human | creative director, daily playtester | one person | the whole project |
| Coordinator | producer | 1 | the whole project, with rotation ([operating-model.md](operating-model.md)) |
| Runner | build and QA engineer | 1 (the only session with Unity) | the whole project |
| Owners | discipline leads | 1 for each core area, for example World, Art, Gameplay, Mechanics | long, with rotation; they own their files |
| Specialists | experts on demand | for example Look, Sound, Performance and Network | started for one need, stopped after it |
| Task sessions | a contractor for one job | 1 for each clear job | archived after the merge of the job |

In the tested setup, one machine (a Mac with 24 GB of memory and 12 cores) ran up to twelve sessions at the same time.
The sessions themselves need little memory. Unity needs much memory and disk, so only the runner runs Unity.

## 1. The human (the creative director and daily playtester)

- Is the author: has the first ideas, owns the vision and the pillars (`templates/pillars.md`), the art direction,
  the premise and the key voices, and the feel ([ai-pitfalls.md](ai-pitfalls.md), section 3). Decides each cost,
  risk, and change of scope.
- Talks every day to one session only: the coordinator. The coordinator relays to the other sessions. If the human
  talks to another session, that session sends the decision to the coordinator at once.
- Says yes (or no) to each merge, each release, and each public post. Signs off each milestone.
- Plays the game every day for the feel, and writes numbered play reports ([play-report-loop.md](play-report-loop.md)).

## 2. The coordinator (the producer)

One session. The single point of contact of the human. It does not do large feature work itself.

- Splits the work: it decides which owner, specialist, or task session does each piece, and relays what each session
  needs from the human or from other sessions.
- Keeps the milestones with exit criteria, the backlog with estimates and actual times, the cut list
  (`templates/milestones.md`), the risk register (`templates/risks.md`), and the decisions (`templates/decisions.md`).
- Makes the worktrees (`tools/new-worktree.sh`), writes the briefs (`templates/briefs/`), and starts the sessions.
- Keeps the shared notes folder: the rules file, `runner-worktrees.txt`, the ownership table. With more than one team,
  keeps the space of its team on the board up to date ([multi-team.md](multi-team.md)).
- Merges each pull request after the review, the checks, and the yes of the human, then pushes the integration branch
  ([merge-rule.md](merge-rule.md)).
- Runs the daily bug triage with the runner, and a retrospective at each milestone (`templates/retrospective.md`).
- Gives the human a daily summary (`templates/daily-summary.md`): what changed, at most three decisions with a
  recommendation, and a 10-minute focus list. Sets the daily triage reminder in its own session
  ([operating-model.md](operating-model.md)).
- Rotates the long sessions (also itself) with a handoff file (`templates/handoff.md`).

## 3. The runner (the build and QA engineer)

One session. The only session that runs Unity ([unity-runner.md](unity-runner.md)).

- Runs the Unity jobs of all sessions from a queue, in its own worktree, with a detached checkout of each commit.
- Reviews each branch diff before it says "ready to merge" (the review command of Claude Code, or a fresh review
  session). It sends findings of high severity back to the author.
- Runs the merge checks and the build verification test in the main checkout, and moves the tag `last-good`.
- Keeps the bug list with severity and priority (`templates/bugs.md`), and triages the new bugs each day with the
  coordinator. Each fix of an S1 or S2 bug gets a regression test.
- Builds the release candidates from `last-good`, with the checklist and the release notes
  ([release-rules.md](release-rules.md)).
- Fixes small problems itself on a branch `run/<branch>`, and sends larger problems back to the author.

For a large bug hunt (for example before a milestone), the coordinator can start a separate QA task session
(`templates/briefs/qa.md`). It reads code paths, plays with the bots, and writes bugs; the runner still runs Unity.

## 4. Owners (the discipline leads)

One long session for each core area. An example with four areas:

| Owner | Area |
|---|---|
| World | The levels: the level builders, the layout, the places, the props in the level, navigation |
| Art | The models and the environment: Blender scripts, buildings, textures, materials ([blender-assets.md](blender-assets.md)) |
| Gameplay | The feel of play: weapons, enemies and their AI, damage, movement, the difficulty of the fights |
| Mechanics | The game rules and the UX: missions, items, interaction, HUD and menus, the end of a game, the bots |

Each owner:

- works only in its own worktree, on a branch with the team prefix, and owns the files of its area
  ([file-ownership.md](file-ownership.md));
- starts each new feature with research and a one-page design (`templates/feature-onepager.md`), and names the pillar;
- checks its C# with `tools/quick-compile.sh` and sends its Unity jobs to the runner;
- keeps its report current: the changes, the tests and their output, photos or numbers, the decisions, the open points,
  the estimate and the actual time.

## 5. Specialists on demand

Experts that the coordinator starts for one need and stops after it, for example:

| Specialist | When |
|---|---|
| Look | light, sky, post effects, materials, shaders |
| Sound | sound and music, the mix, occlusion |
| Performance and Network | frame rate, memory, load times, network sync, network tests, soaks |

A specialist works as an owner for the time of its need: its own worktree, a list of the files that it owns for that
time, research first, a report.

## 6. Task sessions

One clear job each, for example the fixes of one play report, an in-game report key, a research question, or the
integration of a batch of models. The brief says what "done" means (`templates/briefs/task.md`).

- A task session owns only the files of its job, for the time of the job.
- It ends with one branch, one pull request, and a report. After the merge, the coordinator archives it and removes its
  worktree.
- A challenger task (`templates/briefs/challenger.md`) attacks a concept with the originality gate before any production
  ([concept-phase.md](concept-phase.md)); it never writes the concept.
- A research task only reads and writes notes. Before a document says that something is new, the best, or the first,
  it searches with more than one method and lists the sources. A claim from one or two short web searches is not proof.
- A play-report task first writes its reading of each point, and asks the human about each point with more than one
  reading ([play-report-loop.md](play-report-loop.md)).

## 7. What each brief must say

The role, the worktree and the branch (with the team prefix), the files that the session owns, the goal and what
"done" means, the pillar, the estimate, the times of the milestones and of the end, the report file, the rules file, how
to get Unity jobs, and the question policy (ask the coordinator, or decide and record). The templates are in
`templates/briefs/`.

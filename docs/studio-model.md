# The studio model: run the sessions as a game studio runs production

The sessions are not only "many agents at the same time". They are a small game studio: a director, a producer,
discipline teams, a build engineer, QA, and playtests, with milestones and gates. This document maps each studio
practice to a role, a document, or a tool of this template, and says what the template does not cover.

The sources are at the end. Studios do not use one standard: the definitions below are common practice, not a norm.
Write your own definitions down, because people (and sessions) who sign off a milestone with different definitions
cause the worst production problems.

## 1. The roles of a studio and of this template

| Studio role | In this template | What it does here |
|---|---|---|
| Creative director, game director | the human | Owns the vision and the pillars. Plays every day for the feel. Approves merges, releases, milestones. |
| Executive producer, publisher | the human | Approves the scope, the dates, and each cost. |
| Producer | the coordinator session | The single point of contact of the human. Splits the work, relays, keeps the milestones, the backlog, the risks, and the cut list, merges after the yes of the human. |
| Build engineer and QA engineer | the runner session | The only Unity jobs, from a queue: builds, test runs, the review before "ready to merge", merge checks, `last-good`, bug triage, release candidates. |
| Discipline leads | owner sessions (for example World, Art, Gameplay, Mechanics) | One core area each, for a long time, in its own worktree, with research first and a report. |
| Experts on demand | specialist sessions (for example Look, Sound, Performance and Network) | Started for one need, stopped after it. |
| Contractors for one job | task sessions | One clear job, one pull request, archived after the merge. |
| Code review by a lead | the runner (the review command), or a review task session | A second reader of each diff before "ready to merge" ([merge-rule.md](merge-rule.md)). |
| Games user research | the human, and the playtest plan | Playtests with first-time players: objectives, observation, questions, telemetry. |
| Several studios or teams on one game | one coordinator for each team, and the shared board | Claims, messages, and a protocol for the coordinators ([multi-team.md](multi-team.md)). |

## 2. Studio practices: what this template gives, and the gaps

| Practice | Studio form | This template | State |
|---|---|---|---|
| Vision and pillars | A one-page vision with 3 to 5 pillars. Each feature must serve a pillar. Short, visual documents. | `templates/pillars.md`; each brief names its pillar. | yes |
| One-page feature design | A one-page design for each feature before the work: the goal, the rules, the cut options. | `templates/feature-onepager.md` | yes |
| Milestones with gates | Prototype, vertical slice, alpha (feature complete), beta (content complete, content lock), release candidate, gold. Each with entry and exit criteria and one sign-off owner. | `templates/milestones.md`; the human signs off. | yes |
| Feature freeze and content lock | Dates after which only fixes enter. | In `templates/milestones.md`; the merge rule enforces them. | yes |
| Backlog, estimates, cut list | A priority order, an estimate and an actual time for each item, a list of what to cut first. | `templates/milestones.md` (the feature table and the cut list). | yes |
| Risk register | Each risk with its effect, its owner, and the action; the large risks first in the schedule. | `templates/risks.md` | yes |
| Ownership and locks | One owner for each scene; locks for binary assets (exclusive checkout); Force Text serialization. | [file-ownership.md](file-ownership.md); `git lfs lock` for hand-made binary assets; generated scenes are not merged. | yes, without a lock server |
| Code review | A lead reads each change before it goes in. | A review step in [merge-rule.md](merge-rule.md). | yes |
| Continuous integration | A build and tests on each commit; a smoke test of each build; nightly full runs. | The runner queue, the test tiers, the hook, the nightly tier. No CI server. | partial |
| Build verification test | Each new build boots, loads, and plays a short sequence before QA takes it. A label for the last good build. | The bot run and the network test after each merge; the tag `last-good` ([test-tiers.md](test-tiers.md), section 7). | yes |
| Bug triage | Severity (the effect) and priority (the order of the fix) are two different fields. A triage at a fixed time. Each fix gets a regression test. | `templates/bugs.md` | yes |
| Playtests | Regular playtests with first-time players; a plan: objectives, observation, questions, telemetry. | `templates/playtest-plan.md`; the human play report loop ([play-report-loop.md](play-report-loop.md)). | yes |
| Performance budgets | A frame-time and memory budget for each target machine, measured on each build. | The budgets in `templates/milestones.md`; a benchmark mode and the `Perf` test category. | partial |
| Release candidates and sign-off | A candidate build, a sign-off checklist, release notes, a version number, the previous release kept for a rollback. | `templates/release-checklist.md`; [release-rules.md](release-rules.md). | yes |
| Postmortems and milestone reviews | At each milestone: what went right, what went wrong, what to change. Read the old ones. | `templates/retrospective.md`; [lessons.md](lessons.md). | yes |
| Localization, accessibility, platform certification, ratings, marketing | Teams or vendors of their own. | Not covered. | no |
| A team of many humans | Many people with many skills. | One human. The sessions do not replace art direction, recorded sound, or the judgment of players. | no |

## 3. The production rhythm

| When | What | Who |
|---|---|---|
| Each change | `tools/quick-compile.sh`; small commits | each specialist |
| Each request | The tests of the area and the quick tier, through the runner queue | the runner |
| Each pull request | The checks, the review, the yes of the human, the merge and the push, the merge checks, the build verification test, the tag `last-good` | the runner and the coordinator |
| Each day | Bug triage: new bugs get a severity, a priority, and an owner | the runner and the coordinator |
| Each night | The nightly tier in a random order; a long soak | the runner |
| Each release for the human | A release candidate, the checklist, the focus list, the release notes | the runner and the coordinator |
| Each play report or playtest | The reading of each point, the questions, the fixes, the proof | a play-report session |
| Each milestone | The exit criteria, the sign-off of the human, a retrospective, the update of the risk register and the cut list | the coordinator and the human |

## 4. The milestone ladder (a first version)

Write your own exit criteria into `templates/milestones.md`. A milestone is passed only when the human signs it off.

| Milestone | Exit criteria (example) |
|---|---|
| Concept gate | The originality gate passed; the comparables show a difference that a player sees; the key risks are named, each with a prototype plan; the pillars are written ([concept-phase.md](concept-phase.md)). |
| Prototype | The core loop is playable in a test room. The main risk of the design has an answer. |
| Vertical slice (the pre-production gate) | One short part of the game at near-final quality. It sets the budgets (frame time, memory), the look, the sound, the controls, and the asset workflow. Each key risk has a result; new players played it; the story bible exists. |
| Alpha (feature complete) | Each planned feature is in and playable from the start to the end. Placeholders are allowed. The cut list is decided. |
| Beta (content complete, content lock) | All content is in. Only fixes enter. No open crash or blocker; the frame-time budget passes on the target machines. |
| Release candidate | A candidate build passes the full tier, the bots, the network tests, the build verification test, and the release checklist. |
| Gold, release | The human approves the candidate. The release is public. A retrospective follows. |

## 5. Sources

Read on 21 October 2026.

- Milestones: [Alpha, Beta and Gold in Game Development](https://gamedevproducer.com/posts/what-is-a-game-milestone-alpha-beta-gold/);
  [What Is a Content Complete Milestone](https://gamedevproducer.com/posts/what-is-a-content-complete-milestone-in-games/);
  [Milestones, Rami Ismail](https://ltpf.ramiismail.com/milestones/);
  [9 stages of game production according to Tim Cain](https://gameworldobserver.com/2023/11/22/game-production-stages-prototype-alpha-beta-ship-tim-cain).
- Reviews at each milestone: [Goodbye Postmortems, Hello Critical Stage Analysis](https://www.gamedeveloper.com/production/goodbye-postmortems-hello-critical-stage-analysis).
- Builds and QA: [How to Set Up Smoke Tests for Game Builds](https://bugnet.io/blog/how-to-set-up-smoke-tests-for-game-builds);
  [Game Dev Testing & QA](https://www.butterstack.com/blog/game-dev-testing-qa-pipeline/).
- Bug triage: [The bug triage process](https://hacknplan.com/blog/the-bug-triage-process);
  [Severity vs Priority](https://qasphere.com/blog/severity-vs-priority/).
- Playtests: [Games User Research Methods](https://gamesuserresearch.com/games-user-research-methods/);
  [Mid-Playtest Feedback Methods](https://www.linkedin.com/pulse/mid-playtest-feedback-methods-john-hopson).
- Design documents: [The Four One Page Design (GDC)](https://gdcvault.com/play/1035510/The-Four-One-Page-Design);
  [Video: One-page designs](https://www.gamedeveloper.com/design/video-one-page-designs).
- Locks and binary assets: [Version Control for Binary Files](https://www.anchorpoint.app/blog/version-control-for-binary-files);
  [Asset serialization mode](https://github.com/JetBrains/resharper-unity/wiki/Asset-serialization-mode).

Many of these sources are vendor blogs or personal guides, not studio standards. The practices are common to them; the
numbers in them are examples.

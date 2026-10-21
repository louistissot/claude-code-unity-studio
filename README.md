# claude-code-unity-studio

**A guide and a template to make an original Unity game with Claude Code, from the first idea to the release, with
Claude Code sessions as a studio team.**

You are the author and the creative director. The sessions research, challenge, build, test, and report: one session
is the producer, owner sessions lead the core areas, specialists come on demand, task sessions do one job each, and
one session is the build and QA engineer. The work follows the order of game development: concept, pre-production,
production (alpha, beta), release candidates, release. Each phase has a gate. It comes from the real setup of one game,
with the paths, names, and data of that game removed.

The main parts:

- **From the first idea to the release, in the right order.** Phases with gates: your own ideas first, a concept that
  passes an originality challenge, pre-production with key-risk prototypes and a vertical slice, then production,
  release candidates, and the release ([docs/guide.md](docs/guide.md)).
- **Original, not a clone.** What to avoid with AI (clones, average ideas, taste given away, generic text), and the
  countermeasures: the human is the author, and a challenger session attacks the concept before any production
  ([docs/ai-pitfalls.md](docs/ai-pitfalls.md), [docs/concept-phase.md](docs/concept-phase.md)).
- **The story and the script.** The order of the story work, the story bible, the script outline, and what AI does
  well there ([docs/narrative.md](docs/narrative.md)).
- **A studio model.** The roles, the milestones (vertical slice, alpha, beta, release candidate), the production
  rhythm, and the gaps, with sources ([docs/studio-model.md](docs/studio-model.md)).
- **A studio team of sessions.** The human is the creative director and daily playtester. The coordinator (the
  producer) is the one session that the human talks to every day. The runner is the build and QA engineer. Owners lead
  the core areas (for example World, Art, Gameplay, Mechanics); specialists come on demand (Look, Sound, Performance and
  Network); task sessions do one job each and are archived after the merge.
- **A daily rhythm and session rotation.** A daily summary with at most three decisions and a 10-minute focus list, a
  daily bug triage at a fixed time, and fresh sessions from handoff files when a long session gets stale.
- **Pull requests and a merge gate.** Branches with a team prefix, a review of each diff, the checks, the yes of the
  human, then the coordinator merges and pushes.
- **One Unity runner.** Only one session runs Unity, from a queue. The other sessions write code and check it with a C#
  compile of about 5 s that needs no Unity.
- **Worktrees that cost almost no disk.** Each new worktree is an APFS clone of the main checkout, with its Library.
- **A lock with a disk guard.** Each Unity job goes through a lock with two slots, first come, first served.
- **Test tiers and a pre-commit hook.** smoke, quick, full, nightly; a fixed frame time; a policy for flaky tests;
  skeletons for bot runs and network tests.
- **The human loop.** Numbered play reports, an in-game report key, a written reading of each point before the work,
  and a 10-minute focus list with each release.
- **Production documents.** The vision and pillars, one-page feature designs, milestones and backlog, the risk
  register, the bug list with severity and priority, playtest plans, the release checklist, and retrospectives.
- **Safe releases.** Release candidates from the last good build, one zip for each system, never parts, with checks
  before and after the upload.
- **More than one team.** A shared live board (a Claude artifact) with a space for each team, claims, messages, and an
  11-step protocol for the coordinator of each team; or the same with GitHub issues only.

## Status and limits (read this first)

- **Tested on one game, with one human, for about three weeks**, on one Mac (24 GB of memory, 12 cores) with Unity 6,
  with up to about twelve sessions at the same time. The method is not proven for other games, other teams, or other
  machines.
- **The tools here are generic copies** of the tools of that game. Checks without Unity: the bash syntax of all
  scripts; the lock with fake jobs (the order of plain and exclusive jobs, the runner check); the clone command in a
  scratch repository; the hook in its three cases; the release zips and their checks with fake players; `setup.sh` with
  fake Unity tools; and `quick-compile.sh` on a large real project. Checks with Unity 6 (21 October 2026, by the runner
  session of the tested game): `setup.sh` with the template `com.unity.template.urp-blank`, the quick tier on the sample
  project (EditMode 2 of 2, PlayMode 4 of 4), `quick-compile.sh`, and a development build for Mac. **Not run yet:** the
  bot and network skeletons with a real bot, and the upload part of the release script.
- **The board for more than one team is new.** It mirrors the board of the tested game, but no second team used it
  over a long time yet. It needs the Claude artifact runtime; a GitHub-only form is described in
  [docs/multi-team.md](docs/multi-team.md).
- **APFS clones work only on macOS.** On another system, `tools/new-worktree.sh` stops, or makes a full copy that costs
  the full size of the checkout.
- **The messages between sessions are a feature of the Claude desktop app.** With the Claude Code CLI in terminals, the
  shared notes folder still works, but a session cannot send a message to another session. The app can also pause the
  messages of a session (in the tested setup: after about ten messages for one message of the human).
- **`quick-compile.sh` reads internal files of Unity** (`Library/Bee`). A new Unity version can change them.
- **The release script needs macOS** (ditto) and the GitHub CLI.
- **Many sessions use your Claude plan limits fast.** Start with the coordinator, the runner, and one or two
  specialists.

## What it does not do

- It does not make a game for you, and it does not give you a game idea. It has no game code, only small samples. It
  helps you to find, test, and build your own idea.
- It is not a set of agent personas with prompts for each studio job, and it adds no Claude Code skills or slash
  commands. The studio model here is about how the production runs: the gates, the pipeline, and the human in charge.
- It does not drive the Unity Editor window. It runs Unity in batch mode only.
- It has no CI server. Everything runs on one machine.
- It does not replace the human: the human says yes to each merge, push, and release.

## For whom

- One developer (or a small team) who makes a Unity game with Claude Code and wants to run more than one session.
- People who already know Git, the terminal, and Unity, and who work on a Mac.

## Quick start

First, the concept. Read [docs/guide.md](docs/guide.md) and do phase 0 and phase 1 before any Unity work: write your own
ideas, write one-page concepts (`templates/concept-doc.md`), research the comparables, and pass the originality gate
with a challenger session (`templates/briefs/challenger.md`). For this phase you need only Claude Code and these
documents. The steps below set up the project for pre-production, after the concept gate.

1. Make a repository from this template. Clone it to the folder of the main checkout (`MAIN_CHECKOUT` in
   `sessions.conf`; the default is `~/UnityProjects/game-dev`).
2. Make the integration branch: `git switch -c dev` (`BASE_BRANCH`).
3. Edit `sessions.conf`: the game name, the Unity version, the paths.
4. Install the Unity CLI and the Unity Editor of that version.
5. Run the setup. It starts Unity one time to make an empty project:

   ```bash
   ./setup.sh
   ```

6. Run the first checks (this also writes the files that the quick compile needs):

   ```bash
   UNITY_LOCK=off tools/test-tier.sh smoke
   ```

7. Commit the project files.
8. Make the worktree of the runner (it is the only one that runs Unity, with the main checkout):

   ```bash
   tools/new-worktree.sh qa
   ```

9. Start the runner session with `templates/briefs/runner.md`, and the coordinator with
   `templates/briefs/coordinator.md`. The coordinator starts the other sessions.

Then read [docs/README.md](docs/README.md).

## What is inside

| Path | Contents |
|---|---|
| `sessions.conf` | The one configuration file: each path and each name that the tools use. |
| `llms.txt` | A short summary with links, for AI agents that read this repository. |
| `CHANGELOG.md` | The changes of each version. |
| `setup.sh` | Makes an empty Unity 6 project here with the Unity CLI, and adds the samples and the hook. |
| `docs/` | The method: roles, the life of a session, the merge rule, ownership, disk, the runner, tests, the play report loop, releases, lessons, Blender models, photo pairs. |
| `tools/unity-lock.sh` | The lock for Unity jobs: the runner check, two slots, the disk guard, `jobs.log`. |
| `tools/quick-compile.sh` | The C# compile check without Unity (about 5 s). |
| `tools/new-worktree.sh` | A new worktree as an APFS clone of the main checkout. |
| `tools/worktrees.sh` | Each worktree, its Unity turn, its Library, and the free disk. |
| `tools/init-notes.sh` | Makes the shared notes folder with the runner list and the queue. |
| `tools/batch.sh`, `tools/test-tier.sh`, `tools/test-one.sh`, `tools/test-summary.py` | Batch jobs and test tiers. |
| `tools/install-hooks.sh`, `tools/hooks/pre-commit` | The pre-commit hook. |
| `tools/release.sh` | One zip for each system, the checks, the GitHub release. |
| `tools/bot-run.sh`, `tools/net-test.sh` | Skeletons of the bot run and of the network test (also a long soak). |
| `templates/CLAUDE.md` | A `CLAUDE.md` for the game: batch mode only, everything built with code, Simplified Technical English as an option. |
| `templates/briefs/` | A brief for each kind of session: coordinator, runner, owner, specialist, task, challenger, research, Blender, QA, play report. |
| `templates/board/` | The shared board for more than one team (a page for the Claude artifact runtime), its data model, and the protocol. |
| `templates/` (concept and story) | `concept-doc.md`, `concept-challenge.md` (the originality gate), `comparables.md`, `prototype-plan.md` (key risks), `story-bible.md`, `script-outline.md`, `ai-record.md`. |
| `templates/` (operation) | `daily-summary.md`, `handoff.md`. |
| `templates/` (production) | `pillars.md`, `feature-onepager.md`, `milestones.md`, `risks.md`, `bugs.md`, `playtest-plan.md`, `release-checklist.md`, `retrospective.md`. |
| `templates/` | The play report, the 10-minute focus list, `decisions.md`, the session log, the session report. |
| `templates/notes/` | The files of the shared notes folder. |
| `templates/unity/Assets/` | The sample assemblies, tests, build methods, the command-line driver, and the report key. |

## Similar projects

Other projects also combine Claude Code and game development. They do other parts of the work, and you can use them
together with this repository. Checked on 21 October 2026; see each project for its current state.

- [Claude-Code-Game-Studios](https://github.com/Donchitos/Claude-Code-Game-Studios): a Claude Code configuration with
  a hierarchy of studio agents, workflow skills, hooks, and templates. It is not specific to Unity.
- `claude-unity-game-studio`: a collection of Unity skills and studio workflow files for Claude Code.
- [Unity's plugin for Claude Code](https://docs.unity.com/en-us/ai/unity-plugin/claude-code): official Unity skills
  for project setup, Editor control from the terminal, packages, and more.
- Unity MCP servers, which connect Claude to an open Unity Editor, for example
  [CoplayDev/unity-mcp](https://github.com/CoplayDev/unity-mcp), [IvanMurzak/Unity-MCP](https://github.com/IvanMurzak/Unity-MCP),
  and [CoderGamester/mcp-unity](https://github.com/CoderGamester/mcp-unity).

The difference: those projects give Claude roles, skills, or a live connection to the Editor. This repository is about
how the production runs, as in a studio, with many sessions on one machine: the milestones and gates, the review and
merge rule, the disk, the Unity jobs, the tests, the bug triage, the playtests, the releases, and the loop with the
human.

## Language

All text in this repository is in ASD-STE100 Simplified Technical English: short sentences, one word for one concept,
the active voice. This makes the rules easy to read for people and for Claude, also for readers whose first language
is not English. The `CLAUDE.md` template keeps this as an option.

## Licence

MIT. See [LICENSE](LICENSE).

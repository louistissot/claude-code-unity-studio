# Checks and test tiers

Fast checks run often; slow checks run less often. A session never waits for a slow check to see a compile error.

| Check | Unity | Time in the tested game | When |
|---|---|---|---|
| `tools/quick-compile.sh` | no | about 5 s | after each code change, in each worktree |
| smoke tier | yes | 1 to 3 min | before each commit of code (the hook, in a runner worktree) |
| quick tier | yes | 5 to 8 min | before each milestone, and for each runner request |
| full tier | yes | 25 to 35 min | after a level build, after a merge, at the end of a work period |
| nightly tier | yes | about 1 h | each night, in a random order |
| bots and network tests | a built player | 2 to 30 min each | after changes to game rules or to the network, before a release |

## 1. The compile check without Unity

`tools/quick-compile.sh` uses the C# compiler of the Unity install with the response files (`.rsp`) of the last Unity
compile of the worktree (in `Library/Bee/artifacts/<id>E.dag`). It compiles the assemblies of
`QUICK_COMPILE_ASSEMBLIES` with the source files of now.

- It finds compile errors. It does not import assets, run tests, run code weavers (for example of a network library),
  or run Burst. A pass is not a full Unity pass; an error is a real error.
- It needs one Unity compile of the worktree first. A clone worktree has one from the main checkout.
- It checks only code in assembly definitions (`.asmdef`). Put all game code into assemblies.
- It compiles the Editor version of the code (the defines of the Editor). Code inside `#if !UNITY_EDITOR` is not checked.

## 2. The tiers

`tools/test-tier.sh smoke|quick|full|nightly` (through the lock). The PlayMode categories of each tier are in
`sessions.conf`:

| Tier | Contents |
|---|---|
| smoke | the compile, EditMode |
| quick | the compile, EditMode, PlayMode without `Level`, `Slow`, `Tool`, `Visual`, `Perf`, `Quarantine` |
| full | EditMode, PlayMode without `Slow`, `Tool`, `Visual`, `Perf`, `Quarantine` |
| nightly | EditMode, PlayMode without `Tool` and `Quarantine` |

Rules:

1. Put a category on each new test class that loads the level (`[Category("Level")]`), that runs longer than 60 s
   (`[Category("Slow")]`), or that only makes photos (`[Category("Tool")]`). A test with no category is in the quick
   tier.
2. The script calls the Unity binary with `-testCategory`, and a watchdog stops a run after the limit of its tier. A
   hung run can last hours while the machine sleeps.
3. Each run adds a line to `TestResults/history.csv`: the time, the commit, the tier, the counts, the order seed, and
   the failed tests.
4. `ORDER_SEED=N` runs the PlayMode tests in a random order. A test that passes alone and fails in a long run depends
   on another test: find that test (run the failed test after one half of the tests before it, keep the half that makes
   it fail, and do it again).

## 3. Tests that give the same result on each machine

- **The fixed frame time.** Before each PlayMode test, set `Time.captureDeltaTime` to 1/60 s. Then each frame advances
  the game time by 1/60 s, whatever the speed of the machine. Without it, a batch run had about 390 frames each second,
  and code that adds values in `Update` gave other results than a game at 60 fps. Wait in game time
  (`WaitForSeconds`, `Time.time`), never in real time. See `templates/unity/Assets/Tests/PlayMode/FixedFrameTimeTests.cs`.
- **The frame-rate matrix.** Run the important cases (walk, jump, a hit, a push on a door) at 30, 60, 144, and 300 fps of
  game time, in a new world for each rate, and compare the results with a limit (for example a spread of 3 %).
- **The isolation guard.** When Enter Play Mode Options keep the domain (no reload), static values live from one test
  into the next one. Give each class with static state a reset method, and call the resets before each PlayMode test
  from a test run callback. Remove the root objects that a test leaves, and log their names with the name of the test.
- **Batch mode has no camera.** Code that depends on a rendered camera (for example the culling of animators) acts in
  another way in batch mode. Read `Application.isBatchMode` where it matters.

## 4. The pre-commit hook

`tools/install-hooks.sh` installs a small hook that starts `tools/hooks/pre-commit` of the worktree of the commit. For a
commit with files that match `HOOK_PATTERN`:

- in a worktree on the runner list: the smoke tier, through the lock;
- in any other worktree: `tools/quick-compile.sh`;
- when Unity has the project open: a warning, and the commit goes on.

`SKIP_TESTS=1 git commit ...` skips the hook. Use it only when you ran the checks of the commit just before, and say so
in the commit message. Before the hook went through the lock, it started Unity directly and went past the runner rule.

## 5. Flaky tests

A flaky test passes and fails on the same commit (`history.csv` shows it).

1. Run it 5 times alone. If it fails one time or more, it is flaky.
2. Find the cause the same day: real time in the test (use game time), the order of the tests, a random value without a
   seed, or a race with a scene that loads.
3. If the cause is not found in 2 hours, give the test `[Category("Quarantine")]` with a comment: the date, the failure
   message, and the probable cause. The tiers do not run quarantined tests; list them in the nightly report.
4. A quarantined test leaves the quarantine in one week: fixed, or removed with a reason in the session log.

## 6. Bots and network tests

These run a built development player, not the Editor. They find faults that unit tests do not find: a game that cannot
be finished, a client that sees other objects than the host, a memory leak over an hour.

- `tools/bot-run.sh [seed] [scenario]`: the player plays one full game alone with a bot that your game supplies. The
  report ends with `Result: PASS` or `Result: FAIL <reason>`. Run many seeds and scenarios, and read the failures
  together: a failure is a weak part of the bot or of the game.
- `tools/net-test.sh [seconds] [clients] [mode]`: one headless host and N headless clients on this machine. The checks:
  each player ends with exit code 0, no exception, each client connects, all players see all players, all players have
  the same seed, and in a long run (a soak) the memory grows less than a limit.
- The contract between the tools and the game (the arguments and the log lines) is at the top of each script. A sample
  driver is in `templates/unity/Assets/Scripts/Testing/CommandLineDriver.cs`.
- Run the network test at different frame rates for the host and the client (for example 30 and 300). In the tested
  game this found objects that broke at the load on one machine only.

Caution: a network test on one machine (127.0.0.1) does not test the real network. It does not show a firewall, the
privacy dialogs of the system, a machine with two network interfaces on one subnet, or players with different builds.
Before a test with other people, make a checklist and a list of these risks, and test with two real machines.

## 7. The build verification test and the last good build

In a studio, QA takes a new build only after a short build verification test (BVT). Here, the runner runs it after each
merge, in the main checkout:

1. Build the development player (`tools/batch.sh BuildTools.BuildDevMac`, exclusive).
2. `tools/bot-run.sh <seed> bvt`: the player starts, loads the level, plays about 60 s with the bot, and quits with exit
   code 0 and no exception. Your bot supplies a short scenario `bvt` for this.
3. `tools/net-test.sh 90 1 walk`: one host and one client connect and see each other.

When the merge checks and the BVT pass, the runner moves the tag `last-good` to the merge commit:

```bash
git tag -f last-good <merge commit>
```

A session that needs a base that works (for example a play-report fix, or a release candidate) starts from `last-good`.
When a merge breaks the game, `git diff last-good` shows the changes since the last build that worked.

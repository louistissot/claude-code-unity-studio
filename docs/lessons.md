# What went wrong, and the fix for each problem

These problems came during about three weeks with one game on one machine. Each one has the symptom, the cause, and the
fix that is now in the tools or the rules.

## 1. The disk fell to 7 GB

- **Symptom.** Builds and test runs failed or waited. The free disk fell from about 60 GB to 7 GB in a few days.
- **Cause.** Each specialist worktree ran its own Unity jobs. Unity wrote a new Library in each worktree (10 to 25 GB
  each), and each session kept its own logs, photos, and builds.
- **Fix.** One Unity runner with a queue ([unity-runner.md](unity-runner.md)); clone worktrees that only hold code
  ([disk-and-worktrees.md](disk-and-worktrees.md)); the disk guard of the lock; `tools/worktrees.sh` before each new
  session.

## 2. Worktrees without a Library

- **Symptom.** A new session cost about 25 GB of disk after its first Unity job.
- **Cause.** The app made a plain worktree for the session. A plain worktree has no Library (the Library is not in
  Git), so the first Unity import wrote a full Library.
- **Fix.** Make each worktree with `tools/new-worktree.sh` (an APFS clone that also clones the Library). If an app opens
  a session in its own folder, the brief tells the session to work in the clone with full paths.

## 3. Split zips that did not open

- **Symptom.** A player could not open the Mac app: "corrupted".
- **Cause.** A zip near the GitHub limit of 2 GiB was split into independent parts. The parts of the Mac app did not give
  an app that works after the extraction.
- **Fix.** One zip for each system, never parts; the highest compression; a size check that stops the release; a check
  that the Mac zip opens and has the executable; a checksum check after the upload
  ([release-rules.md](release-rules.md)).

## 4. The wrong reading of a play report

- **Symptom.** A point of a play report came back in the next report.
- **Cause.** The human wrote that the game name "has spaces" for the application. A session read this as "remove the
  spaces". The human meant "keep the spaces".
- **Fix.** Before any change, the session writes its reading of each point as a visible result, and asks one question
  for each point with more than one reading ([play-report-loop.md](play-report-loop.md)).

## 5. Flaky tests

- **Symptom.** Tests passed alone and failed in the full tier, or failed about one run in three.
- **Causes.** Static state from one test into the next (no domain reload); objects that a test left behind; code that
  added values in `Update` with the frame time of a fast batch run; real time in a test; a race with a scene that
  loads.
- **Fix.** The fixed frame time, the frame-rate matrix, the isolation guard, the history file, the random order with a
  seed, and the quarantine policy ([test-tiers.md](test-tiers.md)).

## 6. More problems with a short fix

| Problem | Fix |
|---|---|
| The pre-commit hook started Unity directly and went past the lock and the runner rule. | The hook goes through the lock; in a worktree that cannot run Unity, it runs the quick compile. Tools that start Unity refuse to run outside the lock. |
| A test run hung for 2.5 h while the machine slept. | A watchdog for each tier. Its `sleep` has no output, so that a pipe after the script does not wait for the full limit. |
| Two sessions found races in the lock: a slot with no owner file yet was freed; an exclusive build waited for a long time behind newer plain jobs. | A grace time of 30 s for a slot with no owner file; first come, first served with wait files; the exclusive job takes slot 1 first. |
| A job that waited for a slot went on after Ctrl+C. | A trap for INT and TERM that removes the wait file and the slots. |
| The app paused the messages of the coordinator after about ten messages. | The rules file in the notes folder is the channel that always works; each session reads it at each milestone. |
| The human did not see commands that a session wrote before a tool call. | Commands for the human go into the last message of the session. |
| All network tests ran on one machine and passed; a real test with two machines can fail for other reasons. A risk review before the first real test found that the game did not compare the build versions of the players. | A checklist and a risk list for the real test. The game now sends its build version when a player connects, and a player with another build stops with a clear message ([release-rules.md](release-rules.md), sections 1 and 3). |
| A first claim that the framework was new came from two short web searches. Similar projects exist. | Research before claims: more than one search method, and a list of sources ([roles.md](roles.md), section 4). |
| A client started before the host listened and never connected; the host waited for ever. | The network test starts the clients only after the host writes "host started". |
| Long sessions were summarized (compacted) many times and then used stale facts: old paths, old rules, old names. | Session rotation with a handoff file: after two summaries, at each milestone, or after two stale facts ([operating-model.md](operating-model.md)). |
| The app archives the idle side sessions of an archived session. An archive of an old coordinator can stop the owners that it started. | Never archive an old coordinator while its side sessions work; the new coordinator asks each session to report to it by message. |
| The human talked to many sessions, and decisions were in many places. | One daily contact (the coordinator), a daily summary with at most three decisions, and a forward of each decision that another session gets. |
| A replay folder of test images reached 14 GB. | Each session deletes its own large outputs; the clean-up order in [disk-and-worktrees.md](disk-and-worktrees.md). |

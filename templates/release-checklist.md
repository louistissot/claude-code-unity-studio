# Release checklist: <version> (<release tag>, commit <commit>)

A release starts as a release candidate. It goes to the players only when each line of this list passes and the human
says yes. Keep the previous good release on the release page, so that the players can go back to it.

## 1. The candidate

- [ ] The version number: <major.minor.patch> plus the commit, shown in the menu and in the log of the game.
- [ ] The commit is on the remote, and the work tree was clean (`tools/release.sh` checks this).
- [ ] No open bug with severity S1 or S2 and priority P1 (`bugs.md`).

## 2. The checks of the build

- [ ] The full tier passes on this commit (the result line of `TestResults/history.csv`).
- [ ] The build verification test: the player starts, loads the level, plays 60 s with the bot, and quits with no
      exception, on each system.
- [ ] The bots over <n> seeds and scenarios: <n> of <n> pass.
- [ ] The network test, also with different frame rates for the host and the client.
- [ ] The frame-time and memory budgets on each target machine (the benchmark result files).
- [ ] The game refuses a player with another build version, with a clear message.

## 3. The files

- [ ] One zip for each system, never parts, below the size limit (`tools/release.sh`).
- [ ] The checks before the upload pass: `unzip -t`, the Mac app opens, `SHA256SUMS.txt`.
- [ ] The checks after the upload pass: the size and the SHA-256 of each file on the release page.

## 4. For the players

- [ ] The release notes: what is new, what is fixed (with the numbers of the play reports and the bug IDs), the known
      problems, how to install, where the logs are.
- [ ] The focus list for the human (`templates/release-focus.md`).
- [ ] Old releases that do not work with this one are marked or deleted.

## 5. Sign-off

- [ ] The human says yes: <date and time, the words of the human>.

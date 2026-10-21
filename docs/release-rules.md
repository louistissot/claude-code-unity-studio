# The release rules

A release is the build that the human and the other players download. A bad release costs the time of each player, so
the release script checks the files before and after the upload.

## 1. The rules

1. **One zip for each system: one for Windows, one for Mac. Never split a zip into parts.** A Mac app in two parts did
   not open for a player ("corrupted"). One zip is also simpler to explain.
2. **The highest compression** (`zip -9`, and `ditto --zlibCompressionLevel 9` for the Mac app).
3. **The size limit.** GitHub takes a release file of less than 2 GiB. The script stops at `RELEASE_MAX_BYTES`. If a
   zip is too large, make the build smaller (textures, unused assets, debug files). Do not split it.
4. **A release is a commit.** The script stops when the work tree has changes in `Assets`, `Packages`, or
   `ProjectSettings`, and (for an upload) when the commit is not on the remote.
5. **Checks before the upload:** `unzip -t` of each zip; the Mac zip opens with `ditto` into a test folder and has the
   executable of the app; a file `SHA256SUMS.txt` with the checksum of each zip.
6. **Checks after the upload:** each file on the release page has the size of the local file; with
   `RELEASE_VERIFY_DOWNLOAD=1`, a download of each file has the SHA-256 of the local file.
7. **The human says yes** before a release goes to people outside the team, and before a public release.
8. **One build for all players.** Delete or mark old releases, so that nobody plays with an old zip. The game must
   compare the build version of each player when it connects, and refuse another version with a clear message.
9. **A focus list** goes with each release for the human ([play-report-loop.md](play-report-loop.md)).
10. **A release candidate first, from `last-good`.** Each release starts as a candidate from the tag `last-good`, with a version number (major.minor.patch plus
    the commit) in the menu and the log. It goes to the players only when `templates/release-checklist.md` passes
    and the human says yes. The release notes say what is new, what is fixed (with the numbers of the play reports
    and the bug IDs), and the known problems.
11. **A way back.** Keep the previous good release on the release page, so that the players can go back to it.

## 2. The script

```bash
tools/unity-lock.sh --exclusive tools/release.sh
```

```bash
tools/release.sh --skip-build --no-upload
```

The second command makes and checks the zips from players that are already built, with no Unity and no upload.

The release page says how to start the game, because the builds have no code signature:

- Windows: extract the zip (right-click, Extract All) to a normal folder, start the program; at "Windows protected your
  PC", click "More info", then "Run anyway".
- Mac: double-click the zip, right-click the app and select Open; if macOS refuses, use System Settings, Privacy and
  Security, "Open Anyway".

## 3. Before a test with other people

- Run the game on each kind of machine before the day (for example a benchmark mode that writes a result file).
- Make a checklist in the order of the test, with the action and the thing to look at for each step.
- List the risks that only real machines show: the firewall, the network profile (a public network blocks the LAN
  discovery), the privacy settings for the microphone and the local network, a second network interface of the host,
  the graphics API of the other system, the first start that compiles the shaders.
- Tell each player which folder has the logs, and to copy the logs before the next start of the game.

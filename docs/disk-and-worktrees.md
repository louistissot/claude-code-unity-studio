# The disk budget and the APFS clone worktrees

The disk is the first limit when many sessions work on one Unity project. Memory is the second. The tools keep both
under control: the clone worktrees, the single Unity runner, and the disk guard of the lock.

## 1. Where the disk goes

The numbers come from the tested game (a large city level, Git LFS for the art, about 40 GB for the main checkout with
its Library). Your numbers will be different. Measure them with the free disk (`df -h`), before and after.

| Item | Cost | Note |
|---|---|---|
| The main checkout, with its Library and the LFS files | 25 to 40 GB | One time. |
| A worktree that runs Unity | 10 to 25 GB more | Unity writes its own Library in each folder where it runs. |
| A plain `git worktree add` folder that runs Unity once | about 20 to 25 GB | It has no Library, so the first import writes a full one. |
| An APFS clone worktree that holds only code | almost 0 | It shares the blocks with the main checkout. Only changed files cost disk. |
| A level build, a light bake, a player build | 2 to 16 GB while it runs | The lock waits for 16 GB of free disk for an exclusive job. |
| Logs, test photos, replays, release zips | grows each day | Delete your own outputs. A folder of replay images reached 14 GB. |

Caution: do not use `du` to measure a clone. `du` counts the shared blocks of a clone in each copy. Only the free disk
of the volume shows the true cost.

## 2. The clone worktree

`tools/new-worktree.sh <area> [<base>]` does these steps:

1. `git worktree add --no-checkout -b <branch> <folder> <base>`: a new worktree with no files.
2. `cp -c` (an APFS clone) of each entry of the main checkout, also the Library, except `.git` and the folders of
   `CLONE_EXCLUDE` (Temp, Logs, Builds, TestResults).
3. `git reset --mixed`: the index of the new branch, with no file writes.
4. `git checkout` of only the tracked files that differ from the base.

The result: a worktree on its own branch, with a Library, at almost no cost. `tools/quick-compile.sh` works in it at
once, because the Library has the response files of the last compile.

Caution: the clone stays cheap only while Unity does not run in it. One Unity import or compile in the clone writes a
new Library. That is why only the runner worktrees run Unity ([unity-runner.md](unity-runner.md)).

Limits:

- APFS clones exist only on macOS (APFS volumes). On another file system, `cp -c` fails, and the script stops. A full
  copy (`ALLOW_FULL_COPY=1`) costs the full size. On Linux, a file system with reflinks (Btrfs, XFS) can give the same
  result with `cp --reflink`; the script does not do this now.
- The clone and the main checkout must be on the same volume.
- Do not make a clone while Unity writes the Library of the main checkout. The script refuses when Unity has the main
  checkout open.

## 3. Worktrees that an app makes

A tool or an app can make its own worktree for a new session, for example a plain `git worktree add` folder without a
Library. If such a session runs Unity, the first import writes a full Library (about 20 GB in the tested game). Rules:

- Start each session in a clone worktree from `tools/new-worktree.sh`.
- If the app opens a session in another folder, the brief says: "Work only in `<clone path>`, with full paths. Do not
  run Unity in the folder of the app."

## 4. The disk guard

- `tools/unity-lock.sh` waits until the disk has `DISK_MIN_GB_PLAIN` (default 8 GB) free for a plain job and
  `DISK_MIN_GB_EXCLUSIVE` (default 16 GB) for an exclusive job. It writes a message every 5 minutes while it waits.
- `tools/new-worktree.sh` refuses below `DISK_MIN_GB_CLONE` (default 8 GB).
- The coordinator runs `tools/worktrees.sh` before it starts a session, and after each long run.

## 5. Clean up

In this order, from the safest:

1. Your own `Logs`, `Temp`, `TestResults`, and `Builds` outputs that you do not need.
2. Old release zips (keep the newest release of each system).
3. Worktrees of finished sessions: `git worktree remove <path>`, then `git worktree prune`.
4. Old Git LFS objects that the remote also has: `git lfs prune`.
5. The Libraries of worktrees that will not run Unity again: delete the folder `Library` of that worktree (the next
   Unity run there writes it again).

Ask the human before you delete anything that is not your own output.

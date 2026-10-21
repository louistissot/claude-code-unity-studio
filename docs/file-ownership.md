# File ownership

Each file has one owner: one session, for the life of that session. Two sessions that change the same file at the same
time give merge conflicts, and a conflict in a Unity scene or prefab is difficult to solve.

## 1. The ownership table

The coordinator keeps this table in the rules file of the notes folder, and gives each brief the line of its session.
An example with generic areas:

| Session | Owns |
|---|---|
| World (owner) | The level builders and their data, the layout, the places, the props of the level, navigation |
| Art (owner) | Blender scripts and their data, models, textures, materials of the environment |
| Gameplay (owner) | Weapons, enemies and their AI, damage and health, movement, the difficulty of the fights |
| Mechanics (owner) | Missions, items, interaction, the HUD and the menus, the end of a game, the bots |
| Look, Sound, Performance and Network (specialists) | The files that the brief gives them, for the time of their need |
| Task sessions | Only the files of their job, for the time of the job |
| Runner | Tests, test tools, the build and release scripts, `run/<branch>` fixes |
| Coordinator | `CLAUDE.md`, `docs/decisions.md`, `docs/milestones.md`, the merge commits, the rules file |

With more than one team, a team also adds a claim on the board before it changes files ([multi-team.md](multi-team.md)).

## 2. Rules

1. A session changes only the files of its area.
2. A change outside its area must be small and have a comment. The session writes it in `cross-<area>.md` in the notes
   folder (the file, the change, the reason) and sends one short message to the owner.
3. The owner can change or remove that change later. The coordinator solves the merge conflicts.
4. Before a session starts, the coordinator checks that no active session owns the files of the new session.
5. A file that no area owns goes to the coordinator.

## 3. Generated files

Make the level, the meshes, the materials, and the textures with Editor code from data, with a fixed seed. Then the code
and the data are the source, and the generated files are an output.

- A specialist commits the source (the builder code, the data, the scripts, the new art files), not the outputs of a
  build: the generated scenes, the generated meshes and materials, the baked light, the navigation data, and the prefabs
  that a build only writes again with new object IDs.
- After the merge, the runner builds the outputs one time and commits them (or keeps them out of Git, when a build is
  fast enough).
- A builder writes a log with counts (objects, vertices, places without content). Read the counts after each change.

## 4. Files that nobody commits

Some Unity files change as a side effect of a batch job or a build, for example `ProjectSettings/ProjectSettings.asset`
after a player build, or a font asset that the text system fills at run time. List them in `CLAUDE.md` under "Never
commit", and in `RELEASE_RESTORE_FILES` of `sessions.conf`, so that the release script puts them back before it checks
the work tree.

## 5. Binary assets and locks

Git cannot merge binary files (textures, models, sounds): the second commit replaces the first. Studios lock these files
(an exclusive checkout). Here:

- Ownership by area prevents most overlaps.
- For a binary asset that a human or a session changes by hand, use a Git LFS lock: `git lfs lock <path>` before the
  change, `git lfs unlock <path>` after the merge. Git LFS locks need a server that supports them (GitHub does), and
  each client must respect them: they are weaker than the locks of a lock server.
- Generated binary files have no lock: the runner builds them again after the merge.
- Set the asset serialization of Unity to Force Text (Project Settings, Editor), so that scenes, prefabs, and assets
  are text files that Git can compare.

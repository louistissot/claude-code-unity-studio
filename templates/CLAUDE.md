# CLAUDE.md: {{GAME_NAME}}

<One or two sentences: what the game is, for whom, and the feel that it must have.>
Unity {{UNITY_VERSION}}, <render pipeline>, <input system>, <UI system>, <network library, if any>.

Read these files at the start of a session:

1. [docs/README.md](docs/README.md): the index of the documents of the game.
2. [docs/session-log.md](docs/session-log.md): what the last sessions did, and what is open.
3. [docs/decisions.md](docs/decisions.md): the decisions and the reasons.
4. The rules file and your brief in the shared notes folder (`NOTES_DIR` in `sessions.conf`).

## Originality and AI (read docs/ai-pitfalls.md of the template)

- The human is the author: the concept, the pillars, the art direction, the premise and the key voices, the feel, and
  each visible asset that defines the identity of the game. Sessions give options with a recommendation; the human
  decides.
- Do not copy the look and feel of an existing game. Rules and genres are free; the expression of another game is not.
- Each feature serves a pillar of `docs/pillars.md`. A feature without a pillar goes to the cut list.
- Text that a player reads gets a human editor. Check it against `docs/story-bible.md`.
- Record each AI-made asset in `docs/ai-record.md` (what, which tool, what the human changed), for the store disclosure.
- Phase: <concept / pre-production / production / release>. Do not start work of a later phase before its gate passes
  (`docs/milestones.md`).

## Rules for each session

- **Batch mode only.** Do not open the Unity Editor window, and do not click in it. Run Unity only in batch mode,
  through `tools/unity-lock.sh`. Only the runner session and the main checkout start Unity jobs
  (`docs/unity-runner.md` of the template).
- **Everything built with code.** Make the level, the meshes, the materials, and the textures with Editor code from
  data, with a fixed seed. Make 3D models with Blender scripts in batch mode. Do not build the level in Play mode. Do
  not edit a scene by hand.
- **Check the code.** After a change to C#, run `tools/quick-compile.sh`. Add tests for each new feature. Send the
  Unity jobs to the runner.
- **Commit and push** only when the human or your brief says so. Never merge into `<integration branch>`, and never
  push it.
- **Never commit** these files: <the files that a build or a test run changes as a side effect, for example
  `ProjectSettings/ProjectSettings.asset`>, and the outputs of a level build: <the generated scenes and folders>.
- **Own only your area.** Change only the files that your brief gives you. A change outside your area: small, with a
  comment, in `cross-<area>.md` in the notes folder.
- **Assets.** Use free assets (CC0 first). Record each file (name, source, size, licence) in
  `Assets/Art/ThirdParty/CREDITS.md`. Do not log in to accounts. Do not pay.
- **Quiet automatic runs.** Batch runs, headless players, and test runs make no sound.
- **Keep the memory low.** No log message in each frame, no new material or mesh in each frame.
- **Questions.** <Ask the human for decisions with a cost, a risk, or a change of scope. / In a long run: do not ask;
  decide, and record the decision and the reason in your report.>
- **Commands for the human** go into your last message, not into text before a tool call.
- **At the end of a session,** add an entry to `docs/session-log.md`, and give the commit or the branch at the start of
  your last message.

Option: **Language.** Write all text (chat, code comments, commit messages, docs) in ASD-STE100 Simplified Technical
English: approved words, one word for one concept, the active voice, simple tenses, no contractions, sentences of 20
words or less for an instruction and 25 words or less for a description. Keep the exact words of code, file names,
commands, log lines, and quotations.

## Quick commands

Run these commands from the project folder.

```bash
tools/quick-compile.sh
```

```bash
tools/unity-lock.sh tools/test-tier.sh quick
```

```bash
tools/unity-lock.sh tools/test-one.sh PlayMode "MyTests"
```

```bash
tools/unity-lock.sh --exclusive tools/batch.sh BuildTools.BuildDevMac
```

## Where things are

| Path | Contents |
|---|---|
| `Assets/Scripts/` | The runtime code (assembly `Game`). One folder for each system. |
| `Assets/Editor/` | The Editor code: the level builders, the build methods (assembly `Game.Editor`). |
| `Assets/Tests/EditMode/`, `Assets/Tests/PlayMode/` | The tests. |
| `Assets/Art/ThirdParty/` | Downloaded free assets, with `CREDITS.md`. |
| `tools/` | The shell tools. Each tool has its usage at its top. |
| `docs/` | The documents of the game. |

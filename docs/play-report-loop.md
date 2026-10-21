# The human play report loop

The tests find what a test can describe. The human finds what feels wrong. The loop gives each human report a number, a
written reading, a fix, and a check in the next release.

```
release + focus list ──> the human plays 10 minutes (and more) ──> numbered play report (+ report key folders)
        ^                                                                     │
        │                                                                     v
 the next release <── fixes + a document: point, cause, change, test <── the reading of each point (+ questions)
```

## 1. The focus list (with each release)

Each release for the human comes with a focus list for 10 minutes of play (`templates/release-focus.md`):

- the 3 to 8 changes of this release that the human can see, each with the place, the steps, and the expected result;
- the points of the last play report that this release fixes, with their numbers;
- one or two known problems, so that the human does not report them again.

Ten minutes is a limit that a busy human can keep. The human can play longer, but the focus list comes first.

## 2. The play report

- The human writes points, and each point gets a number (1, 2, 3, ...). The number stays the same in all later
  documents and messages.
- The report itself also gets a number or a date (for example "play report 25").
- The human can press the in-game report key (for example F8) at the moment of a problem. The key writes a folder with a
  screenshot, the build version, the scene, the camera position and direction, the game time, and the last log lines
  (`templates/unity/Assets/Scripts/Testing/ReportKey.cs`). The human writes the folder name next to the point.
- The human sends the player log of that game when the report has a crash, a freeze, or a frame-rate problem.

## 3. The reading (before any change)

The session that fixes the report first writes its reading of each point, with `templates/play-report.md`:

| No. | The words of the human | Our reading: what the human expects to see | Question |
|---|---|---|---|

- The reading repeats the point in the words of the session, as a result that a player can see.
- For each point with more than one reading, the session asks the human one short question, and waits for the answer
  before it changes that point. It can start the other points.
- A point that is a taste (a colour, a feel) gets a photo or a short video of the change, for the human to approve.

Why: in the tested game, the human wrote that the game name "has spaces" for the application. A session read this as a
request to remove the spaces, and the next release had the name without spaces. The human had to report it again. A
reading in one line and one question would have cost one minute.

## 4. The fix and its document

For each point, the fixer writes the cause that it found, the change, and the test (or the photo) that proves the
change. The document goes to `docs/` of the game (for example `docs/play-reports/report-25.md`), so that later sessions
find the reason of each change.

- A point that the session cannot reproduce gets "not reproduced", what was tried, and what data would help.
- A point that needs a decision of the human goes to the questions at the end.
- The runner runs the tests of the fixes first in its queue (the highest priority).

## 5. Close the loop

The next release has the fixed points on its focus list, with their numbers. The human checks them first. A point that
is not fixed for the human stays open with its number.

## 6. Playtests with new players

The human knows the game too well to see what a new player does not understand. So, before each milestone, run a
playtest with people who did not make the game (`templates/playtest-plan.md`):

1. Write two to four objectives: what you want to learn.
2. Select the players, the build, the machines, and the time.
3. Observe: think-aloud, or record the screen and the voice. Do not help, except when a player is stuck.
4. Record only the telemetry events that answer the objectives.
5. Ask the same short questions after each game.
6. Turn each result into a backlog item or a bug, with its number.

A play report of the human and a playtest give different data. Use both.

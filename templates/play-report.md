# Play report <number> (<date>)

The human played <the build: release tag or commit> <alone / with N players> for about <minutes> minutes, and sent
<count> points. The report key folders: <names, or "none">. The player log: <path, or "none">.

## 1. The reading of each point (before any change)

Write this part first. Send the questions to the human before you change a point that has a question.

| No. | The words of the human | Our reading: what the human expects to see | Question | Answer |
|---|---|---|---|---|
| 1 | "<exact words>" | <a visible result, in our words> | <one short question, or "none"> | <the answer of the human> |
| 2 | | | | |

## 2. The fixes

| No. | Cause | Change | Proof (test or photo) | State |
|---|---|---|---|---|
| 1 | <the cause that we found, with the file and the numbers> | <the change, with the file> | `<TestClass.Test>` or `<photo file>` | fixed / open / not reproduced / waits for an answer |

For a point that is not reproduced: what we tried, and what data would help.

## 3. For the next release

The points for the focus list of the next release (`templates/release-focus.md`): <numbers>.

## 4. Questions for the human

1. <one decision, with the options and our recommendation>

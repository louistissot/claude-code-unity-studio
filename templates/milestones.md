# Milestones and backlog: <game name>

The coordinator (the producer) keeps this file. The human signs off each milestone. Write the exit criteria before the
work starts, so that everybody uses the same definition.

## 1. The milestones

| Milestone | Date | Exit criteria | Proof | Sign-off |
|---|---|---|---|---|
| Concept gate | <date> | <the originality gate passed (10 of 10 accepted); comparables with a visible difference; the key risks named with a prototype plan; the pillars written> | `concept-challenge.md`, `comparables.md`, `prototype-plan.md` | <the human, date> |
| Prototype | <date> | <the core loop is playable; the main design risk has an answer> | <a playtest note> | <the human, date> |
| Pre-production gate (vertical slice) | <date> | <each key risk has a result; one part at near-final quality; the budgets pass on the target machines; three or more new players played it; the story bible and the script outline exist> | <photos, benchmark result, playtest results> | |
| Alpha (feature complete) | <date> | <each planned feature is in and playable from start to end; the cut list is decided> | <the full tier, a bot run> | |
| Beta (content complete) | <date> | <all content is in; no open crash or blocker; the budgets pass on the target machines> | <bug list, benchmark on each machine> | |
| Release candidate | <date> | <the candidate passes the release checklist> | `templates/release-checklist.md` | |
| Release | <date> | <the human approves the candidate> | the release page | |

Feature freeze: <date> (after alpha, no new features). Content lock: <date> (after beta, only fixes).
After a freeze, the coordinator merges only fixes, unless the human says yes to an exception.

## 2. The backlog

The order of this table is the order of the work. Each line has an owner and an estimate. At the end, write the actual
time: the difference makes the next estimates better.

| No. | Item | Pillar | Milestone | Owner | Estimate (h) | Actual (h) | State |
|---|---|---|---|---|---|---|---|
| 1 | <item> | <P1> | <alpha> | <area> | <8> | | <planned / in work / review / merged / cut> |

## 3. The cut list

Cut in this order when a milestone is at risk. The human approves each cut.

| No. | Item | What the player loses | What we gain (hours) |
|---|---|---|---|
| 1 | <item> | <loss> | <hours> |

## 4. The status at each checkpoint

- <date>: <each milestone: green, amber, or red, with the reason and the next action>

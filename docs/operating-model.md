# The operating model: the daily rhythm and session rotation

This document gives the day of the team and the rule that keeps long sessions fresh. It comes with the roles
([roles.md](roles.md)), the merge rule ([merge-rule.md](merge-rule.md)), and the studio hygiene
([studio-model.md](studio-model.md)).

## 1. Who talks to whom

- The human (the creative director and daily playtester) talks to the **coordinator** every day, and to no other
  session for the daily work.
- The coordinator (the producer) splits the work, tells the human what the other sessions need, and asks the human for
  each decision. The other sessions get their work from the coordinator.
- If the human talks to another session directly, that session sends the decision to the coordinator at once. Then
  the coordinator (and the board, with more than one team) stays the source of truth.

## 2. The daily rhythm

1. **When the human starts: the summary.** The coordinator gives one short summary (`templates/daily-summary.md`):
   - what changed since the last summary: merges, releases, results;
   - **at most three decisions** for the human, each with a recommendation;
   - a **10-minute focus list** for the playtest of the newest build: what changed, and three to five things to check.
2. **The human plays.** The human marks problems with the in-game report key and sends the coordinator a few lines.
3. **The coordinator splits** the points by owner, and briefs each owner with the milestone, an estimate, and the exact
   words of the human.
4. **The runner tests** the fixes, and reviews each diff. The coordinator asks the human before each merge, merges, and
   pushes the integration branch.
5. **At a fixed time each day: the bug triage.** The coordinator and the runner give each new bug a severity (S1 to S4)
   and a priority (P1 to P4), update the backlog of the milestones file, and tell the human the P1 and P2 list in three
   lines.
6. **The board** (with more than one team) gets a log line for each event.

### The triage reminder

The coordinator sets a reminder for the triage time in its own session. In Claude Code, a session can schedule a
prompt that repeats (the CronCreate tool), for example with the cron expression `2 18 * * *` for 18:02 each day.

Caution: in the tested setup this job belonged to the session: it ended with that session, and it ended after 7 days.
So a new coordinator sets it again at its start, and renews it every 7 days until the end of the milestone.

## 3. Session rotation

A long session loses details when its conversation is summarized (compacted), and then it can use stale facts: old
paths, old rules, old numbers. Rotation replaces such a session with a fresh one that starts from a handoff file.

### When to rotate

| Session | Rotate when |
|---|---|
| Task session | It does not rotate: it ends at its merge. The coordinator archives it after the merge, with the yes of the human. |
| Owners and the runner | Its conversation was summarized two times; or a milestone ends; or it used stale facts two times. |
| Coordinator | The same rule as the owners. |

### How to rotate

1. **The handoff file.** The old session writes `handoff-<role>.md` in the notes folder (`templates/handoff.md`): the
   state, the open items, its files and branches, the rules that it follows, the facts that are easy to get wrong, and
   the steps for the takeover.
2. **The fresh session.** The coordinator starts a new session with the brief template of the role and the handoff
   file. The new session reads the handoff file first. (For a new coordinator, the old coordinator or the human starts
   it.)
3. **The new id.** The coordinator tells each active session the id of the new session. With more than one team, the
   board shows it.
4. **The reports.** In the Claude desktop app, the end-of-turn notes of a side session go to the session that started
   it. After a rotation of the coordinator, the owners were started by the old coordinator, so the new coordinator asks
   each session to report to it by message.
5. **The old session stays idle** until the new session works. Then the human can archive it, with the caution below.

> **Warning:** never archive an old coordinator while the sessions that it started still work. When the app archives a
> session, it also archives the idle side sessions of that session. If the owners are side sessions of the old
> coordinator, an archive of the old coordinator stops the team.

### The memory of Claude Code

At each rotation of the coordinator, the new coordinator cleans up the memory index of the project: one line for each
memory, and no stale facts. A stale memory brings old facts into each new session.

## 4. Why

- One contact for the human keeps the decisions in one place and saves the time of the human.
- Three decisions at most, each with a recommendation, keeps the human in control without long reading.
- A fixed triage time keeps the bug list short and the priorities current.
- A fresh session from a good handoff file makes fewer mistakes than a long session with an old, summarized context.

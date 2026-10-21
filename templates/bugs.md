# Bug list: <game name>

The runner (the build and QA engineer) keeps this file in the notes folder. Severity is the effect of the bug. Priority is the order of the fix:
a decision of the coordinator (with the human for a release). They are two different fields.

- **Severity:** S1 crash or data loss; S2 blocker (the game cannot go on); S3 major (a feature does not work, a
  workaround exists); S4 minor (cosmetic, text).
- **Priority:** P1 fix now (before the next build for the human); P2 fix in this milestone; P3 fix when there is time;
  P4 do not fix (with the reason).
- **Proof:** code (the path and the trigger were read), test (a test fails; give its name), run (a bot, a network test,
  or a play session shows it). Give your confidence when the proof is only code.
- **State:** OPEN, FIXED in <commit> (by the owner), RETEST PASS or RETEST FAIL on <commit> (by QA), WONTFIX (with the
  reason).
- **Triage:** each day at <time>, QA and the coordinator give each new bug a severity, a priority, and an owner. A fix
  of an S1 or S2 bug gets a regression test.

| ID | Severity | Priority | Area | Short text | Proof | Owner | State |
|---|---|---|---|---|---|---|---|
| B1 | S2 | P1 | <area> | <what the player sees> | <test `Class.Test` FAILS> | <area> | OPEN |

## Details

### B1 (S2, P1, <area>): <short text>

- Steps: <1, 2, 3>
- Expected: <result>. Actual: <result>.
- Build: <commit or release tag>. Report key folder: <name, or "none">.
- Cause (if known): <file and line>.

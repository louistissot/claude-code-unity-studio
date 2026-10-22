# Changes

## v0.1.1 (not released yet)

- `setup.sh`: the default template is now `com.unity.template.urp-blank` (`UNITY_TEMPLATE` in `sessions.conf`). In
  v0.1.0, `setup.sh` stopped at once with "Could not resolve default template", because the Unity CLI has no default
  template when the Editor has no 3D template (Unity 6000.6 has only the URP blank and the 2D templates).
- `setup.sh`: when the Unity CLI is not there or fails, it falls back to the Editor with `-createProject`. Before the
  CLI runs, it warns when the Editor does not have the template, and it lists the templates that the Editor has.
- README: the status now lists the checks with Unity (setup, the quick tier, the compile check, a development build).
- The method, after a first test with a real game idea (16 findings):
  - Phase 0 has a path for a person with one idea: three variants (smaller, stranger, more personal) and the "why".
  - The concept document has fields for online or offline play, the players in one world, and the business model. It
    holds only the words of the human; suggestions of a session go into a separate `concept-notes.md`.
  - The originality gate has three verdicts (accepted, refused, no answer yet, with a pre-check for candidates), a
    column for the question, and twelve parts: part 5 asks for the twist first; part 4 asks for the theme in one phrase
    first; part 8 asks for a blind test when the hook is an AI feature; part 10 is split into AI in production (10a)
    and live AI in the play (10b: limits, red-team test, cost for each player, brand names); a new part 11 checks the
    players and the money.
  - The research of the challenger is in a separate section of the record, for after the answers of the human (no
    anchor). The coordinator researches the comparables first; the challenger adds only what is not there yet.
  - The challenger brief works for a session and for a subagent, judges only the words of the human, asks for proof of
    what the human played, and uses one file name for the record.
  - The prototype plan has the kinds of risk "cost to run" and "legal", with examples of a blind test and a red-team
    test. The guide and the pitfalls add a red-team prototype for each live AI feature in pre-production.

## v0.1.0 (21 October 2026)

- The first public version.

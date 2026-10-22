# The guide: from the first idea to the release

This is the order of the work, from the first idea to the release and after it. Each phase has a goal, the work of the
human, the work of the sessions, the documents, and a gate. **Do not start the next phase before its gate passes.** A
team of many sessions can build a game very fast; that only helps when the game is worth the work.

```
0 Spark ─► 1 Concept ─► [concept gate] ─► 2 Pre-production ─► [pre-production gate] ─► 3 Production
          (human first,                    (risks, prototypes,                          (alpha, beta)
           challenger)                      story, vertical slice)                            │
                                                                                              ▼
                                      6 After the release ◄── 5 Release ◄── 4 Release candidate and polish
```

The phases follow common studio practice: concept, pre-production, production with alpha and beta, release, and live
work after it ([studio-model.md](studio-model.md)). The names and the exit criteria differ between studios; write yours
down in `docs/milestones.md` before you start.

## Who does what

The human is the author. The human has the first ideas, makes each decision of taste, and signs each gate. The
sessions research, challenge, build, test, and report. Research shows why this order matters:

- People who ideate with an LLM give ideas that are more similar to each other at the group level, and they feel less
  responsible for their ideas ([Anderson, Shah, Kreminski, C&C 2024](https://dl.acm.org/doi/10.1145/3635636.3656204)).
- LLM help can raise creativity during the task, and lower it later when people work without help
  ([Kumar et al., CHI 2025](https://arxiv.org/abs/2410.03703)).

So in the early phases, the AI is a **critic and a researcher**, not the author ([concept-phase.md](concept-phase.md)).
See also what to avoid: [ai-pitfalls.md](ai-pitfalls.md).

## Phase 0: the spark (the human alone)

- **Goal:** your own first ideas, before any AI output can steer them.
- **Human:** write 10 or more ideas on paper in 30 minutes: places, people, experiences, systems, and constraints that
  you know and care about. Then write why each one matters to you. Keep the list. If you already have one idea, write
  three variants of it (smaller, stranger, more personal) and the "why" of each ([concept-phase.md](concept-phase.md),
  step 1).
- **Sessions:** none.
- **Output:** the idea list, in your own words.

## Phase 1: concept (1 to 3 weeks)

- **Goal:** one concept that is clear, original, and possible, with its largest risks named.
- **Human:** select up to three ideas from the list and write a one-page concept for each (`templates/concept-doc.md`).
  Answer the questions of the challenger. Play the nearest published games. Make a paper or toy prototype of the core
  verb.
- **Sessions:** the **coordinator** (research of comparables and of the market) and a **challenger** (a session or a
  subagent; `templates/briefs/challenger.md`) that attacks each concept with the originality gate
  (`templates/concept-challenge.md`). No owner sessions yet. No production code.
- **Output:** the concept document, the comparables table (`templates/comparables.md`), the vision and pillars
  (`templates/pillars.md`), the key risks as yes-or-no questions (`templates/prototype-plan.md`), and the challenge
  record.
- **The concept gate:** each question of the originality gate has an answer that the challenger accepts; the human
  writes the answers, not the AI; the top three or four risks are named, each with a prototype; the human signs it.
  Method: [concept-phase.md](concept-phase.md).

## Phase 2: pre-production (3 to 8 weeks for a small game)

- **Goal:** prove the risky parts, fix the look, the story, and the plan, and make one short part of the game at
  near-final quality.
- **Human:** play each prototype; decide the art direction from references that you select; write the premise, the
  theme, and the voice of the key characters ([narrative.md](narrative.md)); approve the scope and the cut list.
- **Sessions:** the coordinator, the **runner** (set up the Unity project with `setup.sh`, the tests, the builds), and
  one task session for each key-risk prototype. Owner sessions start near the end, for the vertical slice.
- **Live AI in the game:** when the game runs an AI while it plays (characters, rulers, text, voices), pre-production
  also has a red-team prototype (players try to break the AI), the guardrails that a human writes, and a cost sheet for
  each player from a real log ([ai-pitfalls.md](ai-pitfalls.md)).
- **Output:** a result for each key risk (abandon, change, or go); the story bible and the script outline
  (`templates/story-bible.md`, `templates/script-outline.md`); one-page designs for the main features
  (`templates/feature-onepager.md`); the milestone plan, the backlog, and the cut list (`templates/milestones.md`); the
  vertical slice.
- **The pre-production gate:** each key risk has a result; the vertical slice runs at the frame-time budget on the
  target machines; three or more people who did not make the game played it (`templates/playtest-plan.md`) and the
  core loop held them; the human signs it.

## Phase 3: production

- **Goal:** all features (alpha), then all content (beta), with the quality of the vertical slice.
- **Human:** the daily summary and the daily playtest ([operating-model.md](operating-model.md)); a playtest with new
  players before each milestone; the yes for each merge.
- **Sessions:** the full team ([roles.md](roles.md)): coordinator, runner, owners, specialists on demand, task
  sessions. All the rules of this template apply: [merge-rule.md](merge-rule.md), [test-tiers.md](test-tiers.md),
  [unity-runner.md](unity-runner.md).
- **Gates:** alpha (feature complete) and beta (content complete, content lock), with the exit criteria in
  `docs/milestones.md`.

## Phase 4: release candidate and polish

- **Goal:** a stable, honest build.
- **Work:** only fixes; the bug triage each day; release candidates from `last-good` (`templates/release-checklist.md`);
  the store page and the trailer from real game footage; the AI disclosure of your store (for example Steam asks
  about pre-generated and live-generated AI content).
- **Gate:** the release checklist passes and the human says yes.

## Phase 5: release

- One zip for each system, the checks before and after the upload ([release-rules.md](release-rules.md)), release
  notes, and the previous good release kept as a way back.

## Phase 6: after the release

- A retrospective (`templates/retrospective.md`) and a short postmortem that you will read before the next project.
- Fixes from the reports of the players, with the same play-report loop ([play-report-loop.md](play-report-loop.md)).

## When to stop or change

A gate can fail. That is a result, not a loss. When a key risk fails, change the concept or stop it; when the
originality gate fails, go back to phase 0 with what you learned. A project that skips a failed gate usually pays for it
later in production, where each change costs the most.

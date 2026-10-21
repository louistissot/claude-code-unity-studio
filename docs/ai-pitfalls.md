# What to avoid: the pitfalls of AI in game development

AI sessions make it cheap to build a game. They also make it cheap to build a game that nobody needs. This document
lists the pitfalls that players, developers, and researchers report, and the countermeasure for each one in this
template. The sources are at the end.

## 1. The context (October 2026)

- In the GDC 2026 State of the Game Industry survey (more than 2,300 professionals), 52 % said that generative AI has a
  negative effect on the industry (30 % one year before, 18 % two years before), and 7 % a positive effect. 36 % use it
  in their work, most for research and idea work ("research or brainstorming", 81 %) and code help (47 %). In game design and narrative, 63 %
  said that the effect is negative.
- At the Steam Next Fest of October 2026 (about 8,200 demos), players and press complained about a flood of AI-made
  demos: clones of popular games and "clones of clones", builds without quality control, repeated simulator genres, and
  store art and text with little sign of human work. Players asked Valve for filters.
- In the AI game development community on Reddit, the human of the tested project saw the same complaint: people are
  tired of clones of published games made with Claude, and of AI designs without human input or originality.

A game made with AI sessions must therefore show human intent in each part that a player sees.

## 2. The pitfalls and the countermeasures

| No. | Pitfall | What you see | Why it hurts | Countermeasure in this template |
|---|---|---|---|---|
| 1 | **The clone** | "Game X, but with ..."; the same loop, the same look, the same screenshots as a popular game | Players skip it; the store is full of them. Copying the look and feel (not only the rules) can also infringe copyright: in *Tetris Holding v. Xio* (2012) the court protected the visual expression of Tetris, while game rules stay free. | The originality gate before any production ([concept-phase.md](concept-phase.md), `templates/concept-challenge.md`); the comparables table with the visible difference in the first five minutes. |
| 2 | **The average idea** | Ideas that many people and models would give: the first idea for a theme | LLM help makes the ideas of a group more similar to each other, and later independent creativity can drop. | Phase 0: the human writes the first ideas alone; the AI is a critic in the concept phase, not the author; the "first ideas" test. |
| 3 | **Taste given away** | Art, music, characters, and texts that nobody chose: the first output went in | The backlash of players is strongest for what they see and hear: key art, cutscenes, store pages. | The human selects the references and approves each visible asset; the pillars and the art direction filter each choice; see section 3. |
| 4 | **The half-built game** | A build that looks complete in a trailer and fails in play | Players leave in the first minutes; reviews stay low. | The test tiers, the bots, the build verification test, playtests with new players, the gates ([test-tiers.md](test-tiers.md), [guide.md](guide.md)). |
| 5 | **Scope without end** | Many features, none of them finished; agents add features because it is cheap | The core loop never gets polish; the content never fits the features. | Pillars as a filter, the milestones with a feature freeze and a content lock, the cut list ([studio-model.md](studio-model.md)). |
| 6 | **Code that grows without design** | Duplicated code, quick patches, systems that do the same thing in two ways | GitClear reports more copy-paste and less moved (refactored) code since AI assistants spread. Later changes cost more. | File ownership, one-page designs, the review before each merge, time for refactors in the backlog ([merge-rule.md](merge-rule.md)). |
| 7 | **Generic text** | Text that sounds like every other AI text; clichés; no voice | Players notice it at once; it breaks the world. | The human writes the premise, the theme, and the key voices; the AI edits and checks against the story bible ([narrative.md](narrative.md)). |
| 8 | **Hidden AI use** | No disclosure, or a wrong one | Stores ask for it (Steam: pre-generated and live-generated content), and players report it. | Record each AI-made asset; disclose it honestly in the store form. |
| 9 | **Work that nobody owns** | Assets and texts made only by a model | In the United States, the Copyright Office (January 2025) says that material made only by AI, also from detailed prompts, has no copyright protection; the human parts do. | Keep a record of the human contribution to each asset (selection, change, composition); prefer human-made or human-changed assets for the identity of the game. |
| 10 | **Claims without proof** | "The first", "the best", "realistic" from one short search | Wrong claims cost trust. | Research before claims, with more than one method and a list of sources ([roles.md](roles.md)). |
| 11 | **Third-party assets without a licence** | Downloads with unclear rights; assets that copy a protected style or character | Takedowns, store removal. | Free assets with a clear licence (CC0 first), a credits file for each file. |

## 3. Where the human must decide

The human makes these decisions. A session gives options and a recommendation, and then waits:

1. The concept, the hook, and the pillars.
2. The art direction: the reference images, the palette, the shapes, the look of the main characters.
3. The premise, the theme, the main characters, and the ending.
4. The feel: the speed, the weight, the difficulty, the sound of the main actions.
5. Each visible asset that defines the identity of the game: the logo, the key art, the capsule, the trailer.
6. The scope: each feature in, each cut.

## 4. A short test before each release

Answer each question with yes or no. A "no" stops the release until it is fixed.

1. Can you name the human decision behind each thing that a player sees in the first ten minutes?
2. Is the difference from the nearest three games visible in a screenshot or in the first five minutes?
3. Did three or more people who did not make the game play this build, and did you change the game after it?
4. Is each AI-made asset in the record, and is the store disclosure correct?
5. Does each text that a player reads have a human editor?

## 5. Sources

Read on 21 October 2026.

- [GDC 2026 State of the Game Industry](https://gdconf.com/article/gdc-2026-state-of-the-game-industry-reveals-impact-of-layoffs-generative-ai-and-more/)
- [Steam Next Fest under fire as demo festival drowns in a flood of "AI slop" (Time Extension, October 2026)](https://www.timeextension.com/news/2026/10/thin-end-of-the-wedge-steam-next-fest-under-fire-as-demo-festival-drowns-in-a-flood-of-ai-slop)
- [Homogenization Effects of Large Language Models on Human Creative Ideation (Anderson, Shah, Kreminski, C&C 2024)](https://dl.acm.org/doi/10.1145/3635636.3656204)
- [Human Creativity in the Age of LLMs (Kumar et al., CHI 2025)](https://arxiv.org/abs/2410.03703)
- [Homogenizing effect of LLMs on creative diversity (2025)](https://www.sciencedirect.com/science/article/pii/S294988212500091X)
- [Tetris Holding, LLC v. Xio Interactive, Inc. (2012)](https://en.wikipedia.org/wiki/Tetris_Holding,_LLC_v._Xio_Interactive,_Inc.)
- [US Copyright Office report on the copyrightability of AI works (January 2025), a summary](https://www.jenner.com/en/news-insights/publications/client-alert-us-copyright-office-issues-report-on-copyrightability-of-works-incorporating-ai-generated-material)
- [Valve: new rules for AI content on Steam (GeekWire, 2024)](https://www.geekwire.com/2024/valve-software-reveals-new-rules-for-ai-powered-game-development-on-steam/)
- [GitClear: AI Copilot code quality (a summary of the 2025 report)](https://blog.robbowley.net/2025/02/17/gitclears-latest-report-indicates-genai-is-having-a-negative-impact-on-code-quality/)

This is not legal advice. Check the rules of your country and of your store.

# The concept phase: from your ideas to one concept that is worth the work

The concept phase decides what the game is. It is the cheapest phase to change and the most expensive one to skip. Its
result is one concept that passes the **originality gate** and the **concept gate** ([guide.md](guide.md)).

## 1. The rules of this phase

1. **The human ideates first, alone.** Write your ideas before you read any AI output about them. LLM help makes the
   ideas of a group more similar, and it can lower later independent creativity ([ai-pitfalls.md](ai-pitfalls.md)).
2. **The AI is a critic and a researcher here, not the author.** It finds the nearest published games, names the
   clichés, asks hard questions, and checks the scope. It does not write the concept for you.
3. **Decisions on paper.** Each answer to the gate is in your words, in the concept documents.
4. **No production yet.** No owner sessions, no Unity project beyond a toy prototype, no store page.

## 2. The steps

### Step 1: the spark list (phase 0)

Write 10 or more ideas in 30 minutes, without AI. Good sources are your own life and knowledge: a place that you know
well, a job, a hobby, a fear, a system that you understand (a market, a machine, a sport, an ecosystem), a story from
your family, a question that you cannot answer. For each idea, write one line on why it matters to you.

**If you already have one idea,** do not throw it away, and do not skip this step. Write three variants of your own
idea, in your own words: a **smaller** one (one system, one place, one player), a **stranger** one (change the verb or
the point of view), and a **more personal** one (put in a place, a job, or an experience of your own). For each
variant, write why it matters to you. Then continue with the variant that you like most, or with the first idea.

### Step 2: past the first ideas

The first ideas for a theme are the ones that everybody has. Advice for game jams says the same: your first five ideas
are probably the ideas of many other people. For each idea on your list, write the five most obvious games about it.
Then change your idea until it is none of them. Methods that help:

- **A constraint:** one button, no combat, one room, ten minutes, no text, play as the opposite side.
- **A different verb:** what if the player does not shoot, build, or collect, but listens, repairs, hides, trades, or
  persuades?
- **A different point of view:** the enemy, the shopkeeper, the city, the weather, the person who cleans up after the
  hero.
- **A real system:** take the rules of a real system (an engine, a market, a body, an ecosystem) and make them the
  rules of play.
- **A collision:** two things that you know well and that nobody puts together.

### Step 3: up to three one-page concepts

Select up to three ideas and write a one-page concept for each (`templates/concept-doc.md`): the game in one sentence,
the player fantasy, the experience goals, the core verb and the core loop, the hook, your personal angle, the
comparables, the players and the business model, the scope, and the largest risks.

The concept document holds **only your words**. A session that helps you (for example the coordinator that puts your
notes into the template) leaves the fields that you did not answer empty, and writes its own suggestions into a
separate file (`concept-notes.md`). Suggestions in the concept document anchor you and the challenger.

Use the MDA view (mechanics, dynamics, aesthetics) for the experience goals: designers build from the mechanics up, but
players meet the game from the aesthetics down. So first write what the player must feel (for example challenge,
discovery, fellowship, expression), then the dynamics that make that emotion, then the mechanics.

### Step 4: the comparables

The coordinator researches first, before the challenge. It finds the nearest published games for each concept (`templates/comparables.md`): at least five, with
what each one does, how players react to it (reviews, numbers when the store shows them), and what you take from it.
Play the nearest two or three yourself. The key column is **the difference that a player sees**: in a screenshot, in
the first five minutes, in one sentence.

### Step 5: the challenge

Start a **challenger** (`templates/briefs/challenger.md`): a separate session, or a subagent with a fresh context;
the brief is the same. Its only job is to attack the concept with the questions of `templates/concept-challenge.md`,
and to judge each answer with a reason. It does not propose the answers. It reads the comparables of the coordinator
and adds only what is not there yet. A devil's advocate (a person whose job is to challenge the common view) can lead to
better decisions, and an AI can take that role, because a person often finds it hard to argue against a friend.

The challenge has twelve parts: the sentence, the nearest games, the visible difference, the first ideas, the
subtraction test (with the twist that you name), the personal angle, the core verb, the hook, the scope, AI in
production, live AI in the play, and players and money. Each part gets one of three verdicts: **accepted**, **refused**
(a direct answer that fails), or **no answer yet**. A refused part goes back to you.

Write your own lists of the nearest games and of the obvious games before you read the lists of the challenger: its
research is in a separate section of the record, for after your answers. The challenger cannot see what you played or
watched; keep notes as the proof.

### Step 6: the key risks and the prototypes

Write the three or four risks that can stop the game, each as a yes-or-no question (`templates/prototype-plan.md`), for
example "Is the core verb fun for ten minutes without art?" or "Can two players on different networks join in under
one minute?". Plan the cheapest prototype that answers each question: a paper prototype, a toy in an empty scene, a
video of a similar game, a spreadsheet. The result of each prototype is one of three: **abandon**, **change**, or
**go**. Do not start with the gameplay prototype when the largest risk is somewhere else.

Look at all kinds of risk: fun, technology, market, production, content, **cost to run** (servers, AI calls for each
player), and **legal** (brand names, licences, the rules of the stores). Two cases need a prototype each:

- **The hook is an AI feature** (for example "the rulers are real AI models"): a blind test. Players play with the AI
  and with a scripted version, in an order that they do not know, and say which one they prefer and why.
- **The game runs an AI while it plays** (characters, rulers, text, voices): a red-team test. Players try to break the
  AI (to make it say what it must not say, or give what it must not give), and you measure the cost of the AI for each
  player from a real log.

### Step 7: the concept gate

The concept passes when:

1. each part of the challenge is "accepted";
2. the human wrote the answers, not the AI;
3. the comparables show a difference that a player sees;
4. the key risks are named, each with a prototype plan;
5. the vision and pillars page is written (`templates/pillars.md`);
6. the human signs the gate in `docs/milestones.md`.

## 3. If you use AI to generate ideas anyway

Sometimes you want many variations, for example names, small events, or item ideas. Then:

- give the model your constraints, your pillars, and your list of first ideas to avoid;
- ask for many variations, and change the persona or the point of view between rounds (a study suggests that diverse
  AI personas reduce the effect that all ideas become similar);
- treat the output as raw material: select, combine, and change it yourself; never take the first output as it is;
- record which ideas came from the AI, so that you know where the human parts are.

## 4. Sources

Read on 21 October 2026.

- [MDA: A Formal Approach to Game Design and Game Research (Hunicke, LeBlanc, Zubek, 2004)](https://users.cs.northwestern.edu/~hunicke/MDA.pdf)
- [Game Design Workshop, a playcentric approach (Tracy Fullerton), publisher excerpt](https://gamedeveloper.com/design/book-excerpt-game-design-workshop)
- [Coming up with ideas for a game jam game (Game Developer)](https://www.gamedeveloper.com/design/coming-up-with-ideas-for-a-game-jam-game)
- ["Key Risks" based game pre-production](https://gamemakers.beehiiv.com/p/key-risks-based-game-preproduction)
- [Enacting constructive conflicts with AI agents (2026)](https://arxiv.org/pdf/2608.04166)
- [Diverse AI personas can mitigate the homogenization effect in human-AI collaborative ideation](https://arxiv.org/pdf/2504.13868)
- [Homogenization Effects of Large Language Models on Human Creative Ideation (C&C 2024)](https://dl.acm.org/doi/10.1145/3635636.3656204)
- [Human Creativity in the Age of LLMs (CHI 2025)](https://arxiv.org/abs/2410.03703)

# The shared board of the teams

`board.html` is a page for the Claude artifact runtime: a live board that all teams of one game read, and that each
team writes in its own space. The method is in [docs/multi-team.md](../../docs/multi-team.md).

Caution: the board works only as a Claude artifact with the `db` and `user` capabilities. Open in a normal browser, it
shows the empty layout and the text "Open this page in Claude to see the live data". If your teams do not use Claude
artifacts, use the GitHub form of the board (docs/multi-team.md, section 5).

## 1. Publish the board (the owner of the board, one time)

Ask a Claude Code session to publish `templates/board/board.html` as an artifact with these capabilities:

```json
{
  "db": {
    "rules": [
      { "path": "", "read": "view", "write": "owner" },
      { "path": "teams", "read": "view", "write": "owner" },
      { "path": "teams/{self}", "write": "interact" },
      { "path": "data/users", "read": "view", "write": "owner" },
      { "path": "data/users/{self}", "write": "interact" },
      { "path": "claims", "read": "view", "write": "interact" },
      { "path": "messages", "read": "view", "write": "interact" }
    ]
  },
  "user": {}
}
```

The rules give: each person with access reads all; only the owner writes the root documents (`board/meta`); each team
writes only its own entry in `teams` and its own space under `data/users/<its id>`; each team can add claims and
messages.

## 2. Set the facts of the band (the owner)

Write the document `board/meta` (for example with the ArtifactData tool):

```json
{
  "name": "<game name>",
  "repo": "<owner>/<repository>",
  "dev": "dev",
  "freeze": "YYYY-MM-DD",
  "eventName": "Release",
  "eventStart": "YYYY-MM-DD",
  "eventEnd": "YYYY-MM-DD",
  "updatedAt": "<ISO time>"
}
```

## 3. Give access to the other teams

Share the artifact with each team that works on the game, with edit access. A person with view access only reads the
board.

## 4. Each team

1. The human of the team opens the board in Claude and presses "Make my team space" (the team name and the branch
   prefix, for example `alpha/`).
2. The human gives the protocol of the board ("Copy the protocol", or `protocol.md` in this folder) to the coordinator
   session of the team, with the URL of the board.
3. From then on, the coordinator follows the protocol at the start of each session and before each change of files.

## 5. The data

| Path | Contents | Who writes |
|---|---|---|
| `board/meta` | The name, the repository, the integration branch, the dates | the owner |
| `teams/<team id>` | `name`, `joinedAt`, `order` | that team |
| `data/users/<team id>/team` | `name`, `coordinator`, `branchPrefix`, `dev`, `release`, `focus`, `updatedAt`, `log` (newest first, 14 lines) | that team |
| `data/users/<team id>/team/areas/<id>` | `order`, `group` (core, task, specialist), `name`, `status`, `scope`, `now`, `branch`, `paths` | that team |
| `data/users/<team id>/team/queue/<id>` | `order`, `what`, `state`, `branch`, `where`, `jobs` | that team |
| `claims/<id>` | `team`, `teamUid`, `area`, `paths`, `what`, `state` (claimed, in work, in review, merged), `until`, `createdAt`, `by` | each team, its own claims |
| `messages/<id>` | `fromUid`, `fromTeam`, `toUid` (a team id or `all`), `text`, `createdAt`, `readBy` | each team |

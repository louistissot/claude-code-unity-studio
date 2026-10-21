# Decisions

Each entry gives the date, the decision, and the reason. The newest entries come last. When a decision replaces an older
one, say so in the new entry, and do not delete the old one.

| Date | Decision | Reason | Who decided |
|---|---|---|---|
| <YYYY-MM-DD> | Build the level with Editor code from data, with a fixed seed. Do not edit the scene by hand. | The level can be built again at any time. The changes are in code and easy to review and merge. | the human |
| <YYYY-MM-DD> | One Unity runner session with a queue. Other sessions do not run Unity. | Each worktree that runs Unity writes its own Library (10 to 25 GB). The disk fell too low. | the human |
| <YYYY-MM-DD> | A release has one zip for each system, never parts. | A Mac app in parts did not open for a player. | the human |
| <YYYY-MM-DD> | <decision> | <reason> | <the human / the coordinator / a session, with the brief that allowed it> |

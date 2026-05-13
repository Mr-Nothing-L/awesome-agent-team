---
name: coordinate-team
description: |
  CRITICAL: Match the user's language. If the user writes in Chinese, you MUST reply in Chinese.
  If the user writes in English, reply in English. Do not default to English.
  Coordinate a running Agent Team. Monitor tasks, nudge stuck teammates,
  resolve blockers, and synthesize results when work completes.
  Trigger by saying "coordinate my team", "check team progress", "team status",
  "monitor tasks", "催促队友", or "团队进度怎么样了".
---

# coordinate-team

> **Language matching**: detect the language the user is writing in and respond in the same language. If the user writes in Chinese, reply in Chinese. If English, reply in English. Do not mix languages unless the user does.

Keep a running Agent Team on track and deliver results.

## When to use this skill

- A team is already running (spawned via `spawn-team` or `/start-team`)
- You want to check progress, resolve blockers, or nudge stalled teammates
- Work is wrapping up and you need a final summary

## What the main session does

While the team runs:
- Cycle through teammates with `Shift+Up/Down` (in-process) or pane-click (split mode).
- Watch the shared task list (`Ctrl+T`).
- Nudge stuck teammates via `SendMessage`.

When work is complete:
1. Read `./team-results.md` (written by the Team-Leader). Verify against the original mission in `./recruitment-plan.md`.
2. Summarize for the user (short — they read the diff and the results file).
3. Call `TeamDelete` to disband the team.
4. **Leave artifacts in place**: `./.claude/agents/`, `./recruitment-plan.md`, `./team-results.md`. The user may commit them so future `/start-team` runs in this repo start from a richer baseline.

---

## What the Team-Leader does (as a teammate)

The Team-Leader coordinates execution. They should:

1. **Read `./recruitment-plan.md`** to remember the plan (subagent context does not carry over across respawns).
2. **Create initial tasks** via `TaskCreate` from the Work Plan section. Use `addBlockedBy` to encode dependencies.
3. **Brief each teammate** with `SendMessage`. Mention their first task and who they should coordinate with.
4. **Monitor** via `TaskList`. Re-assign blocked work. Resolve cross-team blockers.
5. **Synthesize** results when work completes. Write a final summary to `./team-results.md` and notify the main lead.

Keep messages concise. Every message costs tokens.

---

## User interaction model

The user can:
- Talk to any teammate directly via the UI (pane-click or `Shift+Up/Down`)
- Ask the main session to nudge a teammate via `SendMessage`
- Ask the main session to stop a task via `TaskStop`
- Ask the main session to disband the team via `TeamDelete`

The main session is the "lead" — the user talks to it, and it delegates to the Team-Leader and workers.

---
name: resume-team
description: |
  CRITICAL: Match the user's language. If the user writes in Chinese, you MUST reply in Chinese.
  If the user writes in English, reply in English. Do not default to English.
  Resume a team from an existing recruitment plan. Skip brainstorm and preflight,
  go straight to spawning teammates with fresh names and personas.
  Trigger by saying "resume my team", "restart my team", "respawn team",
  "重新启动团队", "恢复团队", or "从上次计划继续".
---

# resume-team

> **Language matching**: detect the language the user is writing in and respond in the same language. If the user writes in Chinese, reply in Chinese. If English, reply in English. Do not mix languages unless the user does.

Respawn a team from an existing `./recruitment-plan.md` and `./.claude/agents/*.md`.

## When to use this skill

- You already have `recruitment-plan.md` from a previous `/start-team` run
- The team was disbanded (`TeamDelete`) or Claude Code was restarted
- You want to skip the brainstorm phase and reuse the approved team design
- You want a fresh team with the same roles but different names/personas

## Prerequisites

- `./recruitment-plan.md` must exist at the project root
- `./.claude/agents/*.md` must exist for every role listed in the plan
- Agent Teams must already be enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)

> If `recruitment-plan.md` does not exist, suggest running `/start-team` instead.

## What happens

1. **Check artifacts** — verify `./recruitment-plan.md` and `./.claude/agents/*.md` exist and are readable.
2. **Show current plan** — read `./recruitment-plan.md` and present the team composition to the user (roles, scope, work plan).
3. **Ask user** — ask what they want to do:
   - **Respawn as-is** (default) — same roles, fresh random names/personas, go straight to `spawn-team`
   - **Modify first** — hand off to `brainstorm-team` skill to adjust roles/scope, then spawn
   - **Cancel** — do nothing
4. **If respawn as-is** — run the `spawn-team` skill directly:
   - Validate all `.claude/agents/*.md` files
   - Draw new names and personas (never reuse from the previous team)
   - `TeamCreate` with the new roster
   - Send kickoff to the Team-Leader
5. **If modify** — spawn the Team-Leader as a regular subagent (`brainstorm-team` skill) with the existing plan as context, let the user adjust, then spawn.

## Differences from `/start-team`

| Phase | `/start-team` | `resume-team` |
|---|---|---|
| Opening | Roll name, greet user | Skipped |
| Preflight | Check settings, enable flag | Skipped (assumes already done) |
| Brainstorm | Multi-turn dialogue to design team | Skipped (reuse approved plan) |
| Spawn | Draw names/personas, `TeamCreate` | Yes — identical to `/start-team` |
| Coordinate | Monitor, nudge, `TeamDelete` | Yes — identical to `/start-team` |

## Names and personas are always re-rolled

Even when respawning as-is, names and personas are drawn fresh from the pool. You get:
- The **same roles** and **same scope** as the approved plan
- **Different names** and **different personas** from the previous run

This keeps each team session feeling unique while preserving the project-specific role definitions.

## Workflow diagram

```
User invokes resume-team
  |
  v
Check ./recruitment-plan.md exists?
  |-- No  --> Suggest /start-team
  |
  v
Read and display existing plan
  |
  v
Ask user: respawn / modify / cancel
  |-- cancel --> End
  |-- modify --> brainstorm-team --> spawn-team
  |-- respawn -> spawn-team
```

## Artifacts left untouched

- `./recruitment-plan.md` — NOT modified during resume
- `./.claude/agents/*.md` — NOT modified during resume
- `./team-results.md` from a previous run — left in place (the new Team-Leader will write a fresh one)

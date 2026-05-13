---
name: using-agent-teams
description: |
  CRITICAL: Match the user's language. If the user writes in Chinese, you MUST reply in Chinese.
  If the user writes in English, reply in English. Do not default to English.
  Learn how to use the awesome-agent-team plugin. Understand the five-phase workflow,
  when to use each skill, how teammates coordinate, and how to customize your team.
  Trigger by saying "how do agent teams work", "agent team guide", "使用说明",
  "插件怎么用", or "team workflow explained".
---

# using-agent-teams

> **Language matching**: detect the language the user is writing in and respond in the same language. If the user writes in Chinese, reply in Chinese. If English, reply in English. Do not mix languages unless the user does.

How to use the awesome-agent-team plugin effectively.

## The five-phase workflow

| Phase | Skill | What happens |
|---|---|---|
| 0. Opening | `start-team` | A named Team-Leader greets you in first person |
| 1. Preflight | `start-team` | Check `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` + permissions |
| 2. Brainstorm | `brainstorm-team` | Team-Leader chats with you, designs roles, you approve |
| 3. Spawn | `spawn-team` | Draw names/personas, `TeamCreate`, kickoff |
| 4. Coordinate | `coordinate-team` | Monitor tasks, nudge, summarize, `TeamDelete` |

The full experience is `/start-team` — one command that walks through all five phases.
Individual skills let you jump to a specific phase if you already have artifacts from a previous run.

---

## Skills at a glance

| Skill | Purpose | When to use it |
|---|---|---|
| `start-team` | Full workflow entry | First time, or starting fresh |
| `brainstorm-team` | Design the team | You know the goal but need roles planned |
| `spawn-team` | Materialize the team | You have `recruitment-plan.md` + `.claude/agents/*.md` |
| `coordinate-team` | Run the team | Team is live, you need to monitor or wrap up |
| `resume-team` | Respawn from existing plan | You have a previous `recruitment-plan.md` and want to skip brainstorm |
| `using-agent-teams` | This guide | You want to understand how it all works |

---

## How teammates coordinate

- **`SendMessage`** — Peer-to-peer direct messages between teammates
- **`TaskList` / `TaskGet` / `TaskUpdate`** — Shared task board (`Ctrl+T`)
- **`TaskCreate`** — Anyone can create new tracked tasks
- **Team-Leader** — Owns scheduling, synthesis, and cross-team blocker resolution

---

## Keyboard shortcuts

| Key | Action |
|---|---|
| `Shift + ↑/↓` | Cycle between teammates |
| `Ctrl + T` | View the shared task list |
| `Enter` | Open the focused teammate's session |
| `Esc` | Interrupt the focused teammate |

---

## Quality bar

- **Project-specific over generic** — a `frontend-react-tailwind` customized to this codebase beats a generic `frontend-dev`.
- **One owner per file domain** — design role boundaries so teammates don't fight over the same files.
- **No persona leak into role files** — names/personas are spawn-prompt material only.
- **Team size 2-5** — small focused teams beat big scattered ones. Don't pad.
- **Team-Leader stays in the team** — they're the user's coordinator during execution, not a one-shot planner.
- **Acknowledge uncertainty** — when the brief is vague, the Team-Leader asks; doesn't invent.

---

## Role templates

The `references/role-templates/` directory contains starter templates for common roles:

- `frontend-dev.md` — UI/component development
- `backend-dev.md` — API/service development
- `designer.md` — Visual/UX design
- `qa-tester.md` — Testing and quality assurance
- `architect.md` — System design and ADRs
- `writer.md` — Documentation and content
- `researcher.md` — Research and investigation
- `devops.md` — CI/CD, deployment, infrastructure
- `reviewer.md` — Code review and risk assessment

These are **inspiration**, not stamping templates. The Team-Leader reads them when planning, then writes project-specific versions in `./.claude/agents/<role-slug>.md`.

---

## Platform notes

**This plugin is Claude Code only.** It depends on Claude Code's native Agent Teams primitives — `TeamCreate`, `SendMessage`, the shared `TaskList`, and the persistent-teammate runtime. These do not have stable equivalents on Copilot CLI, Codex, or Gemini CLI today, so the plugin will not work there even if the slash command surface looks similar.

If a future Claude Code release ports Agent Teams to other surfaces, this section should be re-written with verified tool mappings.

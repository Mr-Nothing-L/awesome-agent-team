---
name: brainstorm-team
description: |
  Match the user's language. If the user writes in Chinese, reply in Chinese.
  Brainstorm with a Team-Leader to design an Agent Team tailored to your project.
  Clarify goals, draft customized worker roles, iterate with the Team-Leader,
  and get a recruitment plan plus project-specific agent definitions.
  Trigger by saying "brainstorm a team", "design my team", "plan team roles",
  "what teammates do I need", or "帮我设计团队".
---

# brainstorm-team

> **Language matching**: detect the language the user is writing in and respond in the same language. If the user writes in Chinese, reply in Chinese. If English, reply in English. Do not mix languages unless the user does.

Work with a Team-Leader to design an Agent Team for your project.

## When to use this skill

- You know what you want to build but aren't sure what roles you need
- You want project-specific agent definitions (not generic templates)
- You want to review and approve the team design before anyone is spawned

## What happens

1. A Team-Leader subagent chats with you to clarify your goal
2. The Team-Leader drafts a team composition (roles, scope, ownership)
3. You iterate until you're satisfied
4. The Team-Leader writes `./recruitment-plan.md` and `./.claude/agents/<role>.md` files
5. You're ready for `spawn-team`

> **Prerequisite**: Agent Teams must be enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`).
> If not, run `/start-team` first — its Preflight phase will guide you through setup.

---

## How to invoke

### From `/start-team`
This is Phase 2 of the `/start-team` command. The main session spawns the Team-Leader automatically after Opening and Preflight.

### Standalone
If you already have Agent Teams enabled and want to re-brainstorm (e.g. the project scope changed):

```
Agent({
  subagent_type: "awesome-agent-team:team-leader",
  description: "Brainstorm team for: <your goal>",
  prompt: "<your goal and context>"
})
```

The Team-Leader's full behaviour is defined in `team-leader-prompt.md` (in this skill's directory).

---

## The sign-off gate (critical)

The Team-Leader **must not** write any files until you explicitly approve the draft.

The loop:
1. Team-Leader presents a draft table (roles, first tasks, file ownership)
2. You approve, modify, add, or remove
3. Loop until you say "go", "ok", "approved", "可以", "继续"
4. **Only then** files are written

A premature `./.claude/agents/` directory means the gate was skipped — that's a bug.

---

## Output artifacts

| File | Purpose |
|---|---|
| `./recruitment-plan.md` | Human-readable mission, team composition, work plan |
| `./.claude/agents/<slug>.md` | One file per worker role (subagent definition) |

These files are **project-scope** and meant to be committed. They contain no names or personas — those are injected at spawn time.

---

## Quality bar for the Team-Leader

- **Project-specific over generic** — `frontend-react-tailwind` beats `frontend-dev`
- **One owner per file domain** — no two teammates should fight over the same files
- **Team size 2-5** — small focused teams beat large scattered ones
- **Acknowledge uncertainty** — when the brief is vague, ask; don't invent

The Team-Leader reads `../using-agent-teams/references/role-templates/*.md` for inspiration, but never copies a template verbatim.

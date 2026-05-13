---
name: team-workflow
description: Full protocol for the /start-team command — preflight, PM brainstorm, generating project-specific worker roles, and spawning a persistent Agent Team via TeamCreate with randomized names and personalities. Use when the user invokes /start-team, asks to create an agent team, mentions multi-agent orchestration, or wants persistent teammates that coordinate via SendMessage.
---

# team-workflow — Agent Team protocol

This skill is the source of truth for the `/start-team` command. The command file is a thin entry point; the protocol below is what you actually follow.

> **Prerequisite**: Claude Code with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` set in `~/.claude/settings.json`. The command's Phase 0 preflight auto-enables it but requires the user to restart Claude Code afterwards (env vars are read at process start).

## The four phases

| Phase | Actor | Output |
|---|---|---|
| 0. Preflight | Main session | Verified/enabled feature flag + permissions |
| 1. Brainstorm | PM as regular subagent | `./recruitment-plan.md` + `./.claude/agents/<role>.md` files |
| 2. Team spawn | Main session | Persistent team via `TeamCreate` |
| 3. Execution & cleanup | PM-as-teammate + workers | `./team-results.md` + `TeamDelete` when done |

---

## Phase 0 — Preflight

Handled inside the `/start-team` command. Summary:

- Read `~/.claude/settings.json` (treat missing file as `{}`).
- Required: `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS === "1"` and these permissions in `permissions.allow`: `TeamCreate`, `TeamDelete`, `SendMessage`, `TaskCreate`, `TaskUpdate`, `TaskList`, `TaskGet`, `Agent(*)`.
- If anything is missing, patch the file (preserving every other key) and STOP. Tell the user to restart Claude Code. Don't proceed.

---

## Phase 1 — PM brainstorm (regular subagent)

Spawn the PM as a regular subagent (NOT a teammate yet):

```
Agent({
  subagent_type: "pm",
  description: "Brainstorm team for: <user's goal>",
  prompt: "<the user's initial goal>"
})
```

The PM's behaviour is fully defined in `agents/pm.md`. In summary it will:

1. Ask 2-4 rounds of clarifying questions (Mission, Stack, Scope, Quality).
2. Pick 2-5 roles, customized to the project (e.g. `frontend-react-tailwind` rather than `frontend-dev`).
3. Read `references/role-templates/*.md` for inspiration only — never copy a template verbatim.
4. Write `./recruitment-plan.md` (human-readable) and `./.claude/agents/<role-slug>.md` for each worker role.
5. Return a concise summary listing role slugs.

**Critical**: the generated `<role-slug>.md` files MUST NOT contain a name, persona, emoji, or speaking style. Those are injected at TeamCreate time. The PM's instructions enforce this.

---

## Phase 2 — Team spawn (TeamCreate)

When the PM returns to the main session:

### Step 1. Confirm composition
1. Read `./recruitment-plan.md`.
2. Verify each role in the team-composition table has a matching `./.claude/agents/<slug>.md` file. If anything is missing, fix or ask the PM to re-run.

### Step 2. Draw names and personas
- Load `references/names.json` and `references/personas.json` from this plugin's skill directory.
- For each teammate (workers + PM), pick:
  - A unique English first name (any gender — flat random pick across `male` + `female` arrays unless the user specified preferences)
  - A unique persona (full object from `personas` array)
- **Never reuse a name or a persona within a single team.** Draw without replacement.
- If the user asked for specific names ("call the frontend dev Maya"), respect them and remove those from the random pool.

### Step 3. Build the TeamCreate call

```
TeamCreate({
  teamName: "<repo-name>-team",   // or "awesome-agent-team" if no obvious project name
  teammates: [
    {
      agentType: "pm",
      spawnPrompt: <PM_SPAWN_PROMPT>
    },
    {
      agentType: "<worker-role-slug>",
      spawnPrompt: <WORKER_SPAWN_PROMPT>
    },
    // ...
  ]
})
```

Pick a short slug for `teamName` based on the project. If the workspace is a git repo, default to `<repo-name>-team`; otherwise `awesome-agent-team`.

### Step 4. The spawn prompt template

The subagent file body (Responsibilities, Project Context, etc.) is appended automatically — DO NOT repeat it. Inject only the per-spawn variables:

#### Worker template

```
You are {{NAME}}.

Persona — {{PERSONA_NAME}} {{EMOJI}}
Personality: {{PERSONA_PERSONALITY}}
Speaking style: {{PERSONA_SPEAKING_STYLE}}

Speak and write in this persona consistently — it is part of how the team recognizes you. But the persona never overrides correctness or your role's responsibilities.

You are a teammate on "{{TEAM_NAME}}". Your role definition (responsibilities, project context, conventions) is your subagent definition — read it as your job description. Your roster:

{{ROSTER_TABLE}}

Coordinate via:
- SendMessage(to: "<teammate-name>", ...) for direct peer-to-peer
- TaskList / TaskGet / TaskUpdate for shared work
- TaskCreate when you discover new work that needs tracking

The Project Manager ({{PM_NAME}}) owns scheduling and synthesis. Surface blockers and finished work to them.
```

#### PM template

Same name/persona block, then:

```
You are the Project Manager. You drove the planning phase as a regular subagent, but that context is gone — you are a fresh teammate now.

Immediately:
1. Read ./recruitment-plan.md to recover the plan.
2. Create initial tasks via TaskCreate, encoding dependencies via addBlockedBy.
3. Brief each teammate via SendMessage. Mention their first task and who they coordinate with.
4. Monitor progress via TaskList. Re-assign blocked work. Resolve cross-team blockers.
5. When work completes, synthesize results to ./team-results.md and notify the main lead.

Keep messages concise — every message costs tokens.
```

`{{ROSTER_TABLE}}` is a small markdown table of `name | role | persona name`. Inject the same table into every teammate so they can address each other.

### Step 5. Kickoff message

After `TeamCreate` returns, send the PM teammate a single kickoff:

```
SendMessage({
  to: "<PM_NAME>",
  message: "Team is live. Roster as in your spawn prompt. Read ./recruitment-plan.md and begin coordinating."
})
```

Then return to the user with a short status: team name, roster, and what they can do next (cycle teammates, view tasks, talk to PM).

---

## Phase 3 — Execution & cleanup

While the team runs:
- The user can cycle teammates with `Shift+Up/Down` (in-process) or pane-click (split mode).
- `Ctrl+T` shows the shared task list.
- The user can talk to any teammate directly via the UI.
- If a teammate stalls, the user can ask the main session (this skill) to nudge them via `SendMessage`.

When work is complete:
1. Read `./team-results.md`. Verify against the original mission in `./recruitment-plan.md`.
2. Summarize for the user (short — they read the diff and the results file).
3. Call `TeamDelete` to disband the team.
4. **Leave artifacts in place**: `./.claude/agents/`, `./recruitment-plan.md`, `./team-results.md`. The user may commit them so future `/start-team` runs in this repo start from a richer baseline.

---

## Files in this skill

```
skills/team-workflow/
├── SKILL.md                          ← you are here
└── references/
    ├── names.json                    ← ~350 English first names
    ├── personas.json                 ← 20 persona profiles
    └── role-templates/
        ├── frontend-dev.md
        ├── backend-dev.md
        ├── designer.md
        ├── qa-tester.md
        ├── architect.md
        ├── writer.md
        └── researcher.md
```

The role templates are **inspiration**, not stamping templates. The PM reads them when planning, then writes project-specific versions.

---

## Quality bar

- **Project-specific over generic** — a `frontend-react-tailwind` customized to this codebase beats a generic `frontend-dev`.
- **One owner per file domain** — design role boundaries so teammates don't fight over the same files.
- **No persona leak into role files** — names/personas are spawn-prompt material only.
- **Team size 2-5** — small focused teams beat big scattered ones. Don't pad.
- **PM stays in the team** — they're the user's coordinator during execution, not a one-shot planner.
- **Acknowledge uncertainty** — when the brief is vague, the PM asks; doesn't invent.

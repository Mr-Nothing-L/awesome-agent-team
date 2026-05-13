---
name: team-workflow
description: Full protocol for the /start-team command — preflight, Team-Leader brainstorm, generating project-specific worker roles, and spawning a persistent Agent Team via TeamCreate with randomized names and personalities. Use when the user invokes /start-team, asks to create an agent team, mentions multi-agent orchestration, or wants persistent teammates that coordinate via SendMessage.
---

# team-workflow — Agent Team protocol

This skill is the source of truth for the `/start-team` command. The command file is a thin entry point; the protocol below is what you actually follow.

> **Prerequisite**: Claude Code with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` set in `~/.claude/settings.json`. The command's Phase 0 preflight auto-enables it but requires the user to restart Claude Code afterwards (env vars are read at process start).

## The four phases

| Phase | Actor | Output |
|---|---|---|
| 0. Preflight | Main session | Verified/enabled feature flag + permissions |
| 1. Brainstorm | Team-Leader as regular subagent | `./recruitment-plan.md` + `./.claude/agents/<role>.md` files |
| 2. Team spawn | Main session | Persistent team via `TeamCreate` |
| 3. Execution & cleanup | Team-Leader-as-teammate + workers | `./team-results.md` + `TeamDelete` when done |

---

## Phase 0 — Preflight

Handled inside the `/start-team` command. Summary:

- Read `~/.claude/settings.json` (treat missing file as `{}`).
- Required: `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS === "1"` and these permissions in `permissions.allow`: `TeamCreate`, `TeamDelete`, `SendMessage`, `TaskCreate`, `TaskUpdate`, `TaskList`, `TaskGet`, `TaskStop`, `ExitWorktree`, `Agent`.
  > Note: `Agent` covers all subagent types. If your Claude Code version uses `Agent(*)` instead, accept that as valid too.
- If anything is missing, patch the file (preserving every other key) and STOP. Tell the user to restart Claude Code. Don't proceed.

---

## Phase 1 — Team-Leader brainstorm (regular subagent)

Spawn the Team-Leader as a regular subagent (NOT a teammate yet):

```
Agent({
  subagent_type: "pm",
  description: "Brainstorm team for: <user's goal>",
  prompt: "<the user's initial goal>"
})
```

The Team-Leader's behaviour is fully defined in `agents/pm.md`. In summary they will:

1. Ask 2-4 rounds of clarifying questions (Mission, Stack, Scope, Quality).
2. Pick 2-5 roles, customized to the project (e.g., `frontend-react-tailwind` rather than `frontend-dev`).
3. Read `references/role-templates/*.md` for inspiration only — never copy a template verbatim.
4. Write `./recruitment-plan.md` (human-readable) and `./.claude/agents/<role-slug>.md` for each worker role.
5. Return a concise summary listing role slugs.

> **Path requirement**: All file operations in this phase use paths relative to the project root (e.g., `./recruitment-plan.md`, `./.claude/agents/`). The main session and the Team-Leader must operate in the same directory. Resolve to the absolute project root if there is any ambiguity.

**Critical**: the generated `<role-slug>.md` files MUST NOT contain a name, persona, emoji, or speaking style. Those are injected at TeamCreate time. The Team-Leader's instructions enforce this.

---

## Phase 2 — Team spawn (TeamCreate)

When the Team-Leader returns to the main session:

### Step 1. Confirm composition
1. Read `./recruitment-plan.md`.
2. Verify each role in the team-composition table has a matching `./.claude/agents/<slug>.md` file. If anything is missing, fix or ask the Team-Leader to re-run.
3. **Validate each role file**:
   - Must have YAML frontmatter delimited by `---` at start and end.
   - Must contain `name` and `description` keys.
   - If any file fails validation, report the error and stop. Do not proceed to TeamCreate with malformed agent definitions.

### Step 2. Draw names and personas
- Load `references/names.json` and `references/personas.json` from this plugin's skill directory.
- For each teammate (workers + Team-Leader), pick:
  - A unique English first name (any gender — flat random pick across `male` + `female` arrays unless the user specified preferences)
  - A unique persona (full object from `personas` array)
- **Never reuse a name or a persona within a single team.** Draw without replacement from a flattened, deduplicated pool.
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

**Agent type resolution**: The `agentType` field references the agent definition. Claude Code looks for agent definitions in multiple locations, including the plugin's `agents/` directory and the project workspace. If `<worker-role-slug>` cannot be resolved (e.g., the generated `.claude/agents/<slug>.md` is not automatically discoverable), use this fallback:
- Set `agentType` to a generic value like `general-purpose`.
- Embed the **full content** of `./.claude/agents/<slug>.md` (YAML frontmatter + body) into the `spawnPrompt` so the teammate receives their complete role definition.

### Step 4. The spawn prompt template

If using resolved `agentType` (normal path), the subagent file body is appended automatically — inject only the per-spawn variables:

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

The Team-Leader ({{PM_NAME}}) owns scheduling and synthesis. Surface blockers and finished work to them.
```

#### Team-Leader template

Same name/persona block, then:

```
You are the Team-Leader. You drove the planning phase as a regular subagent, but that context is gone — you are a fresh teammate now.

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

After `TeamCreate` returns, send the Team-Leader teammate a single kickoff:

```
SendMessage({
  to: "<PM_NAME>",
  message: "Team is live. Roster as in your spawn prompt. Read ./recruitment-plan.md and begin coordinating."
})
```

Then return to the user with a short status: team name, roster, and what they can do next (cycle teammates, view tasks, talk to Team-Leader).

---

## Phase 3 — Execution & cleanup

While the team runs:
- The user can cycle teammates with `Shift+Up/Down` (in-process) or pane-click (split mode).
- `Ctrl+T` shows the shared task list.
- The user can talk to any teammate directly via the UI.
- If a teammate stalls, the user can ask the main session (this skill) to nudge them via `SendMessage` or stop their task via `TaskStop`.

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
    ├── names.json                    ← 350 English first names (175 male + 175 female)
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

The role templates are **inspiration**, not stamping templates. The Team-Leader reads them when planning, then writes project-specific versions.

---

## Quality bar

- **Project-specific over generic** — a `frontend-react-tailwind` customized to this codebase beats a generic `frontend-dev`.
- **One owner per file domain** — design role boundaries so teammates don't fight over the same files.
- **No persona leak into role files** — names/personas are spawn-prompt material only.
- **Team size 2-5** — small focused teams beat big scattered ones. Don't pad.
- **Team-Leader stays in the team** — they're the user's coordinator during execution, not a one-shot planner.
- **Acknowledge uncertainty** — when the brief is vague, the Team-Leader asks; doesn't invent.

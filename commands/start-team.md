---
description: Launch a real Claude Code Agent Team. PM brainstorms your goal, generates project-specific worker roles, then spawns persistent teammates via TeamCreate with randomized names and personalities.
allowed-tools: Read, Write, Edit, Agent, TeamCreate, TeamDelete, SendMessage, TaskCreate, TaskUpdate, TaskList, TaskGet
---

# /start-team

Launch a real Claude Code Agent Team. Three phases:

1. **Preflight** — verify Agent Teams is enabled in `~/.claude/settings.json`, enable it if not
2. **PM brainstorm** — spawn a Project Manager subagent to clarify the goal and generate project-specific worker role definitions
3. **Team spawn** — use `TeamCreate` to spawn PM + workers as persistent teammates with randomized names and personalities

Follow the `team-workflow` skill for the full protocol. The summary below is the entry point.

---

## Phase 0: Preflight (MUST run first)

Before anything else, ensure `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is set in the user's settings.

**Step 1 — Read `~/.claude/settings.json`.**
- If the file doesn't exist, treat it as an empty `{}`.

**Step 2 — Check the flag.**
- Is `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` equal to `"1"`?
- Are these tools in `permissions.allow` (any missing counts as not OK):
  `TeamCreate`, `TeamDelete`, `SendMessage`, `TaskCreate`, `TaskUpdate`, `TaskList`, `TaskGet`, `Agent(*)`?

**Step 3a — If everything is already OK** → proceed to Phase 1.

**Step 3b — If anything is missing**:

1. **Update settings.json**, preserving every other existing key:
   - Set `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` to `"1"`.
   - Add any missing entries to `permissions.allow` (do not duplicate existing ones).
   - Use `Edit` if the file exists, `Write` if creating it fresh. Always pretty-print with 2-space indent.
2. **STOP. Do NOT proceed to Phase 1.** Tell the user verbatim:

   > Agent Teams was just enabled in your Claude Code settings (`~/.claude/settings.json`). The env flag must be loaded at process startup, so **exit and restart Claude Code** (run `claude` again), then re-invoke `/start-team`. The current session can't use Agent Teams.

3. End the turn here. The user will restart and re-invoke.

---

## Phase 1: PM brainstorm (regular subagent)

Spawn the Project Manager as a **regular subagent** (NOT a teammate yet) via the `Agent` tool:

- `subagent_type: "pm"`
- Pass the user's initial goal as the task description.

The PM will:
1. Hold a multi-turn dialogue with the user to clarify scope, tech stack, and constraints.
2. Decide which roles the project needs. **Customize roles to the project** rather than using generic templates (e.g., `frontend-react-tailwind` over `frontend-dev`).
3. Write `./recruitment-plan.md` to the workspace (human-readable).
4. Write `./.claude/agents/<role-slug>.md` for each worker role (project-scope subagent definitions, NO names/personas — those are injected at spawn).
5. Return a concise summary listing role slugs.

The PM's full protocol is in the `team-workflow` skill. Do not duplicate it here.

---

## Phase 2: Team spawn (TeamCreate)

When the PM returns:

1. Read `./recruitment-plan.md` to confirm the team composition.
2. Verify `./.claude/agents/*.md` exists for each role the PM listed.
3. Load `skills/team-workflow/references/names.json` and `personas.json` from this plugin.
4. For each role (and the PM itself), pick a unique random name and a unique random persona. If the user specified names, respect them. Never reuse the same name or persona within one team.
5. Call `TeamCreate`:
   - `teamName`: a short slug, e.g., `<repo-name>-team` or `awesome-agent-team` if no obvious project name
   - One teammate per role, referencing the project-scope agent type by name
   - **Also include the PM** as a teammate (so the user can talk to PM during execution)
   - Each spawn prompt must follow the template in `team-workflow` skill (name, persona, speaking style, role file reference, coordination instructions)
6. After spawn, brief the team via `SendMessage` to the PM teammate, telling them to read `./recruitment-plan.md` and start coordinating.

---

## Phase 3: Execution & Cleanup

While the team runs:
- Cycle through teammates with `Shift+Down` (in-process) or click panes (split mode).
- Watch the shared task list (`Ctrl+T`).
- Nudge stuck teammates via `SendMessage`.

When work is complete:
1. Synthesize results into a final summary for the user.
2. Call `TeamDelete` to disband the team.
3. Leave `./.claude/agents/` in place — the user may want to commit those role definitions for future runs.

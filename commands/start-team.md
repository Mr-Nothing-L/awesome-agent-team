---
description: Launch a real Claude Code Agent Team. A Team-Leader brainstorms your goal, drafts the team in conversation, gets your sign-off, then spawns persistent teammates via TeamCreate with randomized names and personalities.
allowed-tools: Read, Write, Edit, Agent, TeamCreate, TeamDelete, SendMessage, TaskCreate, TaskUpdate, TaskList, TaskGet, TaskStop, ExitWorktree
---

# /start-team

Launch a real Claude Code Agent Team. Three phases:

1. **Preflight** — verify Agent Teams is enabled in `~/.claude/settings.json`, enable it if not
2. **Team-Leader brainstorm** — spawn a Team-Leader subagent who clarifies the goal, drafts the team in conversation, and writes role files only after the user explicitly approves
3. **Team spawn** — use `TeamCreate` to spawn Team-Leader + workers as persistent teammates with randomized names and personalities

Follow the `team-workflow` skill for the full protocol. The summary below is the entry point.

---

## Phase 0: Preflight (MUST run first)

Before anything else, ensure `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is set in the user's settings.

**Step 1 — Read `~/.claude/settings.json` with the `Read` tool.**
- If the file doesn't exist, treat its contents as the empty object `{}`.
- Parse it as JSON in your head; you will need a representation you can mutate.

**Step 2 — Compute what is missing.**

Required:
- `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS === "1"`
- These tools must be present in `permissions.allow` (any missing counts as not OK):
  `TeamCreate`, `TeamDelete`, `SendMessage`, `TaskCreate`, `TaskUpdate`, `TaskList`, `TaskGet`, `TaskStop`, `ExitWorktree`, `Agent`
  > Note: `Agent` covers all subagent types. If your Claude Code version uses `Agent(*)` instead, accept that as valid too.

**Step 3a — If nothing is missing** → proceed to Phase 1.

**Step 3b — If anything is missing**, patch settings.json with a *full rewrite*, never with a partial edit:

1. Build a `new_settings` object starting from the file you just read (or `{}` if absent). Mutate ONLY two keys:
   - `new_settings.env ||= {}; new_settings.env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1"`
   - `new_settings.permissions ||= {}; new_settings.permissions.allow ||= []`
   - Append (do NOT duplicate) any of the tools that are missing, preserving the existing order.
   - **Do NOT touch any other keys.** Every key in the file you read MUST appear unchanged in `new_settings`.

2. **Show the user a short diff before writing** — list the env key you're setting and the permission entries you are appending. Example:

   ```
   Will update ~/.claude/settings.json:
     + env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1"
     + permissions.allow += ["TeamCreate", "TeamDelete", "SendMessage"]
   (other keys preserved verbatim)
   ```

3. Use the **`Write` tool (NOT `Edit`)** to write the full `new_settings` back to `~/.claude/settings.json`. Serialize as pretty JSON: 2-space indent, trailing newline. The full rewrite is what guarantees the file's structure remains valid — partial edits on nested JSON are fragile and easy to corrupt.

4. **STOP. Do NOT proceed to Phase 1.** Tell the user verbatim:

   > Agent Teams was just enabled in your Claude Code settings (`~/.claude/settings.json`). The env flag must be loaded at process startup, so **exit and restart Claude Code** (run `claude` again), then re-invoke `/start-team`. The current session can't use Agent Teams.

5. End the turn here. The user will restart and re-invoke.

---

## Phase 1: Team-Leader brainstorm (regular subagent)

Spawn the Team-Leader as a **regular subagent** (NOT a teammate yet) via the `Agent` tool:

- `subagent_type: "pm"`
- Pass the user's initial goal as the task description.

The Team-Leader will:
1. Hold a multi-turn dialogue with the user to clarify scope, tech stack, and constraints.
2. **Draft** a team composition in the conversation only — proposed roles, ownership boundaries, work plan — and present it to the user **without touching the filesystem yet**.
3. **Iterate with the user** (add / remove / modify roles, customize tech stack, redraw ownership). New employee JDs requested mid-discussion are folded into the draft inside this loop. The loop only exits on an explicit approval signal from the user (e.g. "go", "ok", "可以", "approved").
4. **Only after sign-off** write `./recruitment-plan.md` (human-readable) and `./.claude/agents/<role-slug>.md` for each worker role (project-scope subagent definitions, NO names/personas — those are injected at spawn).
5. Return a concise summary listing role slugs.

> **Path requirement**: `/start-team` must be invoked from the project root directory. All phases execute in the same directory. The Team-Leader writes to `./recruitment-plan.md` and `./.claude/agents/`, and the main session reads from the same paths. If the user changed directory between phases, resolve to the absolute project root first.

The Team-Leader's full protocol is in the `team-workflow` skill. Do not duplicate it here.

---

## Phase 2: Team spawn (TeamCreate)

When the Team-Leader returns:

1. Read `./recruitment-plan.md` to confirm the team composition.
2. Verify `./.claude/agents/*.md` exists for each role the Team-Leader listed. If any file is missing, ask the Team-Leader to re-run.
3. Validate each `.claude/agents/<role-slug>.md` file:
   - Must have YAML frontmatter delimited by `---`.
   - Must contain `name` and `description` keys.
   - If validation fails, surface the error to the user before proceeding.
4. Load `skills/team-workflow/references/names.json` and `personas.json` from this plugin.
5. For each role (and the Team-Leader itself), pick a unique random name and a unique random persona. If the user specified names, respect them. Never reuse the same name or persona within one team.
6. Call `TeamCreate`:
   - `teamName`: a short slug, e.g., `<repo-name>-team` or `awesome-agent-team` if no obvious project name
   - One teammate per role. For the `agentType` field:
     - Try the role slug first (e.g., `frontend-react-tailwind`). If Claude Code can resolve it from `./.claude/agents/`, use it.
     - **Fallback**: if the agentType cannot be resolved, embed the full role definition (frontmatter + body) into the `spawnPrompt` and use a generic `agentType` like `general-purpose`.
   - **Also include the Team-Leader** as a teammate (so the user can talk to them during execution)
   - Each spawn prompt must follow the template in `team-workflow` skill (name, persona, speaking style, role file reference, coordination instructions)
7. After spawn, brief the team via `SendMessage` to the Team-Leader teammate, telling them to read `./recruitment-plan.md` and start coordinating.

---

## Phase 3: Execution & Cleanup

While the team runs:
- Cycle through teammates with `Shift+Down` (in-process) or click panes (split mode).
- Watch the shared task list (`Ctrl+T`).
- Nudge stuck teammates via `SendMessage`.

When work is complete:
1. Read `./team-results.md` (written by the Team-Leader). Verify it against the original mission in `./recruitment-plan.md`.
2. Synthesize results into a final summary for the user.
3. Call `TeamDelete` to disband the team.
4. Leave `./.claude/agents/` in place — the user may want to commit those role definitions for future runs.

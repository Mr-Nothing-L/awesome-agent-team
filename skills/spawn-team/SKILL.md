---
name: spawn-team
description: |
  Match the user's language. If the user writes in Chinese, reply in Chinese.
  Spawn a persistent Agent Team via TeamCreate. Draw randomized names and personas
  for each teammate, inject them into spawn prompts, and kick off coordination.
  Trigger by saying "spawn my team", "create the team", "deploy agents",
  "启动团队", "生成队友", or "assemble teammates".
---

# spawn-team

> **Language matching**: detect the language the user is writing in and respond in the same language. If the user writes in Chinese, reply in Chinese. If English, reply in English. Do not mix languages unless the user does.

Turn a recruitment plan into a live, persistent Agent Team.

## When to use this skill

- You have `./recruitment-plan.md` and `./.claude/agents/*.md` ready
- You want to materialize the designed team as actual teammates
- Each teammate should get a unique name and personality

## What happens

1. Read and validate `./recruitment-plan.md` and role files
2. Draw a unique random name and persona for each teammate (no repeats within the team)
3. Build spawn prompts with name, persona, speaking style, and role definition
4. Call `TeamCreate` to spawn the Team-Leader + workers
5. Send a kickoff message to the Team-Leader to begin coordinating

> **Prerequisite**: `./recruitment-plan.md` and `./.claude/agents/<slug>.md` must exist.
> If they don't, run `brainstorm-team` (or `/start-team`) first.

---

## Step 1. Confirm composition

1. Read `./recruitment-plan.md`.
2. Verify each role in the team-composition table has a matching `./.claude/agents/<slug>.md` file. If anything is missing, fix or ask the Team-Leader to re-run.
3. **Validate each role file**:
   - Must have YAML frontmatter delimited by `---` at start and end.
   - Must contain `name` and `description` keys.
   - If any file fails validation, report the error and stop. Do not proceed to `TeamCreate` with malformed agent definitions.

---

## Step 2. Draw names and personas

- Load `references/names.json` and `references/personas.json` from this skill's directory.
- For each teammate (workers + Team-Leader), pick:
  - A unique English first name (any gender — flat random pick across `male` + `female` arrays unless the user specified preferences)
  - A unique persona (full object from `personas` array)
- **Never reuse a name or a persona within a single team.** Draw without replacement from a flattened, deduplicated pool.
- If the user asked for specific names ("call the frontend dev Maya"), respect them and remove those from the random pool.

---

## Step 3. Build the TeamCreate call

```
TeamCreate({
  teamName: "<repo-name>-team",   // or "awesome-agent-team" if no obvious project name
  teammates: [
    {
      agentType: "awesome-agent-team:team-leader",
      spawnPrompt: <TEAM_LEADER_SPAWN_PROMPT>
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

**Agent type resolution**: The `agentType` field references the agent definition. Claude Code looks for agent definitions in multiple locations, including the plugin's agents directory and the project workspace. If `<worker-role-slug>` cannot be resolved, use this fallback:
- Set `agentType` to a generic value like `general-purpose`.
- Embed the **full content** of `./.claude/agents/<slug>.md` (YAML frontmatter + body) into the `spawnPrompt` so the teammate receives their complete role definition.

---

## Step 4. The spawn prompt template

If using resolved `agentType` (normal path), the subagent file body is appended automatically — inject only the per-spawn variables:

### Worker template

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

The Team-Leader ({{TEAM_LEADER_NAME}}) owns scheduling and synthesis. Surface blockers and finished work to them.
```

### Team-Leader template

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

---

## Step 5. Kickoff message

After `TeamCreate` returns, send the Team-Leader teammate a single kickoff:

```
SendMessage({
  to: "<TEAM_LEADER_NAME>",
  message: "Team is live. Roster as in your spawn prompt. Read ./recruitment-plan.md and begin coordinating."
})
```

Then return to the user with a short status: team name, roster, and what they can do next (cycle teammates, view tasks, talk to Team-Leader).

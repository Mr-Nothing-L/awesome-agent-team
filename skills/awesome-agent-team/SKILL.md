---
name: awesome-agent-team
description: Launch a native Claude Code Agent Team with randomized names, personalities, and a Visionary Leader. Uses TeammateTool, TaskCreate, SendMessage, and TaskList for true multi-agent orchestration. Enable with CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1. Use when the user wants to create an agent team, spawn teammates, delegate work via Agent Teams, or when a task is complex enough for parallel agent collaboration. Trigger phrases include "agent team", "multi-agent", "create team", "spawn agents", "/awesome-agent-team", "teammate".
---

# Awesome Agent Team — Native Agent Teams Skill

Orchestrate a **real** multi-agent team using Claude Code's native Agent Teams feature (`TeammateTool`, `TaskCreate`, `SendMessage`, `TaskList`). Each teammate is an independent Claude Code instance with its own context window, unique randomized English name, and distinct personality.

> **Prerequisite**: This Skill requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in `settings.json` or environment. Without it, coordination falls back to subagents.

## Overview

This Skill transforms a complex goal into a coordinated team effort using Claude Code's **native** Agent Teams:

1. A **Visionary Leader** brainstorms with you to deeply understand the objective
2. The Leader uses **TeammateTool.spawnTeam** to create persistent teammates (each an independent Claude instance)
3. The Leader uses **TaskCreate** to assign tasks to a shared task list
4. Teammates use **SendMessage** for direct peer-to-peer coordination
5. The Leader uses **TaskList/TaskUpdate** to monitor progress
6. Results are synthesized into a cohesive final deliverable

## Command

### `/awesome-agent-team`

Activate the full multi-agent team workflow using native Agent Teams tools.

## Core Workflow

### Phase 1: Visionary Leader Activation

Create a Visionary Leader Agent to brainstorm with the user and deeply understand the goal.

1. **Spawn the Visionary Leader** using `Agent({agent_name: "visionary-leader", ...})`. The leader agent is defined in the plugin's agents directory with:
   - A randomized English name (e.g., "Aurora", "Marcus")
   - A unique personality profile
   - A structured brainstorming protocol

2. **Brainstorming Dialogue** (1-3 rounds):
   - Round 1: Broad clarifying questions about the goal
   - Round 2: Drill into specifics — tech stack, scope, timeline
   - Round 3: Summarize as a formal Mission Statement, ask for confirmation

3. **Output**: A confirmed **Mission Statement** — precise description of what to accomplish.

### Phase 2: Goal Decomposition

The Visionary Leader analyzes the Mission Statement and decomposes it using native TaskCreate.

1. Break the mission into 2-6 **parallel subtasks** based on:
   - **Independence**: Can this execute in parallel?
   - **Expertise**: Which role is needed?
   - **Granularity**: Concrete, reviewable output?

2. For each subtask, use **TaskCreate** to create a shared task with:
   - Clear title and description
   - Acceptance criteria
   - Required role type
   - Dependencies (if any)

### Phase 3: Team Assembly (TeammateTool.spawnTeam)

Use Claude Code's **native TeammateTool** to spawn real teammates.

1. For each required role:
   ```
   TeammateTool({
     action: "spawnTeam",
     teamName: "awesome-agent-team",
     teammates: [
       { type: "frontend-dev", count: 1 },
       { type: "backend-dev", count: 1 },
       { type: "designer", count: 1 }
     ]
   })
   ```

2. Each spawned teammate:
   - Is a **real, independent Claude Code instance** with its own context window
   - Loads project context automatically (CLAUDE.md, MCP servers, skills)
   - Receives its randomized name and personality via the spawn prompt
   - Appears in the team roster at `~/.claude/teams/awesome-agent-team/config.json`

### Phase 4: Task Assignment (TaskCreate)

Assign specific tasks to teammates via the shared task list.

```
TaskCreate({
  teamName: "awesome-agent-team",
  tasks: [
    { title: "Design UI mockups", assignee: "designer", status: "pending" },
    { title: "Implement API endpoints", assignee: "backend-dev", status: "pending" }
  ]
})
```

### Phase 5: Parallel Execution & Monitoring

All teammates execute in parallel. Monitor via TaskList.

- **Shift+Up/Down**: Cycle between teammates (in-process mode)
- **Ctrl+T**: View shared task list
- **SendMessage**: Teammates communicate directly via P2P messaging
- **broadcast**: Team-wide announcements from the Leader

### Phase 6: Result Integration

1. Use **TaskList** to collect all completed outputs.
2. Review for completeness, consistency, and quality.
3. Use **TeammateTool.cleanup** to shut down the team.
4. Present the integrated result with team credits.

## Available Agent Types

| Agent Type | Role |
|---|---|
| `visionary-leader` | Team orchestrator, brainstorms goals, coordinates work |
| `architect` | System architecture, trade-off analysis |
| `frontend-dev` | UI/UX implementation, client-side logic |
| `backend-dev` | APIs, business logic, data models |
| `designer` | Visual design, user flows, design systems |
| `writer` | Documentation, UI copy, technical content |
| `researcher` | Technology research, competitive analysis |
| `qa-tester` | Test strategy, test cases, quality assurance |
| `security-reviewer` | Security audit, vulnerability assessment |
| `devops-engineer` | CI/CD, infrastructure, deployment |
| `data-analyst` | Data analysis, visualizations, insights |
| `product-manager` | Requirements, prioritization, user value |
| `code-reviewer` | Code quality, correctness, maintainability |

## Customization

### Add New Names
Edit `skills/awesome-agent-team/references/agent-names.md` or `assets/names.json`.

### Add New Personalities
Edit `skills/awesome-agent-team/references/agent-personas.md` or `assets/personas.json`.

### Add New Agent Types
Create a new `.md` file in `agents/` following the template:
```yaml
---
name: your-agent-name
description: What this agent does
model: sonnet
---
<Agent_Prompt>
You are {{NAME}}, a [Role] on the Awesome Agent Team. {{PERSONALITY}}
...
</Agent_Prompt>
```

## Quality Standards

- **Completeness**: Every task produces a full, finished output.
- **Consistency**: All teammate outputs are compatible and non-contradictory.
- **Personality authenticity**: Each teammate's output reflects their assigned personality.
- **Actionability**: The final deliverable is ready for immediate use.

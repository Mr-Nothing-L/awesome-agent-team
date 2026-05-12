---
description: Launch the Awesome Agent Team using Claude Code's native Agent Teams. Creates a Visionary Leader to brainstorm your goal, then spawns persistent teammates via TeammateTool with randomized names and personalities.
---

# `/awesome-agent-team`

Launch a native multi-agent team using Claude Code's experimental Agent Teams feature.

## Prerequisites

Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in your `~/.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

## How It Works

This command triggers the Visionary Leader agent to initiate a native Agent Team workflow:

| Step | Action | Tool |
|------|--------|------|
| **1** | Visionary Leader brainstorms with you to clarify the goal | Agent |
| **2** | Leader decomposes the goal into parallel tasks | TaskCreate |
| **3** | Leader spawns teammates via native Agent Teams | TeammateTool.spawnTeam |
| **4** | Teammates execute in parallel with P2P messaging | SendMessage, TaskList |
| **5** | Leader synthesizes results and cleans up the team | TeammateTool.cleanup |

## Key Difference from Subagents

Unlike `create_subagent` + `task` (which creates disposable subagents), this command uses **TeammateTool.spawnTeam** which creates:

- **Real, persistent teammates** — Each is an independent Claude Code instance with its own context window
- **Shared task list** — Central work queue with pending/in-progress/completed states
- **P2P messaging** — Direct `SendMessage` communication between teammates
- **Team roster** — Stored at `~/.claude/teams/awesome-agent-team/config.json`

## Example Usage

> **User**: `/awesome-agent-team`
>
> **System**: Activating Awesome Agent Team... Spawning Visionary Leader.
>
> **Aurora** (Visionary Leader): Hi there! I'm Aurora, your Visionary Leader. To assemble the perfect team for you, I need to deeply understand your goal. What are you trying to accomplish?
>
> **User**: I want to build a personal portfolio website with React + Tailwind.
>
> **Aurora**: Great vision! A few clarifying questions:
> 1. What sections do you need (hero, projects, about, contact)?
> 2. Do you need it fully coded and deployable, or just the design?
> 3. Any specific animations or interactive features?
>
> **User**: Hero, projects, about, contact. Fully deployable. Smooth scroll animations.
>
> **Aurora**: Mission understood! Assembling your team now via TeammateTool.spawnTeam...
>
> ┌─────────────────────────────────────────────────┐
> │  Team "awesome-agent-team" Deployed              │
> ├─────────────────────────────────────────────────┤
> │  🎨 Liam (designer)        — UI/Visual Design    │
> │  💻 Noah (frontend-dev)    — React Implementation│
> │  🔍 Sofia (code-reviewer)  — Review & Polish     │
> │  🧠 Ethan (architect)      — System Architecture │
> └─────────────────────────────────────────────────┘
>
> *[All teammates execute in parallel via native Agent Teams]*
>
> **Aurora**: All tasks complete! Here's the integrated result...

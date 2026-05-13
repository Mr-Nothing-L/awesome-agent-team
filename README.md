# awesome-agent-team

> [中文 README](./README_ZH.md)
>
> A [Claude Code](https://claude.ai/code) plugin that spawns a **real native Agent Team**. A Team-Leader brainstorms your goal with you, generates **project-specific** worker roles, then assembles persistent teammates via `TeamCreate` — each with a randomized name and a distinct personality, coordinating through `SendMessage` and a shared task list.

[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-blue)](https://claude.ai/code)
[![Agent Teams](https://img.shields.io/badge/Agent%20Teams-Experimental-orange)](https://code.claude.com/docs/en/agent-teams)
[![Version](https://img.shields.io/badge/Version-0.1.0-green)](#)
[![License](https://img.shields.io/badge/License-MIT-yellow)](./LICENSE)

---

## Why this plugin

| | Plain subagents | **awesome-agent-team** |
|---|---|---|
| Lifecycle | One-shot, disposable | **Persistent until `TeamDelete`** |
| Context window | Shared with parent | **Independent per teammate** |
| Communication | Fire-and-forget result | **`SendMessage` P2P + shared `TaskList`** |
| Role design | Generic templates | **Generated per-project by the Team-Leader** |
| Identity | None | **Random name + distinct persona** |
| Plan artifact | None | **`./recruitment-plan.md` + `./.claude/agents/*`** committable |

You get a team that *feels* like a team: each member has a name, a voice, a defined scope, and a way to talk to peers.

---

## Requirements

- **Claude Code** ≥ v2.1.32 (Agent Teams is an experimental feature)
- **git** (for cloning; the install scripts also use it)
- **OS**: Linux, macOS, Windows (PowerShell / Git Bash / WSL all OK)
- One environment variable: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` — **handled automatically** by the plugin's `/start-team` preflight on first run.

---

## Installation

### Method A · Native marketplace add (recommended)

```
/plugin marketplace add https://github.com/Mr-Nothing-L/awesome-agent-team
/plugin install awesome-agent-team@awesome-agent-team
```

### Method B · One-line shell install (Linux / macOS / WSL / Git Bash)

```bash
curl -fsSL https://raw.githubusercontent.com/Mr-Nothing-L/awesome-agent-team/main/install.sh | bash
```

### Method C · One-line PowerShell install (Windows)

```powershell
iwr -useb https://raw.githubusercontent.com/Mr-Nothing-L/awesome-agent-team/main/install.ps1 | iex
```

### Method D · Manual git clone

```bash
git clone https://github.com/Mr-Nothing-L/awesome-agent-team ~/.claude/marketplaces/awesome-agent-team
```

Then in Claude Code:

```
/plugin marketplace add ~/.claude/marketplaces/awesome-agent-team
/plugin install awesome-agent-team@awesome-agent-team
```

On the first `/start-team`, the plugin will check your Claude Code settings, enable Agent Teams if needed, and ask you to restart. Subsequent runs are zero-friction.

---

## Usage

In any project directory:

```
/start-team
```

The Team-Leader will chat with you to understand your goal, then spin up a team of persistent teammates. Each teammate has a unique name and personality, and they coordinate via `SendMessage` and a shared task list.

### Keyboard shortcuts

| Key | Action |
|---|---|
| `Shift + ↑/↓` | Cycle between teammates |
| `Ctrl + T` | View the shared task list |
| `Enter` | Open the focused teammate's session |
| `Esc` | Interrupt the focused teammate |

---

## Skills Library

Each phase of the workflow is also available as an independent skill. You can invoke them naturally in conversation or via the `Skill` tool.

| Skill | Trigger keywords | What it does |
|---|---|---|
| `start-team` | `/start-team`, "start a team", "create a team", "agent cluster" | Full five-phase workflow entry point |
| `brainstorm-team` | "brainstorm a team", "design my team", "plan team roles" | Team-Leader chats with you, designs roles, you approve |
| `spawn-team` | "spawn my team", "deploy agents", "assemble teammates" | Draw names and personas, `TeamCreate`, kickoff |
| `coordinate-team` | "check team progress", "monitor tasks", "nudge teammates" | Monitor, nudge, summarize, `TeamDelete` |
| `using-agent-teams` | "how do agent teams work", "agent team guide" | Guide, quality bar, role templates reference |

The `/start-team` command orchestrates `brainstorm-team` → `spawn-team` → `coordinate-team` automatically. Use individual skills when you want to jump to a specific phase (e.g. you already have a `recruitment-plan.md` from a previous run and just want to re-spawn).

---

## Customization

Talk to the Team-Leader naturally when you invoke `/start-team`. Tell them what you're building, your tech stack, your constraints, or even specific names you want for certain roles. The Team-Leader will adapt the team composition to your project.

Examples:

```
/start-team I'm building a Rust CLI. Please call the backend dev Maya and the QA Marcus.
```

```
/start-team We need to refactor this React codebase to use Next.js App Router. Keep the team small.
```

---

## Troubleshooting

**Q: `/start-team` errors with "Agent Teams not enabled".**
A: The preflight should have prompted you to restart Claude Code. Exit the process completely (the env var is read at startup) and re-run `claude`.

**Q: PowerShell refuses to run `install.ps1`.**
A: Your execution policy is restricted. Run with `-ExecutionPolicy Bypass` (see Method C above) — this only affects the single invocation.

**Q: The Team-Leader generated only a single worker.**
A: Either the project is small enough that one worker is appropriate, or your spec was too narrow. Re-run `/start-team` with more context, or edit `./.claude/agents/` directly.

**Q: Can I commit the generated `.claude/agents/` files?**
A: Yes — they're project-scope, deterministic per project, and meant to be versioned. Personas/names are NOT in those files; they're injected fresh at every `TeamCreate`.

**Q: How do I shut down the team early?**
A: Ask the main session to call `TeamDelete`, or use `/plugin` UI commands. Either way, the conversations and `team-results.md` (if any) remain on disk.

**Q: Does the plugin survive Claude Code session restarts?**
A: The plugin install survives — your `/start-team` command stays available. The *running team* does not survive: Agent Teams do not currently resume across Claude Code restarts. Re-run `/start-team` to rebuild from `recruitment-plan.md`.

---

## Uninstall

```
/plugin uninstall awesome-agent-team@awesome-agent-team
/plugin marketplace remove awesome-agent-team
```

Then delete the cloned repo if you want:

```bash
rm -rf ~/.claude/marketplaces/awesome-agent-team
```

Your project artifacts (`recruitment-plan.md`, `team-results.md`, `./.claude/agents/`) are left alone.

---

## License

MIT — see [LICENSE](./LICENSE).

---

<p align="center">
  Built on Claude Code's native Agent Teams
</p>

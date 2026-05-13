# awesome-agent-team

> A [Claude Code](https://claude.ai/code) plugin that spawns a **real native Agent Team**. A Project Manager brainstorms your goal with you, generates **project-specific** worker roles, then assembles persistent teammates via `TeamCreate` — each with a randomized name and a distinct personality, coordinating through `SendMessage` and a shared task list.
>
> 一个 [Claude Code](https://claude.ai/code) 插件，启动**真正的原生 Agent Team**。项目经理（PM）先和你头脑风暴，理解目标后生成**项目专属**的员工角色定义，再通过 `TeamCreate` 拉起持久化的队友 —— 每位队友有随机的英文名和独特性格，通过 `SendMessage` 和共享任务列表协作。

[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-blue)](https://claude.ai/code)
[![Agent Teams](https://img.shields.io/badge/Agent%20Teams-Experimental-orange)](https://code.claude.com/docs/en/agent-teams)
[![Version](https://img.shields.io/badge/Version-0.1.0-green)](#)
[![License](https://img.shields.io/badge/License-MIT-yellow)](./LICENSE)

---

## TL;DR

```bash
# Linux / macOS / WSL / Git Bash
curl -fsSL https://raw.githubusercontent.com/Mr-Nothing-L/awesome-agent-team/main/install.sh | bash

# Windows PowerShell
iwr -useb https://raw.githubusercontent.com/Mr-Nothing-L/awesome-agent-team/main/install.ps1 | iex
```

Then inside Claude Code:

```
/plugin marketplace add ~/.claude/marketplaces/awesome-agent-team
/plugin install awesome-agent-team@awesome-agent-team
/start-team
```

The very first time you run `/start-team`, it will flip on `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in your settings and ask you to restart Claude Code. After that, every run goes straight to the PM brainstorm.

---

## Why this plugin / 为什么需要这个插件

| | Plain subagents | **awesome-agent-team (this plugin)** |
|---|---|---|
| Lifecycle / 生命周期 | One-shot, disposable | **Persistent until `TeamDelete`** |
| Context window / 上下文 | Shared with parent | **Independent per teammate** |
| Communication / 通信 | Fire-and-forget result | **`SendMessage` P2P + shared `TaskList`** |
| Role design / 角色设计 | Generic templates | **Generated per-project by the PM** |
| Identity / 身份 | None | **Random name + distinct persona** |
| Plan artifact / 方案物料 | None | **`./recruitment-plan.md` + `./.claude/agents/*`** committable |

You get a team that *feels* like a team: each member has a name, a voice, a defined scope, and a way to talk to peers.

---

## Requirements / 系统要求

- **Claude Code** ≥ v2.1.32 (Agent Teams is an experimental feature)
- **git** (for cloning; the install scripts also use it)
- **OS**: Linux, macOS, Windows (PowerShell / Git Bash / WSL all OK)
- One environment variable: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` — **handled automatically** by the plugin's `/start-team` preflight on first run.

---

## Installation / 安装

You have four ways to install, ordered from most to least automated.

### Method A · Native marketplace add (recommended) / 原生 marketplace 添加（推荐）

The most portable path. Works identically on Linux, macOS, and Windows because Claude Code itself does the git clone.

Open Claude Code, then run:

```
/plugin marketplace add https://github.com/Mr-Nothing-L/awesome-agent-team
/plugin install awesome-agent-team@awesome-agent-team
```

Done. Run `/start-team` in any project directory to use it.

### Method B · One-line shell install (Linux / macOS / WSL / Git Bash)

```bash
curl -fsSL https://raw.githubusercontent.com/Mr-Nothing-L/awesome-agent-team/main/install.sh | bash
```

The script:
1. Verifies `git` is available
2. Clones the repo to `~/.claude/marketplaces/awesome-agent-team` (creating dirs as needed)
3. Prints the two slash commands you need to run inside Claude Code

Re-run any time to update — the script `git pull`s if the checkout already exists.

#### Custom install location / 自定义路径

```bash
curl -fsSL https://raw.githubusercontent.com/Mr-Nothing-L/awesome-agent-team/main/install.sh \
  | AWESOME_AGENT_TEAM_DIR=/opt/awesome-agent-team bash
```

Or after downloading:

```bash
./install.sh --dir /opt/awesome-agent-team --ref main
```

### Method C · One-line PowerShell install (Windows)

Open PowerShell (Windows Terminal / pwsh / `powershell.exe` all work):

```powershell
iwr -useb https://raw.githubusercontent.com/Mr-Nothing-L/awesome-agent-team/main/install.ps1 | iex
```

The script clones to `%USERPROFILE%\.claude\marketplaces\awesome-agent-team` and prints the slash commands.

If PowerShell's execution policy blocks the script, run it with:

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr -useb https://raw.githubusercontent.com/Mr-Nothing-L/awesome-agent-team/main/install.ps1 | iex"
```

Or download first and call it explicitly:

```powershell
iwr -useb https://raw.githubusercontent.com/Mr-Nothing-L/awesome-agent-team/main/install.ps1 -OutFile install.ps1
.\install.ps1 -InstallDir D:\tools\awesome-agent-team
```

### Method D · Manual git clone (everywhere) / 手动克隆

For anyone who wants to inspect the source first, or who works behind a corporate proxy:

```bash
# Linux / macOS / WSL / Git Bash
git clone https://github.com/Mr-Nothing-L/awesome-agent-team ~/.claude/marketplaces/awesome-agent-team

# Windows PowerShell
git clone https://github.com/Mr-Nothing-L/awesome-agent-team $HOME\.claude\marketplaces\awesome-agent-team
```

Then in Claude Code:

```
/plugin marketplace add ~/.claude/marketplaces/awesome-agent-team
/plugin install awesome-agent-team@awesome-agent-team
```

### After install / 安装后

On the first `/start-team`, the plugin will check `~/.claude/settings.json` for `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` and the eight required permission entries (`TeamCreate`, `TeamDelete`, `SendMessage`, `TaskCreate`, `TaskUpdate`, `TaskList`, `TaskGet`, `Agent(*)`). If anything is missing it patches them in and tells you to **exit Claude Code and re-run `claude`**, because env vars are read at process start. Subsequent runs are zero-friction.

---

## Usage / 使用

In any project directory:

```
/start-team
```

What happens then, step by step:

```
┌─────────────────────────────────────────────────────────────────┐
│ Phase 0 — Preflight                                             │
│   Reads ~/.claude/settings.json, enables Agent Teams if needed. │
│   If it had to enable anything, STOP and ask you to restart.    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ Phase 1 — PM brainstorm (regular subagent)                      │
│   A Project Manager subagent asks 2–4 rounds of questions:     │
│     • Deliverable / 交付物                                       │
│     • Tech stack & constraints / 技术栈与约束                     │
│     • Scope & timeline / 范围与时间                              │
│     • Quality bar / 质量要求                                     │
│   It then writes:                                                │
│     • ./recruitment-plan.md      — human-readable plan          │
│     • ./.claude/agents/*.md      — project-specific roles       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ Phase 2 — Team spawn (TeamCreate)                               │
│   Main session draws unique names + personas for each role.     │
│   Calls TeamCreate to spawn the PM + workers as persistent      │
│   teammates. Each teammate is an independent Claude instance    │
│   with its own context window.                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ Phase 3 — Execution (parallel, P2P)                             │
│   PM creates initial tasks via TaskCreate (with addBlockedBy    │
│   for dependencies), briefs each teammate via SendMessage,      │
│   monitors via TaskList. Teammates message each other directly. │
│   You can cycle them with Shift+Up/Down and view tasks with     │
│   Ctrl+T.                                                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ Phase 4 — Synthesis & cleanup                                   │
│   PM writes ./team-results.md when work completes.              │
│   Main session summarizes for you and calls TeamDelete.         │
│   Plan + role files stay on disk — commit them if you want.     │
└─────────────────────────────────────────────────────────────────┘
```

### Keyboard / 快捷键

| Key | Action |
|---|---|
| `Shift + ↑/↓` | Cycle between teammates (in-process mode) |
| `Ctrl + T` | View the shared task list |
| `Enter` | Open the focused teammate's session |
| `Esc` | Interrupt the focused teammate |

---

## What gets created in your project / 工作区产物

```
your-project/
├── recruitment-plan.md      # PM's plan (commit this for future runs)
├── team-results.md          # Final synthesis (after team disbands)
└── .claude/
    └── agents/              # PM-generated project-scope agents
        ├── frontend-react-tailwind.md
        ├── backend-fastapi-postgres.md
        └── qa-playwright.md
```

These are normal files. Commit them and future `/start-team` runs in the same repo will start from a richer baseline.

---

## Architecture / 架构

```
awesome-agent-team/
├── .claude-plugin/
│   ├── plugin.json              # Plugin manifest
│   └── marketplace.json         # Marketplace listing
├── commands/
│   └── start-team.md            # /start-team slash command (4 phases incl. preflight)
├── agents/
│   └── pm.md                    # PM subagent (Phase 1 brainstorm + Phase 2 teammate)
├── skills/
│   └── team-workflow/
│       ├── SKILL.md             # Full protocol + spawn-prompt template
│       └── references/
│           ├── names.json       # ~350 English first names
│           ├── personas.json    # 20 distinct personas
│           └── role-templates/  # Inspiration for the PM (not stamped verbatim)
│               ├── frontend-dev.md
│               ├── backend-dev.md
│               ├── designer.md
│               ├── qa-tester.md
│               ├── architect.md
│               ├── writer.md
│               └── researcher.md
├── install.sh                   # Linux / macOS / WSL / Git Bash
├── install.ps1                  # Windows PowerShell
├── LICENSE
└── README.md
```

### Tools used / 使用的官方工具

All real, native Claude Code tools (no fabrication):

| Tool | Purpose |
|---|---|
| `Agent` | Spawn the PM as a regular subagent in Phase 1 |
| `TeamCreate` | Spawn the persistent team in Phase 2 |
| `SendMessage` | Direct P2P messaging between teammates |
| `TaskCreate` / `TaskUpdate` / `TaskList` / `TaskGet` | Shared task list |
| `TeamDelete` | Disband the team in Phase 4 |

---

## Customization / 自定义

### Add your own names / 增加名字

Edit `skills/team-workflow/references/names.json`. Names are drawn uniformly at random; just append to the `male` or `female` arrays.

### Add your own personas / 增加性格

Edit `skills/team-workflow/references/personas.json`. Required keys per entry: `name`, `personality`, `speaking_style`, `traits`, `emoji`. Personas are drawn without replacement per team, so more variety = fewer collisions.

### Add a role template / 增加角色模板

Drop a `<role>.md` into `skills/team-workflow/references/role-templates/`. The PM reads this directory during Phase 1 for inspiration; it does NOT use templates verbatim. Each template should describe scope, working principles, and handoffs — the PM will customize tech-specific details.

### Use specific names / 指定特定名字

When invoking `/start-team`, mention names in your request:

```
/start-team I'm building a Rust CLI. Please call the backend dev Maya and the QA Marcus.
```

The main session honors these and removes them from the random pool.

---

## Troubleshooting / 常见问题

**Q: `/start-team` errors with "Agent Teams not enabled".**
A: The preflight should have prompted you to restart Claude Code. Exit the process completely (the env var is read at startup) and re-run `claude`.

**Q: PowerShell refuses to run `install.ps1`.**
A: Your execution policy is restricted. Run with `-ExecutionPolicy Bypass` (see [Method C](#method-c--one-line-powershell-install-windows)) — this only affects the single invocation.

**Q: The PM generated only a single worker.**
A: Either the project is small enough that one worker is appropriate, or your spec was too narrow. Re-run `/start-team` with more context, or edit `./.claude/agents/` directly.

**Q: Can I commit the generated `.claude/agents/` files?**
A: Yes — they're project-scope, deterministic per project, and meant to be versioned. Personas/names are NOT in those files; they're injected fresh at every `TeamCreate`.

**Q: How do I shut down the team early?**
A: Ask the main session to call `TeamDelete`, or use `/plugin` UI commands. Either way, the conversations and `team-results.md` (if any) remain on disk.

**Q: Does the plugin survive Claude Code session restarts?**
A: The plugin install survives — your `/start-team` command stays available. The *running team* does not survive: Agent Teams do not currently resume across Claude Code restarts. Re-run `/start-team` to rebuild from `recruitment-plan.md`.

---

## Uninstall / 卸载

```
# Inside Claude Code
/plugin uninstall awesome-agent-team@awesome-agent-team
/plugin marketplace remove awesome-agent-team
```

Then delete the cloned repo:

```bash
# Linux / macOS / WSL / Git Bash
rm -rf ~/.claude/marketplaces/awesome-agent-team

# Windows PowerShell
Remove-Item -Recurse -Force $HOME\.claude\marketplaces\awesome-agent-team
```

Your project artifacts (`recruitment-plan.md`, `team-results.md`, `./.claude/agents/`) are left alone — delete them manually if you want.

---

## License / 许可证

MIT — see [LICENSE](./LICENSE).

---

<p align="center">
  Built on Claude Code's native Agent Teams · 基于 Claude Code 原生 Agent Teams 打造
</p>

# Awesome Agent Team 🚀

> A [Claude Code](https://claude.ai/code) **Plugin** that launches a **native Agent Team** — real, persistent teammates with randomized English names, unique personalities, and speaking styles. Features a Visionary Leader who brainstorms your goals before assembling the perfect team via `TeammateTool`.

> 一个用于 [Claude Code](https://claude.ai/code) 的 **Plugin**，可以拉起**原生的 Agent Team** — 每个 Teammate 都是独立的 Claude Code 实例，拥有随机的英文名、独特的性格和说话风格。愿景领袖（Visionary Leader）通过头脑风暴理解你的目标，然后通过 `TeammateTool` 组建最合适的团队。

[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-blue)](https://claude.ai/code)
[![Agent Teams](https://img.shields.io/badge/Agent%20Teams-Native-green)](https://code.claude.com/docs/en/agent-teams)
[![Version](https://img.shields.io/badge/Version-1.0.0-orange)](#)
[![License](https://img.shields.io/badge/License-MIT-yellow)](./LICENSE)

---

## Quickstart / 快速开始

Give your Claude Code **Awesome Agent Team**:

```bash
# Step 1: Clone the repository
git clone https://github.com/Mr-Nothing-L/awesome-agent-team.git
cd awesome-agent-team

# Step 2: Run the install script
./scripts/install.sh

# Step 3: Restart Claude Code
claude

# Step 4: Launch your team
/awesome-agent-team
```

---

## Key Difference / 关键区别

| | Subagent Simulation (Old) | **Native Agent Teams (This Plugin)** |
|---|---|---|
| **Agent Type** | Disposable `create_subagent` | **Persistent `TeammateTool.spawnTeam`** |
| **Context** | Shared with parent | **Independent context window per teammate** |
| **Communication** | None (fire-and-forget) | **P2P `SendMessage` + shared task list** |
| **Team Roster** | None | **Stored at `~/.claude/teams/`** |
| **Names/Personality** | Fixed in prompt | **Randomized at install time** |
| **Display** | Hidden | **Visible via `Shift+Up/Down` or split panes** |

---

## Table of Contents / 目录

- [Installation / 安装](#installation--安装)
- [Usage / 使用](#usage--使用)
- [How It Works / 工作原理](#how-it-works--工作原理)
- [Available Roles / 可用角色](#available-roles--可用角色)
- [Architecture / 架构](#architecture--架构)
- [Customization / 自定义](#customization--自定义)
- [FAQ / 常见问题](#faq--常见问题)

---

## Installation / 安装

### Method 1: npm (Recommended) / npm 安装（推荐）

**Global install**:
```bash
npm install -g awesome-agent-team
awesome-agent-team init
```

**One-time use with npx** (no installation):
```bash
npx awesome-agent-team init
```

**Auto mode with specific team size**:
```bash
npx awesome-agent-team init --auto --team-size 5
```

**Use custom names**:
```bash
npx awesome-agent-team init --names "Elena,Marcus,Sophie,Aiden"
```

### Method 2: Git Clone + Bash / Git 克隆 + Bash

#### Prerequisites / 前置条件

**Enable Agent Teams**:
```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

**Install jq**:
```bash
# macOS
brew install jq

# Linux
sudo apt-get install jq
```

**Clone and install**:
```bash
git clone https://github.com/Mr-Nothing-L/awesome-agent-team.git
cd awesome-agent-team
./scripts/install.sh
```

### Method 3: Claude Code /plugin / Claude Code 插件命令

```bash
# In Claude Code:
/plugin marketplace add Mr-Nothing-L/awesome-agent-team-marketplace
/plugin install awesome-agent-team@awesome-agent-team-marketplace

# Then initialize:
npx awesome-agent-team init
```

### Step: Restart Claude Code / 重启 Claude Code

```bash
claude
```

---

## Usage / 使用

Once installed, type the slash command in Claude Code:

```
/awesome-agent-team
```

Claude will then:

1. **Spawn a Visionary Leader** — a persistent agent that asks clarifying questions
2. **Brainstorm together** — 1-3 rounds of dialogue to fully understand your goal
3. **Assemble a unique team** — Leader uses `TeammateTool.spawnTeam` to create real teammates
4. **Execute in parallel** — All teammates work simultaneously via native Agent Teams
5. **Communicate via SendMessage** — Teammates coordinate directly with each other
6. **Monitor via TaskList** — Leader tracks progress on the shared task list
7. **Integrate results** — All outputs merged into a single coherent deliverable

### Keyboard Shortcuts / 键盘快捷键

| Key | Action |
|-----|--------|
| `Shift + Up/Down` | Cycle between teammates |
| `Ctrl + T` | View shared task list |
| `Enter` | View selected teammate's session |
| `Escape` | Interrupt current teammate |

---

## How It Works / 工作原理

This plugin uses Claude Code's **native Agent Teams** (not simulated subagents):

```
User: /awesome-agent-team
    │
    ▼
┌──────────────────────────────────────────────────────────────┐
│  Phase 1: Visionary Leader Activation                        │
│  └─ Agent({agent_name: "visionary-leader"})                  │
│     Leader brainstorms with user (1-3 rounds)               │
│     领袖通过 1-3 轮对话理解目标                               │
└──────────────────────────────────────────────────────────────┘
    │
    ▼
┌──────────────────────────────────────────────────────────────┐
│  Phase 2: Goal Decomposition                                 │
│  └─ Leader breaks mission into parallel subtasks             │
│     领袖将目标拆解为可并行子任务                               │
└──────────────────────────────────────────────────────────────┘
    │
    ▼
┌──────────────────────────────────────────────────────────────┐
│  Phase 3: Team Spawn (TeammateTool.spawnTeam) ⭐ NATIVE       │
│  └─ TeammateTool({ action: "spawnTeam", ... })               │
│     Each teammate = REAL independent Claude Code instance    │
│     每个队友 = 真正的独立 Claude Code 实例                     │
└──────────────────────────────────────────────────────────────┘
    │
    ▼
┌──────────────────────────────────────────────────────────────┐
│  Phase 4: Task Assignment (TaskCreate) ⭐ NATIVE             │
│  └─ TaskCreate({ teamName: "awesome-agent-team", ... })      │
│     Shared task list with pending/in-progress/completed      │
│     共享任务列表，支持依赖关系                                 │
└──────────────────────────────────────────────────────────────┘
    │
    ▼
┌──────────────────────────────────────────────────────────────┐
│  Phase 5: Parallel Execution ⭐ NATIVE                       │
│  └─ All teammates run in parallel                            │
│     P2P messaging via SendMessage                            │
│     所有队友并行执行，通过 SendMessage 直接通信                │
└──────────────────────────────────────────────────────────────┘
    │
    ▼
┌──────────────────────────────────────────────────────────────┐
│  Phase 6: Result Integration                                 │
│  └─ TaskList → collect results → synthesize                  │
│     TeammateTool.cleanup to shut down team                   │
│     整合所有结果，清理团队资源                                 │
└──────────────────────────────────────────────────────────────┘
```

---

## Available Roles / 可用角色

| Role | Description |
|------|-------------|
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

---

## Architecture / 架构

```
awesome-agent-team/
├── .claude-plugin/              # Plugin manifest
│   ├── plugin.json              # Plugin metadata
│   └── marketplace.json         # Marketplace listing
├── agents/                      # Agent role templates
│   ├── visionary-leader.md      # Leader template ({{NAME}}, {{PERSONALITY}})
│   ├── architect.md
│   ├── frontend-dev.md
│   ├── backend-dev.md
│   ├── designer.md
│   ├── writer.md
│   ├── researcher.md
│   ├── qa-tester.md
│   ├── security-reviewer.md
│   ├── devops-engineer.md
│   ├── data-analyst.md
│   ├── product-manager.md
│   └── code-reviewer.md
├── commands/
│   └── awesome-agent-team.md    # /awesome-agent-team command
├── skills/
│   └── awesome-agent-team/
│       ├── SKILL.md             # Skill definition
│       └── references/
│           ├── agent-names.md   # Human-readable name reference
│           └── agent-personas.md # Human-readable persona reference
├── assets/
│   ├── names.json               # 400+ names (machine-readable)
│   └── personas.json            # 20 personas (machine-readable)
├── scripts/
│   └── install.sh               # Install script (randomizes team)
├── settings.json                # Recommended settings template
├── README.md
└── LICENSE
```

### What Gets Installed / 安装到哪里

After running `./scripts/install.sh`, these files are created in your Claude Code config:

```
~/.claude/
├── agents/
│   ├── aat-visionary-leader.md  # Personalized leader agent
│   ├── aat-frontend-dev.md      # Personalized frontend agent
│   ├── aat-backend-dev.md       # Personalized backend agent
│   └── ... (one per team member)
├── teams/
│   └── awesome-agent-team/
│       └── config.json          # Team roster (names, roles, IDs)
└── settings.json               # Updated with Agent Teams enabled
```

---

## Customization / 自定义

### Add New Names / 添加新名字

Edit `assets/names.json` and add to `male` or `female` arrays. Re-run `install.sh`.

### Add New Personalities / 添加新性格

Edit `assets/personas.json` and add to `personas` array. Re-run `install.sh`.

### Add New Agent Roles / 添加新角色

1. Create a new `.md` file in `agents/` following the template:

```markdown
---
name: your-role-name
description: What this role does
model: sonnet
---

<Agent_Prompt>
You are {{NAME}}, a [Role] on the Awesome Agent Team. {{PERSONALITY}}
...
</Agent_Prompt>
```

2. Re-run `install.sh`

---

## FAQ / 常见问题

**Q: Is this using real Agent Teams or simulated subagents?**

A: **Real Agent Teams.** This plugin uses Claude Code's native `TeammateTool.spawnTeam`, `TaskCreate`, `SendMessage`, and `TaskList` — not `create_subagent` + `task`. Each teammate is a real, independent Claude Code instance.

**Q: 这是真正的 Agent Team 还是模拟的 subagent？**

A: **真正的 Agent Team。** 本插件使用 Claude Code 原生的 `TeammateTool.spawnTeam`、`TaskCreate`、`SendMessage` 和 `TaskList` — 不是 `create_subagent` + `task`。每个 teammate 都是真正的独立 Claude Code 实例。

**Q: How do I enable Agent Teams?**

A: Add `"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"` to `~/.claude/settings.json` under the `env` key. See [Installation](#installation--安装).

**Q: 如何启用 Agent Teams？**

A: 在 `~/.claude/settings.json` 的 `env` 下添加 `"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"`。参见 [安装](#installation--安装)。

**Q: Can I re-run install.sh for a different team?**

A: Yes! Each run produces a new randomized team. Your previous agent files will be overwritten.

**Q: 可以重新运行 install.sh 生成不同的团队吗？**

A: 可以！每次运行都会产生一个新的随机团队。之前的 agent 文件会被覆盖。

**Q: How many teammates can I have?**

A: Claude Code supports 2-16 teammates. We recommend 3-7 for optimal balance.

**Q: 可以有多少个 teammate？**

A: Claude Code 支持 2-16 个 teammate。建议 3-7 个以获得最佳平衡。

**Q: Can teammates talk to each other?**

A: Yes! Teammates use `SendMessage` for direct P2P communication and `broadcast` for team-wide messages. They also share a task list via `TaskCreate`/`TaskList`.

**Q: Teammate 之间可以互相通信吗？**

A: 可以！Teammate 使用 `SendMessage` 进行直接的 P2P 通信，使用 `broadcast` 进行团队广播。它们还通过 `TaskCreate`/`TaskList` 共享任务列表。

**Q: Will my teammates persist across sessions?**

A: No — Agent Teams do not currently support session resumption. You need to re-run `/awesome-agent-team` for each new session.

**Q: Teammate 会跨会话持久化吗？**

A: 不会 — Agent Teams 目前不支持会话恢复。每个新会话都需要重新运行 `/awesome-agent-team`。

---

## License / 许可证

MIT License. See [LICENSE](./LICENSE) for details.

---

<p align="center">
  Built for Claude Code's native Agent Teams | 为 Claude Code 原生 Agent Teams 打造
</p>
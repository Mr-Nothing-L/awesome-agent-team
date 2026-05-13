# awesome-agent-team

> 一个 [Claude Code](https://claude.ai/code) 插件，启动**真正的原生 Agent Team**。Team-Leader 先和你头脑风暴，理解目标后生成**项目专属**的员工角色定义，再通过 `TeamCreate` 拉起持久化的队友 —— 每位队友有随机的英文名和独特性格，通过 `SendMessage` 和共享任务列表协作。

[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-blue)](https://claude.ai/code)
[![Agent Teams](https://img.shields.io/badge/Agent%20Teams-Experimental-orange)](https://code.claude.com/docs/en/agent-teams)
[![Version](https://img.shields.io/badge/Version-0.1.0-green)](#)
[![License](https://img.shields.io/badge/License-MIT-yellow)](./LICENSE)

---

## Why This Plugin

| | 普通子代理 | **awesome-agent-team** |
|---|---|---|
| 生命周期 | 一次性的，用完即弃 | **持久化，直到 `TeamDelete`** |
| 上下文窗口 | 与父会话共享 | **每个队友独立** |
| 通信方式 |  fire-and-forget | **`SendMessage` P2P + 共享 `TaskList`** |
| 角色设计 | 通用模板 | **Team-Leader 按项目动态生成** |
| 身份 | 无 | **随机名字 + 独特性格** |
| 方案物料 | 无 | **`./recruitment-plan.md` + `./.claude/agents/*`** 可提交 |

你得到的不是一个工具，而是一支**有名字、有性格、有分工、能互相说话**的团队。

---

## Requirements

- **Claude Code** ≥ v2.1.32（Agent Teams 是实验性功能）
- **git**（安装脚本需要）
- **OS**: Linux、macOS、Windows（PowerShell / Git Bash / WSL 均可）
- 一个环境变量：`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`。首次运行 `/start-team` 时，preflight 会检测是否启用；未启用时，插件会给出可直接复制的 JSON 片段，并提示你合并到 `~/.claude/settings.json` 后重启。只需配置一次，之后每次运行都是零摩擦。

---

## Installation

### 方法 A · 原生 marketplace 添加（推荐）

```
/plugin marketplace add https://github.com/Mr-Nothing-L/awesome-agent-team
/plugin install awesome-agent-team@awesome-agent-team
```

### 方法 B · 一行命令安装（Linux / macOS / WSL / Git Bash）

```bash
curl -fsSL https://raw.githubusercontent.com/Mr-Nothing-L/awesome-agent-team/main/install.sh | bash
```

### 方法 C · 一行 PowerShell 安装（Windows）

```powershell
iwr -useb https://raw.githubusercontent.com/Mr-Nothing-L/awesome-agent-team/main/install.ps1 | iex
```

### 方法 D · 手动克隆

```bash
git clone https://github.com/Mr-Nothing-L/awesome-agent-team ~/.claude/marketplaces/awesome-agent-team
```

然后在 Claude Code 中：

```
/plugin marketplace add ~/.claude/marketplaces/awesome-agent-team
/plugin install awesome-agent-team@awesome-agent-team
```

首次运行 `/start-team` 时，插件会检查你的 Claude Code 设置，自动启用 Agent Teams（如需启用会提示重启）。之后每次运行都直接进入 Team-Leader 头脑风暴。

---

## Usage

在项目目录下：

```
/start-team
```

Team-Leader 会和你聊聊你的目标，然后拉起一支持久化的队友团队。每位队友都有独一无二的名字和性格，通过 `SendMessage` 和共享任务列表协作。

### Keyboard Shortcuts

| 按键 | 功能 |
|---|---|
| `Shift + ↑/↓` | 在队友之间切换 |
| `Ctrl + T` | 查看共享任务列表 |
| `Enter` | 打开当前队友的会话 |
| `Esc` | 中断当前队友 |

---

## Skills Library

每个工作流阶段也作为独立的 skill 提供。你可以在对话中自然触发，或通过 `Skill` 工具显式调用。

| Skill | 触发关键词 | 功能 |
|---|---|---|
| `start-team` | `/start-team`, "start a team", "agent cluster", "agent集群" | 完整五阶段工作流入口 |
| `brainstorm-team` | "brainstorm a team", "design my team", "帮我设计团队" | Team-Leader 与你对话，设计角色，你确认 |
| `spawn-team` | "spawn my team", "deploy agents", "启动团队", "生成队友" | 抽取名字/人设，`TeamCreate`，启动协作 |
| `coordinate-team` | "check team progress", "monitor tasks", "团队进度", "催促队友" | 监控、催促、汇总、`TeamDelete` |
| `using-agent-teams` | "how do agent teams work", "使用说明", "插件怎么用" | 使用指南、质量标准、角色模板参考 |

`/start-team` 命令会自动编排 `brainstorm-team` → `spawn-team` → `coordinate-team`。当你想跳到特定阶段时使用独立 skill（例如你已有上次运行留下的 `recruitment-plan.md`，只想重新 spawn）。

---

## Customization

调用 `/start-team` 时直接跟 Team-Leader 交流。告诉他们你要做什么、用什么技术栈、有什么限制，甚至直接指定某个角色的名字。Team-Leader 会根据你的项目动态调整团队组成。

示例：

```
/start-team 我要做一个 Rust CLI 工具，后端开发叫 Maya，QA 叫 Marcus。
```

```
/start-team 需要把这套 React 代码重构为 Next.js App Router，团队保持精简。
```

---

## Troubleshooting

**Q: `/start-team` 报错 "Agent Teams not enabled"。**
A: Preflight 应该已经提示你重启 Claude Code。完全退出进程（环境变量在启动时读取）然后重新运行 `claude`。

**Q: PowerShell 拒绝运行 `install.ps1`。**
A: 执行策略受限。用 `-ExecutionPolicy Bypass` 运行（见方法 C）—— 仅影响本次调用。

**Q: Team-Leader 只生成了一个 worker。**
A: 要么项目确实很小，要么你的需求描述太窄。用更多上下文重新运行 `/start-team`，或直接编辑 `./.claude/agents/`。

**Q: 生成的 `.claude/agents/` 文件可以提交到 git 吗？**
A: 可以 —— 它们是项目级别的、每个项目确定的、设计为可版本化的。人设和名字不在这些文件里，每次 `TeamCreate` 都会重新注入。

**Q: 如何提前解散团队？**
A: 让主会话调用 `TeamDelete`，或使用 `/plugin` UI 命令。无论哪种方式，对话记录和 `team-results.md`（如有）都会保留在磁盘上。

**Q: 插件能在 Claude Code 重启后存活吗？**
A: 插件安装本身是持久的 —— `/start-team` 命令一直可用。但*运行中的团队*不能跨会话恢复：Agent Teams 目前不支持跨重启恢复。重新运行 `/start-team` 即可从 `recruitment-plan.md` 重建。

---

## Uninstall

```
/plugin uninstall awesome-agent-team@awesome-agent-team
/plugin marketplace remove awesome-agent-team
```

然后按需删除克隆的仓库：

```bash
rm -rf ~/.claude/marketplaces/awesome-agent-team
```

项目产物（`recruitment-plan.md`、`team-results.md`、`./.claude/agents/`）会保留 —— 如需删除请手动处理。

---

## License

MIT — 见 [LICENSE](./LICENSE)。

---

<p align="center">
  基于 Claude Code 原生 Agent Teams 打造
</p>

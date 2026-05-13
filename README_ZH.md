# awesome-agent-team

> 一个 [Claude Code](https://claude.ai/code) 插件，启动**真正的原生 Agent Team**。Team-Leader 先和你头脑风暴，理解目标后生成**项目专属**的员工角色定义，再通过 `TeamCreate` 拉起持久化的队友 —— 每位队友有随机的英文名和独特性格，通过 `SendMessage` 和共享任务列表协作。

[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-blue)](https://claude.ai/code)
[![Agent Teams](https://img.shields.io/badge/Agent%20Teams-Experimental-orange)](https://code.claude.com/docs/en/agent-teams)
[![Version](https://img.shields.io/badge/Version-0.1.0-green)](#)
[![License](https://img.shields.io/badge/License-MIT-yellow)](./LICENSE)

---

## 为什么需要这个插件

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

## 系统要求

- **Claude Code** ≥ v2.1.32（Agent Teams 是实验性功能）
- **git**（安装脚本需要）
- **OS**: Linux、macOS、Windows（PowerShell / Git Bash / WSL 均可）
- 一个环境变量：`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` —— 首次运行 `/start-team` 时插件会自动处理。

---

## 安装

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

## 使用

在项目目录下：

```
/start-team
```

Team-Leader 会和你聊聊你的目标，然后拉起一支持久化的队友团队。每位队友都有独一无二的名字和性格，通过 `SendMessage` 和共享任务列表协作。

### 快捷键

| 按键 | 功能 |
|---|---|
| `Shift + ↑/↓` | 在队友之间切换 |
| `Ctrl + T` | 查看共享任务列表 |
| `Enter` | 打开当前队友的会话 |
| `Esc` | 中断当前队友 |

---

## 自定义

调用 `/start-team` 时直接跟 Team-Leader 交流。告诉他们你要做什么、用什么技术栈、有什么限制，甚至直接指定某个角色的名字。Team-Leader 会根据你的项目动态调整团队组成。

示例：

```
/start-team 我要做一个 Rust CLI 工具，后端开发叫 Maya，QA 叫 Marcus。
```

```
/start-team 需要把这套 React 代码重构为 Next.js App Router，团队保持精简。
```

---

## 常见问题

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

## 卸载

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

## 许可证

MIT — 见 [LICENSE](./LICENSE)。

---

<p align="center">
  基于 Claude Code 原生 Agent Teams 打造
</p>

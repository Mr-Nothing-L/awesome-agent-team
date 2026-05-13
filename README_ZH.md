# awesome-agent-team

> 一个 [Claude Code](https://claude.ai/code) 插件，启动**真正的原生智能体团队**。团队负责人先和你头脑风暴，理解目标后生成**项目专属**的员工角色定义，再通过原生接口拉起持久化的队友 —— 每位队友有随机的英文名和独特性格，通过点对点消息和共享任务列表协作。

[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-blue)](https://claude.ai/code)
[![Agent Teams](https://img.shields.io/badge/Agent%20Teams-Experimental-orange)](https://code.claude.com/docs/en/agent-teams)
[![Version](https://img.shields.io/badge/Version-0.1.0-green)](#)
[![License](https://img.shields.io/badge/License-MIT-yellow)](./LICENSE)

---

## Why This Plugin

| | 普通子代理 | **本插件** |
|---|---|---|
| 生命周期 | 一次性的，用完即弃 | **持久化，直到手动解散** |
| 上下文窗口 | 与父会话共享 | **每个队友独立** |
| 通信方式 | 单向返回结果 | **点对点消息 + 共享任务板** |
| 角色设计 | 通用模板 | **团队负责人按项目动态生成** |
| 身份 | 无 | **随机名字 + 独特性格** |
| 方案物料 | 无 | **招募计划 + 角色定义文件** 可提交版本控制 |

你得到的不是一个工具，而是一支**有名字、有性格、有分工、能互相说话**的团队。

---

## Requirements

- **Claude Code** 版本不低于 2.1.32（智能体团队是实验性功能）
- **git**（安装脚本需要）
- **操作系统**: Linux、macOS、Windows（PowerShell / Git Bash / WSL 均可）
- 一个环境变量需要在首次运行 `/start-team` 时由插件自动处理

---

## Installation

### 方法 A · 原生应用市场添加（推荐）

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

首次运行 `/start-team` 时，插件会检查你的 Claude Code 设置，自动启用智能体团队功能（如需启用会提示重启）。之后每次运行都直接进入团队负责人头脑风暴。

---

## Usage

在项目目录下：

```
/start-team
```

团队负责人会和你聊聊你的目标，然后拉起一支持久化的队友团队。每位队友都有独一无二的名字和性格，通过点对点消息和共享任务列表协作。

### Keyboard Shortcuts

| 按键 | 功能 |
|---|---|
| `Shift + ↑/↓` | 在队友之间切换 |
| `Ctrl + T` | 查看共享任务列表 |
| `Enter` | 打开当前队友的会话 |
| `Esc` | 中断当前队友 |

---

## Skills Library

每个工作流阶段也作为独立的能力提供。你可以在对话中自然触发。

| 能力 | 触发关键词 | 功能 |
|---|---|---|
| 启动团队 | "启动团队"、"创建团队"、"智能体集群" | 完整五阶段工作流入口 |
| 头脑风暴 | "设计我的团队"、"规划团队角色"、"帮我设计团队" | 团队负责人与你对话，设计角色，你确认 |
| 生成队友 | "生成队友"、"部署智能体"、"组建团队" | 抽取名字和人设，创建团队，启动协作 |
| 协调团队 | "查看团队进度"、"监控任务"、"催促队友" | 监控、催促、汇总、解散 |
| 使用指南 | "使用说明"、"插件怎么用"、"团队工作流介绍" | 指南、质量标准、角色模板参考 |

`/start-team` 命令会自动编排 头脑风暴 → 生成队友 → 协调团队。当你想跳到特定阶段时使用独立能力（例如你已有上次运行留下的招募计划，只想重新生成队友）。

---

## Customization

调用 `/start-team` 时直接跟团队负责人交流。告诉他们你要做什么、用什么技术栈、有什么限制，甚至直接指定某个角色的名字。团队负责人会根据你的项目动态调整团队组成。

示例：

```
/start-team 我要做一个 Rust 命令行工具，后端开发叫 Maya，质检叫 Marcus。
```

```
/start-team 需要把这套前端代码重构为另一套框架，团队保持精简。
```

---

## Troubleshooting

**问: `/start-team` 报错 "智能体团队未启用"。**
答: 环境检查应该已经提示你重启 Claude Code。完全退出进程然后重新运行 `claude`。

**问: PowerShell 拒绝运行安装脚本。**
答: 执行策略受限。用特定参数运行 —— 仅影响本次调用。

**问: 团队负责人只生成了一个工作人员。**
答: 要么项目确实很小，要么你的需求描述太窄。用更多上下文重新运行 `/start-team`，或直接编辑角色定义文件。

**问: 生成的角色定义文件可以提交到版本控制吗？**
答: 可以 —— 它们是项目级别的、每个项目确定的、设计为可版本化的。人设和名字不在这些文件里，每次创建团队都会重新注入。

**问: 如何提前解散团队？**
答: 让主会话调用解散命令，或使用应用界面命令。无论哪种方式，对话记录和结果文件都会保留在磁盘上。

**问: 插件能在 Claude Code 重启后存活吗？**
答: 插件安装本身是持久的 —— 命令一直可用。但运行中的团队不能跨会话恢复。重新运行 `/start-team` 即可从招募计划重建。

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

项目产物（招募计划、结果文件、角色定义目录）会保留 —— 如需删除请手动处理。

---

## License

MIT — 见 [LICENSE](./LICENSE)。

---

<p align="center">
  基于 Claude Code 原生智能体团队打造
</p>

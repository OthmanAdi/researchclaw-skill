# ResearchClaw 技能 — Claude Code 自主研究论文生成器

**一条命令，让 Claude Code 变成自主研究论文生成引擎。**

本技能封装了 [AutoResearchClaw](https://github.com/aiming-lab/AutoResearchClaw) — 一个 23 阶段的自主研究管线，输入研究主题即可自动生成会议级 LaTeX 论文，包含真实引文、沙箱实验、多智能体同行评审和引文验证。

[English](../../README.md) | **中文**

---

## 为什么需要这个技能？

AutoResearchClaw 功能强大，但安装配置非常痛苦。它需要 Python 3.11+、Docker、LaTeX、复杂的 YAML 配置文件，以及精确的依赖管理。项目上线 5 天内就收到了 55+ 个 issue——大多数是关于安装失败、配置混乱和 Stage 10 崩溃的问题。

本技能通过以下方式解决这些问题：

- **`/researchclaw:setup`** — 一键检测并安装所有前置依赖
- **`/researchclaw:config`** — 交互式向导，自动生成可用的 config.yaml
- **`/researchclaw:run`** — 运行前验证 + 管线执行 + 自动诊断
- **`/researchclaw:diagnose`** — 模式匹配错误检测，给出具体修复方案
- **3 个自定义钩子** — 错误自动诊断、配置备份、产物删除保护
- **诚实的错误报告** — 不虚构功能，不隐藏故障

## 快速开始

### 1. 安装技能

将 `.claude/` 目录复制到你的项目根目录：

```bash
# 克隆此仓库
git clone https://github.com/YOUR_USERNAME/researchclaw-skill.git

# 复制技能文件到你的项目
cp -r researchclaw-skill/.claude your-project/
```

### 2. 在 Claude Code 中运行安装检查

```
/researchclaw:setup
```

Claude 会检查每个依赖，告诉你缺少什么以及如何安装。

### 3. 生成配置文件

```
/researchclaw:config
```

按照交互式问题回答。你需要准备：
- 研究主题
- LLM API 密钥（OpenAI、Anthropic、DeepSeek 等）
- 实验模式（首次运行建议选 `simulated`，最快）

### 4. 运行管线

```
/researchclaw:run 你的研究主题
```

### 5. 查看状态

```
/researchclaw:status
```

## 命令列表

| 命令 | 功能 |
|---|---|
| `/researchclaw` | 显示帮助和可用子命令 |
| `/researchclaw:setup` | 检查并安装所有前置依赖 |
| `/researchclaw:config` | 交互式配置向导 |
| `/researchclaw:run` | 启动研究管线 |
| `/researchclaw:status` | 查看管线进度（X/23 阶段） |
| `/researchclaw:resume` | 从上次成功的阶段恢复 |
| `/researchclaw:diagnose` | 自动检测并解释故障 |
| `/researchclaw:validate` | 运行前验证清单 |

## 自定义钩子

本技能包含 3 个 Claude Code 钩子，自动运行：

| 钩子 | 类型 | 功能 |
|---|---|---|
| 运行后检查 | PostToolUse | 扫描 researchclaw 命令输出中的错误模式，自动诊断 |
| 配置备份 | PreToolUse | 覆盖 config.yaml 前自动备份 |
| 产物保护 | PreToolUse | 阻止意外删除 artifacts/ 目录 |
| 完成通知 | Notification | 管线完成/失败时记录日志并发送桌面通知 |

## 中国大陆用户特别说明

### 网络问题

如果无法访问 arXiv 或 Semantic Scholar，配置代理：

```bash
export HTTP_PROXY=http://your-proxy:port
export HTTPS_PROXY=http://your-proxy:port
```

### 推荐使用 DeepSeek

DeepSeek 在中国大陆访问更稳定，配置如下：

```yaml
llm:
  provider: deepseek
  model: deepseek-chat
  api_key_env: DEEPSEEK_API_KEY
```

### 镜像源加速

安装 Python 包时使用国内镜像：

```bash
pip install researchclaw[all] -i https://pypi.tuna.tsinghua.edu.cn/simple
```

## 系统要求

| 组件 | 要求 | 说明 |
|---|---|---|
| Python | 3.11+ | 核心依赖 |
| pip 或 uv | 必需 | 包管理 |
| Git | 必需 | 克隆上游仓库 |
| Docker | 沙箱模式需要 | 模拟模式不需要 |
| LaTeX | 生成 PDF 需要 | 推荐 texlive-full |
| 内存 | 最低 16 GB | 推荐 32 GB+ |
| 磁盘 | 10 GB 可用 | 大型运行推荐 50 GB+ |
| 网络 | 必需 | API 调用 + 文献检索 |

## 本技能不做的事情

诚实是核心原则。本技能：

- **不会启动 Docker** — 只检查 Docker 是否运行，无法替你启动守护进程
- **不会提供 API 密钥** — 你必须自己提供 LLM API 密钥
- **不会修复网络问题** — 如果防火墙阻止了 arXiv，技能会告诉你但无法修复
- **不保证论文质量** — 输出取决于 LLM 模型、主题复杂度和实验模式
- **不修改上游代码** — 封装官方 CLI，不是 fork

## 测试

运行自验证测试套件：

```bash
bash tests/test-skill.sh
```

**当前状态：58/58 测试通过。**

## 许可证

MIT — 与 AutoResearchClaw 上游一致。

---

**基于 [AutoResearchClaw](https://github.com/aiming-lab/AutoResearchClaw)（aiming-lab）构建，灵感来自 [Karpathy 的 autoresearch](https://github.com/karpathy/autoresearch) 理念。**

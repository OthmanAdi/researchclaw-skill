---
name: researchclaw-cn
description: AutoResearchClaw 23 阶段自主研究管线的中文技能。自动设置、交互式配置、执行监控和故障诊断。当用户提到 ResearchClaw、自主研究、论文生成、研究管线时使用。
license: MIT
user-invocable: true
compatibility: 需要 Python 3.11+、Docker 和 LaTeX。支持 Claude Code 及兼容的编码代理。
metadata:
  author: OthmanAdi
  version: "1.0.0"
  upstream: https://github.com/aiming-lab/AutoResearchClaw
  upstream-version: "0.3.1"
  language: zh-CN
allowed-tools: Bash(python*) Bash(pip*) Bash(docker*) Bash(researchclaw*) Bash(git*) Bash(cat*) Bash(ls*) Bash(grep*) Bash(which*) Bash(uv*) Read Write Grep Glob
hooks:
  PostToolUse:
    - matcher: "Bash(researchclaw*)"
      hooks:
        - type: command
          command: "bash \"${CLAUDE_SKILL_DIR}/scripts/post-run-check.sh\""
  PreToolUse:
    - matcher: "Write(config.yaml)"
      hooks:
        - type: command
          command: "bash \"${CLAUDE_SKILL_DIR}/scripts/pre-config-write.sh\""
    - matcher: "Bash(rm *artifacts*)"
      hooks:
        - type: command
          command: "bash \"${CLAUDE_SKILL_DIR}/scripts/pre-delete-guard.sh\""
---


# ResearchClaw 技能 — 自主研究管线（中文版）

> **重要提示：本技能需要先安装 [AutoResearchClaw](https://github.com/aiming-lab/AutoResearchClaw)。** 本技能是封装层，不能独立运行。请先安装上游项目，再安装本技能。

本技能封装了 [AutoResearchClaw](https://github.com/aiming-lab/AutoResearchClaw)，一个 23 阶段的自主研究管线。输入一个研究主题，即可自动完成从文献综述到论文生成的全流程，包括真实引文检索、沙箱实验执行、多智能体同行评审和引文验证。

**诚实原则：** 本技能不会虚构功能。每个命令都映射到真实的上游功能。如果某些功能失败，技能会报告实际错误并建议具体的修复方案——绝不假装问题不存在。

## 命令列表

| 命令 | 功能 |
|---|---|
| `/researchclaw` | 显示帮助信息和可用子命令 |
| `/researchclaw:setup` | 检查并安装所有前置依赖（Python、Docker、LaTeX、pip 包） |
| `/researchclaw:config` | 交互式配置向导 — 生成可用的 `config.yaml` |
| `/researchclaw:run` | 启动研究管线 |
| `/researchclaw:status` | 查看管线运行状态 |
| `/researchclaw:resume` | 从上次成功的阶段恢复运行 |
| `/researchclaw:diagnose` | 自动检测并解释常见故障 |
| `/researchclaw:validate` | 运行前验证配置、依赖和连接性 |

---

## /researchclaw — 帮助

调用时不带子命令，显示命令列表和状态摘要：

1. 检查 `researchclaw` CLI 是否已安装：`which researchclaw`
2. 检查当前目录是否有 `config.yaml`
3. 打印上方命令表
4. 根据缺失的组件建议下一步操作

---

## /researchclaw:setup — 前置依赖安装

**必须：安装任何内容前先征求用户同意。** 展示缺失项并获得明确批准。

运行前置检查脚本：

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/check-prereqs.sh"
```

脚本检查每个依赖并输出 JSON 报告。根据报告：

1. **Python 3.11+**：检查 `python3 --version`。如果缺失或版本太旧，建议 `pyenv install 3.11` 或系统包管理器。
2. **pip / uv**：检查 `pip3 --version` 或 `uv --version`。如果没有 `uv`，建议安装（更快）。
3. **Docker**：检查 `docker info`。如果 Docker 守护进程未运行，如实告知用户——本技能无法在大多数系统上启动 Docker。
4. **LaTeX**：检查 `pdflatex --version`。如果缺失，建议 `sudo apt-get install texlive-full`（Linux）或 `brew install --cask mactex`（macOS）。**如实说明：这是大型下载（2-4 GB）。**
5. **AutoResearchClaw**：检查 `pip3 show researchclaw`。如果未安装：
   ```bash
   pip3 install researchclaw
   ```
   或从源码安装：
   ```bash
   git clone https://github.com/aiming-lab/AutoResearchClaw.git
   cd AutoResearchClaw
   pip3 install -e ".[all]"
   ```

**中国大陆用户**：使用国内镜像加速安装：
```bash
pip install researchclaw[all] -i https://pypi.tuna.tsinghua.edu.cn/simple
```

**本技能无法做到的事：**
- 启动 Docker 守护进程（需要系统级权限）
- 在 Linux 上不用 sudo 安装 LaTeX
- 修复阻止 API 访问的网络/防火墙问题
- 提供 LLM API 密钥——用户必须自己提供

---

## /researchclaw:config — 交互式配置向导

通过分批询问用户来生成可用的 `config.yaml`。每批使用 `AskUserQuestion`。

**第一批 — 必要设置（必须询问）：**

1. **研究主题**：你想研究什么？（自由文本）
2. **LLM 提供商**：使用哪个 LLM API？选项：`openai`、`anthropic`、`azure`、`deepseek`、`local`
3. **API 密钥**：提供 API 密钥，或保存密钥的环境变量名（如 `OPENAI_API_KEY`）
4. **模型**：使用哪个模型？按提供商建议默认值：
   - openai：`gpt-4o`
   - anthropic：`claude-sonnet-4-20250514`
   - deepseek：`deepseek-chat`

**第二批 — 实验设置（带智能默认值询问）：**

5. **实验模式**：`simulated`（无代码执行，最快）、`sandbox`（本地执行）或 `ssh_remote`（GPU 服务器）。默认：`simulated`
6. **自动审批门控**：跳过阶段 5、9、20 的人工审批？默认：首次运行选 `true`
7. **输出目录**：保存产物的位置。默认：`artifacts/`

**第三批 — 可选高级设置（提供但不要求）：**

8. **论文模板**：`neurips`、`icml`、`iclr` 或 `generic`。默认：`neurips`
9. **最大迭代次数**：迭代管线模式。默认：`3`
10. **文献来源**：`arxiv`、`semantic_scholar` 或 `both`。默认：`both`

收集答案后，使用 `assets/config-template.yaml` 中的模板生成 `config.yaml`。写入当前目录并展示给用户。

---

## /researchclaw:run — 执行管线

**起飞前检查（启动前必须运行）：**

1. 静默运行 `/researchclaw:validate` 逻辑
2. 如果任何检查失败，报告并询问用户是继续还是先修复

**启动管线：**

```bash
researchclaw run --topic "$ARGUMENTS" --config config.yaml --auto-approve 2>&1 | tee researchclaw-run.log
```

如果 `$ARGUMENTS` 为空，从 `config.yaml` 读取主题。

**执行期间：**
- 管线运行 23 个阶段。每个阶段在 `artifacts/<run-id>/stage-N/` 中产生输出
- 通过检查阶段目录是否存在来监控进度
- 如果管线失败，捕获错误输出并自动运行 `/researchclaw:diagnose` 逻辑

**完成后：**
- 报告哪些阶段成功、哪些失败
- 显示生成论文的路径
- 显示总执行时间

---

## /researchclaw:status — 管线状态

检查管线运行的当前状态：

1. 找到最新的 `artifacts/rc-*` 目录
2. 统计已完成的阶段数
3. 检查 `pipeline_summary.json`——如果存在则运行已完成
4. 报告：`阶段 X/23 已完成。当前阶段：[阶段名称]。状态：[运行中/失败/完成]`

**阶段名称映射：**

| 阶段 | 名称 |
|---|---|
| 1 | 主题初始化 |
| 2 | 问题分解 |
| 3 | 文献检索 |
| 4 | 文献分析 |
| 5 | 研究方向（门控） |
| 6 | 假设生成 |
| 7 | 实验设计 |
| 8 | 实验评审 |
| 9 | 实验审批（门控） |
| 10 | 代码生成 |
| 11 | 代码评审 |
| 12 | 实验执行 |
| 13 | 结果收集 |
| 14 | 结果分析 |
| 15 | 论文大纲 |
| 16 | 章节撰写 |
| 17 | 论文初稿 |
| 18 | 同行评审 |
| 19 | 修订 |
| 20 | 最终审查（门控） |
| 21 | 引文验证 |
| 22 | 可视化 |
| 23 | 最终导出 |

---

## /researchclaw:resume — 恢复失败的运行

从上次成功的阶段恢复：

1. 找到最新的运行目录
2. 找到最后完成的阶段
3. 运行：
   ```bash
   researchclaw run --config config.yaml --from-stage STAGE_NAME --output <run-dir> --auto-approve
   ```

**已知问题（上游）：** `--from-stage` 标志在所有版本中可能不正确工作。如果恢复失败，如实告知用户并建议重新开始。

---

## /researchclaw:diagnose — 自动诊断故障

读取最近的日志和错误输出来识别问题：

```bash
tail -100 researchclaw-run.log 2>/dev/null || tail -100 researchclaw-resume.log 2>/dev/null
```

**常见故障模式和修复：**

| 错误模式 | 原因 | 修复 |
|---|---|---|
| `HTTP 401` | API 密钥无效或过期 | 检查 `config.yaml` → `llm.api_key` 或环境变量 |
| `HTTP 429` | API 速率限制 | 等待 60 秒后恢复，或切换模型 |
| `Stage 10` 失败 | 代码生成产生无效 Python | 检查生成的代码，使用更强模型 |
| `Docker` 错误 | Docker 未运行或权限不足 | 运行 `docker info` 验证 |
| `pdflatex` 未找到 | LaTeX 未安装 | 安装 texlive-full |
| `quality_score < threshold` | 质量门控太严格 | 降低 `quality.min_score`（默认 2.0 很严格） |
| `MemoryError` | 内存不足（需要 32GB+） | 使用 `simulated` 模式 |

---

## /researchclaw:validate — 运行前验证

运行所有检查但不启动管线：

1. **配置语法**：验证 YAML 可解析
2. **配置完整性**：检查 API 密钥和研究主题已设置
3. **API 连通性**：测试 LLM 端点
4. **Docker 健康**：`docker info`（如果是沙箱模式）
5. **磁盘空间**：低于 10 GB 时警告
6. **写入权限**：测试可以写入 artifacts/

以通过/失败清单形式报告结果。

---

## 中国大陆用户特别说明

### 推荐使用 DeepSeek

DeepSeek 在中国大陆访问更稳定：

```yaml
llm:
  provider: deepseek
  model: deepseek-chat
  api_key_env: DEEPSEEK_API_KEY
```

### 网络代理

如果无法访问 arXiv 或 Semantic Scholar：

```bash
export HTTP_PROXY=http://your-proxy:port
export HTTPS_PROXY=http://your-proxy:port
```

### 镜像源加速

```bash
pip install researchclaw[all] -i https://pypi.tuna.tsinghua.edu.cn/simple
```

---

## 原则

1. **绝不撒谎。** 如果某个功能坏了，如实说明。如果上游不存在某个功能，不假装存在。
2. **始终测试。** 每次管线执行前运行验证。每次操作后检查结果。
3. **行动前先询问。** 未经用户明确批准，绝不安装包、修改配置或启动长时间运行的进程。
4. **如实报告。** 显示实际错误信息，不显示美化的摘要。
5. **保持更新。** 本技能针对 AutoResearchClaw v0.3.x。

# ResearchClaw 技能 — 自主研究管线

[English](../SKILL.md) | **中文**

## 简介

本技能封装了 [AutoResearchClaw](https://github.com/aiming-lab/AutoResearchClaw)，一个 23 阶段的自主研究管线。输入一个研究主题，即可自动完成从文献综述到论文生成的全流程，包括真实引文检索、沙箱实验执行、多智能体同行评审和引文验证。

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

## 快速开始

### 第一步：安装前置依赖

```bash
/researchclaw:setup
```

技能会自动检测缺少的依赖，并在安装前征求你的同意。

### 第二步：生成配置文件

```bash
/researchclaw:config
```

按照交互式向导回答问题，技能会自动生成 `config.yaml`。

你需要准备：
- **研究主题**：你想研究什么？
- **LLM API 密钥**：OpenAI、Anthropic、DeepSeek 等任一提供商的 API 密钥
- **实验模式**：`simulated`（模拟，最快）、`sandbox`（本地执行）或 `ssh_remote`（远程 GPU）

### 第三步：运行管线

```bash
/researchclaw:run 你的研究主题
```

### 第四步：查看状态

```bash
/researchclaw:status
```

## 系统要求

| 组件 | 最低要求 | 推荐配置 |
|---|---|---|
| Python | 3.11+ | 3.12+ |
| 内存 | 16 GB | 32 GB+ |
| 磁盘 | 10 GB 可用空间 | 50 GB+ |
| Docker | 可选（模拟模式不需要） | 推荐安装 |
| LaTeX | 可选（生成 PDF 需要） | texlive-full |
| 网络 | 必需（API 调用 + 文献检索） | 稳定宽带 |

## 常见问题

### API 密钥错误 (HTTP 401)

检查 `config.yaml` 中的 `llm.api_key_env` 是否指向正确的环境变量。

```bash
echo $OPENAI_API_KEY  # 确认变量已设置
```

### 阶段 10 代码生成失败

这是最常见的失败点。建议：
1. 使用更强的模型（gpt-4o 或 claude-sonnet-4-20250514）
2. 切换到 `simulated` 模式跳过代码执行
3. 运行 `/researchclaw:diagnose` 获取详细错误信息

### 质量门控拒绝

默认阈值（2.0）非常严格。编辑 `config.yaml`：

```yaml
quality:
  min_score: 3.0  # 降低阈值
```

### Docker 未运行

```bash
# Linux
sudo systemctl start docker

# macOS
open -a Docker
```

### 中国大陆网络问题

如果无法访问 arXiv 或 Semantic Scholar：

1. 配置代理：
```bash
export HTTP_PROXY=http://your-proxy:port
export HTTPS_PROXY=http://your-proxy:port
```

2. 考虑使用 DeepSeek 作为 LLM 提供商（国内访问更稳定）：
```yaml
llm:
  provider: deepseek
  model: deepseek-chat
  api_key_env: DEEPSEEK_API_KEY
```

## 管线阶段概览

| 阶段 | 名称 | 说明 |
|---|---|---|
| 1 | 主题初始化 | 解析和细化研究主题 |
| 2 | 问题分解 | 将研究问题拆分为子问题 |
| 3 | 文献检索 | 从 arXiv 和 Semantic Scholar 搜索相关论文 |
| 4 | 文献分析 | 阅读、总结并识别研究空白 |
| 5 | 研究方向（门控） | 提交研究方向供人工审批 |
| 6 | 假设生成 | 基于文献空白生成可测试的假设 |
| 7 | 实验设计 | 设计实验来测试每个假设 |
| 8 | 实验评审 | AI 评审实验设计 |
| 9 | 实验审批（门控） | 提交实验计划供人工审批 |
| 10 | 代码生成 | 生成 Python 实验代码 |
| 11 | 代码评审 | AI 评审生成的代码 |
| 12 | 实验执行 | 在沙箱/模拟/远程模式下执行实验 |
| 13 | 结果收集 | 收集和整理实验结果 |
| 14 | 结果分析 | 统计分析和结果解读 |
| 15 | 论文大纲 | 生成论文结构和章节大纲 |
| 16 | 章节撰写 | 撰写各章节 |
| 17 | 论文初稿 | 组装完整论文初稿 |
| 18 | 同行评审 | 多智能体模拟会议审稿人评审 |
| 19 | 修订 | 根据评审意见修改论文 |
| 20 | 最终审查（门控） | 提交修改后的论文供人工审批 |
| 21 | 引文验证 | 四层引文验证 |
| 22 | 可视化 | 生成图表和图形 |
| 23 | 最终导出 | 编译 LaTeX 为 PDF |

## 诚实声明

本技能不会虚构功能。每个命令都映射到真实的上游功能。如果某些功能失败，技能会报告实际错误并建议具体的修复方案——绝不假装问题不存在。

<p align="center">
  <img src="https://raw.githubusercontent.com/OthmanAdi/researchclaw-skill/main/media/banner.png" alt="ResearchClaw" width="800">
</p>

<p align="center">
  <strong>Turn your coding agent into a one-command autonomous research paper generator.</strong>
</p>

<p align="center">
  <a href="https://github.com/aiming-lab/AutoResearchClaw"><img src="https://img.shields.io/badge/Wraps-AutoResearchClaw_v0.3.x-red" alt="AutoResearchClaw"></a>
  <a href="#"><img src="https://img.shields.io/badge/Tests-58%2F58_passing-brightgreen" alt="Tests"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"></a>
  <a href="#"><img src="https://img.shields.io/badge/version-1.0.0-blue" alt="Version"></a>
</p>

<p align="center">
  <a href="https://code.claude.com/docs/en/skills"><img src="https://img.shields.io/badge/Claude%20Code-Skill-blue" alt="Claude Code Skill"></a>
  <a href="https://docs.cursor.com/context/skills"><img src="https://img.shields.io/badge/Cursor-Skills-purple" alt="Cursor Skills"></a>
  <a href="https://geminicli.com/docs/cli/skills/"><img src="https://img.shields.io/badge/Gemini%20CLI-Skills-4285F4" alt="Gemini CLI"></a>
  <a href="https://openclaw.ai"><img src="https://img.shields.io/badge/OpenClaw-Skills-FF6B6B" alt="OpenClaw"></a>
  <a href="https://developers.openai.com/codex/skills"><img src="https://img.shields.io/badge/Codex-Skills-74aa9c" alt="Codex"></a>
</p>

<p align="center">
  <a href="docs/zh-CN/README.md"><strong>中文文档 Chinese Documentation</strong></a>
</p>

---

> **This skill requires [AutoResearchClaw](https://github.com/aiming-lab/AutoResearchClaw) to be installed.** It is a wrapper that simplifies setup, configuration, execution, and troubleshooting — it does not replace the upstream project. Install AutoResearchClaw first, then install this skill on top.

---

<details>
<summary><strong>What is AutoResearchClaw?</strong></summary>

[AutoResearchClaw](https://github.com/aiming-lab/AutoResearchClaw) is a fully autonomous 23-stage research pipeline by [aiming-lab](https://github.com/aiming-lab). You give it a research topic. It gives you a conference-grade LaTeX paper.

What happens in those 23 stages:

| Phase | What It Does |
|-------|-------------|
| **Research Scoping** | Parses your topic, decomposes it into sub-problems |
| **Literature Discovery** | Searches arXiv, Semantic Scholar, OpenAlex for real papers |
| **Knowledge Synthesis** | Clusters findings, identifies gaps, generates testable hypotheses |
| **Experiment Design** | Plans experiments, generates hardware-aware Python code |
| **Experiment Execution** | Runs code in a sandbox with self-healing (up to 10 repair cycles) |
| **Analysis & Decision** | Multi-agent result analysis — autonomously decides to proceed, refine, or pivot |
| **Paper Writing** | Generates 5,000-6,500 word paper with multi-agent peer review |
| **Finalization** | 4-layer citation verification, LaTeX export, PDF compilation |

The pipeline includes 3 human-approval gates, anti-fabrication guards, and a self-learning system (MetaClaw) that gets smarter with each run.

**The problem:** AutoResearchClaw is powerful but painful to set up. 55+ issues filed in the first 5 days — most about setup failures, config confusion, and Stage 10 crashes.

**This skill solves that.**

</details>

## Quick Install

```bash
npx skills add OthmanAdi/researchclaw-skill --skill researchclaw -g
```

中文版 / Chinese:
```bash
npx skills add OthmanAdi/researchclaw-skill --skill researchclaw-cn -g
```

Works with Claude Code, Cursor, Codex, Gemini CLI, OpenClaw, and any agent supporting the [Agent Skills](https://agentskills.io) spec.

### Prerequisites

**You must install AutoResearchClaw before using this skill:**

```bash
pip install researchclaw
```

Or from source (recommended for latest features):

```bash
git clone https://github.com/aiming-lab/AutoResearchClaw.git
cd AutoResearchClaw
pip install -e ".[all]"
```

You also need:
- **Python 3.11+**
- **An LLM API key** (OpenAI, Anthropic, DeepSeek, or any OpenAI-compatible provider)
- **Docker** (optional — only for sandbox experiment mode)
- **LaTeX** (optional — only for PDF compilation)

## Commands

| Command | What It Does |
|---------|-------------|
| `/researchclaw` | Show help and suggest next step based on what's missing |
| `/researchclaw:setup` | Detect and install all prerequisites (asks before installing anything) |
| `/researchclaw:config` | Interactive wizard — generates a working `config.yaml` in 3 question batches |
| `/researchclaw:run` | Pre-flight validation + pipeline execution + auto-diagnosis on failure |
| `/researchclaw:status` | Show progress: `Stage X/23 — [stage name] — [running/failed/complete]` |
| `/researchclaw:resume` | Resume from last successful stage (with workarounds for known upstream bugs) |
| `/researchclaw:diagnose` | Pattern-match errors from logs and surface concrete fixes |
| `/researchclaw:validate` | Run all checks without starting the pipeline |

## How It Works

```
You: /researchclaw:config
     ↓ answers 3 batches of questions (topic, LLM, experiment mode)
     ↓ generates config.yaml

You: /researchclaw:run "Attention mechanisms for time series forecasting"
     ↓ pre-flight validation (config, API key, Docker, disk space)
     ↓ launches AutoResearchClaw pipeline
     ↓ monitors 23 stages automatically
     ↓ auto-diagnoses failures via PostToolUse hook
     ↓ reports results with paper location

You: artifacts/rc-20260320-141523-a7f3/deliverables/paper.pdf
```

<p align="center">
  <img src="https://raw.githubusercontent.com/OthmanAdi/researchclaw-skill/main/media/logo_wizard.png" alt="ResearchClaw Wizard" width="200">
</p>

## Custom Hooks

This skill includes 4 Claude Code hooks that run automatically — no configuration needed:

| Hook | Event | What It Does |
|------|-------|-------------|
| Error Scanner | `PostToolUse` | Scans output of any `researchclaw` command for 10 known error patterns (HTTP 401, Stage 10, OOM, Docker, LaTeX, rate limits) and surfaces auto-diagnosis |
| Config Backup | `PreToolUse` | Creates timestamped backup of `config.yaml` before any overwrite |
| Artifact Guard | `PreToolUse` | Blocks accidental deletion of `artifacts/` directory |
| Completion Notify | `Notification` | Logs pipeline completion/failure + sends desktop notification |

## What This Skill Does NOT Do

Honesty is a core principle. This skill:

- **Does not replace AutoResearchClaw** — It wraps the official CLI. You must install the upstream project first.
- **Does not start Docker** — It checks if Docker is running, but cannot start the daemon for you
- **Does not provide API keys** — You must supply your own LLM API keys
- **Does not fix network issues** — If your firewall blocks arXiv or Semantic Scholar, the skill tells you but cannot fix it
- **Does not guarantee paper quality** — Output depends on the LLM model, topic complexity, and experiment mode
- **Does not modify upstream code** — Zero changes to AutoResearchClaw's codebase

<details>
<summary><strong>Common Errors and Fixes</strong></summary>

The skill's `PostToolUse` hook catches these automatically, but here's the reference:

| Error Pattern | Cause | Fix |
|--------------|-------|-----|
| `HTTP 401` / `AuthenticationError` | Invalid or expired API key | Check `config.yaml` → `llm.api_key_env` or the env var it points to |
| `HTTP 429` / `RateLimitError` | API rate limit hit | Wait 60 seconds and `/researchclaw:resume`, or switch model |
| `Stage 10` failure | Code generation produced invalid Python | Use a stronger model (gpt-4o, claude-sonnet-4-20250514) or switch to `simulated` mode |
| `Docker` errors | Docker not running or permission denied | Run `docker info` to check; may need `sudo usermod -aG docker $USER` |
| `pdflatex` not found | LaTeX not installed | `sudo apt-get install texlive-full` (Linux) or `brew install --cask mactex` (macOS) |
| `quality_score < threshold` | Quality gate too strict | Lower `quality.min_score` in config (default 2.0 is very strict, try 3.0-4.0) |
| `MemoryError` / OOM | Insufficient RAM | Use `simulated` experiment mode or reduce `max_concurrent_stages` |
| `ConnectionError` | Network issue with arXiv/Semantic Scholar | Check internet; try `curl https://api.semanticscholar.org/graph/v1/paper/search?query=test` |
| `YAML` parse error | Malformed config file | Run `python3 -c "import yaml; yaml.safe_load(open('config.yaml'))"` |
| `ModuleNotFoundError` | Missing Python dependency | Run `pip install researchclaw[all]` |

</details>

<details>
<summary><strong>ACP Mode — Use Your Agent as the LLM Brain</strong></summary>

AutoResearchClaw supports **ACP (Agent Client Protocol)**, which lets your coding agent (Claude Code, Copilot CLI, Gemini CLI) act as the LLM backend for all 23 stages. No separate API key needed.

```yaml
llm:
  provider: "acp"
  acp:
    agent: "claude"
    cwd: "."
```

In ACP mode, the pipeline maintains a **persistent session** with your agent across all stages. The agent remembers context from literature review when designing experiments, and from experiments when writing the paper.

</details>

<details>
<summary><strong>Pipeline Stage Reference (All 23 Stages)</strong></summary>

| # | Stage | Phase | Gate? |
|---|-------|-------|-------|
| 1 | Topic Initialization | Research Scoping | |
| 2 | Problem Decomposition | Research Scoping | |
| 3 | Search Strategy | Literature Discovery | |
| 4 | Literature Collection | Literature Discovery | |
| 5 | Literature Screening | Literature Discovery | Human Approval |
| 6 | Knowledge Extraction | Literature Discovery | |
| 7 | Synthesis | Knowledge Synthesis | |
| 8 | Hypothesis Generation | Knowledge Synthesis | |
| 9 | Experiment Design | Experiment Design | Human Approval |
| 10 | Code Generation | Experiment Design | |
| 11 | Resource Planning | Experiment Design | |
| 12 | Experiment Execution | Execution | |
| 13 | Iterative Refinement | Execution | |
| 14 | Result Analysis | Analysis | |
| 15 | Research Decision | Analysis | PROCEED / REFINE / PIVOT |
| 16 | Paper Outline | Paper Writing | |
| 17 | Paper Draft | Paper Writing | |
| 18 | Peer Review | Paper Writing | |
| 19 | Paper Revision | Paper Writing | |
| 20 | Quality Gate | Finalization | Human Approval |
| 21 | Knowledge Archive | Finalization | |
| 22 | Export & Publish | Finalization | |
| 23 | Citation Verification | Finalization | |

Gate stages (5, 9, 20) pause for human approval. Skip with `--auto-approve`.

Stage 15 can autonomously loop: REFINE goes back to Stage 13, PIVOT goes back to Stage 8.

</details>

## Project Structure

```
.claude/
├── hooks.json                          # 4 Claude Code hooks
└── skills/
    └── researchclaw/
        ├── SKILL.md                    # Main skill definition
        ├── assets/
        │   └── config-template.yaml    # Config generation template
        ├── references/
        │   ├── pipeline-stages.md      # All 23 stages documented
        │   ├── config-reference.md     # Every config field explained
        │   ├── troubleshooting.md      # 10 error patterns with fixes
        │   └── README-CN.md           # Chinese reference
        └── scripts/
            ├── check-prereqs.sh        # JSON prerequisite report
            ├── post-run-check.sh       # PostToolUse error scanner
            ├── pre-config-write.sh     # PreToolUse config backup
            ├── pre-delete-guard.sh     # PreToolUse artifact guard
            └── notify-completion.sh    # Completion notification
tests/
└── test-skill.sh                       # 58-test self-validation suite
docs/
└── zh-CN/
    └── README.md                       # Full Chinese documentation
media/
├── banner.png                          # Repo banner
├── logo.png                            # Logo (researcher lobster)
└── logo_wizard.png                     # Logo variant (wizard lobster)
```

## Testing

```bash
bash tests/test-skill.sh
```

Validates file structure (21 checks), content quality (20 checks), script syntax (5 checks), hooks configuration (4 checks), and config template (8 checks).

**58/58 tests passing.**

## System Requirements

| Component | Required | Notes |
|-----------|---------|-------|
| **AutoResearchClaw** | **Yes** | **`pip install researchclaw` — this skill does not work without it** |
| Python | 3.11+ | Core requirement |
| pip or uv | Yes | Package installation |
| Git | Yes | Cloning upstream repo |
| LLM API key | Yes | OpenAI, Anthropic, DeepSeek, or any OpenAI-compatible provider |
| Docker | For sandbox mode | Not needed for simulated mode |
| LaTeX | For PDF output | texlive-full recommended |
| RAM | 16 GB minimum | 32 GB+ recommended for full pipeline |
| Disk | 10 GB free | 50 GB+ for large runs with Docker |

## Upstream

This skill wraps **[AutoResearchClaw](https://github.com/aiming-lab/AutoResearchClaw) v0.3.x** by [aiming-lab](https://github.com/aiming-lab). All research pipeline functionality comes from the upstream project. This skill adds setup automation, interactive configuration, error diagnosis, and hooks — it does not fork or modify the upstream codebase.

Inspired by [Karpathy's autoresearch](https://github.com/karpathy/autoresearch) philosophy and the wave of autonomous research tools that followed.

## Contributing

1. Run `bash tests/test-skill.sh` before submitting
2. Ensure all 58 tests pass
3. Add tests for new functionality
4. Keep the honesty policy — never fabricate capabilities

## License

MIT — same as AutoResearchClaw upstream.

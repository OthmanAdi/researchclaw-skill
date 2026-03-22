---
name: researchclaw
description: Automate setup, configuration, execution, monitoring, and troubleshooting of AutoResearchClaw — the 23-stage autonomous research pipeline that generates conference-grade papers. Use when the user mentions ResearchClaw, wants to write a research paper autonomously, needs to set up or debug the pipeline, or says research paper, autonomous research, or paper generation.
license: MIT
user-invocable: true
compatibility: Requires Python 3.11+, Docker, and a LaTeX distribution. Works with Claude Code and compatible coding agents.
metadata:
  author: OthmanAdi
  version: "1.0.0"
  upstream: https://github.com/aiming-lab/AutoResearchClaw
  upstream-version: "0.3.1"
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


# ResearchClaw Skill — Autonomous Research Pipeline

This skill wraps [AutoResearchClaw](https://github.com/aiming-lab/AutoResearchClaw), a 23-stage pipeline that takes a research topic and produces a conference-grade LaTeX paper with real citations, sandbox-executed experiments, multi-agent peer review, and citation verification.

**Honesty policy:** This skill does not fabricate capabilities. Every command maps to real upstream functionality. If something fails, the skill reports the actual error and suggests concrete fixes — it never pretends the problem does not exist.

## Commands

| Command | Purpose |
|---|---|
| `/researchclaw` | Show help and available subcommands |
| `/researchclaw:setup` | Check and install all prerequisites (Python, Docker, LaTeX, pip packages) |
| `/researchclaw:config` | Interactive config wizard — generates a working `config.yaml` |
| `/researchclaw:run` | Start a research pipeline run |
| `/researchclaw:status` | Check the status of a running or completed pipeline |
| `/researchclaw:resume` | Resume a pipeline from the last successful stage |
| `/researchclaw:diagnose` | Auto-detect and explain common failures |
| `/researchclaw:validate` | Validate config, dependencies, and connectivity before running |

---

## /researchclaw — Help

When invoked without a subcommand, display this command list and a one-line status summary:

1. Check if `researchclaw` CLI is installed: `which researchclaw`
2. Check if `config.yaml` exists in the current directory
3. Print the command table above
4. Suggest the most logical next step based on what is missing

---

## /researchclaw:setup — Prerequisites Installation

**MANDATORY: Ask the user before installing anything.** Present what is missing and get explicit approval.

Run the prerequisite check script:

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/check-prereqs.sh"
```

The script checks each dependency and outputs a JSON report. Based on the report:

1. **Python 3.11+**: Check `python3 --version`. If missing or too old, suggest `pyenv install 3.11` or system package manager.
2. **pip / uv**: Check `pip3 --version` or `uv --version`. Suggest `uv` if not present (faster).
3. **Docker**: Check `docker info`. If Docker daemon is not running, tell the user honestly — this skill cannot start Docker for you on most systems.
4. **LaTeX**: Check `pdflatex --version`. If missing, suggest `sudo apt-get install texlive-full` (Linux) or `brew install --cask mactex` (macOS). **Be honest: this is a large download (2-4 GB).**
5. **AutoResearchClaw**: Check `pip3 show researchclaw`. If not installed:
   ```bash
   pip3 install researchclaw
   ```
   Or from source:
   ```bash
   git clone https://github.com/aiming-lab/AutoResearchClaw.git
   cd AutoResearchClaw
   pip3 install -e ".[all]"
   ```

After installation, re-run the check script to verify everything passes.

**What this skill CANNOT do:**
- Start the Docker daemon (requires system-level access)
- Install LaTeX without sudo on Linux
- Fix network/firewall issues blocking API access
- Provide LLM API keys — the user must supply their own

---

## /researchclaw:config — Interactive Configuration Wizard

Generate a working `config.yaml` by asking the user a series of questions. Use `AskUserQuestion` for each batch.

**Batch 1 — Essential settings (MUST ask):**

1. **Research topic**: What do you want to research? (free text)
2. **LLM provider**: Which LLM API? Options: `openai`, `anthropic`, `azure`, `deepseek`, `local`
3. **API key**: Provide your API key, or the environment variable name that holds it (e.g., `OPENAI_API_KEY`)
4. **Model**: Which model? Suggest defaults per provider:
   - openai: `gpt-4o`
   - anthropic: `claude-sonnet-4-20250514`
   - deepseek: `deepseek-chat`

**Batch 2 — Experiment settings (ask with smart defaults):**

5. **Experiment mode**: `simulated` (no code execution, fastest), `sandbox` (local execution), or `ssh_remote` (GPU server). Default: `simulated`
6. **Auto-approve gates**: Skip human approval at stages 5, 9, 20? Default: `true` for first run
7. **Output directory**: Where to save artifacts. Default: `artifacts/`

**Batch 3 — Optional advanced settings (offer but don't require):**

8. **Paper template**: `neurips`, `icml`, `iclr`, or `generic`. Default: `neurips`
9. **Max iterations**: For iterative pipeline mode. Default: `3`
10. **Literature sources**: `arxiv`, `semantic_scholar`, or `both`. Default: `both`

After collecting answers, generate `config.yaml` using the template in `assets/config-template.yaml`. Write it to the current directory and show the user the generated file.

**Validation**: After generating, run:
```bash
researchclaw validate --config config.yaml
```

If validation fails, explain what went wrong and offer to fix it.

---

## /researchclaw:run — Execute the Pipeline

**Pre-flight checks (always run before starting):**

1. Run `/researchclaw:validate` logic silently
2. If any check fails, report it and ask the user whether to proceed or fix first

**Start the pipeline:**

```bash
researchclaw run --topic "$ARGUMENTS" --config config.yaml --auto-approve 2>&1 | tee researchclaw-run.log
```

If `$ARGUMENTS` is empty, read the topic from `config.yaml`.

**During execution:**
- The pipeline runs 23 stages. Each stage produces output in `artifacts/<run-id>/stage-N/`
- Monitor progress by checking which stage directories exist
- If the pipeline fails, capture the error output and run `/researchclaw:diagnose` logic automatically

**After completion:**
- Report which stages succeeded and which failed
- Show the path to the generated paper (typically `artifacts/<run-id>/stage-17/paper_draft.md` or the final PDF)
- Show total execution time

---

## /researchclaw:status — Pipeline Status

Check the current state of a pipeline run:

```bash
ls -la artifacts/ 2>/dev/null | tail -5
```

For the most recent run:

1. Find the latest `artifacts/rc-*` directory
2. Count completed stages: `ls -d artifacts/rc-*/stage-* 2>/dev/null | wc -l`
3. Check for `pipeline_summary.json` — if it exists, the run is complete
4. If no summary exists, check which stage was last modified to estimate current progress
5. Report: `Stage X/23 complete. Current stage: [stage name]. Status: [running/failed/complete]`

**Stage name mapping** (for human-readable output):

| Stage | Name |
|---|---|
| 1 | Topic Initialization |
| 2 | Problem Decomposition |
| 3 | Literature Search |
| 4 | Literature Analysis |
| 5 | Research Direction (Gate) |
| 6 | Hypothesis Generation |
| 7 | Experiment Design |
| 8 | Experiment Plan Review |
| 9 | Experiment Approval (Gate) |
| 10 | Code Generation |
| 11 | Code Review |
| 12 | Experiment Execution |
| 13 | Result Collection |
| 14 | Result Analysis |
| 15 | Paper Outline |
| 16 | Section Writing |
| 17 | Paper Draft |
| 18 | Peer Review |
| 19 | Revision |
| 20 | Final Review (Gate) |
| 21 | Citation Verification |
| 22 | Visualization |
| 23 | Final Export |

---

## /researchclaw:resume — Resume a Failed Run

Resume from the last successful stage:

1. Find the latest run directory: `ls -td artifacts/rc-* | head -1`
2. Find the last completed stage: check `pipeline_summary.json` or find the highest-numbered `stage-*` directory with output files
3. Determine the next stage name from the stage mapping above
4. Run:
   ```bash
   researchclaw run --config config.yaml --from-stage STAGE_NAME --output <run-dir> --auto-approve 2>&1 | tee researchclaw-resume.log
   ```

**Known issue (upstream):** The `--from-stage` flag may not work correctly in all versions. If resume fails, inform the user honestly and suggest:
- Starting a fresh run
- Manually copying successful stage outputs to a new run directory

---

## /researchclaw:diagnose — Auto-Diagnose Failures

Read the most recent log and error output to identify the problem:

```bash
tail -100 researchclaw-run.log 2>/dev/null || tail -100 researchclaw-resume.log 2>/dev/null
```

**Common failure patterns and fixes:**

| Error Pattern | Cause | Fix |
|---|---|---|
| `HTTP 401` or `AuthenticationError` | Invalid or expired API key | Check `config.yaml` → `llm.api_key` or the env var |
| `HTTP 429` or `RateLimitError` | API rate limit hit | Wait 60 seconds and resume, or switch to a different model |
| `Stage 10` failure | Code generation produced invalid Python | Check `artifacts/*/stage-10/experiment.py` for syntax errors |
| `Docker` errors | Docker not running or permission denied | Run `docker info` to verify; may need `sudo usermod -aG docker $USER` |
| `pdflatex` not found | LaTeX not installed | Install with `sudo apt-get install texlive-full` |
| `ModuleNotFoundError` | Missing Python dependency | Run `pip3 install researchclaw[all]` |
| `quality_score < threshold` | Quality gate too strict | Edit `config.yaml` → lower `quality.min_score` (default 2.0 is very strict) |
| `MemoryError` or OOM | Insufficient RAM (needs 32GB+) | Use `simulated` experiment mode or reduce `max_concurrent_stages` |
| `ConnectionError` to arxiv/semantic_scholar | Network issue | Check internet connectivity; try `curl https://api.semanticscholar.org/graph/v1/paper/search?query=test` |
| `YAML` parse error in config | Malformed config file | Run `python3 -c "import yaml; yaml.safe_load(open('config.yaml'))"` to find the error |

After diagnosis, suggest the specific fix. If the fix is automatable (e.g., installing a package), offer to do it with user approval.

---

## /researchclaw:validate — Pre-Run Validation

Run all checks without starting the pipeline:

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/check-prereqs.sh"
```

Then additionally:

1. **Config syntax**: `python3 -c "import yaml; yaml.safe_load(open('config.yaml'))"`
2. **Config completeness**: Check that `llm.api_key` or `llm.api_key_env` is set, `research.topic` is non-empty
3. **API connectivity**: Test the LLM endpoint with a minimal request
4. **Docker health**: `docker info` (if experiment mode is `sandbox`)
5. **Disk space**: `df -h .` — warn if less than 10 GB free
6. **Write permissions**: `touch artifacts/.write-test && rm artifacts/.write-test`

Report results as a checklist with pass/fail for each item.

---

## Additional Resources

- For the full pipeline stage reference, see [references/pipeline-stages.md](references/pipeline-stages.md)
- For configuration field reference, see [references/config-reference.md](references/config-reference.md)
- For troubleshooting recipes, see [references/troubleshooting.md](references/troubleshooting.md)
- For Chinese documentation, see [references/README-CN.md](references/README-CN.md)

---

## Principles

1. **Never lie.** If something is broken, say so. If a feature does not exist upstream, do not pretend it does.
2. **Always test.** Run validation before every pipeline execution. Check results after every action.
3. **Ask before acting.** Never install packages, modify configs, or start long-running processes without explicit user approval.
4. **Report honestly.** Show actual error messages, not sanitized summaries. The user needs real information to debug.
5. **Stay current.** This skill targets AutoResearchClaw v0.3.x. If the upstream version changes significantly, some commands may need updating.

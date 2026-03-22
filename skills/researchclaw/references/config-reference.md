# AutoResearchClaw Configuration Reference

This document covers all configuration fields in `config.yaml`. Fields marked **required** must be set for the pipeline to run.

## LLM Configuration

| Field | Required | Type | Default | Description |
|---|---|---|---|---|
| `llm.provider` | Yes | string | — | LLM provider: `openai`, `anthropic`, `azure`, `deepseek`, `local` |
| `llm.model` | Yes | string | — | Model name (e.g., `gpt-4o`, `claude-sonnet-4-20250514`) |
| `llm.api_key` | Yes* | string | — | API key (use `api_key_env` instead for security) |
| `llm.api_key_env` | Yes* | string | — | Environment variable name holding the API key |
| `llm.base_url` | No | string | provider default | Custom API endpoint URL |
| `llm.temperature` | No | float | `0.7` | Sampling temperature (0.0-2.0) |
| `llm.max_tokens` | No | int | `4096` | Maximum tokens per LLM call |

*Either `api_key` or `api_key_env` must be set, not both.

### Provider-Specific Notes

**OpenAI:**
- Default base_url: `https://api.openai.com/v1`
- Recommended models: `gpt-4o`, `gpt-4o-mini`
- Set `OPENAI_API_KEY` environment variable

**Anthropic:**
- Default base_url: `https://api.anthropic.com`
- Recommended models: `claude-sonnet-4-20250514`, `claude-3-5-haiku-20241022`
- Set `ANTHROPIC_API_KEY` environment variable

**Azure OpenAI:**
- Must set `base_url` to your Azure endpoint
- Must set `api_key_env` to your Azure API key variable
- Model name should match your Azure deployment name

**DeepSeek:**
- Default base_url: `https://api.deepseek.com`
- Recommended model: `deepseek-chat`
- Set `DEEPSEEK_API_KEY` environment variable

## Research Configuration

| Field | Required | Type | Default | Description |
|---|---|---|---|---|
| `research.topic` | Yes | string | — | The research topic or question |
| `research.context` | No | string | — | Additional context or constraints |

## Experiment Configuration

| Field | Required | Type | Default | Description |
|---|---|---|---|---|
| `experiment.mode` | No | string | `simulated` | Execution mode: `simulated`, `sandbox`, `ssh_remote` |
| `experiment.sandbox.python_path` | No | string | `python3` | Python interpreter path for sandbox mode |
| `experiment.sandbox.timeout` | No | int | `300` | Max seconds per experiment execution |
| `experiment.sandbox.max_retries` | No | int | `2` | Retry count on experiment failure |
| `experiment.ssh_remote.host` | Cond. | string | — | SSH hostname (required for ssh_remote mode) |
| `experiment.ssh_remote.user` | Cond. | string | — | SSH username |
| `experiment.ssh_remote.key_path` | Cond. | string | — | Path to SSH private key |
| `experiment.ssh_remote.python_path` | No | string | `python3` | Remote Python path |

## Pipeline Configuration

| Field | Required | Type | Default | Description |
|---|---|---|---|---|
| `pipeline.auto_approve_gates` | No | bool | `false` | Skip human approval at gate stages (5, 9, 20) |
| `pipeline.max_concurrent_stages` | No | int | `1` | Parallel stage execution (experimental) |
| `pipeline.output_dir` | No | string | `artifacts/` | Base output directory |

## Paper Configuration

| Field | Required | Type | Default | Description |
|---|---|---|---|---|
| `paper.template` | No | string | `neurips` | LaTeX template: `neurips`, `icml`, `iclr`, `generic` |
| `paper.author` | No | string | — | Author name for the paper |
| `paper.institution` | No | string | — | Institution name |

## Literature Configuration

| Field | Required | Type | Default | Description |
|---|---|---|---|---|
| `literature.sources` | No | list | `[arxiv, semantic_scholar]` | Literature search sources |
| `literature.max_papers` | No | int | `30` | Maximum papers to retrieve |
| `literature.search_depth` | No | int | `2` | Citation hop depth |

## Quality Configuration

| Field | Required | Type | Default | Description |
|---|---|---|---|---|
| `quality.min_score` | No | float | `2.0` | Minimum quality score (1-10) for gate stages |

**Important:** The default `min_score` of `2.0` is very strict and blocks many first-time runs. Consider setting it to `3.0` or higher for better results, or `1.0` to always pass (useful for testing).

## Iterative Pipeline Configuration

| Field | Required | Type | Default | Description |
|---|---|---|---|---|
| `iterative.max_iterations` | No | int | `3` | Maximum improvement iterations |
| `iterative.convergence_rounds` | No | int | `2` | Stop if no improvement for N rounds |

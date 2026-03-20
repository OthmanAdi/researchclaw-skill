# AutoResearchClaw Troubleshooting Guide

This document covers the most common failures and their solutions, based on real issues reported by the community.

## Installation Failures

### pip install fails with dependency conflicts

**Symptom:** `ERROR: Cannot install researchclaw because these package versions have conflicting dependencies`

**Fix:**
```bash
# Create a fresh virtual environment
python3 -m venv .venv
source .venv/bin/activate
pip install researchclaw[all]
```

Or use `uv` for faster, more reliable dependency resolution:
```bash
uv pip install researchclaw[all]
```

### Windows: installation fails

**Symptom:** Various errors on Windows, especially with Docker and LaTeX paths.

**Reality check:** AutoResearchClaw has limited Windows support as of v0.3.x. The recommended approach is:
1. Use WSL2 (Windows Subsystem for Linux)
2. Install Docker Desktop with WSL2 backend
3. Run everything inside WSL2

---

## Configuration Failures

### YAML parse error

**Symptom:** `yaml.scanner.ScannerError: mapping values are not allowed in this context`

**Diagnosis:**
```bash
python3 -c "import yaml; yaml.safe_load(open('config.yaml'))"
```

**Common causes:**
- Missing quotes around strings with colons (e.g., `topic: NLP: A Survey` should be `topic: "NLP: A Survey"`)
- Incorrect indentation (YAML requires consistent spaces, not tabs)
- Missing space after colon (`key:value` should be `key: value`)

### API key not found

**Symptom:** `HTTP 401 Unauthorized` or `AuthenticationError`

**Diagnosis:**
```bash
# Check if the env var is set
echo $OPENAI_API_KEY
# or
echo $ANTHROPIC_API_KEY
```

**Fixes:**
1. Verify the key is valid (not expired, not revoked)
2. Check `config.yaml` — is `api_key_env` pointing to the correct variable name?
3. If using `api_key` directly, ensure it has no extra whitespace or quotes

### Azure endpoint configuration

**Symptom:** `Connection refused` or `404 Not Found` when using Azure OpenAI

**Fix:** Azure requires a specific URL format:
```yaml
llm:
  provider: azure
  base_url: "https://YOUR-RESOURCE.openai.azure.com/openai/deployments/YOUR-DEPLOYMENT"
  api_key_env: AZURE_OPENAI_API_KEY
  model: "YOUR-DEPLOYMENT-NAME"  # Must match the Azure deployment name exactly
```

---

## Pipeline Execution Failures

### Stage 10 (Code Generation) failure

**Symptom:** Pipeline stops at stage 10 with code generation errors.

**This is the most common failure.** The LLM generates Python code that may have:
- Syntax errors
- Missing imports
- Incompatible library versions
- Hardcoded paths that don't exist

**Diagnosis:**
```bash
# Check the generated code
cat artifacts/rc-*/stage-10/experiment.py

# Try running it manually
python3 artifacts/rc-*/stage-10/experiment.py
```

**Fixes:**
1. Use a stronger model (gpt-4o or claude-sonnet-4-20250514 instead of smaller models)
2. Switch to `simulated` mode to skip actual code execution
3. Manually fix the generated code and resume from stage 11

### Quality gate rejection

**Symptom:** Pipeline stops with `quality_score below threshold`

**Fix:** The default threshold (2.0) is very strict. Edit `config.yaml`:
```yaml
quality:
  min_score: 1.0  # Lower to always pass (for testing)
```

For production runs, use `3.0-5.0` as a reasonable threshold.

### Rate limiting (HTTP 429)

**Symptom:** `RateLimitError` or `HTTP 429 Too Many Requests`

**Fixes:**
1. Wait 60 seconds and resume: `researchclaw run --from-stage LAST_STAGE --config config.yaml`
2. Switch to a model with higher rate limits
3. Add retry logic in config (if supported by your version)

### Memory exhaustion (OOM)

**Symptom:** Process killed, `MemoryError`, or system becomes unresponsive

**Fixes:**
1. Use `simulated` experiment mode (no code execution = less memory)
2. Close other applications
3. Reduce `literature.max_papers` to 10-15
4. Set `pipeline.max_concurrent_stages: 1`

---

## Docker Failures

### Docker daemon not running

**Symptom:** `Cannot connect to the Docker daemon`

**Fix:**
```bash
# Linux
sudo systemctl start docker

# macOS
open -a Docker  # Start Docker Desktop

# Verify
docker info
```

### Docker permission denied

**Symptom:** `Got permission denied while trying to connect to the Docker daemon socket`

**Fix:**
```bash
sudo usermod -aG docker $USER
# Then log out and log back in
```

---

## LaTeX Failures

### pdflatex not found

**Symptom:** `pdflatex: command not found` at stage 23

**Fix:**
```bash
# Ubuntu/Debian
sudo apt-get install texlive-full  # WARNING: 2-4 GB download

# macOS
brew install --cask mactex

# Minimal install (smaller but may miss some packages)
sudo apt-get install texlive-latex-base texlive-latex-extra texlive-fonts-recommended
```

### Missing LaTeX packages

**Symptom:** `! LaTeX Error: File 'neurips_2024.sty' not found`

**Fix:** The NeurIPS/ICML/ICLR templates require specific style files. These should be included in the AutoResearchClaw package. If missing:
```bash
# Check if the template files exist
find . -name "*.sty" -o -name "*.cls" | head -20

# If missing, reinstall
pip install researchclaw[all] --force-reinstall
```

---

## Resume Failures

### --from-stage not working

**Symptom:** Resume starts from the beginning instead of the specified stage, or crashes.

**Known issue:** The `--from-stage` flag has bugs in some versions.

**Workaround:**
1. Note which stages completed successfully (check `artifacts/rc-*/stage-*/`)
2. Start a fresh run with the same config
3. If you need specific stage outputs, copy them from the old run directory

---

## Network Failures

### Cannot reach arXiv or Semantic Scholar

**Symptom:** `ConnectionError` during literature search (stages 3-4)

**Diagnosis:**
```bash
curl -s https://api.semanticscholar.org/graph/v1/paper/search?query=test | head -100
curl -s "http://export.arxiv.org/api/query?search_query=all:test&max_results=1" | head -100
```

**Fixes:**
1. Check internet connectivity
2. If behind a corporate proxy, set `HTTP_PROXY` and `HTTPS_PROXY` environment variables
3. If arXiv is rate-limiting you, wait 10 minutes and retry

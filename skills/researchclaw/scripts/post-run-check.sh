#!/usr/bin/env bash
# post-run-check.sh — PostToolUse hook for researchclaw commands
# Scans tool output for common error patterns and surfaces warnings
# Input: $1 = tool output (passed by Claude Code hook system)

set -euo pipefail

OUTPUT="${1:-}"

# If no output provided, read from stdin
if [ -z "$OUTPUT" ]; then
  OUTPUT=$(cat)
fi

WARNINGS=()

# Check for common error patterns
if echo "$OUTPUT" | grep -qi "HTTP 401\|AuthenticationError\|Unauthorized"; then
  WARNINGS+=("API_AUTH_FAILURE: API key is invalid or expired. Check config.yaml llm.api_key_env.")
fi

if echo "$OUTPUT" | grep -qi "HTTP 429\|RateLimitError\|rate.limit"; then
  WARNINGS+=("RATE_LIMIT: API rate limit hit. Wait 60 seconds before resuming.")
fi

if echo "$OUTPUT" | grep -qi "MemoryError\|OOM\|Killed"; then
  WARNINGS+=("MEMORY: Out of memory. Consider using simulated mode or closing other applications.")
fi

if echo "$OUTPUT" | grep -qi "Docker\|docker.*not.*running\|Cannot connect to the Docker daemon"; then
  WARNINGS+=("DOCKER: Docker issue detected. Run 'docker info' to check Docker status.")
fi

if echo "$OUTPUT" | grep -qi "pdflatex.*not found\|LaTeX Error"; then
  WARNINGS+=("LATEX: LaTeX issue. Run '/researchclaw:setup' to check LaTeX installation.")
fi

if echo "$OUTPUT" | grep -qi "ModuleNotFoundError\|ImportError"; then
  WARNINGS+=("MISSING_MODULE: Python module missing. Run 'pip3 install researchclaw[all]'.")
fi

if echo "$OUTPUT" | grep -qi "quality_score.*below\|quality.*threshold\|gate.*rejected"; then
  WARNINGS+=("QUALITY_GATE: Quality gate rejected. Consider lowering quality.min_score in config.yaml.")
fi

if echo "$OUTPUT" | grep -qi "ConnectionError\|ConnectionRefused\|Network.*unreachable"; then
  WARNINGS+=("NETWORK: Network connectivity issue. Check internet connection and proxy settings.")
fi

# Output warnings if any
if [ ${#WARNINGS[@]} -gt 0 ]; then
  echo ""
  echo "=== ResearchClaw Auto-Diagnosis ==="
  for w in "${WARNINGS[@]}"; do
    echo "  ⚠ $w"
  done
  echo "Run '/researchclaw:diagnose' for detailed troubleshooting."
  echo "==================================="
fi

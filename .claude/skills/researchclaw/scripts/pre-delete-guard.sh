#!/usr/bin/env bash
# pre-delete-guard.sh — PreToolUse hook
# Prevents accidental deletion of pipeline artifacts
# Returns non-zero to block the operation

set -euo pipefail

echo "BLOCKED: Attempted to delete pipeline artifacts."
echo "Pipeline artifacts contain research results that cannot be regenerated without re-running the pipeline."
echo "If you really want to delete artifacts, do it manually outside of Claude Code."
exit 1

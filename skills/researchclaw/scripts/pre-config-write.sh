#!/usr/bin/env bash
# pre-config-write.sh — PreToolUse hook
# Backs up config.yaml before overwriting to prevent accidental data loss

set -euo pipefail

CONFIG="config.yaml"

if [ -f "$CONFIG" ]; then
  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  BACKUP="${CONFIG}.backup-${TIMESTAMP}"
  cp "$CONFIG" "$BACKUP"
  echo "Backed up existing config.yaml to $BACKUP"
fi

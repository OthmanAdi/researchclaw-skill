#!/usr/bin/env bash
# notify-completion.sh — Notification hook
# Logs pipeline completion/failure to a local log file
# Can be extended to send desktop notifications, Slack messages, etc.

set -euo pipefail

LOG_FILE="researchclaw-notifications.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Check for the most recent run
LATEST_RUN=$(ls -td artifacts/rc-* 2>/dev/null | head -1)

if [ -z "$LATEST_RUN" ]; then
  echo "[$TIMESTAMP] Pipeline run initiated (no artifacts yet)" >> "$LOG_FILE"
  exit 0
fi

# Check if pipeline completed
if [ -f "$LATEST_RUN/pipeline_summary.json" ]; then
  STAGES_COMPLETE=$(ls -d "$LATEST_RUN"/stage-* 2>/dev/null | wc -l)
  echo "[$TIMESTAMP] COMPLETE: Pipeline finished with $STAGES_COMPLETE stages. Output: $LATEST_RUN" >> "$LOG_FILE"

  # Desktop notification (if available)
  if command -v notify-send &> /dev/null; then
    notify-send "ResearchClaw" "Pipeline complete! $STAGES_COMPLETE stages finished. Check $LATEST_RUN"
  fi

  # macOS notification (if available)
  if command -v osascript &> /dev/null; then
    osascript -e "display notification \"Pipeline complete! $STAGES_COMPLETE stages finished.\" with title \"ResearchClaw\""
  fi
else
  STAGES_COMPLETE=$(ls -d "$LATEST_RUN"/stage-* 2>/dev/null | wc -l)
  echo "[$TIMESTAMP] IN_PROGRESS: Pipeline at stage $STAGES_COMPLETE. Output: $LATEST_RUN" >> "$LOG_FILE"
fi

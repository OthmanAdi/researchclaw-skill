#!/usr/bin/env bash
# check-prereqs.sh — Check all prerequisites for AutoResearchClaw
# Returns JSON report with pass/fail for each dependency
# Exit code 0 = all pass, 1 = some failures

set -euo pipefail

PASS=0
FAIL=0
RESULTS=()

check() {
  local name="$1"
  local cmd="$2"
  local required="$3"  # "required" or "optional"

  if eval "$cmd" > /dev/null 2>&1; then
    local version
    version=$(eval "$cmd" 2>&1 | head -1 || echo "unknown")
    RESULTS+=("{\"name\":\"$name\",\"status\":\"pass\",\"version\":\"$version\",\"required\":\"$required\"}")
    PASS=$((PASS + 1))
  else
    RESULTS+=("{\"name\":\"$name\",\"status\":\"fail\",\"version\":null,\"required\":\"$required\"}")
    if [ "$required" = "required" ]; then
      FAIL=$((FAIL + 1))
    fi
  fi
}

# Core dependencies
check "python3.11+" "python3 --version 2>&1 | grep -E 'Python 3\.(1[1-9]|[2-9][0-9])'" "required"
check "pip3" "pip3 --version" "required"
check "git" "git --version" "required"

# AutoResearchClaw itself
check "researchclaw-cli" "which researchclaw" "required"
check "researchclaw-package" "python3 -c 'import researchclaw'" "required"

# Docker (required for sandbox mode, optional for simulated)
check "docker" "docker info" "optional"

# LaTeX (required for PDF output)
check "pdflatex" "pdflatex --version" "optional"

# Optional but useful
check "uv" "uv --version" "optional"

# Build JSON output
JSON="{"
JSON+="\"total_checks\":$((PASS + FAIL)),"
JSON+="\"passed\":$PASS,"
JSON+="\"failed\":$FAIL,"
JSON+="\"all_required_pass\":$([ $FAIL -eq 0 ] && echo 'true' || echo 'false'),"
JSON+="\"checks\":["
for i in "${!RESULTS[@]}"; do
  JSON+="${RESULTS[$i]}"
  if [ $i -lt $((${#RESULTS[@]} - 1)) ]; then
    JSON+=","
  fi
done
JSON+="]}"

echo "$JSON"

# Human-readable summary to stderr
echo "" >&2
echo "=== ResearchClaw Prerequisites Check ===" >&2
echo "Passed: $PASS / $((PASS + FAIL))" >&2
if [ $FAIL -gt 0 ]; then
  echo "FAILED: $FAIL required dependencies missing" >&2
  exit 1
else
  echo "All required dependencies are installed." >&2
  exit 0
fi

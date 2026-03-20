#!/usr/bin/env bash
# test-skill.sh — Self-validation test suite for the researchclaw skill
# Run: bash tests/test-skill.sh
# Exit code 0 = all tests pass, 1 = failures

set -euo pipefail

PASS=0
FAIL=0
TOTAL=0
SKILL_DIR=".claude/skills/researchclaw"

# Colors (if terminal supports them)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass() {
  PASS=$((PASS + 1))
  TOTAL=$((TOTAL + 1))
  echo -e "  ${GREEN}PASS${NC}: $1"
}

fail() {
  FAIL=$((FAIL + 1))
  TOTAL=$((TOTAL + 1))
  echo -e "  ${RED}FAIL${NC}: $1"
}

section() {
  echo ""
  echo -e "${YELLOW}=== $1 ===${NC}"
}

# ============================================================
section "1. File Structure Tests"
# ============================================================

# SKILL.md exists
if [ -f "$SKILL_DIR/SKILL.md" ]; then
  pass "SKILL.md exists"
else
  fail "SKILL.md missing"
fi

# SKILL.md has YAML frontmatter
if head -1 "$SKILL_DIR/SKILL.md" | grep -q "^---"; then
  pass "SKILL.md has YAML frontmatter"
else
  fail "SKILL.md missing YAML frontmatter"
fi

# Frontmatter has required fields
for field in "name:" "description:" "version:"; do
  if head -20 "$SKILL_DIR/SKILL.md" | grep -q "$field"; then
    pass "Frontmatter contains $field"
  else
    fail "Frontmatter missing $field"
  fi
done

# Reference files exist
for ref in "pipeline-stages.md" "config-reference.md" "troubleshooting.md" "README-CN.md"; do
  if [ -f "$SKILL_DIR/references/$ref" ]; then
    pass "Reference file $ref exists"
  else
    fail "Reference file $ref missing"
  fi
done

# Scripts exist and are executable
for script in "check-prereqs.sh" "post-run-check.sh" "pre-config-write.sh" "pre-delete-guard.sh" "notify-completion.sh"; do
  if [ -f "$SKILL_DIR/scripts/$script" ]; then
    pass "Script $script exists"
    if [ -x "$SKILL_DIR/scripts/$script" ]; then
      pass "Script $script is executable"
    else
      fail "Script $script is not executable"
    fi
  else
    fail "Script $script missing"
  fi
done

# Config template exists
if [ -f "$SKILL_DIR/assets/config-template.yaml" ]; then
  pass "Config template exists"
else
  fail "Config template missing"
fi

# Hooks file exists
if [ -f ".claude/hooks.json" ]; then
  pass "hooks.json exists"
else
  fail "hooks.json missing"
fi

# ============================================================
section "2. Content Quality Tests"
# ============================================================

# SKILL.md contains all required commands
for cmd in "/researchclaw:setup" "/researchclaw:config" "/researchclaw:run" "/researchclaw:status" "/researchclaw:resume" "/researchclaw:diagnose" "/researchclaw:validate"; do
  if grep -q "$cmd" "$SKILL_DIR/SKILL.md"; then
    pass "SKILL.md documents command $cmd"
  else
    fail "SKILL.md missing command $cmd"
  fi
done

# SKILL.md contains honesty policy
if grep -qi "honesty\|never lie\|honest" "$SKILL_DIR/SKILL.md"; then
  pass "SKILL.md contains honesty policy"
else
  fail "SKILL.md missing honesty policy"
fi

# SKILL.md documents limitations
if grep -qi "cannot\|limitation\|known issue" "$SKILL_DIR/SKILL.md"; then
  pass "SKILL.md documents limitations"
else
  fail "SKILL.md missing limitations documentation"
fi

# Pipeline stages reference has all 23 stages
STAGE_COUNT=$(grep -c "^| [0-9]" "$SKILL_DIR/references/pipeline-stages.md" || true)
if [ "$STAGE_COUNT" -ge 23 ]; then
  pass "Pipeline stages reference has all 23 stages ($STAGE_COUNT found)"
else
  fail "Pipeline stages reference incomplete ($STAGE_COUNT/23 stages)"
fi

# Config reference has required fields documented
for field in "llm.provider" "llm.model" "research.topic" "experiment.mode"; do
  if grep -q "$field" "$SKILL_DIR/references/config-reference.md"; then
    pass "Config reference documents $field"
  else
    fail "Config reference missing $field"
  fi
done

# Troubleshooting covers common errors
for error in "HTTP 401" "Stage 10" "Docker" "LaTeX" "Rate limiting"; do
  if grep -qi "$error" "$SKILL_DIR/references/troubleshooting.md"; then
    pass "Troubleshooting covers: $error"
  else
    fail "Troubleshooting missing: $error"
  fi
done

# Chinese README exists and has content
if [ -f "$SKILL_DIR/references/README-CN.md" ]; then
  CN_LINES=$(wc -l < "$SKILL_DIR/references/README-CN.md")
  if [ "$CN_LINES" -gt 50 ]; then
    pass "Chinese README has substantial content ($CN_LINES lines)"
  else
    fail "Chinese README too short ($CN_LINES lines)"
  fi
fi

# ============================================================
section "3. Script Syntax Tests"
# ============================================================

# Check bash syntax of all scripts
for script in "$SKILL_DIR"/scripts/*.sh; do
  if bash -n "$script" 2>/dev/null; then
    pass "$(basename "$script") has valid bash syntax"
  else
    fail "$(basename "$script") has bash syntax errors"
  fi
done

# ============================================================
section "4. Hooks Configuration Tests"
# ============================================================

# hooks.json is valid JSON
if python3 -c "import json; json.load(open('.claude/hooks.json'))" 2>/dev/null; then
  pass "hooks.json is valid JSON"
else
  fail "hooks.json is invalid JSON"
fi

# hooks.json has PostToolUse, PreToolUse, and Notification hooks
for hook_type in "PostToolUse" "PreToolUse" "Notification"; do
  if python3 -c "import json; d=json.load(open('.claude/hooks.json')); assert '$hook_type' in d['hooks']" 2>/dev/null; then
    pass "hooks.json has $hook_type hook"
  else
    fail "hooks.json missing $hook_type hook"
  fi
done

# ============================================================
section "5. Config Template Tests"
# ============================================================

# Config template is valid YAML (with placeholders replaced)
TEMP_CONFIG=$(mktemp)
sed -e 's/\${[A-Z_]*}/test/g' "$SKILL_DIR/assets/config-template.yaml" > "$TEMP_CONFIG"
if python3 -c "import yaml; yaml.safe_load(open('$TEMP_CONFIG'))" 2>/dev/null; then
  pass "Config template produces valid YAML when placeholders are filled"
else
  fail "Config template produces invalid YAML"
fi
rm -f "$TEMP_CONFIG"

# Config template has all required sections
for section_name in "research:" "llm:" "experiment:" "pipeline:" "paper:" "literature:" "quality:"; do
  if grep -q "$section_name" "$SKILL_DIR/assets/config-template.yaml"; then
    pass "Config template has section $section_name"
  else
    fail "Config template missing section $section_name"
  fi
done

# ============================================================
# Summary
# ============================================================

echo ""
echo "============================================"
echo "  Test Results: $PASS passed, $FAIL failed (out of $TOTAL)"
echo "============================================"

if [ $FAIL -gt 0 ]; then
  echo -e "  ${RED}SOME TESTS FAILED${NC}"
  exit 1
else
  echo -e "  ${GREEN}ALL TESTS PASSED${NC}"
  exit 0
fi

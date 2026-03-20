# AutoResearchClaw Existing SKILL.md Analysis

## What exists:
- Located at `.claude/skills/researchclaw/SKILL.md`
- Basic skill with NO frontmatter (missing name, description fields)
- Covers: description, trigger conditions, instructions, prerequisites, running pipeline, output structure, experiment modes, troubleshooting
- Just a single SKILL.md file — no references/, scripts/, or assets/ directories
- No hooks, no subagent execution, no dynamic context injection

## Critical gaps in the existing skill:
1. **No YAML frontmatter** — won't be properly indexed by Claude Code
2. **No setup automation** — assumes everything is already installed
3. **No dependency checking** — Docker, LaTeX, Python packages not verified
4. **No config wizard** — user must manually edit YAML
5. **No error recovery** — just "check X" troubleshooting, no auto-fix
6. **No progress monitoring** — no way to check pipeline status
7. **No resume support** — resume is buggy, no wrapper to fix it
8. **No hooks** — no auto-formatting, no notifications, no file protection
9. **No Chinese support** — English only
10. **No testing** — no self-validation scripts
11. **No supporting files** — no references/, scripts/, assets/

## What our skill needs to add:
1. Proper Agent Skills spec-compliant frontmatter
2. Interactive setup wizard (dependency detection + installation)
3. Config generation wizard
4. Pipeline status monitoring
5. Auto-diagnosis and fix for common failures
6. Resume wrapper that actually works
7. Hooks: PostToolUse for logging, PreToolUse for safety, Notification for completion
8. Chinese language support
9. Self-testing scripts
10. Reference files for each subcommand

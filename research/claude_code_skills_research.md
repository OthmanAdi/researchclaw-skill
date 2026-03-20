# Claude Code Skills & Hooks — Research Notes

## Official Skills System (from code.claude.com/docs/en/skills)

### Skill Format
- A skill is a directory containing SKILL.md (required) + optional supporting files
- SKILL.md has YAML frontmatter (between --- markers) + markdown content
- Frontmatter fields: name, description, argument-hint, disable-model-invocation, user-invocable, allowed-tools, model, context, agent, hooks

### Where Skills Live
- Enterprise: managed settings (org-wide)
- Personal: ~/.claude/skills/<skill-name>/SKILL.md (all your projects)
- Project: .claude/skills/<skill-name>/SKILL.md (this project only)
- Plugin: <plugin>/skills/<skill-name>/SKILL.md (where plugin is enabled)

### Skill Directory Structure
```
my-skill/
├── SKILL.md           # Main instructions (required)
├── template.md        # Template for Claude to fill in
├── examples/
│   └── sample.md      # Example output showing expected format
└── scripts/
    └── validate.sh    # Script Claude can execute
```

### Key Features
1. **Arguments**: $ARGUMENTS, $ARGUMENTS[N], $N shorthand
2. **Dynamic context injection**: !`command` syntax runs shell commands before skill content is sent
3. **Subagent execution**: context: fork runs skill in isolated subagent
4. **Agent types**: Explore, Plan, general-purpose, or custom from .claude/agents/
5. **Tool restriction**: allowed-tools field limits what Claude can use
6. **Invocation control**: disable-model-invocation: true (manual only), user-invocable: false (Claude only)
7. **String substitutions**: $ARGUMENTS, ${CLAUDE_SESSION_ID}, ${CLAUDE_SKILL_DIR}

### Bundled Skills (built-in)
- /batch - Large-scale parallel changes
- /claude-api - API reference material
- /debug - Session troubleshooting
- /loop - Repeated prompt execution
- /simplify - Code review and simplification

### Sharing Skills
- Project: commit .claude/skills/ to version control
- Plugins: create skills/ directory in plugin
- Managed: deploy org-wide through managed settings

## Official Hooks System (from code.claude.com/docs/en/hooks-guide)

### Hook Events Available
1. **Notification** - Claude needs input/permission
2. **PostToolUse** - After a tool runs (matcher: Edit|Write, Bash, etc.)
3. **PreToolUse** - Before a tool runs (can block with exit code 2)
4. **SessionStart** - Session begins (matcher: "compact" for after compaction)
5. **ConfigChange** - Settings/skills files change
6. **PermissionRequest** - Before permission prompt (can auto-approve)

### Hook Types
1. **command** - Shell command (deterministic)
2. **prompt** - Uses Claude model to evaluate (judgment-based)
3. **agent** - Uses agent for complex evaluation
4. **http** - HTTP webhook

### Hook Configuration
- Stored in settings.json (project or personal)
- matcher field filters when hook fires
- Exit codes: 0 = success, 2 = block action
- stdin receives JSON with tool info, stdout goes to Claude context

### Hooks in Skills
- Skills can define their own hooks via the `hooks` frontmatter field
- Scoped to the skill's lifecycle

## Agent Skills Open Standard
- Claude Code follows the Agent Skills open standard (agentskills.io)
- Works across multiple AI tools
- Claude Code extends with: invocation control, subagent execution, dynamic context injection

## Key Constraints
- SKILL.md should be under 500 lines
- Skill descriptions budget: 2% of context window (fallback 16,000 chars)
- Override with SLASH_COMMAND_TOOL_CHAR_BUDGET env var
- Skills with same name: enterprise > personal > project priority

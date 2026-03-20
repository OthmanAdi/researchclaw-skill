# AutoResearchClaw - Deep Analysis

## Project Overview
- **URL:** https://github.com/aiming-lab/AutoResearchClaw
- **Stars:** 7k | **Forks:** 723 | **Contributors:** 21 | **Releases:** 4 (v0.1.0 to v0.3.1)
- **Age:** 5 days old (v0.1.0 released March 15, 2026)
- **Language:** Python 95.3%
- **License:** MIT
- **Team:** aiming-lab (academic lab)

## What It Does
Fully autonomous research pipeline: "Chat an Idea. Get a Paper."
- 23-stage pipeline across 8 phases
- Takes a research topic → produces conference-ready LaTeX paper
- Real literature from OpenAlex, Semantic Scholar, arXiv
- Hardware-aware sandbox experiments (GPU/MPS/CPU auto-detected)
- Multi-agent peer review
- Self-healing experiments
- Self-learning across runs (MetaClaw integration)
- 4-layer citation verification (no hallucinated references)
- Targets NeurIPS/ICML/ICLR templates

## Architecture (researchclaw/ directory)
13 subdirectories + 8 Python files:
- agents/ - Multi-agent subsystems (CodeAgent, BenchmarkAgent, FigureAgent)
- data/ - Data handling
- docker/ - Docker sandbox for experiments
- domains/ - Domain-specific logic
- experiment/ - Experiment execution
- feedback/ - Feedback/tester system
- knowledge/ - Knowledge base (6 categories)
- literature/ - Literature search (OpenAlex, Semantic Scholar, arXiv)
- llm/ - LLM provider abstraction (OpenAI, Anthropic, ACP, Novita)
- metaclaw_bridge/ - MetaClaw cross-run learning
- pipeline/ - 23-stage pipeline orchestration
- templates/ - LaTeX templates (NeurIPS, ICLR, ICML)
- utils/ - Utilities
- web/ - Website
- cli.py, config.py, adapters.py, evolution.py, hardware.py, health.py, prompts.py, quality.py, report.py, writing_guide.py

## Integration Options
1. OpenClaw (recommended) - just chat "Research X"
2. Standalone CLI - researchclaw setup → init → run
3. Python API - from researchclaw.pipeline import Runner
4. Claude Code - reads RESEARCHCLAW_CLAUDE.md
5. Copilot CLI - via ACP
6. OpenCode - reads .claude/skills/
7. Any AI CLI - provide RESEARCHCLAW_AGENTS.md as context

## Already Has Multilingual Support
- Chinese (中文), Japanese (日本語), Korean (한국어), French, German, Spanish, Portuguese, Russian, Arabic
- Testing guides in Chinese and Japanese

## Closed Issues (55 total, 0 open) - KEY PAIN POINTS
1. **LLM connectivity** - HTTP 401 errors (#121)
2. **Resume not working** (#119)
3. **Quality score too low** - "Quality score 2.0/10 below threshold 4.0" (#118)
4. **Stage 10 always failed** (#117)
5. **Windows install broken** - Can't install, OpenCode install error (#116)
6. **Azure endpoints config** (#113)
7. **Copilot/Cursor integration** - "Can this be configured with GitHub Copilot / Cursor?" (#112)
8. **Stage 10 CODE_GENERATION fails** - ValueError: unmatched '{' in format spec (#83)
9. **Resume function not working** (#81)
10. **TypeError in Stage 08** - _synthesize_perspectives returns ChatResponse instead of str (#72)
11. **ACP mode memory issues** - persistent session prevents full pipeline on ≤32 GB (#70)
12. **Self-healing failures** - LLM-generated experiments fail due to missing config.py or dependencies (#68)
13. **Feature requests for more literature sources** - J-STAGE, DBLP, INSPIRE-HEP, NASA ADS, HAL, Europe PMC, CiNii, SciELO (#59-66)
14. People posting their research proposals as issues (confused users)

## Key Observations
- Project is VERY new (5 days) and already 7k stars - massive momentum
- 55 issues already closed - active maintenance but lots of bugs
- Windows support is weak
- Setup is complex (Docker, LaTeX, OpenCode, venv, config YAML)
- Many users confused about how to configure LLM providers
- Resume functionality is buggy
- Quality gates sometimes too strict
- Memory issues on consumer hardware (≤32 GB)
- Chinese testing guide already exists but community engagement in Chinese is minimal

## Dependencies (pyproject.toml)
- Python >= 3.11
- Core: pyyaml>=6.0, rich>=13.0, arxiv>=2.1, numpy>=1.24
- Optional (anthropic): httpx>=0.24
- Optional (web): scholarly>=1.7, crawl4ai>=0.2, tavily-python>=0.3
- Optional (pdf): PyMuPDF>=1.23
- Optional (all): httpx, scholarly, crawl4ai, tavily-python, PyMuPDF, huggingface-hub>=0.20, matplotlib>=3.7, scipy>=1.10
- Dev: pytest>=7.0, httpx>=0.24
- Also needs: Docker (for sandbox), LaTeX (for paper compilation), OpenCode (for beast mode)

## Setup Complexity Assessment
HARD to set up because:
1. Needs Python 3.11+
2. Needs Docker running (for experiment sandbox)
3. Needs LaTeX installed (for paper compilation)
4. Needs OpenCode installed (for beast mode)
5. Needs LLM API keys configured (OpenAI/Anthropic/etc)
6. Config YAML is complex with many options
7. Windows support is broken/weak
8. Memory issues on ≤32 GB machines
9. 23-stage pipeline means lots of places things can fail
10. Resume functionality is buggy

## Existing Documentation
- README_CN.md (Chinese) - exists, added 18 hours ago
- README_AR.md, README_DE.md, README_ES.md, README_FR.md, README_JA.md, README_KO.md, README_PT.md, README_RU.md
- TESTER_GUIDE.md, TESTER_GUIDE_CN.md, TESTER_GUIDE_JA.md
- integration-guide.md
- Various bug fix docs, changelog, pipeline test logs
- All multilingual READMEs added just 18 hours ago - very fresh, likely auto-translated

## Chinese Community Engagement
- Sina Weibo post by 蚁工厂 (tech blogger) - got 79 retweets, 5 comments
- Threads post in Chinese - noted 4000+ stars in 4 days
- blockchain.news Chinese coverage
- Chinese testing guide exists
- BUT: no deep Chinese tutorial, no Chinese video, no Chinese community hub
- The Chinese README was just auto-generated 18 hours ago

## Key Gaps & Opportunities
1. NO ONE-CLICK SETUP - setup requires Docker, LaTeX, OpenCode, venv, YAML config
2. NO VIDEO TUTORIALS in Chinese
3. NO SIMPLIFIED WRAPPER/SKILL that makes it work in 1 command for non-technical users
4. Windows support is broken
5. Resume functionality buggy
6. No Manus/Claude Code skill equivalent (uditgoenka did it for autoresearch but NOT for AutoResearchClaw)
7. Chinese community is interested but underserved
8. The project is only 5 days old - PERFECT timing to jump in

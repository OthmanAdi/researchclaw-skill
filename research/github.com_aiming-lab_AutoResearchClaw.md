 11. RESOURCE_PLANNING               22. EXPORT_PUBLISH     ← LaTeX
                                     23. CITATION_VERIFY    ← relevance check


Gate stages (5, 9, 20) pause for human approval or auto-approve with --auto-approve. On rejection, the pipeline rolls back.

Decision loops: Stage 15 can trigger REFINE (→ Stage 13) or PIVOT (→ Stage 8), with automatic artifact versioning.

📋 What Each Phase Does
✨ Key Features
Feature	Description
📚 Multi-Source Literature	Real papers from OpenAlex, Semantic Scholar & arXiv — query expansion, deduplication, circuit breaker with graceful degradation
🔍 4-Layer Citation Verification	arXiv ID check → CrossRef/DataCite DOI → Semantic Scholar title match → LLM relevance scoring. Hallucinated refs auto-removed.
🖥️ Hardware-Aware Execution	Auto-detects GPU (NVIDIA CUDA / Apple MPS / CPU-only) and adapts code generation, imports, and experiment scale accordingly
🦾 OpenCode Beast Mode	Complex experiments auto-routed to OpenCode — generates multi-file projects with custom architectures, training loops, and ablation studies. Install via researchclaw setup.
🧪 Sandbox Experiments	AST-validated code, immutable harness, NaN/Inf fast-fail, self-healing repair, iterative refinement (up to 10 rounds), partial result capture
📝 Conference-Grade Writing	NeurIPS/ICML/ICLR templates, section-by-section drafting (5,000-6,500 words), anti-fabrication guard, revision length guard, anti-disclaimer enforcement
📐 Template Switching	neurips_2025, iclr_2026, icml_2026 — Markdown → LaTeX with math, tables, figures, cross-refs, \cite{}
🚦 Quality Gates	3 human-in-the-loop gates (Stages 5, 9, 20) with rollback. Skip with --auto-approve.
🧠 MetaClaw Integration

AutoResearchClaw + MetaClaw = A pipeline that learns from every run.

MetaClaw adds cross-run knowledge transfer to AutoResearchClaw. When enabled, the pipeline automatically captures lessons from failures and warnings, converts them into reusable skills, and injects those skills into all 23 pipeline stages on subsequent runs — so the same mistakes are never repeated.

How It Works
Run N executes → failures/warnings captured as Lessons
                      ↓
          MetaClaw Lesson → Skill conversion
                      ↓
          arc-* Skill files stored in ~/.metaclaw/skills/
                      ↓
Run N+1 → build_overlay() injects skills into every LLM prompt
                      ↓
          LLM avoids known pitfalls → higher quality, fewer retries

Quick Setup
# 1. Install MetaClaw (if not already)
pip install metaclaw

# 2. Enable in your config
# config.arc.yaml
metaclaw_bridge:
  enabled: true
  proxy_url: "http://localhost:30000"        # MetaClaw proxy (optional)
  skills_dir: "~/.metaclaw/skills"          # Where skills are stored
  fallback_url: "https://api.openai.com/v1" # Direct LLM fallback
  fallback_api_key: ""                      # API key for fallback URL
  lesson_to_skill:
    enabled: true
    min_severity: "warning"                 # Convert warnings + errors
    max_skills_per_run: 3
# 3. Run as usual — MetaClaw works transparently
researchclaw run --config config.arc.yaml --topic "Your idea" --auto-approve

After each run, check ~/.metaclaw/skills/arc-*/SKILL.md to see the skills your pipeline has learned.

Experiment Results

In controlled A/B experiments (same topic, same LLM, same configuration):

Metric	Baseline	With MetaClaw	Improvement
Stage retry rate	10.5%	7.9%	-24.8%
Refine cycle count	2.0	1.2	-40.0%
Pipeline stage completion	18/19	19/19	+5.3%
Overall robustness score (composite)	0.714	0.845	+18.3%

Composite robustness score is a weighted average of stage completion rate (40%), retry reduction (30%), and refine cycle efficiency (30%).

Backward Compatibility
Default: OFF. If metaclaw_bridge is absent or enabled: false, the pipeline behaves exactly as before.
No new dependencies. MetaClaw is optional — the core pipeline works without it.
All 1,634 existing tests pass with the integration code present.
⚙️ Configuration Reference
Click to expand full configuration reference
🙏 Acknowledgments

Inspired by:

🔬 AI Scientist (Sakana AI) — Automated research pioneer
🧠 AutoResearch (Andrej Karpathy) — End-to-end research automation
🌐 FARS (Analemma) — Fully Automated Research System
📄 License

MIT — see LICENSE for details.

📌 Citation

If you find AutoResearchClaw useful, please cite:

@misc{liu2026autoresearchclaw,
  author       = {Liu, Jiaqi and Xia, Peng and Han, Siwei and Qiu, Shi and Zhang, Letian and Chen, Guiming  and Tu, Haoqin and Yang, Xinyu and and Zhou, Jiawei and Zhu, Hongtu and Li, Yun and Zhou, Yuyin and Zheng, Zeyu and Xie, Cihang and Ding, Mingyu and Yao, Huaxiu},
  title        = {AutoResearchClaw: Fully Autonomous Research from Idea to Paper},
  year         = {2026},
  organization = {GitHub},
  url          = {https://github.com/aiming-lab/AutoResearchClaw},
}

Built with 🦞 by the AutoResearchClaw team

About

Fully autonomous & self-evolving research from idea to paper. Chat an Idea. Get a Paper. 🦞

Topics
paper-generation scientific-discovery autonomous-research llm-agents multi-agent-debate citation-verification self-evolving openclaw metaclaw
Resources
 Readme
License
 MIT license
Contributing
 Contributing
 Activity
 Custom properties
Stars
 7k stars
Watchers
 28 watching
Forks
 723 forks
Report repository


Releases 4
v0.3.1 — OpenCode Beast Mode + Community Contributions
Latest
+ 3 releases


Packages
No packages published



Contributors
21
+ 7 contributors


Languages
Python
95.3%
 
HTML
2.3%
 
TeX
0.8%
 
BibTeX Style
0.6%
 
CSS
0.6%
 
Shell
0.3%
 
Dockerfile
0.1%
Footer
© 2026 GitHub, Inc.
Footer navigation
Terms
Privacy
Security
Status
Community
Docs
Contact
Manage cookies
Do not share my personal information
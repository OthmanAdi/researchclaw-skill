# Deep Technical Findings — AutoResearchClaw Internals
> Findings from source code analysis, March 20, 2026
> These details are NOT covered in the existing folder documents.

---

## 1. ACP (Agent Client Protocol) — Persistent Sessions

AutoResearchClaw's `researchclaw/llm/acp_client.py` (14KB) implements **persistent agent sessions** via ACP. This is fundamentally different from normal API calls:

- **Normal mode**: Each stage makes independent API calls → no memory between stages
- **ACP mode**: A single Claude Code (or Copilot/Gemini CLI) session stays alive across all 23 stages → the agent remembers context from literature review when writing experiments, and from experiments when writing the paper

**Configuration:**
```yaml
llm:
  provider: "acp"
  acp:
    agent: "claude"   # Any ACP-compatible agent
    cwd: "."          # Working directory for the agent session
```

**Why this matters:** ACP mode means Claude Code becomes the brain, not just the API. The agent has full access to the filesystem, can read generated artifacts, and maintains conversational context. No separate API key needed — it uses whatever model the agent is already connected to.

**Compatible agents:** Claude Code, Copilot CLI, Gemini CLI, OpenCode, Kimi CLI.

---

## 2. Claude Anthropic Adapter

`researchclaw/llm/anthropic_adapter.py` (6KB) transforms Claude's Messages API format into OpenAI-compatible format so the pipeline can use Claude seamlessly:

- Merges system messages (Claude doesn't support multiple system messages like OpenAI)
- Maps `max_tokens` → `max_tokens` (naming differs between APIs)
- Handles Claude's unique response structure (`content[0].text` vs `choices[0].message.content`)
- Wraps the `anthropic` Python package (requires `pip install httpx` for Anthropic SDK)

**Key insight:** This adapter means you can use Claude as the primary model with full native support, not just as an OpenAI-compatible endpoint.

---

## 3. Self-Healing Experiment Engine

`researchclaw/pipeline/experiment_repair.py` (30KB) + `experiment_diagnosis.py` (26KB) implement a sophisticated self-healing system:

### 14 DeficiencyType Categories:
| Type | What It Catches |
|------|----------------|
| `MISSING_DEPENDENCY` | Import errors, missing packages |
| `INFRA_ISSUE` | Docker, GPU, memory problems |
| `TRAINING_INSTABILITY` | NaN/Inf in loss, gradient explosion |
| `EXECUTION_COVERAGE` | Code paths not exercised |
| `DATA_QUALITY` | Data loading, preprocessing failures |
| `SYNTAX_ERROR` | Python syntax issues in generated code |
| `TYPE_ERROR` | Wrong types passed to functions |
| `SHAPE_MISMATCH` | Tensor dimension mismatches |
| `CONVERGENCE_FAILURE` | Model not learning |
| `RESOURCE_EXHAUSTION` | OOM, disk full |
| `TIMEOUT` | Experiments exceeding time budget |
| `IMPORT_CONFLICT` | Version incompatibilities |
| `RUNTIME_ERROR` | General runtime exceptions |
| `VALIDATION_FAILURE` | Results don't pass quality checks |

### Repair Flow:
1. Run experiment → failure detected
2. Diagnose failure → classify DeficiencyType + severity (critical/major/minor)
3. Apply targeted repair strategy:
   - **Dependency issues**: Auto-install missing packages
   - **Training instability**: Reduce learning rate, add gradient clipping
   - **Shape mismatch**: LLM-based code repair with tensor shape context
   - **Resource exhaustion**: Reduce batch size, scope reduction
4. Re-validate with AST checks
5. Re-execute → up to 10 refinement iterations (configurable)
6. If multiple candidates exist, select best-performing version

---

## 4. Code Generation Pipeline (Multi-Phase)

`researchclaw/pipeline/code_agent.py` (53KB) — the largest pipeline module:

### 5-Phase Code Generation:
1. **Blueprint Planning**: LLM generates a deep specification including:
   - Per-file pseudocode
   - Tensor shapes and dimensions
   - File generation ordering (dependency graph)

2. **Sequential File Generation**: Files generated following dependency order with **CodeMem** — AST-compressed summaries of previously generated files injected as context

3. **Hard Validation Gates**:
   - AST parse check (syntax)
   - `__main__` block presence check
   - Import consistency check (all imports resolvable)
   - No circular dependency check

4. **Execution-in-the-Loop**: Generated code runs in sandbox; runtime errors feed back to LLM for targeted repair with full stack trace context

5. **Tree Search** (optional): Multiple code candidates explored and evaluated; best-performing variant selected

### CodeMem System:
When generating file B that depends on file A, the pipeline doesn't send the full source of file A. Instead, it creates an AST-compressed summary:
- Function signatures with types
- Class definitions with method signatures
- Exported constants and their values
- ~70% token reduction vs full source

---

## 5. MetaClaw Integration — Self-Learning Across Runs

`researchclaw/metaclaw_bridge/` (18KB total) implements cross-run learning:

### How It Works:
1. Every pipeline run extracts **lessons** (failures, warnings, slow stages)
2. Lessons are classified into 6 categories: SYSTEM, EXPERIMENT, WRITING, ANALYSIS, LITERATURE, PIPELINE
3. Stored as JSONL with severity, timestamp, stage name
4. **Time-weighted decay** with 30-day half-life — recent lessons matter more
5. Lessons above `min_severity` threshold automatically converted into **MetaClaw skills**
6. Skills are named with `arc-` prefix (e.g., `arc-fix-nan-gradients`)
7. On subsequent runs, relevant skills are **injected into stage prompts**
8. Max 3 skills generated per run to prevent bloat

### Measured Impact (from controlled A/B experiments):
| Metric | Improvement |
|--------|-------------|
| Stage retry rate | -24.8% |
| Refine cycle count | -40.0% |
| Pipeline stage completion | +5.3% |
| Overall robustness score | +18.3% |

**Configuration:**
```yaml
metaclaw_bridge:
  enabled: true
  proxy_url: "http://localhost:30000"
  skills_dir: "~/.metaclaw/skills"
  lesson_to_skill:
    enabled: true
    min_severity: "warning"
    max_skills_per_run: 3
```

---

## 6. Hardware Auto-Detection

`researchclaw/hardware.py` (7KB) detects available compute and adapts code generation:

| Hardware | Detection Method | Impact on Generated Code |
|----------|-----------------|------------------------|
| NVIDIA CUDA | `torch.cuda.is_available()` | Uses `.cuda()`, `DataParallel`, CUDA-specific imports |
| Apple MPS | `torch.backends.mps.is_available()` | Uses `.to("mps")`, avoids CUDA-only ops |
| CPU-only | Fallback | Smaller models, fewer epochs, no GPU imports |

Generated experiment code automatically includes the correct device handling based on detection results.

---

## 7. Paper Verifier — Anti-Fabrication Defense

`researchclaw/pipeline/paper_verifier.py` (18KB) — hard, deterministic defense against number fabrication:

### What It Does:
- Extracts ALL numbers from the generated LaTeX paper
- Cross-references them against actual experiment results
- **Context-aware**: strict in Results/Experiments sections; lenient in Introduction/Related Work
- Skips citations, code blocks, and reference numbers
- Validates condition names match actual experimental conditions
- Checks training config numbers (learning rates, batch sizes, epochs)

### Severity Levels:
- **Critical**: Number in Results section doesn't match any experiment output → paper revision triggered
- **Warning**: Number in Methodology slightly off → flagged but not blocked
- **Info**: Number in Introduction is approximate → acceptable

**This is NOT an LLM-based check.** It's deterministic number extraction and matching — the LLM cannot talk its way out of fabricated results.

---

## 8. Multi-Source Citation Verification (4 Layers)

`researchclaw/literature/verify.py` (32KB) — the most thorough citation system:

### Verification Order (optimized for speed):
1. **DOI Resolution** (fastest): CrossRef API → DataCite fallback
2. **arXiv ID Lookup**: Direct arXiv API query (1.5s delay between requests, respecting rate limits)
3. **OpenAlex Search**: Broader academic search
4. **Semantic Scholar Title Match**: Fuzzy title matching as last resort

### Classification Results:
| Status | Meaning |
|--------|---------|
| `VERIFIED` | Paper found in at least one source with matching metadata |
| `SUSPICIOUS` | Partial match — title similar but metadata differs |
| `HALLUCINATED` | Paper not found in any source → **automatically removed from paper** |
| `SKIPPED` | Verification could not be performed (API error, rate limit) |

**Hallucinated references are hard-removed**, not just flagged. The paper is revised to remove any claims that relied solely on hallucinated citations.

---

## 9. Domain Detection System

`researchclaw/domains/detector.py` (20KB) automatically detects the research domain from the topic:

### Supported Domains:
- Machine Learning / Deep Learning
- Natural Language Processing
- Computer Vision
- Reinforcement Learning
- Robotics
- Bioinformatics / Computational Biology
- Mathematics / Statistics
- Systems / Networks

### Impact:
- **Prompts**: Domain-specific prompt templates injected into LLM calls
- **Literature search**: Domain-specific query expansion and source prioritization
- **Experiments**: Domain-appropriate evaluation metrics and baselines
- **Paper style**: Domain conventions for section naming and methodology presentation

---

## 10. Execution Environments (5 Options)

| Environment | Module | Use Case |
|-------------|--------|----------|
| **Sandbox** | `experiment/sandbox.py` (17KB) | Local Python with memory limits, fastest |
| **Docker** | `experiment/docker_sandbox.py` (20KB) | Isolated containers, GPU support, network policies |
| **SSH Remote** | `experiment/ssh_sandbox.py` (15KB) | Lab servers, distributed machines |
| **Google Colab** | `experiment/colab_sandbox.py` (12KB) | Free GPU via Colab Drive polling |
| **OpenCode Beast Mode** | `pipeline/opencode_bridge.py` (24KB) | Complex multi-file experiments delegated to OpenCode AI |

### Docker Network Policies:
```yaml
docker:
  network_policy: "setup_only"  # none | setup_only | pip_only | full
```
- `none`: Complete network isolation
- `setup_only`: Network during setup, disabled during execution
- `pip_only`: Only pip install allowed
- `full`: Unrestricted (not recommended)

### OpenCode Beast Mode:
When experiment complexity exceeds a threshold (configurable, default 0.2), the code generation is delegated to OpenCode — an external AI coding agent that can handle multi-file projects with custom architectures. Fallback to LLM-based generation if OpenCode fails.

---

## 11. Research Decision Engine (Stage 15)

The pipeline doesn't just go forward. Stage 15 (`RESEARCH_DECISION`) autonomously evaluates results and decides:

| Decision | Action | What Happens |
|----------|--------|-------------|
| `PROCEED` | Continue to paper writing | Normal flow → Stage 16 |
| `REFINE` | Tweak parameters | Loop back to Stage 13 (iterative refine), new version directory created |
| `PIVOT` | Change research direction | Loop back to Stage 8 (hypothesis generation), full version bump |

**Versioning**: Each REFINE/PIVOT creates a versioned subdirectory. Max pivots configurable via `MAX_DECISION_PIVOTS`. This prevents infinite loops while allowing genuine iterative improvement.

---

## 12. The Prompts File — 147KB of Prompt Engineering

`researchclaw/prompts.py` (147KB) is the single largest file in the project. It contains default LLM prompts for ALL 23 stages plus sub-tasks. Key observations:

- **Anti-fabrication guards** embedded in paper writing prompts
- **Revision length limits** to prevent LLM verbosity drift
- **Disclaimer prevention** — explicit instructions to NOT add "limitations of this automated study" disclaimers
- **Multi-agent debate** prompts for hypothesis generation, result analysis, and peer review
- **Conference-specific** formatting instructions (NeurIPS vs ICML vs ICLR conventions)

Can be overridden with:
```yaml
prompts:
  custom_file: "my-prompts.yaml"
```

---

## 13. Data References Built In

| File | Size | Content |
|------|------|---------|
| `benchmark_knowledge.yaml` | 30KB | Registry of ML benchmarks (ImageNet, GLUE, SQuAD, etc.) with expected ranges |
| `dataset_registry.yaml` | 4KB | Available datasets for experiments |
| `docker_profiles.yaml` | 3KB | Pre-configured Docker images for different experiment types |
| `seminal_papers.yaml` | 8KB | Reference papers per domain for baseline comparisons |

The benchmark knowledge database tells the LLM what "reasonable results" look like — if an experiment claims 99.9% accuracy on ImageNet, the verifier flags it immediately.

---

## 14. Security: SSRF Protection

`researchclaw/web/` includes an SSRF (Server-Side Request Forgery) protection module that prevents the pipeline from:
- Making requests to internal/private IP ranges
- Accessing localhost or metadata endpoints
- Following redirects to internal addresses

This matters because the literature search and web crawling stages make HTTP requests based on LLM-generated queries — without SSRF protection, a compromised LLM prompt could exfiltrate data.

---

## 15. Test Suite Scale

- **1,634 tests** passing (pytest)
- **8 complete papers** generated and validated across domains:
  - Mathematics
  - Statistics
  - Biology
  - Computing
  - NLP
  - Reinforcement Learning
  - Computer Vision
  - Robustness

These aren't toy tests — they include full end-to-end pipeline runs that produced real papers with verified citations.

# AutoResearchClaw Pipeline Stages Reference

The pipeline consists of 23 stages organized into 8 phases. Three stages (5, 9, 20) are human-approval gates that pause for review unless `--auto-approve` is set.

## Phase 1: Topic and Problem Definition (Stages 1-2)

| Stage | Name | What It Does | Output |
|---|---|---|---|
| 1 | TOPIC_INIT | Parse and refine the research topic into a structured research question | `topic_analysis.json` |
| 2 | PROBLEM_DECOMPOSE | Break the research question into sub-problems and identify key variables | `problem_decomposition.json` |

## Phase 2: Literature Review (Stages 3-4)

| Stage | Name | What It Does | Output |
|---|---|---|---|
| 3 | LITERATURE_SEARCH | Query arXiv and Semantic Scholar for relevant papers | `search_results.json`, `papers/` |
| 4 | LITERATURE_ANALYSIS | Read, summarize, and identify gaps in existing work | `literature_review.json`, `gap_analysis.json` |

## Phase 3: Research Direction (Stage 5 — Gate)

| Stage | Name | What It Does | Output |
|---|---|---|---|
| 5 | RESEARCH_DIRECTION | Present proposed research direction for human approval | `direction_proposal.json` |

**Gate behavior:** Pauses for human review. The user can approve, modify, or reject the direction. With `--auto-approve`, this is skipped.

## Phase 4: Hypothesis and Experiment Design (Stages 6-9)

| Stage | Name | What It Does | Output |
|---|---|---|---|
| 6 | HYPOTHESIS_GEN | Generate testable hypotheses based on literature gaps | `hypotheses.json` |
| 7 | EXPERIMENT_DESIGN | Design experiments to test each hypothesis | `experiment_design.json` |
| 8 | EXPERIMENT_REVIEW | AI peer review of experiment design for flaws | `design_review.json` |
| 9 | EXPERIMENT_APPROVAL | Present experiment plan for human approval (Gate) | `approved_plan.json` |

## Phase 5: Experiment Execution (Stages 10-14)

| Stage | Name | What It Does | Output |
|---|---|---|---|
| 10 | CODE_GENERATION | Generate Python experiment code | `experiment.py` |
| 11 | CODE_REVIEW | AI review of generated code for bugs and issues | `code_review.json` |
| 12 | EXPERIMENT_EXECUTION | Execute the experiment in sandbox/simulated/remote mode | `runs/run-*.json` |
| 13 | RESULT_COLLECTION | Collect and organize experiment results | `raw_results.json` |
| 14 | RESULT_ANALYSIS | Statistical analysis and interpretation of results | `experiment_summary.json`, `results_table.tex` |

**Stage 10 is the most common failure point.** The generated code may have syntax errors, missing imports, or incompatible library versions. If it fails, check `artifacts/*/stage-10/experiment.py`.

## Phase 6: Paper Writing (Stages 15-17)

| Stage | Name | What It Does | Output |
|---|---|---|---|
| 15 | PAPER_OUTLINE | Generate paper structure and section outline | `paper_outline.json` |
| 16 | SECTION_WRITING | Write each section (abstract, intro, method, results, discussion, conclusion) | `sections/` |
| 17 | PAPER_DRAFT | Assemble sections into a complete paper draft | `paper_draft.md`, `paper_draft.tex` |

## Phase 7: Review and Revision (Stages 18-20)

| Stage | Name | What It Does | Output |
|---|---|---|---|
| 18 | PEER_REVIEW | Multi-agent peer review simulating conference reviewers | `reviews.json` |
| 19 | REVISION | Address reviewer comments and revise the paper | `revised_paper.md` |
| 20 | FINAL_REVIEW | Present revised paper for human approval (Gate) | `final_review.json` |

## Phase 8: Finalization (Stages 21-23)

| Stage | Name | What It Does | Output |
|---|---|---|---|
| 21 | CITATION_VERIFICATION | 4-layer verification of all citations (URL check, DOI check, content match, hallucination detection) | `citation_report.json` |
| 22 | VISUALIZATION | Generate charts and figures for the paper | `charts/` |
| 23 | FINAL_EXPORT | Compile LaTeX to PDF, generate final artifacts | `final_paper.pdf`, `final_paper.tex` |

## Typical Execution Times

| Mode | Approximate Time | Notes |
|---|---|---|
| Simulated (no code execution) | 30-60 minutes | Fastest, good for testing |
| Sandbox (local execution) | 1-3 hours | Depends on experiment complexity |
| SSH Remote (GPU) | 1-4 hours | Depends on GPU availability and experiment |

## Hardware Requirements

| Component | Minimum | Recommended |
|---|---|---|
| RAM | 16 GB | 32 GB+ |
| Disk | 10 GB free | 50 GB free |
| CPU | 4 cores | 8+ cores |
| GPU | Not required (simulated mode) | NVIDIA with CUDA (sandbox/remote) |
| Network | Required (API calls + literature search) | Stable broadband |

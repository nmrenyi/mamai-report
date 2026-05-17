# MAMAI Technical Report — Paper Design

Two-paper structure for documenting the MAMAI project publicly. Both papers
posted to arXiv as tech reports (no venue target). ACM journal style
(`acmart`, `acmsmall`, `nonacm`).

## Repository layout

Both papers live in a single git repo:

```
mamai-report/
├── paper_design.md         (this doc)
├── system-paper/           (Paper 1: system + evaluation)
└── benchmarks-paper/       (Paper 2: mamabench + mamaretrieval)
```

A monorepo is used (rather than one repo per paper) because the two
papers share a bibliography, cross-reference each other, and iterate
together when an audit number in one affects the error bar in the other.

---

## The split

| Paper | Title (working) | Scope |
|---|---|---|
| **Paper 1** | *MAMAI: An On-Device Medical RAG System for Zanzibar Nurses and Midwives* | The deployed system + all evaluation results for that system |
| **Paper 2** | *mamabench & mamaretrieval: Benchmarks for Evaluating Medical RAG in Maternal & Neonatal Health* | The two reusable benchmark artifacts + their validation |

Paper 1 references Paper 2 for benchmark details; Paper 2 references Paper 1
as a representative consumer. Either can be read alone.

---

## Why two papers (not one, not three)

- **Different audiences.** Paper 1 reaches global-health / clinical-AI /
  on-device-ML readers. Paper 2 reaches NLP / IR / benchmark-construction
  readers. A single document would force both sets of readers through
  content they don't need.
- **Different lifetimes.** Paper 1 is tied to Gemma 4 E4B + bundle v1.0.0
  and will go stale as the system evolves. Paper 2 documents reusable
  artifacts that should outlive any specific deployment.
- **Citation hygiene.** Anyone using `nmrenyi/mamabench` on HuggingFace
  should cite Paper 2, not the Zanzibar deployment paper.
- **Avoided three-paper duplication.** Splitting mamabench from
  mamaretrieval would duplicate ~30% of content (corpus context, OBGYN
  scope, LLM-judge infrastructure) without adding citation surface.

---

## The result-placement principle

**A result lives in the paper whose central claim it verifies.**

- Paper 1's claim: *this on-device system works (or doesn't) for Zanzibar
  clinicians.* → needs deployed-system scores.
- Paper 2's claim: *these benchmarks are valid measurement instruments.*
  → needs reliability / agreement / audit results, not deployed-system
  scores.

If a number is interesting for both, it lives in Paper 1 and Paper 2
references it.

---

## Paper 1 — System & Evaluation

### Working outline

1. **Introduction** — Zanzibar nurse/midwife context, on-device constraint,
   safety priority. The deployment problem this system targets.
2. **System architecture** — Flutter UI ↔ Kotlin native ↔ RagPipeline.
   Gemma 4 E4B via LiteRT-LM, Gecko-110M embeddings, SQLite vector store.
   CPU/GPU backend selection. Streaming, concurrency constraints.
3. **Guideline corpus & RAG bundle** — sources (WHO, NICE, Tanzania MOH,
   Zanzibar MOH, MSF, Oxford Handbook, Hesperian, …), tier system,
   marker-pdf → chunking → Gecko embedding pipeline. Bundle versioning.
4. **Evaluation methodology** — bottom-up framework: retriever in
   isolation → generator under oracle context → end-to-end. Brief
   pointer to Paper 2 for benchmark construction details.
5. **Retrieval evaluation results** (on mamaretrieval)
   - Deployed Gecko+SQLite top-3 vs BM25 / MedCPT / Octen-8B / RRF.
   - Hit Rate@k, MRR, nDCG@k, Recall@k, Precision@k.
   - Per-source-tier breakdown.
6. **Generator-isolation results** (oracle context from mamaretrieval)
   - Faithfulness via MiniCheck (Pipeline 1: scispaCy direct;
     Pipeline 2: + MedScore decomposition).
   - Calibration vs frontier-LLM judge on subset.
   - Stability: paraphrase sensitivity, run-to-run variance,
     greedy vs sampled.
   - Deployment-integrity checks: citation existence,
     contradiction-among-guidelines set.
7. **End-to-end results** (on mamabench)
   - Model × RAG matrix: {Gemma 4 E4B, MedGemma, Meditron-70B,
     Llama-3 / Qwen 2.5, GPT-5, Claude, Gemini} × {no-RAG, +RAG}.
   - MCQ accuracy + calibration (Brier, ECE).
   - Open-ended HealthBench-style rubric scores.
   - Safety: EquityMedQA / FairMedQA pass rates, MedEqualQA / MedFuzz
     robustness.
   - Corpus-composition ablation (WHO-only / Tanzania-only /
     Zanzibar-only / full).
8. **Latency & deployment results** (on real Android hardware)
   - P50/P90/P99 per component (retrieval, generation cold/warm,
     end-to-end).
   - Sustained-load thermal throttling.
   - Battery drain per session.
   - Multi-device comparison (high-end vs Zanzibar-representative).
9. **Discussion** — RAG-hurts-on-device finding, faithfulness vs MCQ
   trade-off, when local guidelines diverge from global standards,
   safety implications.
10. **Limitations** — single-deployment, queries-generated-by-LLMs caveat
    (link to Paper 2's audit), no clinical-trial data, contamination
    caveat on MedMCQA/MedQA/MMLU.
11. **Related work** — on-device LLMs, medical RAG, global-health AI.

### Out of scope for Paper 1

- Full schema and construction of mamabench / mamaretrieval (→ Paper 2).
- Inter-classifier agreement on the OBGYN scope filter (→ Paper 2).
- Phase 3 completeness audit methodology (→ Paper 2; the audit number
  is cited in Paper 1 as the error bar on retrieval scores).
- Producer-pipeline engineering minutiae (marker-pdf flags,
  cluster-submission scripts, embedding-format byte layout) — keep
  high-level in §3, push details to an appendix or the
  mamai-medical-guidelines repo README.

---

## Paper 2 — Benchmarks

### Working outline

1. **Introduction** — gap analysis: existing medical benchmarks are
   under-representative of OBGYN / neonatal / Sub-Saharan-Africa /
   midwifery contexts. Why we needed dedicated benchmarks for the
   downstream RAG evaluation.
2. **Corpus** — shared corpus context for both benchmarks (the
   mamai-medical-guidelines RAG bundle v0.2.0: 63,650 chunks,
   87 sources, tier system).
3. **mamabench — QA benchmark**
   - Sources: MedMCQA, MedQA-USMLE, AfriMed-QA (MCQ + SAQ),
     Kenya Clinical Vignettes, WHB stumps, HealthBench.
   - Schema versions 0.3 (v0.1) and 0.4 (v0.2).
   - 25,997 rows × 7 sources × 3 set_types (mcq, open_ended,
     open_ended_rubric).
   - OBGYN-scope classifier: prompt v8, Qwen3.6-27B-FP8 thinking-on,
     unified 5-category schema, vLLM `guided_json` for structured output.
   - In-place cleanup rules for AfriMed-QA (letter-prefix stripping,
     multi-answer skipping, ambiguous-position skipping).
   - Validation, manifest, and HF release flow.
4. **mamabench — validation results**
   - Cross-classifier agreement (Qwen3.6-27B vs Qwen3.5-397B = 98.12% on
     HealthBench oss_eval).
   - Kenya parity check vs prior Gemini labels (86.8%).
   - 7 non-convergent prompt disclosure + 397B mop-up evidence.
   - Per-source filter yield: Kenya 61.5%, oss_eval 24.2%, hard 25.9%,
     consensus 23.8%, MedQA-USMLE 29.2%, AfriMed-SAQ 100%, WHB 100%.
5. **mamaretrieval — retrieval benchmark**
   - Funnel: 63,650 → 4,540 sampled (tier-weighted) → 3,185 LLM-filtered
     queries with seed → top-10 × {BM25, MedCPT, Octen-8B} pooled
     (~24.7 candidates/query) → 78,571 (query, chunk) pairs judged.
   - LLM filtering rationale: Qwen3.6-27B vs Qwen3 9B comparison.
   - 3-dimension judge rubric (D1 topic / D2 meaningful / D3 actionable),
     score = D1 × (D2 + D3) ∈ {0, 1, 2}. Research backing
     (TREC-CDS, DeCE, Saracevic, UMBRELA, HealthBench, G-Eval).
   - TREC-style pooling design; seed-chunk policy.
   - Reproducibility: PROMPT_HASH, RESULT_SCHEMA_VERSION,
     guided_json, resume semantics, sharding-by-query.
6. **mamaretrieval — validation results**
   - 78,571 / 78,571 pairs labeled, 0 errors, 0 invariant violations.
   - Score distribution: 0=49.3%, 1=19.1%, 2=31.6%.
   - 10-sample stratified manual spot-check verdict.
   - **Phase 3 completeness audit** — 30-query gold subset with
     voyage-4-large, BGE-reranker, LateOn additions; gap on Hit Rate /
     MRR / nDCG between pipeline labels and exhaustive labels. This is
     the error bar on every retrieval number in Paper 1.
7. **A small retriever-baseline table** — BM25 / MedCPT / Octen-8B
   side-by-side on mamaretrieval, framed as showing the benchmark
   distinguishes retrievers (not as endorsing one for production —
   that's Paper 1's job).
8. **Limitations** — LLM-generated queries phrased similarly to chunk
   text inflates dense-retriever scores; no hand-written calibration
   queries; benchmark tied to corpus version
   (`(corpus_version, queries, labels)` is one versioned artefact);
   single-judge model bias.
9. **Access** — HuggingFace dataset link, GitHub repos, license notes
   (AfriMed-QA's CC-BY-NC-SA 4.0 propagation).

### Out of scope for Paper 2

- Any scores of Gemma 4, MedGemma, GPT-5, etc. on these benchmarks
  (→ Paper 1).
- The mamai system architecture, latency, deployment context.
- Producer-pipeline engineering (the corpus is treated as an input).

---

## Cross-references between papers

- Paper 1 §4 (methodology) cites Paper 2 §3 + §5 once each, then refers
  by name (`mamabench`, `mamaretrieval`) thereafter.
- Paper 1 §5–§7 cite Paper 2 §6 once at the top of the retrieval-results
  section to declare the audit-gap error bar.
- Paper 2 §1 cites Paper 1 as the motivating consumer, but Paper 2's
  argument does not require knowing the mamai system internals.

---

## Format, source, and distribution

- **arXiv tech reports** for both. No conference page limit.
- **Source format: direct LaTeX** (`.tex`). No Quarto / Pandoc / Markdown
  translation layer. Reasons:
  - LaTeX source is already AI-friendly — LLMs read `\section{}`, `\cite{}`,
    `\begin{tabular}` fluently. The PDF-is-bad-for-AI problem is about
    rendering loss, not source readability.
  - arXiv auto-generates HTML at `arxiv.org/html/<id>` from LaTeX submissions
    (via ar5iv). No need for a custom HTML toolchain.
  - One compile stage, one set of error messages, full `acmart` feature
    access with zero abstraction cost.
- **Template: ACM journal style** (`acmart` class, `acmsmall` variant).
  Single-column, journal-quality typography (Libertine + Biolinum + STIX
  math), generous margins. Same template used for both papers for
  consistent visual identity.
- **LaTeX preamble:**
  ```latex
  \documentclass[acmsmall,nonacm,review]{acmart}
  ```
  - `acmsmall` — single-column journal layout.
  - `nonacm` — drops ACM copyright block, conference banner, DOI line,
    CCS-concepts requirement. Required for arXiv-only use.
  - `review` — line numbers + looser layout while drafting; remove for
    the final arXiv PDF.
- **Bibliography:** default `ACM-Reference-Format.bst` is fine but verbose;
  consider `\bibliographystyle{abbrvnat}` + `\citestyle{acmauthoryear}` for
  cleaner author-year citations.
- **Distribution surfaces:**
  - **arXiv PDF** — citation target, archival.
  - **arXiv auto-HTML** — free web reading at `arxiv.org/html/<id>`.
  - **GitHub `.tex` source** — AI-readable primary source, version-controlled.
- **No specific venue target.** If a venue is later chosen, `acmart`
  already supports retargeting: switch `acmsmall` → `sigconf` for an ACM
  conference, or rewrite the preamble for ACL/NeurIPS as needed. Paper 1
  is the natural carve-out candidate (system + headline eval) for a
  venue-length submission.

---

## Open issues to resolve before drafting

- Some Paper 1 results are not yet generated (full faithfulness eval,
  stability probes, full model × RAG matrix on mamabench v0.2,
  multi-device latency on Zanzibar-representative hardware). The
  report can be drafted around the completed pieces and grown as
  results arrive — *or* held until the eval matrix is complete.
  Decision pending.
- Phase 3 completeness audit for mamaretrieval is pending. Paper 2
  can ship without it (with the gap reported as future work), but the
  audit number is what gives Paper 1's retrieval-scores their error
  bar. Recommended: ship Paper 2 with the audit included.
- Authorship list and per-paper contribution statements.
- License decision for the report PDFs themselves (CC-BY 4.0 typical
  for arXiv).

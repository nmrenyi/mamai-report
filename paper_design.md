# MAMAI Technical Report — Paper Design

Two-paper structure for documenting the MAMAI project publicly. Both papers
posted to arXiv as tech reports (no venue target). ACM journal style
(`acmart`, `acmsmall`, `nonacm`).

*Last reconciled against the artifact repos on 2026-06-10. All numbers
below were verified against released artifacts or committed reports on
that date; sections marked **[pending]** are gated on runs that have not
happened yet.*

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

- **Different audiences.** Both papers are technical; they target
  different kinds of technical reader. Paper 1 is a *systems* paper for
  on-device-ML and applied clinical-NLP readers — motivated by a
  global-health deployment, but the Zanzibar context is the setting,
  not the audience. Paper 2 is a *benchmarks/resources* paper for
  NLP / IR / benchmark-construction readers. A single document would
  force both sets of readers through content they don't need.
- **Different lifetimes.** Paper 1 is tied to Gemma 4 E4B + RAG bundle
  v0.2.0 and will go stale as the system evolves. Paper 2 documents
  reusable artifacts that should outlive any specific deployment.
- **Citation hygiene.** Anyone using `nmrenyi/mamabench` or
  `nmrenyi/mamaretrieval` on HuggingFace should cite Paper 2, not the
  Zanzibar deployment paper.
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

One consequence worth naming: the **six-retriever scoreboard** (Tier 2/3
audit in `mamaretrieval/AUDIT_REPORT_v2.md`) appears in both papers with
different framing. Paper 2 presents it as evidence the benchmark
*separates retrievers ordinally*; Paper 1 presents it as the evaluation
of the *deployed Gecko configuration* against alternatives.

---

## Narrative target

The interesting story is no longer "we built benchmarks." It is
(per `mamai-mamabench-docs/next-steps-2026-06.md`):

1. **Oracle-context faithfulness is essentially solved** — calibrated
   true-hallucination rate ≈ 0.3% for Gemma 4 E4B under oracle context.
   The safety floor is clean end-to-end too: zero `dangerous` verdicts
   across all 738 SAQ rows, both arms.
2. **The system is safe but unhelpful** (Phase B, 2026-06-09) — the
   model earns only 11–18% of achievable positive rubric credit
   (HealthBench oss_eval/hard) and ~17–21% key-fact recall (SAQ), with
   ~1/3 of responses conveying zero key facts. The loss is behavioral,
   not knowledge: scope-refusal + "escalate to a doctor" deferral
   account for ~91–96% of zero-recall rows. Completeness is the weak
   axis on both tracks.
3. **RAG is ≈ neutral on the open-ended tracks** (deltas −0.5/−2.0/−0.3
   pp on rubric, −0.5 to −4.9 pp recall on SAQ, mostly within noise) and
   a small regression on MCQ (−1.8 pp). The deployed retriever is still
   the weakest measured component — Gecko ~25 pp behind voyage / octen /
   lateon on weighted precision — but retrieval is *not* the recall
   lever.
4. **The levers are corpus coverage** (ICM demo finding) **and
   prompt/behavior changes** (the "won't name specifics" deferral
   pattern is cheap to fix) — not model swaps, not fine-tuning.

Both papers should be written so this arc is visible: Paper 2 builds the
instruments; Paper 1 uses them to localize the system's failure mode to
coverage and conservative behavior, not the generator's faithfulness.

---

## State of the artifacts (2026-06-10)

| Artifact | Version | Status |
|---|---|---|
| RAG bundle (`mamai-medical-guidelines`) | **v0.2.0** (2026-05-19) | Released. 63,650 chunks, 87 sources, stable 64-bit CIDs. The app pins this version (`rag_assets.lock.json`). *There is no v1.0.0.* |
| mamabench (HF `nmrenyi/mamabench`) | **v0.2.1** (2026-05-21) | Released. 25,949 rows, schema 0.4, + judge-calibration side-file (6,853 physician triples). |
| mamaretrieval (HF `nmrenyi/mamaretrieval`) | **v0.2.0** (2026-05-24) | Released. 3,185 queries; Tier 3 = 230,964 judged pairs (top-20 × 6 retrievers, v2 graded rubric). |
| Faithfulness eval (`mamai-eval` branch `feat/faithfulness-eval`) | v0.2.0 doc (2026-05-21) | Run twice. Calibrated headline ≈ 0.3% true hallucination. Final closed-source recalibration pending. |
| End-to-end eval (`mamai-eval` `config-v0.2.0`) | — | Complete for **Gemma 4 E4B only** (MCQ / rubric / SAQ, ±RAG). Other models not run. |
| Phase A judge calibration (`docs/judge-validation-phase-a-result-20260608.html`) | 2026-06-08 | **Done.** 5 judges on the 6,853-triple physician set; no judge at physician baseline; **gpt-oss-120b stands** (mildest bias, −3.8 pp met-rate, conservative); gpt-5 under-rates −18.7 pp. gpt-5.4-mini result pending for completeness. |
| Phase B open-ended rescore (`docs/phase-b-rubric-result-20260609.html`, `phase-b-saq-result-20260609.html`) | 2026-06-09 | **Done.** 38,308 rubric verdicts + ~3,700 SAQ key-fact verdicts, 0 errors, pinned gpt-oss-120b judge. These are the final open-ended ±RAG numbers. |
| Latency (`mamai/evaluation/reports/latency_report_v2.md`) | 2026-05-17 | Complete on Snapdragon 8 Elite (E4B + E2B, CPU/GPU, k-sweep). Battery / thermal / multi-device pending. |
| Deployment | v0.1.1-beta.1 | Pre-deployment. No Zanzibar users this cycle; user testing dropped. |

---

## Paper 1 — System & Evaluation

### Working outline

1. **Introduction** — Zanzibar nurse/midwife context, on-device constraint,
   safety priority. The deployment problem this system targets. Honest
   framing: feature-complete pre-deployment prototype with a comprehensive
   evaluation, not a fielded system.
2. **System architecture** — Flutter UI ↔ Kotlin native ↔ RagPipeline.
   Gemma 4 E4B (int4, 3.66 GB) via LiteRT-LM 0.11.0, Gecko-110M embeddings
   (768-dim TFLite), SQLite vector store. CPU default / GPU opt-in with
   automatic fallback. 4096-token context ceiling. Streaming, concurrency
   constraints. EN/SW system prompts.
3. **Guideline corpus & RAG bundle** — sources (WHO, NICE, Tanzania MOH,
   Zanzibar MOH, MSF, Hesperian, ICM, textbooks, …), tier system,
   marker-pdf → chunking → Gecko embedding pipeline. **Pin bundle v0.2.0**
   (63,650 chunks / 87 sources, SHA-256 manifest, stable CIDs).
4. **Evaluation methodology** — bottom-up framework: retriever in
   isolation → generator under oracle context → end-to-end. Brief
   pointer to Paper 2 for benchmark construction details. Device-vs-cluster
   MCQ calibration (Δ +2.7 pp, κ 0.558 — "interchangeable") justifies
   running the matrix on cluster.
5. **Retrieval evaluation results** (on mamaretrieval Tier 2/3)
   - Deployed Gecko+SQLite vs **BM25 / MedCPT / Octen-8B / voyage-4-large /
     LateOn** (the six-retriever audit panel; the earlier BM25/MedCPT/
     Octen/RRF plan was superseded).
   - Hit Rate / weighted precision at k=3 (deployed depth) and k=20,
     lenient (score ≥ 3) and strict (≥ 5) thresholds.
   - Headline: Gecko HR@3 0.814 vs voyage 0.996; Gecko captures ~34% of
     pool relevance at k=20 vs voyage's 66% — partly ranking, partly a
     real retrieval gap.
   - Per-source-tier breakdown if cheap to produce.
6. **Generator-isolation results** (oracle context from mamaretrieval)
   - Oracle = score ≥ 5 chunks from mamaretrieval v0.1.0; 2,659 queries;
     top-3 cap to match deployment.
   - **Judge journey**: MiniCheck rejected (7B classifier, unauditable);
     Qwen3.5-397B rejected (circularity with oracle labels);
     **Patronus Lynx 70B chosen**. (The earlier MiniCheck/scispaCy/
     MedScore pipeline plan is dead — do not describe it as the method.)
   - Raw Lynx pass 94.55% (2,514/2,659); all 145 FAILs categorized;
     blinded 100-row calibration → Lynx precision ≈ 6%, miss rate 0/50,
     **population estimate ≈ 0.3% true hallucination**.
   - 6 self-contradictory oracle contexts identified
     (`mamaretrieval#18`) — disclose.
   - **[pending]** Final recalibration with the consolidated closed-source
     judge; real-retrieval faithfulness probe (deployed Gecko top-3
     instead of oracle — the experiment that gates the fine-tuning plan).
   - Stability probes (paraphrase sensitivity, run-to-run variance,
     greedy vs sampled) were **not executed** — cut from results; mention
     in limitations/future work.
7. **End-to-end results** (on mamabench, `config-v0.2.0`)
   - **Complete (Gemma 4 E4B, ±RAG; Phase B final, 2026-06-09):**
     - MCQ (23,241 rows): no-RAG 53.7% vs +RAG 51.9% — **−1.8 pp
       regression**, with net-flip analysis
       (`mcq-rag-effect-20260520.md`).
     - HealthBench rubric (2,339 rows × 2 arms, 38,308 verdicts,
       0 errors): **the headline is the absolute level, not the RAG
       delta.** Blended weighted_met ≈ 0.00 (oss_eval) / −0.18 (hard) /
       0.51 (consensus, penalty-free lens — not the same scale);
       decomposed: 11–18% of positive credit earned vs 38–46% of
       penalty weight incurred. RAG ≈ neutral (−0.5/−2.0/−0.3 pp,
       mostly within noise — report as neutral, not regression). Weak
       axis: completeness. Caveat for the paper: the three subsets are
       *nested* (consensus ⊂ oss_eval; hard mostly ⊂ oss_eval) — never
       pool them.
     - SAQ / open-ended (369 rows × 2 arms): "safe but unhelpful" —
       recall 0.18→0.13 (Kenya), ~1/3 of responses zero-recall; zero
       `dangerous` verdicts across all 738 rows; zero-recall rows are
       ~91–96% scope-refusal + defer/escalate (refusal-adjusted lift
       only +1.5–4.3 pp — the loss is behavioral, not knowledge or
       judge strictness); "won't name specifics" identified as the
       cheapest fixable pattern.
   - **Judge validation (Phase A, 2026-06-08):** five judges on the
     6,853-triple physician set; none reaches the physician baseline;
     larger open models over-rate (Maverick +11.8 pp), closed models
     under-rate (gpt-5 −18.7 pp); **gpt-oss-120b retained** (met-rate
     −3.8 pp vs physicians, LLM↔consensus 81.6%). Disclose the
     conservative bias as a known direction on all rubric numbers.
   - **Rescoped:** the full model × RAG matrix (MedGemma, Meditron,
     Llama/Qwen, GPT-5, Claude, Gemini) has **not been run** and likely
     will not be by 2026-06-30. Decide: descope the paper to "deployed
     model, fully characterized" + the older app-parity GPT-5 reference
     numbers (in `mamai/evaluation/reports/eval_report_app_parity_v1.md`,
     different protocol — label clearly if used), or hold §7 for a
     partial matrix.
   - **Cut / future work:** safety suites (mamabench v0.3 not started);
     corpus-composition ablation (not started); Brier/ECE calibration.
8. **Latency & deployment results** — from `latency_report_v2.md`
   (Snapdragon 8 Elite, 2026-05-17):
   - E4B vs E2B × CPU vs GPU × k ∈ {0…20}; GPU 2–3.5× faster;
     E4B GPU 13–25 s at k ≤ 15.
   - **FP16-GPU context wall**: deterministic decode failure at ~5,000
     total tokens; root-caused to FP16 attention precision
     (`maxnumtoken_investigation.md`); 4096 deployment ceiling. This is
     a novel, load-bearing finding — give it space.
   - Device-compatibility / market mapping (RAM floors, E2B option for
     sub-$120 tier).
   - **[pending]** battery drain, sustained-load thermal, multi-device
     (Zanzibar-representative MediaTek hardware not yet procured) —
     disclose Snapdragon-only scope.
9. **Discussion** — the narrative arc: faithfulness solved and the
   safety floor clean; the failure mode is conservative behavior
   (refusal/deferral) plus corpus coverage, not the generator. RAG:
   small MCQ regression, ≈ neutral open-ended — what that means for
   shipping RAG on-device. The retriever gap (Gecko −25 pp) and why
   closing it is necessary but not sufficient for recall.
   Local-vs-global guideline divergence.
10. **Limitations** — pre-deployment (no users, no clinical-trial data);
    single benchmark device; queries-generated-by-LLMs caveat (link to
    Paper 2); contamination caveat on MedMCQA/MedQA; no Swahili eval;
    stability probes not run; safety track deferred.
11. **Related work** — on-device LLMs, medical RAG, global-health AI,
    hallucination detection (Lynx, MiniCheck as related work),
    LLM-as-judge methodology. Seed from
    `mamai-mamabench-docs/rag-small-vs-large-literature.md`.

### Out of scope for Paper 1

- Full schema and construction of mamabench / mamaretrieval (→ Paper 2).
- Inter-classifier agreement on the OBGYN scope filter (→ Paper 2).
- Tier 1/2/3 audit *methodology* (→ Paper 2; Paper 1 consumes the
  scoreboard and cites Paper 2 for how the labels were made).
- Producer-pipeline engineering minutiae (marker-pdf flags,
  cluster-submission scripts, embedding-format byte layout) — keep
  high-level in §3, push details to the mamai-medical-guidelines README.

---

## Paper 2 — Benchmarks

### Working outline

1. **Introduction** — gap analysis: existing medical benchmarks are
   under-representative of OBGYN / neonatal / Sub-Saharan-Africa /
   midwifery contexts. Why we needed dedicated benchmarks for the
   downstream RAG evaluation.
2. **Corpus** — shared corpus context for both benchmarks (the
   mamai-medical-guidelines RAG bundle **v0.2.0**: 63,650 chunks,
   87 sources, tier system, stable chunk CIDs).
3. **mamabench — QA benchmark**
   - Sources: MedMCQA, MedQA-USMLE, AfriMed-QA (MCQ + SAQ),
     Kenya Clinical Vignettes, WHB stumps, HealthBench
     (oss_eval / consensus / hard).
   - Schema versions 0.3 (benchmark v0.1) and 0.4 (v0.2/v0.2.1).
   - **25,949 rows**: MCQ 23,241 (MedMCQA 18,508; MedQA-USMLE 4,199;
     AfriMed-QA 534), open_ended 369 (Kenya 312; AfriMed-SAQ 37;
     WHB 20), open_ended_rubric 2,339 (oss_eval 1,209; consensus 872;
     hard 258); + 12,211-row HealthBench criteria side-table.
   - OBGYN-scope classifier: prompt v8 (modular), Qwen3.6-27B-FP8
     thinking-on, five-category schema (MATERNAL, NEONATAL,
     CHILD_HEALTH, SEXUAL_AND_REPRODUCTIVE_HEALTH, NONE), vLLM
     `guided_json`, temperature 0, full reasoning side-files.
   - In-place cleanup rules for AfriMed-QA (letter-prefix stripping,
     multi-answer skipping, ambiguous-position skipping).
   - **Judge-calibration side-file** (v0.2.1): 6,853 physician-labeled
     (prompt, completion, criterion) triples derived from HealthBench
     meta-eval — lets consumers validate any LLM judge before use.
   - Validation, manifests (0 errors), and HF release flow
     (one git tag per release).
4. **mamabench — validation results**
   - Cross-classifier agreement (Qwen3.6-27B vs Qwen3.5-397B = 98.12% on
     HealthBench oss_eval, 4,988 rows).
   - Kenya parity check vs prior Gemini labels (86.8%).
   - 7 non-convergent prompt disclosure + 397B mop-up evidence
     (net in-scope effect zero).
   - Per-source filter yield: Kenya 61.5%, oss_eval 24.2%, hard 25.9%,
     consensus 23.8%, MedQA-USMLE 29.2%, AfriMed-SAQ 100%, WHB 100%.
5. **mamaretrieval — retrieval benchmark**
   - Funnel: 63,650 chunks → 4,540 tier-weighted sample → 3,185
     LLM-filtered queries with seed (Qwen3.6-27B-FP8; 70.2% kept,
     0 errors).
   - **Rubric evolution — tell it honestly:** Phase 2b used a
     three-dimension binary rubric (score = D1×(D2+D3) ∈ {0,1,2}) over
     top-10 pools from BM25/MedCPT/Octen (78,571 pairs). It was then
     superseded by the **v2 graded rubric**:
     `score = d1 × (d2 + d3 + d4) ∈ {0..6}` — D1 topic (boolean),
     D2 meaningful (0/1/2), D3 actionable (0/1/2), D4 density (0/1/2).
   - **Tiered evaluation** (replaces the planned 30-query "Phase 3
     completeness audit" — it was superseded by something strictly
     larger):
     - Tier 1 pilot (100 queries × 6 retrievers, 1,150 pairs): judge
       validation vs Claude Opus 4.7 reference labels — 95% threshold
       agreement at score ≥ 3, 85% at ≥ 5.
     - Tier 2 full (3,185 × 6, top-3 union, 36,418 pairs) → HF v0.1.0.
     - Tier 3 deep (3,185 × 6, top-20 union, **230,964 pairs**) →
       HF v0.2.0.
   - Retriever panel: BM25, MedCPT, Octen-8B, voyage-4-large, LateOn,
     Gecko (the deployed embedder).
   - Judge: Qwen3.5-397B-A17B-FP8, temperature 0, thinking budgets
     (soft 10k / hard 25k), prompt hash pinned.
   - Research backing (TREC-CDS, DeCE, Saracevic, UMBRELA, HealthBench,
     G-Eval); TREC-style pooling; seed-chunk policy.
   - Reproducibility: PROMPT_HASH, RESULT_SCHEMA_VERSION, guided_json,
     resume semantics, sharding-by-query, full thinking traces in the
     v0.2.0 `audit/` split.
6. **mamaretrieval — validation results**
   - 78,571 Phase 2b + 230,964 Tier 3 pairs labeled; 0 errors,
     0 invariant violations.
   - Phase 2b score distribution: 0 = 49.3%, 1 = 19.1%, 2 = 31.6%.
   - Pool-completeness evidence: the v1 audit measured Phase 2a's
     top-10/3-retriever pooling at ~0.49 lenient recall against a
     6-retriever pool — the finding that motivated Tier 3's top-20 ×
     6-retriever exhaustive pooling. Frame Tier 3 as the resolution of
     the completeness question, not a separate audit.
   - 10-sample stratified manual spot-check verdict; judge calibration
     vs Opus (Tier 1).
7. **Retriever scoreboard** — six retrievers side-by-side on Tier 2/3
   (HR/weighted precision @3 and @20, lenient + strict), framed as
   showing the benchmark distinguishes retrievers ordinally (voyage
   0.996 → medcpt 0.644 HR@3) — not as endorsing one for production
   (that's Paper 1's job).
8. **Limitations** — LLM-generated queries phrased similarly to chunk
   text inflate dense-retriever scores; per_chunk queries only
   (synthesis / adversarial unimplemented); no hand-review layer over
   Tier 2/3 judgments (mitigated by the Opus-calibrated judge +
   spot checks); single-judge bias; benchmark tied to corpus version
   (`(corpus_version, queries, labels)` is one versioned artefact).
9. **Access** — HuggingFace datasets (`nmrenyi/mamabench` v0.2.1,
   `nmrenyi/mamaretrieval` v0.2.0), GitHub repos, license notes
   (AfriMed-QA CC-BY-NC-SA 4.0 propagation).

### Out of scope for Paper 2

- Any scores of Gemma 4, GPT-5, etc. on these benchmarks (→ Paper 1).
- The mamai system architecture, latency, deployment context.
- Producer-pipeline engineering (the corpus is treated as an input).

---

## Cross-references between papers

- Paper 1 §4 (methodology) cites Paper 2 §3 + §5 once each, then refers
  by name (`mamabench`, `mamaretrieval`) thereafter.
- Paper 1 §5 cites Paper 2 §6 once at the top of the retrieval-results
  section for label provenance and the pooling-completeness evidence.
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
  Single-column, journal-quality typography. Same template for both papers.
  Compiled with **LuaLaTeX** (`.latexmkrc` sets `pdf_mode=4`) for CJK
  author-name support.
- **LaTeX preamble:**
  ```latex
  \documentclass[acmsmall,nonacm,review]{acmart}
  ```
  `review` (line numbers) is dropped for the final arXiv PDF.
- **Distribution surfaces:**
  - **arXiv PDF** — citation target, archival.
  - **arXiv auto-HTML** — free web reading at `arxiv.org/html/<id>`.
  - **GitHub `.tex` source** — AI-readable primary source.
  - **Concise highlights page on renyi.ch** — a *separate, short*
    hand-authored HTML artifact summarizing headline findings, written
    last (after numbers freeze), with Google Scholar `citation_*` meta
    tags pointing at the arXiv versions. Decided 2026-06-10; not a
    conversion of the full papers.
- **No specific venue target.** `acmart` retargets if one is chosen later;
  Paper 1 is the natural venue-length carve-out.

---

## Open issues (gating items, 2026-06-10)

Hard deadline: **2026-06-30** (internship end). Per
`mamai-mamabench-docs/next-steps-2026-06.md`, drafting starts now;
open-ended ±RAG and safety are written last.

0. **Drafting decisions (settled 2026-06-10):** system paper is drafted
   first (benchmarks paper second); §7 is descoped to Gemma-only with
   the matrix as future work. The earlier "draft with revision note"
   plan for the rubric numbers is moot — Phase B landed 2026-06-09 and
   those are the final numbers (disclose the judge's −3.8 pp
   conservative bias instead).
1. **Open-ended ±RAG numbers** — *resolved.* Phase A (2026-06-08)
   found no judge that beats gpt-oss-120b cleanly (escalation to
   gpt-5-tier judges makes calibration *worse* — they under-rate); the
   pinned judge stands. Phase B rescore (2026-06-09) produced the final
   rubric + SAQ numbers. Remaining loose end: the gpt-5.4-mini
   completeness result (~99% done at time of writing) — note in the
   paper only if it changes the Phase A conclusion.
2. **Faithfulness final headline** — still open. gpt-oss-120b failed
   the faithfulness-track calibration gates (75/100 vs ≥90 required),
   and Phase A's no-winner outcome means the planned closed-source
   escalation no longer has an obvious candidate. Decide: ship the
   Lynx + blinded-calibration ≈ 0.3% estimate as-is (defensible — it
   already has an independent calibration), or hold for one more judge
   run. Also: fix the 6 self-contradictory oracle contexts
   (`mamaretrieval#18`).
3. **Real-retrieval faithfulness probe** — only experiment that can fire
   the fine-tuning gate; feeds Paper 1 §6/§9.
4. **Model × RAG matrix scope decision** — *decided 2026-06-10:
   descope to Gemma-only* (see decision 0); the matrix is future work
   and the paper's claim doesn't need it.
5. **Numbers may move under June improvement work** — query rewriting
   (`mamai#62`), embedding-model swap, corpus expansion. **Freeze both
   papers on the v0.2.0 artifact generation**; report any improvement
   results as a clearly-dated addendum section or a v2 of the report.
6. Noisy-query probe (mamaretrieval robustness) — include if it lands;
   otherwise future work.
7. Authorship list and per-paper contribution statements.
8. License decision for the report PDFs (CC-BY 4.0 typical for arXiv).

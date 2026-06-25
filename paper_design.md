# MAMAI Technical Report — Paper Design

Two-paper structure for documenting the MAMAI project publicly. Both papers
posted to arXiv as tech reports (no venue target). ACM journal style
(`acmart`, `acmsmall`, `nonacm`).

*Last reconciled against the artifact repos AND the renyi.ch/projects/mamai
webpage on 2026-06-25. The project advanced substantially in June (June 18–25);
several "deployed config" and narrative facts from the earlier 2026-06-10
reconciliation are now superseded and are corrected throughout. Sections
marked **[pending]** are gated on runs that have not happened yet.*

## Audience and purpose

- The **full papers (this repo, LaTeX → arXiv)** are the *exhaustive,
  rigorous record*: every experiment, every parameter-selection decision,
  every ablation that justifies the deployed configuration. They are not
  optimized for a casual human read — they organize the work logically and
  demonstrate its richness and soundness.
- The **concise human-facing version already exists**: the
  renyi.ch/projects/mamai webpage
  (`~/Downloads/my-site/src/data/projectPages.ts`). It carries the essential
  findings for a lay/recruiter reader. **The full papers follow the
  webpage's narrative structure** but add the full experimental detail the
  webpage compresses to one line.

The webpage is the canonical narrative skeleton. The `mamai-eval` reports
(`configs/config-v0.2.0/reports/*.html`, `config-v0.3.0/`) are the canonical
source of numbers. **Do not** use `mamai-mamabench-docs/` as the skeleton —
it is frozen at 2026-06-08 and its framing is stale (see "What changed").

---

## Repository layout

```
mamai-report/
├── paper_design.md         (this doc)
├── system-paper/           (Paper 1: system + evaluation)
└── benchmarks-paper/       (Paper 2: mamabench + mamaretrieval)
```

Monorepo because the two papers share a bibliography, cross-reference each
other, and iterate together.

---

## The split (decided 2026-06-25: keep two papers)

| Paper | Title (working) | Scope | Webpage sections it covers |
|---|---|---|---|
| **Paper 1** | *MAMAI: An On-Device Medical RAG System for Zanzibar Nurses and Midwives* | The deployed system + all evaluation results | Motivation, System Design, Evaluation (all four layers), Knowledge Base |
| **Paper 2** | *mamabench & mamaretrieval: Benchmarks for Evaluating Medical RAG in Maternal & Neonatal Health* | The two reusable benchmark artifacts + their validation | MamaBench, MamaRetrieval (+ shared Corpus context) |

Both technical, different kinds of technical reader (systems vs
benchmarks/resources). Zanzibar is the setting, not the audience. The
benchmarks keep a standalone citation identity (HF datasets outlive the
deployment).

---

## The result-placement principle

**A result lives in the paper whose central claim it verifies.** Deployed-
system scores → Paper 1; benchmark-validity evidence → Paper 2. The
**7-retriever scoreboard** appears in both: Paper 2 frames it as evidence the
benchmark separates retrievers; Paper 1 frames it as the evaluation of the
deployed EmbeddingGemma config against alternatives.

**Knowledge base / corpus (decided 2026-06-25).** The **system paper owns
the full knowledge-base treatment** — its own section (kept after the
evaluation, per the webpage order), illustrated like the renyi.ch webpage
(source-family table, construction pipeline, a sample chunk). The benchmarks
paper gives only a brief corpus description for context and cross-references
Paper 1. Source-disclosure posture: neutral surface (name openly-available
sources; group commercial reference texts generically; no permissions
admission; sample chunk from a free WHO source), with full per-document
provenance left in the open bundle manifest for researchers. See memory
`mamai-report-source-disclosure`.

---

## Narrative target (REWRITTEN 2026-06-25 — the arc has inverted)

The story is no longer "retriever is the weakest link / corpus coverage is
the blocker." After the June work, the arc is:

1. **On-device retrieval is largely solved.** Swapping Gecko →
   **EmbeddingGemma-300M** put the deployed on-device retriever 3rd of 7 on
   mamaretrieval (P@3 0.784, within ~8 pp of cloud voyage; +30.7 pp over
   Gecko). A 300M model on the phone rivals cloud retrieval.
2. **But better retrieval doesn't reach the answers.** On a matched
   end-to-end study, the Gecko→EmbeddingGemma upgrade lifts retrieval P@3
   (0.270→0.396) but end-to-end Kenya recall is flat (0.125→0.126), and on
   the small generator RAG is net-neutral-to-negative vs no-RAG (0.178).
   **The binding constraint is the generator's ability to use context.**
3. **The deployed model is chosen by a safety-vs-usefulness tradeoff.**
   Gemma 3n is more helpful (higher recall, ~2× HealthBench) but far less
   safe (4–15 genuine dangerous answers, hand-adjudicated); Gemma 4 is the
   mirror image (less complete, ~0 dangerous). **We deployed Gemma 4 (safe).**
4. **A prompt redesign (G1) wins back most of the usefulness.** The base
   model deflected on ~1/3 of questions ("see a doctor"); G1 cut deflection
   32.7% → 3.2% and ~doubled key-fact recall (0.139 → 0.279) with no added
   dangerous answers.
5. **Generator faithfulness is strong and the deciding axis.** Under oracle
   context, Gemma 4's true-hallucination is 2.6–3.6% — ~2× better than
   Gemma 3n (6.3–6.7%) and on par with frontier Qwen-397B (2.5–3.7%). So
   the small size is not the problem; Gemma 3n is the outlier.
6. **The open problem is generator-side RAG-grounding** (teach the model to
   use retrieved context faithfully — a fine-tune), not prompt or retriever
   tuning. The Qwen ceiling proves the prompts are sound; the gap is grounding.

Corpus coverage remains a *limitation* (the corpus was not expanded this
cycle — v0.3.0 is a pure re-embed), but it is no longer the headline.

---

## State of the artifacts (verified 2026-06-25)

| Artifact | Version | Status |
|---|---|---|
| **Deployed app** (`mamai`) | **v0.4.0+4** | Gemma 4 E4B (int4, 3.66 GB) + **G1 prompt**, **EmbeddingGemma-300M** retriever, **English-only** (Swahili removed). top-3, 4096 ctx. Pre-deployment (no users this cycle). Live web demo + YouTube. |
| **RAG bundle** (`mamai-medical-guidelines`) | **v0.3.0** (2026-06-18) | **Pure re-embed** of v0.2.0 with EmbeddingGemma — *same 63,650 chunks / 87 sources, byte-identical corpus*. ~260 MB SQLite. No corpus expansion. |
| **mamabench** (HF) | **v0.2.1** (2026-05-21) | Released. 25,949 rows + 6,853-triple judge-calibration side-file. Frozen since May 21. Safety track still deferred to v0.3 (not built). |
| **mamaretrieval** (HF) | **v0.2.0** (2026-05-24) | Released with 6 retrievers (230,964 Tier-3 labels). **EmbeddingGemma added as 7th retriever internally** (commit 2026-06-25, matched run, 6 originals reproduce exactly) — **not yet HF-released**. |
| **3×3 end-to-end matrix** (`mamai-eval`) | config-v0.2.0/v0.3.0 | **Complete** (2026-06-19→22). {Gemma 4, Gemma 3n, Qwen-397B} × {baseline, G1, G1+G2}, two tracks. 31 dangerous cases hand-adjudicated. |
| **Faithfulness** (`mamai-eval`) | 2026-06-22 | **Re-run** with two-pass Lynx-70B→GPT-5 over 2,989 oracle answers × the matrix. Gemma 4 2.6–3.6%, Gemma 3n 6.3–6.7%, Qwen 2.5–3.7%. Supersedes the old 0.3% blinded-calibration framing. |
| **Judge validation** | Phase A 2026-06-08 | gpt-oss-120b retained (5-judge bake-off on 6,853 physician triples). |
| **Latency** (`mamai`) | latency_report_v2 (2026-05-17) | Snapdragon 8 Elite sweep; FP16 ~5,000-token cliff → 4096 cap; k=3 chosen by 60 s CPU budget. Battery/thermal/multi-device pending. |

---

## What changed since the 2026-06-10 reconciliation (read before editing scaffolds)

The committed scaffolds + the §2 draft are now stale in load-bearing ways:

- Deployed embedder **Gecko → EmbeddingGemma-300M**; bundle **v0.2.0 → v0.3.0**.
- Deployed prompt **baseline → G1**; **Swahili removed** (so §2's EN/SW dual
  prompt is wrong — it's English-only).
- Retriever is **no longer the weakest link** — it's largely solved.
- Corpus was **not expanded** — "corpus coverage is the blocker" is demoted to
  a limitation.
- Model matrix is **not unrun** — the **full 3×3 is complete and is the
  centerpiece** (decided 2026-06-25). The "descope to Gemma-only" decision is
  obsolete.
- Faithfulness headline **0.3% → 2.6–3.6%** (categorized, full-population) and
  is now **comparative** (Gemma 4 ≈ frontier; Gemma 3n outlier).
- The old "RAG hurts MCQ" framing is demoted; the real end-to-end story is
  **deflection (fixed by G1)** + **RAG doesn't convert on the small generator**.
- `mamai-mamabench-docs/` is **frozen at 2026-06-08** and still carries the
  old narrative — not a usable skeleton anymore.

---

## Paper 1 — System & Evaluation (top-down, follows the webpage)

Presentation order leads with the deployed-system result, then decomposes —
the methodology is bottom-up (build retriever → generator → end-to-end) but
the *telling* is top-down (end-to-end headline → retrieval → faithfulness →
latency), matching the webpage.

1. **Introduction / Motivation** — Zanzibar nurse-midwife context, maternal/
   neonatal mortality, on-device constraint (no connectivity, data cost),
   on-device privacy. Honest framing: thoroughly-evaluated research prototype,
   pre-deployment. Contributions: the deployed system; the bottom-up
   evaluation; the 3×3 model×prompt finding; the faithfulness result; the
   latency characterization incl. the FP16 cliff.
2. **System Design / Architecture** — Flutter ↔ Kotlin ↔ RagPipeline; Gemma 4
   E4B via LiteRT-LM 0.11.0 (int4, 3.66 GB, 4096 ctx, CPU-default/GPU-fallback,
   speculative decoding off); **EmbeddingGemma-300M** (768-dim, seq256,
   mixed-precision, the doc/query prompts) + SQLite; pre-computed embeddings,
   chunk-header/CID contract; top-3; **the G1 system prompt** and its seven
   levers; English-only; lock-file-pinned distribution (bundle v0.3.0).
   *Rewrite needed: §2 currently describes Gecko + EN/SW.*
3. **Evaluation Methodology** — bottom-up framework + why; **judge validation**
   (Phase A: 5 judges × 6,853 physician triples → gpt-oss-120b, the
   rubber-stamp-detector argument; the conservative-bias disclosure);
   device↔cluster calibration (Δ +2.7 pp, κ 0.558, interchangeable); the two
   benchmarks (cite Paper 2).
4. **End-to-End Results — the deployed system (CENTERPIECE)** — the full **3×3
   matrix** {Gemma 4, Gemma 3n, Qwen-397B} × {baseline, G1, G1+G2} on Kenya
   (n=312) + HealthBench-oss (n=1,209):
   - The deflection-fix story (Gemma 4: deflection 32.7%→3.2%, recall
     0.139→0.279 via G1).
   - The safety/usefulness tradeoff (Gemma 3n more useful, 4→11→15 dangerous;
     Gemma 4 0→1→0). **31 dangerous cases hand-adjudicated** — show the
     clinical error taxonomy (1000× oxytocin overdose, neonatal ceftriaxone,
     etc.); Gemma 4's single flag adjudicated to a judge error.
   - The Qwen-397B ceiling (G1+G2 pure upside: recall 0.553, harm 4.2%, 0
     dangerous) → prompts are sound; the gap is grounding.
   - Metrics: key-fact recall, deflection, potentially-harmful %, dangerous
     count, weighted_met (with the positive-credit vs penalty decomposition,
     and the nested-subset caveat for oss/consensus/hard).
   - The MCQ ±RAG negative control (−1.8 pp; off-domain corpus) as an aside —
     explains why the deployment-relevant signal is the open-ended tracks.
5. **Retrieval Results** — the **7-retriever scoreboard** (voyage, octen,
   EmbeddingGemma[deployed], lateon, Gecko, bm25, medcpt) at top-3, lenient/
   strict + weighted; EmbeddingGemma 3rd, +30.7 pp over Gecko. Then the
   **matched end-to-end bake-off** (no-RAG vs Gecko vs EmbeddingGemma): better
   retrieval P@3 (0.270→0.396) but flat answer recall (0.125→0.126), RAG
   net-neutral-to-negative — the pivot to "the generator is the constraint."
   Reranker tested & rejected; no thresholdable abstention score exists.
   Tier-3 pool-recall as the ranking-gap-vs-retrieval-gap diagnostic.
6. **Generator Faithfulness (oracle isolation)** — oracle = mamaretrieval
   score≥5, top-3, n=2,989. Two-pass judge: **Lynx-70B detector → GPT-5
   verifier** (the journey: MiniCheck rejected, Qwen circularity rejected,
   Lynx chosen; GPT-5 as the categorizing second pass). Categorized
   true-hallucination across the matrix: Gemma 4 2.6–3.6%, Gemma 3n 6.3–6.7%,
   Qwen 2.5–3.7%. The honest §4a dissection of the 53.9% calibration artifact
   (G1+G2 long-answer × narrow-oracle interaction). Finding: Gemma 4 ≈
   frontier; small size isn't the problem; grounding (a fine-tune) is the lever.
7. **On-Device Latency** — Snapdragon 8 Elite (OnePlus OPD2413), 54 runs/config.
   Deployed (Gemma 4, GPU, k=3): TTFT ~1 s, ~16 s gen, ~19 s total; CPU ~43 s;
   E2B tier ~14 s. The **k=3 choice** (CPU crosses the 60 s budget by k=5; GPU
   ~flat in k). The **FP16-GPU ~5,000-token cliff** → 4096 cap (own subsection;
   FP32 fixes it at ~25% TTFT cost). EmbeddingGemma retrieval faster than Gecko.
   [pending] battery, sustained thermal, MediaTek device.
8. **Discussion** — the inverted arc (retriever solved → generator can't use
   context → safety/usefulness tradeoff → G1 wins usefulness back → grounding
   is the open problem). RAG-doesn't-convert hypotheses. Local-vs-global
   guideline divergence. Why a deferring assistant is safe but limited.
9. **Limitations** — pre-deployment (no users, funding lag); not fully
   clinician-verified; LLM judges not human gold standard; **English-only**
   (Swahili is a real gap); RAG doesn't yet pay off on the small generator
   (the central open problem); latency on one flagship device; corpus coverage;
   contamination caveat (MedMCQA/MedQA).
10. **Related Work** — on-device LLMs, medical RAG, hallucination detection
    (Lynx, MiniCheck), LLM-as-judge/calibration, global-health AI.

### Out of scope for Paper 1
- mamabench / mamaretrieval construction (→ Paper 2).
- Producer-pipeline minutiae (→ corpus repo README).

---

## Paper 2 — Benchmarks

1. **Introduction** — gap analysis (existing medical benchmarks under-
   represent OBGYN/neonatal/Sub-Saharan/midwifery); the two benchmarks and
   what each is for; cite Paper 1 as the motivating consumer.
2. **Corpus** — shared context: bundle (63,650 chunks, 87 sources; tier
   system; structure-first chunking, breadcrumbs, SHA-256 CIDs; per-doc
   checksums). Note the v0.2.0→v0.3.0 re-embed (Gecko→EmbeddingGemma) is a
   producer-side change; the benchmark labels are corpus-text-pinned, so they
   carry across (chunk text is byte-identical).
3. **mamabench — construction** — 25,949 rows (MCQ 23,241 / open-ended 369 /
   rubric 2,339); 7 sources; schema 0.4; OBGYN classifier (Qwen3.6-27B, prompt
   v8, 5 categories); AfriMed-QA cleanup; the 6,853-triple judge-calibration
   side-file; manifests (0 errors); HF release flow.
4. **mamabench — validation** — cross-classifier agreement 98.12% (vs
   Qwen-397B); Kenya parity 86.8% (vs Gemini); 7 non-convergent prompts
   (net-zero); per-source yields.
5. **mamaretrieval — construction** — funnel 63,650 → 4,540 → 3,185 queries
   (Qwen3.6-27B filter); the **v2 graded rubric** `score = d1×(d2+d3+d4) ∈
   [0..6]` (D1 topic / D2 clinical content / D3 actionable / D4 density); the
   **tiered evaluation** (Tier 1 pilot 100×6 / Tier 2 full 3,185×6 top-3 /
   Tier 3 top-20 = 230,964 labels); judge Qwen3.5-397B (prompt hash pinned);
   research grounding; reproducibility infra.
6. **mamaretrieval — validation** — invariant checks (0 violations); score
   distribution; **judge calibration vs Claude Opus 4.7** (95% @≥3, 85% @≥5);
   spot-check; **pool-completeness** story (the v1 ~0.49-recall finding → Tier 3
   top-20 pooling); Tier-3 pool-recall (Gecko's gap is retrieval + ranking,
   concentrated on actionable chunks).
7. **Retriever scoreboard** — the **7-retriever** table (now incl.
   EmbeddingGemma, added in a matched run with the 6 originals reproducing
   exactly — the no-drift evidence). Framed as: the benchmark separates
   retrievers ordinally across ~35 pp HR / ~53 pp P. (Production endorsement
   is Paper 1's job.)
8. **Limitations** — LLM-written queries flatter dense retrievers (lead with
   ranking, not absolute scores); per_chunk-only queries (synthesis/
   adversarial unimplemented); single-judge bias; no hand-review layer at
   scale; corpus-version coupling; EmbeddingGemma not yet in the HF release.
9. **Access** — HF datasets (mamabench v0.2.1, mamaretrieval v0.2.0 [+ planned
   EmbeddingGemma refresh]); GitHub repos; license notes (AfriMed-QA
   CC-BY-NC-SA 4.0).

### Out of scope for Paper 2
- Model scores on the benchmarks (→ Paper 1).
- System architecture / latency / deployment.

---

## Format, source, distribution

- **arXiv tech reports**, **direct LaTeX** (`acmart`, `acmsmall`, `nonacm`,
  LuaLaTeX, `pdf_mode=4`). `review` (line numbers) dropped for final.
- Author block: **EPFL only** (decided 2026-06-25). (Webpage lists the D-tree
  International placement; the papers use EPFL.)
- Surfaces: arXiv PDF (citation/archival) + arXiv auto-HTML; GitHub `.tex`
  (AI-readable source); **the renyi.ch webpage is the concise HTML version**
  (already live) — add Scholar `citation_*` meta tags pointing at the arXiv
  IDs once posted.

---

## Open issues (gating items, 2026-06-25)

Hard deadline: **2026-06-30** (internship end). ~3 working days left.

1. **Re-grounding pass (next action).** Rewrite §2 (EmbeddingGemma / G1 /
   English-only / v0.3.0) and reorder Paper 1 to the top-down structure
   above; re-point the retrieval/faithfulness/end-to-end scaffolds to the
   3×3 matrix and the new numbers. Update the benchmarks-paper retriever
   section to 7 retrievers.
2. **Numbers to pull at draft time** from `mamai-eval` report HTMLs (the
   webpage rounds): the matrix cells, faithfulness table, retrieval bake-off,
   dangerous-case taxonomy. The webpage and eval reports differ by ≤1 pp on a
   few harm-rate cells — use the eval reports as the source of record.
3. **Faithfulness final framing** — the 2.6–3.6% categorized rates are final
   and full-population; keep the §4a artifact dissection. The old 0.3% number
   should not appear except as historical context if at all.
4. **Real-retrieval faithfulness probe** — still the experiment that would
   fire the fine-tuning gate; [pending], feeds Paper 1 §6/§8 as future work.
5. **mamaretrieval HF refresh** with EmbeddingGemma (optional before
   submission); the internal scoreboard is ready.
6. **Safety track** (mamabench v0.3) — not built; future work in both papers.
7. **Per-paper contribution statements**; report PDF license (CC-BY 4.0).

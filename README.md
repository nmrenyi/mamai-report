# MAM-AI Tech Report

LaTeX source for two arXiv tech reports documenting the MAM-AI project — an on-device medical retrieval-augmented generation system for nurses and midwives in Zanzibar.

## Papers

- **[`system-paper/`](system-paper/)** ([arXiv:2606.29580](https://arxiv.org/abs/2606.29580)) — *MAM-AI: An On-Device Medical Retrieval-Augmented Generation System for Nurses and Midwives in Zanzibar.* The deployed system, the bottom-up evaluation methodology, and headline results across retrieval, faithfulness, end-to-end accuracy, and on-device latency.
- **[`benchmarks-paper/`](benchmarks-paper/)** ([arXiv:2606.29467](https://arxiv.org/abs/2606.29467)) — *mamabench and mamaretrieval: Benchmarks for Evaluating Medical Retrieval-Augmented Generation in Maternal, Neonatal, and Reproductive Health.* The two benchmark artifacts used to evaluate the system above, with construction methodology and validation results.

Both papers are written in ACM journal style (`acmart` class, `acmsmall` variant, `nonacm` mode) and posted on arXiv. No specific venue is pursued.

## How to cite

The author's name is in Chinese order — family name **Ren**, given name **Yi**. The double braces around `{{Ren Yi}}` keep the full name as one unit so author–year styles render "[Ren Yi 2026]" and do not reorder it to "Yi Ren" or abbreviate it to the bare family name.

```bibtex
@misc{ren2026mamai,
  author        = {{Ren Yi}},
  title         = {{MAM-AI}: An On-Device Medical Retrieval-Augmented Generation System for Nurses and Midwives in Zanzibar},
  year          = {2026},
  eprint        = {2606.29580},
  archivePrefix = {arXiv},
  primaryClass  = {cs.CL}
}

@misc{ren2026mamabench,
  author        = {{Ren Yi}},
  title         = {{mamabench} and {mamaretrieval}: Benchmarks for Evaluating Medical Retrieval-Augmented Generation in Maternal, Neonatal, and Reproductive Health},
  year          = {2026},
  eprint        = {2606.29467},
  archivePrefix = {arXiv},
  primaryClass  = {cs.CL}
}
```

## Design

See [`paper_design.md`](paper_design.md) for:

- the two-paper split rationale (why not one monolithic report, not three separate reports);
- the result-placement principle (deployed-system results in the system paper; benchmark-validation results in the benchmarks paper);
- section-level outlines for each paper;
- open issues and outstanding evaluation runs that gate certain sections.

## Project context

The MAM-AI system, the producer pipeline, and the benchmark construction tooling live in sibling repositories:

- [`nmrenyi/mamai`](https://github.com/nmrenyi/mamai) — the Android app and on-device RAG pipeline.
- [`nmrenyi/mamai-medical-guidelines`](https://github.com/nmrenyi/mamai-medical-guidelines) — the corpus producer pipeline (PDF → marker → chunk → embed → bundle).
- [`nmrenyi/mamabench`](https://github.com/nmrenyi/mamabench) — QA benchmark construction tooling. Dataset on HuggingFace at [`nmrenyi/mamabench`](https://huggingface.co/datasets/nmrenyi/mamabench).
- [`nmrenyi/mamaretrieval`](https://github.com/nmrenyi/mamaretrieval) — retrieval benchmark construction tooling.

This report repo describes what those repos produced; the source repos are not required to build the papers.

## Build

Each paper is a self-contained LaTeX project.

```bash
cd system-paper          # or benchmarks-paper
latexmk -pdf main.tex    # build
latexmk -c main.tex      # clean intermediate artifacts
```

Requires a TeX Live (or other) distribution that includes the `acmart` class. Tested on TeX Live 2025.

## Status

Both papers are complete and posted on arXiv (June 2026): the system paper at [arXiv:2606.29580](https://arxiv.org/abs/2606.29580) and the benchmarks paper at [arXiv:2606.29467](https://arxiv.org/abs/2606.29467). Each cites the other as a companion paper.

# MAM-AI System and Evaluation — Tech Report

LaTeX source for the MAM-AI tech report:
*An On-Device Medical Retrieval-Augmented Generation System for Nurses and Midwives in Zanzibar.*

- **Distribution:** arXiv (no specific venue target).
- **Format:** ACM journal style (`acmart`, `acmsmall`, `nonacm`).
- **Companion paper:** the benchmarks paper (mamabench + mamaretrieval) — see [`../benchmarks-paper/`](../benchmarks-paper/).
- **Design rationale and scope boundary** between this paper and the companion are documented in [`../paper_design.md`](../paper_design.md).

## Build

Requires TeX Live (or another distribution) with the `acmart` class.

```bash
latexmk -pdf main.tex      # build
latexmk -c main.tex        # clean intermediates
```

## Structure

```
.
├── main.tex            # document class, front matter, section inputs
├── references.bib      # bibliography
├── sections/           # one .tex per section
└── figures/            # placeholders, filled from external eval runs
```

## Status

Outline-only at present. Sections will be drafted as evaluation results are produced. Outstanding eval runs that gate certain sections are tracked in `../paper_design.md` (Open issues).

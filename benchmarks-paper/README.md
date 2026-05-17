# mamabench & mamaretrieval — Benchmarks Paper

LaTeX source for the benchmarks paper:
*mamabench and mamaretrieval: Benchmarks for Evaluating Medical Retrieval-Augmented Generation in Maternal, Neonatal, and Reproductive Health.*

- **Distribution:** arXiv (no specific venue target).
- **Format:** ACM journal style (`acmart`, `acmsmall`, `nonacm`).
- **Companion paper:** the MAM-AI system & evaluation report — see [`../system-paper/`](../system-paper/).
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
└── figures/            # placeholders
```

## Status

Outline-only at present. The benchmarks are largely built (mamabench v0.2 released; mamaretrieval Phase 2b complete; Phase 3 completeness audit pending). Drafting begins once the Phase 3 results land — see `../paper_design.md` (Open issues).

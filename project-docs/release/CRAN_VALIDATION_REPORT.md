# CRAN Validation Report

## Current Release Branch

- Branch: `codex/cran-gate-reconciliation`
- Base: `origin/main`
- Integrated:
  - PR #550 branch `origin/feat/name-matching-mvp`
  - Release-prep commit `a3954f8`
  - CRAN gate reconciliation through commit `e4a78da`

## Validation Matrix

| Check | Status | Evidence |
|---|---|---|
| Metadata cleanup | Complete locally | `DESCRIPTION` set to `0.1.0`; `pryr` removed; PR #550 imports retained where used |
| Release docs | Complete locally | `NEWS.md`, `cran/cran-comments.md`, and release docs added/updated |
| Privacy wording | Complete locally | Active CRAN-facing docs reworded to privacy-supporting / FERPA-oriented language; no legal compliance guarantee claimed |
| Issue #153 privacy validation | Approved locally | Real-world, institutionally authorized validation rendered on commit `e4a78da`: 4 outputs, no `comments` column, 0 blocking identifier scan hits, 0 metadata identifier scan hits, clean tarball check; approval limited to privacy-safe CSV export surface |
| Issue #154 adoption guidance | Complete locally | `vignettes/ferpa-ethics.Rmd` provides institutional adoption guidance with privacy-supporting caveats |
| Tests | Pass locally | `devtools::test()`: 2,501 pass, 0 fail, 67 warnings, 6 skips |
| Coverage | Pass locally | Overall 83.82%; strategic exported API 92.34% |
| Lint | Non-blocking debt remains | `lintr::lint_package()`: 52 existing style/object-usage findings |
| R CMD check | Pass locally | 0 errors, 0 warnings, 0 notes |
| Build/tarball inspection | Pass locally | `R CMD build .` succeeded; tarball has 267 files and no local release docs, project-only docs, private transcript data, `.Rcheck`, `.DS_Store`, backup files, generated outputs, or excluded extdata paths |
| Benchmarks | Complete locally | Transcript and synthetic name-matching benchmarks recorded below |
| CI | Pass on release PR | PR #557 passes Ubuntu, Windows, and macOS R-CMD-check; coverage; lint; and build validation |

## Local Benchmark Results

Run on macOS Tahoe 26.4.1, R 4.5.3, with two iterations unless noted.

| Benchmark | Median Runtime | Memory |
|---|---:|---:|
| Small VTT parse | 35.3 ms | 8.2 MB |
| Engagement summary | 47.8 ms | 1.3 MB |
| Exact name matching, 100 speakers | 12.0 ms | 1.7 MB |
| Exact name matching, 1,000 speakers | 127.7 ms | 8.8 MB |
| Exact name matching, 5,000 speakers | 629.8 ms | 196.8 MB |

The 5,000-speaker name-matching benchmark is sub-second locally. Memory should
be watched in CI and future benchmark runs, but this result does not yet justify
speculative optimization before CRAN.

## Notes

- Overall coverage will be reported separately from the strategic exported API
  gate.
- Issue #153 is approved for the CRAN privacy gate based on the rendered local
  validation report. The approval does not classify raw transcripts, rosters,
  in-memory metric objects, or explicitly raw comment exports as de-identified.
- Release PR #557 was green at the time of the earlier release-prep report.
  Recheck CI after pushing this reconciliation branch.

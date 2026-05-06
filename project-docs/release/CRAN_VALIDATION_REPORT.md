# CRAN Validation Report

## Current Release Branch

- Branch: `codex/cran-submission-0.1.0`
- Base: `origin/main`
- Integrated:
  - PR #550 branch `origin/feat/name-matching-mvp`
  - Release-prep commit `a3954f8`

## Validation Matrix

| Check | Status | Evidence |
|---|---|---|
| Metadata cleanup | Complete locally | `DESCRIPTION` set to `0.1.0`; `pryr` removed; PR #550 imports retained where used |
| Release docs | Complete locally | `NEWS.md`, `cran/cran-comments.md`, and release docs added/updated |
| Privacy wording | Complete locally | Active CRAN-facing docs reworded to privacy-supporting / FERPA-oriented language |
| Tests | Pass locally | `devtools::test()`: 2,395 pass, 0 fail, 71 warnings, 6 skips |
| Coverage | Pass locally | Overall 83.30%; strategic exported API 92.31% |
| Lint | Non-blocking debt remains | `lintr::lint_package()`: 54 existing style/object-usage findings |
| R CMD check | Pass locally | 0 errors, 0 warnings, 1 note (`unable to verify current time`) |
| Build/tarball inspection | Pass locally | `R CMD build .` succeeded; no local release docs, `.codex`, disabled vignettes, perf artifacts, `.github`, `docs/`, `.Rcheck`, or generated test output patterns found |
| Benchmarks | Complete locally | Transcript and synthetic name-matching benchmarks recorded below |
| CI | Pending | Release PR must run R-CMD-check, coverage, lint, and build validation |

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
- CRAN submission should wait until the release PR is green and reviewed.

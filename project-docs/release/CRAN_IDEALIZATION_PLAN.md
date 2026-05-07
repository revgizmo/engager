# CRAN Idealization Plan for `engager`

## Release Defaults

- Target CRAN version: `0.1.0`.
- Release branch: `codex/cran-submission-0.1.0`.
- Package submitted as `engager`, not legacy `zoomstudentengagement`.
- Include the PR #550 exact name-matching MVP before CRAN.
- Gate strategic exported API coverage at `>= 90%`; report overall coverage
  separately.
- Use privacy-supporting and FERPA-oriented language, not legal compliance
  guarantees.

## Implementation Scope

- Start from current `origin/main`.
- Integrate release-prep commit `a3954f8`.
- Merge/rebase PR #550 (`feat/name-matching-mvp`) and keep its public APIs:
  `detect_unmatched_names()`, `match_names_workflow()`, and
  `write_unresolved()`.
- Preserve current transcript processing APIs and add only CRAN-facing cleanup
  needed for release readiness.
- Remove stale or local-only artifacts from the CRAN release surface.
- Disable the scheduled roadmap workflow until it targets this repository and
  no longer creates unrelated main-branch failures.

## Benchmark Targets

| Area | Target Before CRAN |
|---|---:|
| Local tests | 0 failures; warnings reviewed and documented |
| Local R CMD check | 0 errors, 0 warnings, no release-blocking notes |
| Coverage | Strategic exported API coverage >=90%; overall coverage reported honestly |
| Runtime regression | No >20% regression versus refreshed transcript baseline |
| Name matching | Benchmarks at 100, 1k, and 5k synthetic speakers |
| Repo cleanliness | Clean status except intentional release changes |

## Validation Plan

Run and document:

- `devtools::test()`
- `covr::package_coverage()`
- `lintr::lint_package()`
- `devtools::check(args = c("--no-manual", "--as-cran"), error_on = "never")`
- `R CMD build .`
- Tarball inspection for stray docs, real data, local artifacts, `.DS_Store`,
  `.Rcheck`, generated test outputs, and ad hoc files.
- Performance benchmarks from `perf/scripts/performance-test.R`, including the
  new name-matching sizes.

## Optimization Policy

Do not optimize speculatively. Establish fresh benchmarks after PR #550
integration first. Optimize only if the transcript pipeline regresses by more
than 20%, exact name matching shows clear quadratic pain at 5k speakers, or CI
runtime becomes materially worse.

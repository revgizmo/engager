# CRAN Validation Report

Generated: 2026-07-10

## Decision

**GO pending remediation PR merge, hosted CI/review, and maintainer signoff.**

The package-side release gates pass. CRAN upload, public tag replacement, issue
#4 updates, and final release publication remain separately authorized owner
actions.

## Release Candidate

- Branch: `codex/cran-release-surface-remediation`
- Base: `origin/main` at `1eae39368c3d99ccfdead34cc306fb6f81c6690c`
- Package-source commit: `1b89b7fd63044b3b7c09c67927fb28cd1bc46f6c`
- Version: `0.1.0`
- Tarball: `/private/tmp/engager-release-1b89b7f/engager_0.1.0.tar.gz`
- SHA-256: `f7759c980f09ff4d152f60f19fe8110222d752061dd5df9834751582ec362a03`
- UAT evidence: `/private/tmp/engager-release-1b89b7f/uat/UAT_EVIDENCE.md`

## Validation Matrix

| Check | Result | Evidence |
|---|---|---|
| Live ownership | Pass | One worktree; no open PRs or `CRAN-blocker` issues before branch publication |
| Full tests | Pass | 0 failures; 67 expected warnings; 6 documented skips |
| R CMD check | Pass | `--no-manual --as-cran`: 0 errors, 0 warnings, 0 notes |
| Source build | Pass | Built from package-source commit in `/private/tmp` |
| Installed-package UAT | Pass | Isolated install; 3 sessions/34 transcript rows; beginner workflow; exact matching; privacy/report exports; 4 vignettes |
| Onboarding/API contract | Pass | 24 progressive functions and 33 printed function calls checked against installed exports; data-format recovery path included |
| Raw identifier scan | Pass | No bundled raw course identifier hits in checked CSV/report artifacts |
| Tarball hygiene | Pass | 270 entries; no excluded local/project/UAT/private-data paths matched |
| Privacy wording | Pass | Active shipped docs use technical masking/review language and preserve institutional responsibility |
| Independent diff review | Pass | Final review returned GO with no actionable findings |
| CRAN publication check | Not published | `engager` absent from the CRAN package index snapshot downloaded 2026-07-10 09:16 PDT |

## Known Non-Blocking Evidence

- The UAT privacy screen reports `passed = FALSE` because the in-memory metrics
  contain identifier-like column names `name` and `name_raw`. This is expected
  technical-screen behavior; the exported-artifact scan found no raw synthetic
  identifier values.
- One CRAN-check run could not verify current time and emitted that single
  environment note. An unchanged immediate rerun completed at 0/0/0.
- `lintr::lint_package()` reports 52 existing style/object-usage findings under
  the repository configuration. This is pre-existing cleanup debt, not a CRAN
  check failure or a scope justification for pre-submission refactoring.
- Win-builder and R-hub remain optional follow-ups by release-owner decision.
- The public `v0.1.0` tag still points to stale commit `525ea206...` and contains
  outdated compliance wording. It was not modified. Deletion/recreation requires
  separate explicit approval and the replacement tag should be created only for
  the accepted release source.

## Remaining Gates

1. Push the remediation branch, open the scoped PR, and require hosted checks
   and review to pass.
2. Merge the remediation PR and rebuild the final upload tarball from merged
   `main`.
3. Obtain separate approval to remove the stale public `v0.1.0` tag before
   submission; recreate it only after CRAN acceptance.
4. Maintainer reviews the upload packet and manually submits the tarball.
5. Keep issue #4 open through CRAN review and acceptance.

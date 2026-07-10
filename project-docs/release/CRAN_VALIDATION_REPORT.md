# CRAN Validation Report

Generated: 2026-07-10

## Decision

**GO pending feature-surface hardening PR merge, hosted CI/review, and maintainer signoff.**

The package-side release gates pass. CRAN upload, public tag replacement, issue
#4 updates, and final release publication remain separately authorized owner
actions.

## Release Candidate

- Branch: `codex/cran-feature-surface-hardening`
- Base: `origin/main` at `0fe64066e372cdc7a5648625f423b116c26105d4`
- Package-source commit: `0cedc6e0762841d23d3154b61848be474cb8fb5f`
- Version: `0.1.0`
- Tarball: `/private/tmp/engager-feature-hardening-0cedc6e/engager_0.1.0.tar.gz`
- SHA-256: `881581794ee525dfdf4ef157c7089546c5917748c5690c6d68f483f8d10dcd6b`
- UAT evidence: `/private/tmp/engager-feature-hardening-0cedc6e/uat/UAT_EVIDENCE.md`

## Validation Matrix

| Check | Result | Evidence |
|---|---|---|
| Live ownership | Pass | One worktree; no open PRs or `CRAN-blocker` issues before branch publication |
| Full tests | Pass | 0 failures; 67 expected warnings; 5 documented skips; no supported feature is concealed by a skip |
| R CMD check | Pass | `--no-manual --as-cran`: 0 errors, 0 warnings, 0 notes |
| Source build | Pass | Built from package-source commit in `/private/tmp` |
| Installed-package UAT | Pass | Isolated install; 3 sessions/34 transcript rows; beginner workflow; exact matching; bounded identifier transformations; privacy/report exports; 4 vignettes |
| Onboarding/API contract | Pass | Exact 35-function allowlist; 22 progressive functions and 31 printed function calls checked against installed exports |
| Identifier transformation | Pass | Aggregate mode rejected; explicit hash salt required; repeated values map consistently; portable non-serialized SHA-256 used; missing/blank identifiers preserved; recognized raw identifiers absent |
| Raw identifier scan | Pass | No bundled raw course identifier hits in checked CSV/report artifacts |
| Tarball hygiene | Pass | 270 entries; no excluded local/project/UAT/private-data paths matched |
| Privacy wording | Pass | Active shipped docs use technical masking/review language and preserve institutional responsibility |
| Independent diff review | Pending | Required on the feature-surface hardening PR |
| CRAN publication check | Not published | `engager` absent from the CRAN package index snapshot downloaded 2026-07-10 09:16 PDT |

## Known Non-Blocking Evidence

- The UAT privacy screen reports `passed = FALSE` because the in-memory metrics
  contain identifier-like column names `name` and `name_raw`. This is expected
  technical-screen behavior; the exported-artifact scan found no raw synthetic
  identifier values.
- The canonical local CRAN gate completed at 0/0/0. A supplemental incoming
  remote probe reported only the expected `New submission` informational note.
- `lintr::lint_package()` reports 52 existing style/object-usage findings under
  the repository configuration. This is pre-existing cleanup debt, not a CRAN
  check failure or a scope justification for pre-submission refactoring.
- Win-builder and R-hub remain optional follow-ups by release-owner decision.
- The public `v0.1.0` tag still points to stale commit `525ea206...` and contains
  outdated compliance wording. It was not modified. Deletion/recreation requires
  separate explicit approval and the replacement tag should be created only for
  the accepted release source.

## Remaining Gates

1. Push the feature-surface hardening branch, open the scoped PR, and require hosted checks
   and review to pass.
2. Merge the feature-surface hardening PR and rebuild the final upload tarball from merged
   `main`.
3. Obtain separate approval to remove the stale public `v0.1.0` tag before
   submission; recreate it only after CRAN acceptance.
4. Maintainer reviews the upload packet and manually submits the tarball.
5. Keep issue #4 open through CRAN review and acceptance.

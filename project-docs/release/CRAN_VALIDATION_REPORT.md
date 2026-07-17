# CRAN Validation Report

Generated: 2026-07-30

## Decision

**PUBLISHED — acceptance verification passes; final release closeout pending.**

CRAN published `engager` 0.1.0 on 2026-07-30. The public package identity,
source archive, accepted source commit, and installed workflow are reconciled.
Wait for the 48-hour CRAN check matrix before requesting the separately
authorized tag, GitHub release, and issue #4 closure.

## Public CRAN Evidence

- Package page: <https://cran.r-project.org/package=engager>
- Published source:
  <https://cran.r-project.org/src/contrib/engager_0.1.0.tar.gz>
- Publication date: 2026-07-30
- Published SHA-256:
  `0051326ad8e0d648969a56b7d374ba9bb4560ffe0f380e201ec6d07ac860468b`
- Submitted SHA-256:
  `21e6ecddeed86dad177708d7b7f3bf1df79059f769dedc0e0439e995e2fa5e74`
- Archive difference: CRAN-normalized `DESCRIPTION` metadata plus generated
  `MD5`; no R code, documentation, test, vignette, fixture, or other package
  content difference.
- Published-tarball installed UAT: PASS on R 4.5.3,
  `aarch64-apple-darwin20`.

## Final Remediation Artifact

- Source commit: `6214c0316d39154140bdba064266119007bff41a`
- Version: `0.1.0`
- Tarball:
  `/Users/piper/Downloads/engager-cran-0.1.0-remediation-6214c03/engager_0.1.0.tar.gz`
- SHA-256: `21e6ecddeed86dad177708d7b7f3bf1df79059f769dedc0e0439e995e2fa5e74`
- Tarball entries: 270
- Installed UAT evidence:
  `/private/tmp/engager-cran-main-6214c03/uat/UAT_EVIDENCE.md`

## Validation Matrix

| Check | Result | Evidence |
|---|---|---|
| Package scope | Pass | Version 0.1.0 and exact 35-function export allowlist preserved |
| Full local tests | Pass | 0 failures; 68 expected warnings exercised by warning-path tests; 5 documented local skips |
| Local R CMD check | Pass | `--no-manual --as-cran`: 0 errors, 0 warnings, 2 environment-only notes for unavailable network checks and unverifiable local time |
| Source build | Pass | Built from exact merged `main` source commit |
| Installed-package UAT | Pass | Isolated installation using bundled synthetic fixtures; beginner and advanced workflows, name matching, identifier transformation, exports, plots, and installed vignettes passed |
| Default write safety | Pass | Beginner and batch workflows are in-memory by default; public and internal writes require explicit destinations |
| Documentation contract | Pass | All exports document return values and formal arguments; internal functions have no examples; examples are runnable without `\dontrun{}` or commented executable code |
| Windows R-devel | Pass | R-devel r90283: 0 errors, 0 warnings, 1 expected incoming-feasibility note; installation, examples, 2,573 test expectations, vignettes, and PDF/HTML manuals passed |
| Tarball hygiene | Pass | No Git metadata, project-only release documents, development scripts, nested archives, `.Rcheck` directories, local libraries, generated UAT output, or private transcript/roster paths |
| Privacy boundary | Pass | Synthetic fixtures only; default exports omit transcript text and transform recognized structured identifiers; no telemetry or automatic external transfer |

## Expected Non-Blocking Evidence

- R-devel win-builder reported one incoming-feasibility note: `New submission`
  plus `reviewable` as a possible misspelling. `reviewable` is intentional and
  the earlier reviewer-reported `WebVTT` flag is absent.
- Windows tests reported 64 expected warnings and 27 documented
  CRAN/platform/source-only skips, with 2,573 passes and 0 failures. These did
  not become package-check warnings.
- Negative review probes found incomplete `NA`/blank error normalization for
  some explicitly selected write paths. This is P2 error-contract debt under
  issue #438, not a 0.1.0 blocker: default workflows remain read-only and no
  implicit write path was restored.
- The win-builder service is public and does not guarantee confidentiality;
  the submitted artifact contains bundled synthetic fixtures only.

## Remaining Gates

1. Refresh the CRAN check matrix on or after 2026-08-01 10:20 PDT and inspect
   every reported platform; the initial six results are all `OK`.
2. Record the final publication/check/UAT evidence in issue #4 without closing
   it.
3. Obtain separate approval for the annotated `v0.1.0` tag at exact source
   commit `6214c0316d39154140bdba064266119007bff41a`.
4. Obtain separate approval for the GitHub release, then for issue #4 closure.
5. Forward-port the CRAN documentation/write-safety remediation to `develop`
   before rebuilding the 0.1.1 candidate.

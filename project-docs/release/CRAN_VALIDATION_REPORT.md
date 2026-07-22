# CRAN Validation Report

Generated: 2026-07-22

## Decision

**GO for maintainer-controlled manual CRAN resubmission after evidence review.**

The documentation and write-safety remediation requested by CRAN passes the
package-side release gates. Issue #4 updates, CRAN resubmission, acceptance
closeout, tagging, and release publication remain separately authorized owner
actions.

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

1. Review and merge the evidence-only PR; it must not change any file included
   in the frozen tarball.
2. Under separate approval, post the final remediation disposition to issue #4.
3. The maintainer manually resubmits the exact SHA-verified tarball to CRAN and
   confirms the submission email.
4. Preserve any reviewer wording and address only requested failures in a
   bounded remediation branch.
5. Keep issue #4 open and do not tag or publish a GitHub release until CRAN
   acceptance and separate approval.

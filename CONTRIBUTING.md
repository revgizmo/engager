# Contributing to `engager`

This document is the repository's development and merge policy. Product scope
and release sequencing live in [project-docs/ROADMAP.md](project-docs/ROADMAP.md)
and [project-docs/release/V0_1_1_RELEASE_PLAN.md](project-docs/release/V0_1_1_RELEASE_PLAN.md).

## Product and data boundaries

- Use synthetic fixtures only. Never commit or process real or private course
  data in repository validation.
- Describe masking, hashing, pseudonymization, and disclosure review as
  technical privacy-supporting controls. Do not claim anonymity, legal
  compliance, or institutional approval.
- Public APIs are added only after their behavior, errors, schemas,
  documentation, tests, and installed-package workflow are stable.

## Branches and worktrees

- `main` is the stable release and CRAN-remediation line. During review of
  0.1.0, its package contents remain frozen except for a bounded CRAN request.
- `develop` is the integration line for 0.1.1 and later work. Create each
  tranche from current `origin/develop` in a dedicated worktree and target its
  pull request back to `develop`.
- CRAN remediation branches from current `main` as
  `codex/cran-<failure-slug>`. Forward-port applicable fixes in a separate pull
  request to `develop`; never merge unfinished development into remediation.
- Use `codex/<bounded-slug>` branch names. Scan open issues, pull requests,
  branches, and worktrees before taking ownership.
- Do not merge `develop` into `main` until the release plan's final gates pass.

## Change classes and authorization

Classify a change by its highest-risk effect:

### Routine

Bounded implementation, tests, or documentation targeting `develop` that does
not change a public API, privacy or output contract, result schema, repository
ruleset, release artifact, or external system.

Routine changes may merge after required checks pass and review threads are
resolved. GitHub's formal approval count is not a substitute for these
objective gates.

### Governed

Public API, privacy behavior or claims, output/result schemas, repository
rulesets, CRAN remediation, package-content changes targeting `main`, and
`develop`-to-`main` promotion.

Governed changes require explicit maintainer authorization recorded in the
task, issue, or pull request. Automated reviews are evidence: actionable
findings must be fixed or explicitly declined with a reason, but bot comments
do not grant authorization.

### Release or external mutation

CRAN uploads, tags, GitHub releases, destructive branch cleanup, and closing
the CRAN ledger are separate release actions. They require explicit approval;
the maintainer performs CRAN uploads manually.

Read-only tasks must say: "Read-only; do not edit files; do not mutate GitHub."

## Pull requests

- Keep one bounded concern per pull request and link its issue or release
  tranche when applicable.
- Explain user/package impact, privacy or schema impact, validation evidence,
  and rollback.
- Resolve every review thread. Fix actionable automated-review findings or
  record why they do not apply.
- Prefer squash merge to preserve linear history.
- Do not use admin bypass as routine workflow. A pull-request-only bypass is
  reserved for a documented, explicitly authorized exception.

## Validation

Run the canonical non-mutating validator from a clean-enough worktree:

```sh
Rscript scripts/pre-pr-validation.R
```

It runs `git diff --check`, the test suite, and `R CMD check --as-cran` in a
temporary directory, then verifies that tracked and untracked state did not
change. It does not generate or rewrite source files.

For R or roxygen changes, run `devtools::document()` intentionally, inspect the
result, and commit `NAMESPACE` and `man/` updates. CI regenerates documentation
and fails if those tracked outputs drift.

Required hosted gates are:

- strict `R-CMD-check` on Linux, Windows, and macOS;
- `Coverage`, including exact namespace agreement with
  `project-docs/release/supported-exports.txt` and at least 85% statement
  coverage across that complete supported surface.

The 85% floor is the truthful all-export baseline. Raise it only with added
tests and evidence; do not substitute a smaller handpicked API list to report a
higher percentage.

Lint is advisory while the existing baseline is cleaned. Review its reported
findings and avoid adding obvious debt, but do not describe the advisory report
as a passing lint gate.

## CI-degraded exceptions

An override is appropriate only for a genuine runner, billing, or service
failure rather than a package failure. Record the hosted limitation, run the
closest equivalent local checks, attach exact evidence, and obtain explicit
maintainer authorization for governed changes. Never normalize a content
failure into an infrastructure exception.

## Release discipline

- Build and validate the exact source tarball that will be submitted.
- Use bundled synthetic fixtures and temporary output directories for
  installed-package UAT.
- Record the candidate commit, SHA-256, R/platform, commands, warnings, skips,
  and disposition.
- Any package-content change invalidates the candidate and requires a rebuild,
  package check, privacy scan, and installed-package UAT.

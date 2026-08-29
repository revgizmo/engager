# `engager` 0.1.1 Release Plan

Status: approved planning baseline; `engager` 0.1.0 was published on CRAN on
2026-07-30. The validated 0.1.1 QA source is on protected `develop`, but
fresh-user QA remains pending and the refreshed artifact is not the final CRAN
candidate. Merging 0.1.1 package content to `main` remains governed by the T6
release gates and is blocked until the 0.1.0 acceptance closeout is complete.

Last release-state reconciliation: 2026-08-29 against the public CRAN package,
stable `main` at `185f2a8cdf1c27f99dda94f94024fb67221c36e8`, `develop` at
`23d0474072d3d5188749f20450c3363e9bb31036`, and the accepted package-source
commit `6214c0316d39154140bdba064266119007bff41a`. The feature/backlog baseline
remains the 2026-07-15 review.

## Release thesis

Turn multiple session transcripts into reviewable course-attendance results
without exposing raw participant names by default.

Version 0.1.1 will graduate the retained internal attendance and reporting
prototypes into a supported installed-package workflow. It is not a general
reporting, longitudinal analytics, or anonymization release.

## Parallel development and 0.1.0 closeout

The submitted 0.1.0 artifact and 0.1.1 development are separate lanes:

- `main` remains the stable 0.1.0 release and evidence line. No 0.1.1 package
  content may be merged to it before closeout.
- `develop` is the integration target for 0.1.1. It currently records version
  `0.1.1`, 37 exports, and the validated QA source head
  `23d0474072d3d5188749f20450c3363e9bb31036`.
- Every 0.1.1 tranche branches from current `develop`, uses a dedicated
  worktree, and returns through a reviewed PR targeting `develop`.
- A CRAN reviewer request receives one bounded `codex/cran-<failure-slug>`
  branch from current `main`. Unfinished 0.1.1 work must never enter a 0.1.0
  remediation or resubmission.
- A remediation that also applies to 0.1.1 is carried forward through a
  separate `codex/v011-forward-port-<slug>` PR targeting `develop`; do not merge
  the development line into the CRAN remediation lane. The documentation and
  write-safety forward-port, including malformed explicit-path normalization,
  was completed through PR #591 at current `develop`.
- Merging `develop` into `main`, publishing a 0.1.1 tag or release, and any
  0.1.1 CRAN submission remain release actions governed by the T6 gates.

Public publication, archive reconciliation, and installed-package UAT are now
complete. Detailed evidence and release commands are maintained in
[V0_1_0_ACCEPTANCE_CLOSEOUT.md](V0_1_0_ACCEPTANCE_CLOSEOUT.md).

The remaining 0.1.0 closeout sequence is:

1. After separate approval, update issue #4 with the final 13/13 `OK` matrix
   observation. The earlier interim comment already records the CRAN URL,
   publication date, checksums, metadata-only archive differences, accepted
   source commit, and installed UAT result.
2. In a fresh clone, verify the accepted source commit from `main` before
   tagging:

   ```sh
   git fetch origin main
   git cat-file -e 6214c0316d39154140bdba064266119007bff41a^{commit}
   ```

   This commit is the exact source used to build the submitted remediation
   tarball. Later evidence-only commits change only files excluded from the
   package tarball; the release tag remains anchored to the accepted source.
3. Obtain explicit approval before creating the annotated `v0.1.0` tag at the
   accepted package-content commit, publishing the GitHub release, or closing
   issue #4.

## Current 0.1.1 QA checkpoint

- Source head: `23d0474072d3d5188749f20450c3363e9bb31036`
- Source tree: `cdccc447cf60e3abfadc224b6f3524464700ad04`
- Package version: `0.1.1`
- Supported exports: 37
- Refreshed QA tarball SHA-256:
  `7111570b4da2de4b4997995121151b53729ff2ce415e766b9446bcf37ac046b5`
- Disposition: QA-only artifact; fresh-user QA is pending, and this is not the
  final CRAN candidate.
- Issue #576 still records the earlier technical-GO candidate; no refreshed
  candidate comment has been posted.

The protected `develop` branch requires pull requests, resolved review threads,
strict `R-CMD-check` and `Coverage` passing, squash-only linear history, and
protection from force-push or deletion. Routine changes do not require a formal
GitHub approving review. Public API, privacy or schema contracts, repository
rulesets, CRAN remediation, and release promotion require explicit maintainer
authorization under [CONTRIBUTING.md](../../CONTRIBUTING.md). Automated review
is evidence, not authorization. The obsolete `development` branch is not reused
or deleted as part of this release tranche.

## Product boundary

### Included

- Deterministic session identity and ordering, including the unknown-timestamp
  behavior tracked by issue #560.
- Exact roster-based attendance across multiple transcripts.
- Explicit absent, unmatched, failed-session, cancelled-session, threshold,
  and denominator semantics.
- Course-level and session-level attendance summaries.
- Aggregate reports by default, with no raw participant identifiers or
  transcript text.
- Explicitly requested participant detail using a supported masking or
  pseudonymization mode.
- Public, documented versions of `analyze_multi_session_attendance()` and
  `generate_attendance_report()`.
- Installed-tarball UAT using bundled synthetic fixtures only.

### Excluded

- `anonymize_educational_data(method = "aggregate")` or any generic claim of
  anonymization.
- Fuzzy roster matching.
- Longitudinal student profiles or risk scoring.
- Chat, closed-caption, or non-WebVTT ingestion expansion.
- Excel-specific output or chart generation.
- Broad API trimming, performance refactors, CI modernization, warning cleanup,
  and backlog normalization.
- Real or private course data.

## Delivery tranches

Each tranche starts from current `origin/develop` in a dedicated worktree and
targets `develop`. CRAN remediation is the only package-content lane based on
`main` while 0.1.0 remains under review. Before delegation, scan live issues,
PRs, branches, and worktrees for duplicate ownership. Each implementation PR
runs targeted tests, the canonical non-mutating validator, intentional
documentation generation when applicable, and the hosted required checks.

T0 through T6 implementation and the later CRAN remediation forward-port are
complete on `develop`; the tranche definitions below remain the approved
historical delivery contract. The active product gate is fresh-user QA before
a final candidate is rebuilt and revalidated.

### T0 — Development kickoff

- Branch: `codex/v011-kickoff`
- Worktree: `engager-v011-kickoff`
- Deliverables: `0.1.0.9000`, a 0.1.1 NEWS section, and one v0.1.1 umbrella
  issue or milestone.
- Acceptance: metadata-only; no behavior change and no alteration of 0.1.0
  acceptance evidence.

### T1 — Attendance contract and golden fixtures

- Branch: `codex/v011-attendance-contract`
- Worktree: `engager-v011-attendance-contract`
- Decide and document the roster authority, unresolved-speaker handling,
  absence versus failed-session semantics, denominator rules, threshold
  inclusivity, duplicate-session behavior, cancelled-session behavior, result
  schema, and privacy metadata.
- Add synthetic contract tables for zero attendance, full attendance, an
  unmatched instructor or guest, duplicate inputs, failed inputs, blank
  identifiers, and threshold boundaries.
- Gate: maintainer approves the contract. Institutional policy must not be
  inferred from implementation convenience.

### T2 — Session identity and ordering

- Branch: `codex/v011-session-identity`
- Worktree: `engager-v011-session-identity`
- Resolve issue #560: retain a stable derived session key, use `NA` for unknown
  recording times, order known sessions chronologically, order unknown sessions
  deterministically, and issue one specific warning for unparseable times.
- Acceptance: Zoom and non-Zoom synthetic cases, mixed known/unknown times,
  duplicate keys, and repeated-run stability all pass.

### T3 — Exact roster-based attendance engine

- Branch: `codex/v011-attendance-engine`
- Worktree: `engager-v011-attendance-engine`
- Use the package's exact matching path and the approved attendance contract.
- Return a typed result, tentatively `engager_attendance`, with an explicit
  eligible-session count and structured problems table.
- Fail fast by default for missing or unreadable inputs. A permissive mode, if
  approved, must never silently remove failed sessions from a denominator.
- Keep unresolved speakers separate from roster attendance and do not mutate
  global privacy options.
- Acceptance: contract tests plus installed use of bundled synthetic VTT and
  roster fixtures.

### T4 — Privacy-safe reports

- Branch: `codex/v011-attendance-report`
- Worktree: `engager-v011-attendance-report`
- Default to aggregate course/session summaries.
- Require explicit opt-in and a supported transformation for participant-level
  detail.
- Propagate the analysis threshold instead of using a hard-coded report value.
- Isolate generated timestamps as metadata so report content remains
  deterministic under test.
- Use technical review and masking language, not `privacy_compliant`, FERPA
  compliance, or anonymity claims.
- Document small-cohort and contextual disclosure risks.
- Acceptance: generated artifacts contain no bundled raw identifiers or free
  transcript text by default; opt-in and missing/blank behavior are tested.

### T5 — Public API, documentation, and installed UAT

- Branch: `codex/v011-attendance-public-api`
- Worktree: `engager-v011-attendance-public-api`
- Export only `analyze_multi_session_attendance()` and
  `generate_attendance_report()` from this feature family.
- Update roxygen/Rd, `NAMESPACE`, `_pkgdown.yml`, README, NEWS, and one active
  vignette. Do not revive disabled legacy vignettes wholesale.
- Extend the installed-package UAT to cover the export allowlist, a three-session
  course, ordering, denominators, unresolved speakers, aggregate-default output,
  masked opt-in output, and raw-identifier absence.
- Acceptance: additive API; existing 0.1.0 exports and behavior remain compatible.

### T6 — Release candidate

- Branch: `codex/release-v0.1.1`
- Worktree: `engager-release-v011`
- Bump to `0.1.1`, finalize NEWS and `cran/cran-comments.md`, and make no
  unrelated changes.
- Build one release candidate from a clean committed head and record its commit,
  SHA-256, R/platform details, commands, warnings, skips, and UAT disposition.

## Release gates

A GO disposition requires:

- The approved attendance contract is implemented without unresolved semantic
  decisions.
- Default reports contain no raw participant identifiers or transcript text.
- The package makes no unsupported anonymity, legal, or institutional-compliance
  claim.
- Existing 0.1.0 exports remain compatible and only the two reviewed attendance
  functions are added.
- Full tests have zero failures; every remaining warning and skip is explained.
- `R CMD check --as-cran` has zero errors and warnings and only explained notes.
- Hosted Linux, Windows, and macOS `R-CMD-check` plus `Coverage` pass at the
  exact release head; generated documentation is drift-free and advisory lint
  findings are reviewed.
- The exact source tarball passes hygiene inspection and installed-package UAT.
- R-devel win-builder and a documented current secondary remote check complete.
- The maintainer approves the exact candidate checksum before manual upload.

Any package-content change invalidates the candidate and requires a new build,
check, privacy scan, and installed-package UAT. CRAN reviewer feedback receives
one bounded remediation branch. The `v0.1.1` tag and GitHub release wait for CRAN
publication and separate approval.

## Work that must stay separate

Backlog normalization, stale-branch cleanup, disabled-vignette cleanup, test
warning reduction, lint cleanup, CI modernization, performance work, and generic
aggregation design are valuable post-CRAN work. They must use separate control
or maintenance PRs and cannot expand the v0.1.1 feature PRs or release candidate.

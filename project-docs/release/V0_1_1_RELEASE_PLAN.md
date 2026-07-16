# `engager` 0.1.1 Release Plan

Status: approved planning baseline; execution is blocked until `engager` 0.1.0
is publicly available from CRAN.

Last reconciled: 2026-07-14 against `main` at
`50188a1ae17fa646dc5792b52992db7210192b85` and the live GitHub backlog.

## Release thesis

Turn multiple session transcripts into reviewable course-attendance results
without exposing raw participant names by default.

Version 0.1.1 will graduate the retained internal attendance and reporting
prototypes into a supported installed-package workflow. It is not a general
reporting, longitudinal analytics, or anonymization release.

## Entry gate: close version 0.1.0

Do not change package content until both a CRAN acceptance message and the
public CRAN package page exist.

After publication:

1. Download the published CRAN source tarball and calculate its SHA-256.
2. Compare it with the submitted replacement artifact SHA-256:
   `2a8087a2b315fac48de8fa8239465d7360152dacf0c725d803e5cdeb50ce6ae1`.
3. Install from CRAN in an isolated library and run the beginner smoke workflow.
4. Update issue #4 with the CRAN URL, publication date, published checksum,
   reviewer-remediation history, package-content commit
   `67918c4904c072e91f378f3bb3677d2ffdd35bda`, and main-line evidence commit
   `50188a1ae17fa646dc5792b52992db7210192b85`.
5. In a fresh clone, make the accepted package-content commit reachable through
   the preserved PR #572 pull ref, then verify the object before tagging:

   ```sh
   git fetch origin refs/pull/572/head:refs/remotes/origin/pr/572
   git cat-file -e 67918c4904c072e91f378f3bb3677d2ffdd35bda^{commit}
   ```

   PR #572's final head descends from this commit. The later squash commit
   changes only `cran/cran-comments.md`, which is excluded from the package
   tarball, but the release tag remains anchored to the exact accepted package
   content.
6. Obtain explicit approval before creating the annotated `v0.1.0` tag at the
   accepted package-content commit, publishing the GitHub release, or closing
   issue #4.
7. Open a separate kickoff PR that changes the development version to
   `0.1.0.9000` and adds an `engager 0.1.1` NEWS section. The development suffix
   identifies work toward 0.1.1; the accepted 0.1.0 source remains unchanged.

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

Each tranche starts from current `origin/main` in a dedicated worktree. Before
delegation, scan live issues, PRs, branches, and worktrees for duplicate
ownership. Each implementation PR runs targeted tests, full tests,
`devtools::document()`, `git diff --check`, and the hosted required checks.

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
- Hosted Linux, Windows, and macOS checks, coverage, lint, and documentation
  checks pass at the exact release head.
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

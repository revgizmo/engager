# `engager` Product Roadmap

Status: product and release planning source of truth.

Last reconciled: 2026-07-14 against `main` at
`50188a1ae17fa646dc5792b52992db7210192b85`, 35 current exports, the historical
pre-scope-reduction API, and 122 live open GitHub issues. The existing
`project-docs/backlog-normalization` snapshot contains 128 issues and must be
refreshed before it authorizes any live mutation.

This roadmap governs product direction. GitHub issues remain the execution
ledger; [release/V0_1_1_RELEASE_PLAN.md](release/V0_1_1_RELEASE_PLAN.md) governs
the next release.

## Product promise

`engager` helps instructors and researchers turn locally held WebVTT course
transcripts into reviewable participation evidence. It should make common
analysis easy, preserve uncertainty, minimize identifier exposure, and avoid
turning participation measurements into unsupported judgments about students.

## Roadmap principles

1. **Local and reviewable by default.** No telemetry or automatic external data
   transfer. Derived results retain enough provenance to be audited locally.
2. **Privacy-supporting, not compliance-certifying.** Masking, hashing,
   pseudonymization, aggregation, and review helpers are technical operations.
   They do not establish anonymity, FERPA compliance, or institutional approval.
3. **Exact before probabilistic.** Exact roster matching remains the supported
   default. Any future fuzzy assistance must be review-only, preserve ambiguity,
   and never silently assign identities.
4. **One coherent workflow per release.** A release should solve one user job
   end to end, including installed-package UAT, rather than expose a collection
   of partially related helpers.
5. **Public APIs are earned.** Internal helpers become exports only when their
   contract, error semantics, documentation, privacy behavior, and installed use
   are proven.
6. **Synthetic evidence only.** Tests and committed validation artifacts use
   bundled synthetic fixtures, never real or private course data.
7. **Accepted release lines stay immutable.** Post-0.1.0 package work uses a
   development version and targets 0.1.1 or later.

## Release sequence

### 0.1.0 — Focused transcript-analysis foundation

Status: submitted to CRAN; awaiting public acceptance at this reconciliation.

Supported product:

- WebVTT loading, processing, and consolidation.
- Speaker-level engagement metrics and plots.
- Privacy-supporting metric exports.
- Exact roster matching and unresolved-name review.
- Structured identifier masking, hashing with caller-provided salt, and
  pseudonymization.
- Beginner, composable, and batch transcript workflows.

Isolated 0.1.1 development may proceed on protected `develop` while CRAN review
continues. `main` remains the stable 0.1.0 release and evidence line. No 0.1.1
package content may merge to it until the 0.1.1 release is finalized under the
T6 gates, and any merge remains blocked until at least the 0.1.0 acceptance
reconciliation, tag, GitHub release, and issue #4 closeout described in the
0.1.1 release plan are approved. CRAN remediation branches from `main`;
applicable fixes are forward-ported to `develop` through separate reviewed PRs.

### 0.1.1 — Multi-session attendance and reviewable reports

Commitment: next feature release.

The complete scope, dependency-ordered tranches, gates, and mutation boundaries
are in [release/V0_1_1_RELEASE_PLAN.md](release/V0_1_1_RELEASE_PLAN.md).

Outcome: a user can analyze a synthetic or locally held course roster and
multiple session transcripts, understand failed/unmatched inputs, and create an
aggregate report that does not reveal raw participant names by default.

### 0.1.2 — Privacy-safe sharing and reliability

Candidate scope; confirm after 0.1.1 user feedback.

- Design a distinct aggregation API that accepts explicit grouping keys and
  permitted metrics and cannot carry row-level identifiers or free text.
- Define minimum-group and disclosure-review behavior without calling the output
  anonymous or compliant.
- Unify identifier transformations and provenance metadata around issue #341.
- Add privacy-sensitive operation audit records without logging identifiers,
  informed by issue #381.
- Standardize file-write errors and atomic output behavior, informed by issue
  #438.
- Publish stable result and output schemas with schema-version metadata.
- Add a machine-readable analysis manifest containing package version, input
  fingerprints rather than paths or names, parameters, warnings/problems, and
  output checksums.

Generic aggregate mode does not return merely because this version exists. It
returns only after its disclosure contract and adversarial privacy tests pass.

### 0.2.0 — Course-project workflows and broader inputs

Candidate scope; revalidate demand and dependencies after the 0.1.x releases.

- A supported course configuration object for roster, session, cancellation,
  threshold, and output settings.
- Strict input contracts and actionable unsupported-file guidance, aligned with
  issues #196 and #197.
- Deliberate support for additional Zoom artifacts such as closed captions or
  chat only after separate privacy and schema review, aligned with issue #97.
- Batch export built on the stable report schema, aligned with issue #441.
- Optional, dependency-light spreadsheet output only if user demand justifies
  it; issues #440 and #453 do not by themselves justify a core dependency.
- A project template or reproducible analysis scaffold if it adds value beyond
  the existing beginner workflow.
- Consolidated, progressive tutorials rather than wholesale restoration of
  disabled legacy vignettes, informed by issue #334.

### 0.3.0 and later — Scale, longitudinal questions, and ecosystem

Exploratory, not committed.

- Evidence-driven large-file improvements: chunked input, memory limits, and
  benchmark budgets only where measurements show a user-visible constraint.
- Longitudinal course-level trends with explicit missingness and cohort-change
  semantics.
- Participant-level longitudinal reporting only after an ethical-use review,
  a narrow purpose statement, strong default masking, and tests against ranking
  or risk-scoring misuse.
- Review-assisted fuzzy matching only as a separate, auditable suggestion layer.
- Reusable parser, privacy, or CI components may become separate packages only
  when maintenance and user demand justify the split.

## Historical feature disposition

The package once exposed as many as 85 functions. Immediately before the major
scope reduction at commit `e258ef5`, it exposed 74; the current package exposes
35. Most removed names were internal machinery, duplicate wrappers, development
tools, or APIs without stable semantics. Historical presence is evidence to
review a capability, not a reason to restore its old interface.

| Historical capability | Representative former or internal functions | Disposition | Target |
|---|---|---|---|
| Multi-session attendance | `analyze_multi_session_attendance()`, `make_student_roster_sessions()` | Redesign and graduate with explicit roster, denominator, failure, and privacy contracts | 0.1.1 |
| Attendance and student reports | `generate_attendance_report()`, `run_student_reports()` | Restore aggregate attendance reporting under the new API; permanently retire the old raw student-report interface | 0.1.1; longitudinal work no earlier than 0.3.0 |
| Generic aggregate transformation | Former `anonymize_educational_data(method = "aggregate")` | Redesign as a separate aggregation contract; never restore the row-preserving implementation | Candidate 0.1.2 |
| Course/session configuration | `create_analysis_config()`, `create_course_info()`, `create_session_mapping()`, `load_session_mapping()`, `load_cancelled_classes()` | Keep internal through 0.1.1; promote one coherent configuration object only if it simplifies the course workflow | Candidate 0.2.0 |
| Ideal-course batch processing | `process_ideal_course_batch()`, `compare_ideal_sessions()` | Preserve the synthetic scenarios as fixtures; implement user value through supported batch/course workflows, not the old API | Fixtures now; product behavior 0.1.1–0.2.0 |
| Ideal-course export and validation | `export_ideal_transcripts_csv()`, `export_ideal_transcripts_json()`, `export_ideal_transcripts_excel()`, `export_ideal_transcripts_summary()`, `calculate_content_similarity()`, `validate_ideal_content_quality()`, `validate_ideal_name_coverage()`, `validate_ideal_scenarios()`, `validate_ideal_timing_consistency()`, `validate_ideal_transcript_comprehensive()`, and `validate_ideal_transcript_structure()` | Keep validation as test infrastructure. Do not restore synthetic-data-specific public exports; general reporting owns output | Tests now; general exports 0.1.1–0.2.0 |
| One-call transcript processing | `load_and_process_zoom_transcript()`, proposed issue #198 orchestration | Superseded by `basic_transcript_analysis()`, `quick_analysis()`, and the composable workflow; reconcile issue rather than add another wrapper | Retire/reconcile |
| Specialized plotting wrappers | `plot_users_by_metric()`, `plot_users_masked_section_by_metric()` | Superseded by parameterized `plot_users()`; add capabilities to the canonical plot API only when needed | Retire old names |
| Legacy metric writers | `write_engagement_metrics()`, `write_transcripts_summary()`, `write_transcripts_session_summary()` | Superseded by `write_metrics()` and future report outputs. Retain lower-level writers internally only while used | Retire/internal |
| Name/lookup internals | `safe_name_matching_workflow()`, `match_names_with_privacy()`, `prompt_name_matching()`, `hash_name_consistently()`, `load_section_names_lookup()`, `make_clean_names_df()`, `make_names_to_clean_df()`, `merge_lookup_preserve()`, `read_lookup_safely()`, `write_lookup_transactional()` | Keep internal behind the exact public matching workflow; do not expose implementation fragments or interactive prompts | Internal |
| Session and summary internals | `join_transcripts_list()`, `load_transcript_files_list()`, `load_zoom_recorded_sessions_list()`, `make_transcripts_summary_df()`, `make_transcripts_session_summary_df()`, `make_students_only_transcripts_summary_df()` | Retain and harden as implementation details. Promote only stable result objects, not assembly helpers | Internal |
| Participant classification | `classify_participants()`, `ensure_instructor_rows()` | Fold only the necessary, explicit roles into the attendance contract; do not infer student status from names | 0.1.1 contract/internal |
| Privacy and ethics reports | `audit_ethical_usage()`, `create_ethical_use_report()`, `generate_ferpa_report()`, `validate_ethical_use()`, `validate_ferpa_compliance()`, `check_data_retention_policy()` | Preserve useful technical checks behind current review APIs; do not restore compliance-branded promises | 0.1.2 review, mostly internal |
| Privacy defaults and processing wrappers | `set_privacy_defaults()`, `mask_user_names_by_metric()`, `process_transcript_with_privacy()` | Avoid hidden global mutation and redundant workflow wrappers. Use explicit per-call configuration and canonical transformation/plot functions | 0.1.1–0.1.2 |
| Schema validation | `validate_schema()` | Replace ad hoc public validation with documented result/output schemas and internal validators | Candidate 0.1.2 |
| Analysis template generation | `make_new_analysis_template()` | Reassess as a reproducible course-project scaffold; do not restore an unmaintained R Markdown template | Candidate 0.2.0 |
| Function inventory and deprecation tooling | `get_deprecated_functions()`, `get_essential_functions()`, `get_internal_functions()`, `get_scope_reduction_summary()` | Repository governance tooling, not package functionality. Keep out of the public API | Retired from package |
| Coverage, diagnostics, CRAN, and benchmark helpers | `benchmark_ideal_transcripts()`, `diag_cat()`, `diag_message()`, and removed coverage, CRAN optimization, scope-reduction, and test-quality functions | Implement through tests, scripts, and CI; never expose as user-facing package APIs | Repository maintenance |
| Pipe export | `%>%` | Dependency plumbing, not a product feature. Prefer qualified or base-pipe examples | Do not restore |

Additional internal helpers such as `add_dead_air_rows()`,
`detect_duplicate_transcripts()`, `make_blank_cancelled_classes_df()`,
`make_blank_section_names_lookup_csv()`, `make_roster_small()`,
`make_sections_df()`, `make_semester_df()`, `make_metrics_lookup_df()`,
`conditionally_write_lookup()`, and
`write_section_names_lookup()` remain implementation details unless a future
user workflow demonstrates a stable public contract.

## Existing roadmap and backlog reconciliation

The live backlog mixes product ideas, already-implemented work, duplicate debt,
and old CRAN assumptions. Before issue mutation, refresh the normalization
control artifacts and review each proposed change.

### Product candidates to preserve and reframe

- #50: topic parsing — consider within the 0.2.0 input/session contract.
- #56: transcript-file identity and duplicate handling — reconcile against the
  current internal detector and 0.1.1 session identity work.
- #97: additional Zoom file types — 0.2.0, after privacy/schema review.
- #148 and #341: identifier coverage and transformation unification — 0.1.2
  privacy contract, not blanket anonymization.
- #196 and #197: strict input behavior and unsupported-file guidance — 0.2.0.
- #334: tutorial overhaul — deliver progressively with each supported workflow.
- #365: VTT edge fixtures — useful as a reliability tranche, with synthetic data.
- #381: privacy operation audit logging — 0.1.2, metadata only.
- #403: metric-existence guards — reliability work after duplicate review.
- #427–#429: ideal-course visualization/configuration follow-up — split fixtures
  from genuine product needs; do not revive the old ideal-course API wholesale.
- #437–#441 and #453: privacy, errors, scale, charts, and exports — route into the
  release horizons above rather than one broad enhancement batch.

### Likely duplicate, implemented, or stale premises to review

- #147, #302, #344, and #364 overlap on warning and output noise.
- #288 is substantially represented by the current hosted R CMD check matrix.
- #296 mixes completed hosted checks with remaining style/spelling/coverage work.
- #298 is substantially represented by current masking behavior.
- #469 assumes a historical export count and cannot govern the current API.
- #471 is performance infrastructure debt, not a CRAN or feature blocker.
- #395 can remain a coordination umbrella but should not own implementation.

Closure, supersession, duplicate marking, label deletion, and issue #4 closure
remain human-only. Comments require an approved manifest/PR; labels, milestones,
priority, status, and body changes require specific review.

## Capabilities newly added to the roadmap

These needs emerge from the current product contract and were not coherently
represented by the legacy public API:

1. **Versioned result schemas.** Attendance, matching, metrics, problems, and
   report outputs need documented columns, types, units, and schema versions.
2. **Analysis provenance manifest.** Record package version, parameter values,
   non-identifying input fingerprints, problems, and output checksums for local
   reproducibility without copying private source data.
3. **Structured partial-failure reporting.** Batch and course workflows must
   distinguish absent data, invalid data, failed processing, and true zeroes.
4. **Disclosure-oriented report tests.** Scan all generated artifacts for raw
   synthetic identifiers, free transcript text, small-cell risk markers, and
   misleading compliance language.
5. **API maturity policy.** Label new functions experimental until their
   installed workflow, error behavior, and schema are stable; add exports only
   at a release boundary.
6. **Release-to-CRAN smoke matrix.** After each CRAN publication, test a fresh
   installation and the advertised workflow before closing the release ledger.
7. **Documented cancellation and missingness semantics.** Treat cancelled,
   absent, unknown, unreadable, and unmatched states as distinct throughout
   analysis and reporting.

## Cross-cutting maintenance lane

Maintenance work runs beside, not inside, feature tranches:

- Refresh and review the 122-issue backlog snapshot in small mutation batches.
- Consolidate warning-cleanup ownership and reduce the 67 expected warning-path
  assertions without hiding real warnings.
- Review the five documented skips and remove skips that conceal supported
  behavior.
- Resolve current lint findings incrementally; do not use broad mechanical
  rewrites in release PRs.
- Remove disabled vignettes, historical artifacts, stale generated documents,
  and remote branches only after evidence and separate approval.
- Make CI, coverage, lint, pkgdown, and release workflows report their true
  scope and status.
- Benchmark before optimizing. Large-file work must be triggered by measured
  workload limits, not historical severity labels.

## Promotion rules

A candidate moves into a numbered release only when it has:

- one named user job and a bounded public contract;
- no duplicate implementation owner;
- synthetic fixtures and acceptance examples;
- explicit error, missingness, privacy, and output semantics;
- an installed-package UAT plan;
- documentation and migration implications;
- a maintainer-approved release boundary.

The next promotion decision occurs after 0.1.1 ships and fresh-user feedback is
reviewed. Until then, 0.1.2 and later scopes are directional, not promises.

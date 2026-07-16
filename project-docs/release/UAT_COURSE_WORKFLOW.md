# Course Workflow UAT for Pre-CRAN Release

## Purpose

This UAT validates that a real user can install the built `engager` source
tarball and run a realistic course workflow without relying on source-tree
paths, development libraries, or private course data.

The workflow uses only installed package resources discovered with
`system.file("extdata/test_transcripts", package = "engager")` and writes all
outputs to a temporary directory outside the repository.

This is a package-side release validation check. It does not submit to CRAN and
does not mutate GitHub issues, pull requests, labels, milestones, or releases.

## Scope

The UAT script installs a supplied source tarball into an isolated R library,
loads `engager` from that library, and exercises:

- Installed synthetic VTT transcript discovery.
- Installed synthetic roster discovery.
- Installed onboarding identity plus function-call checks across getting
  started, workflow, privacy, troubleshooting, task finder, smart
  recommendations, error recovery, and progressive guidance output.
- Exact namespace comparison against the supported export allowlist.
- VTT loading with `load_zoom_transcript()`.
- Transcript processing with `process_zoom_transcript()`.
- Multi-file and single-file summarization with
  `summarize_transcript_files()` and `summarize_transcript_metrics()`.
- The exported beginner workflow with `basic_transcript_analysis()`, including
  its plot and privacy-processed CSV output.
- Plot-label masking for `mask`, `privacy_standard`, and `privacy_strict`, plus
  explicit `none` behavior and vector privacy-level normalization.
- Exact name matching with `match_names_workflow()`.
- Unresolved-name review with `detect_unmatched_names()` and
  `write_unresolved()`.
- Privacy review with `review_privacy_risks()`.
- Privacy report generation with `generate_privacy_review_report()`.
- Identifier transformation checks confirming that unsafe aggregation is
  rejected, hash mode requires a caller-provided salt, and missing or blank
  identifiers are preserved.
- CSV export through `write_metrics()`.
- Multi-session attendance with `analyze_multi_session_attendance()`, including
  chronological ordering, roster/session denominators, and structured
  unmatched-speaker problems.
- Aggregate-default and explicitly masked attendance reports with
  `generate_attendance_report()`.
- Attendance-report scans for raw synthetic roster identifiers, transcript
  text, and source paths.
- Installed vignette discovery with:
  `vignette(package = "engager")`,
  `vignette("getting-started", package = "engager")`,
  `vignette("essential-functions", package = "engager")`,
  `vignette("plotting", package = "engager")`, and
  `vignette("privacy-ethics-review", package = "engager")`.

## Prerequisites

- R is installed and available to `Rscript`.
- Package dependencies needed by the tarball are already installed in the
  normal user or site libraries.
- The source tarball exists; replace `VERSION` below with the built package
  version.
- The command is run from the repository root.

## Command

Run the default UAT against the current release-candidate tarball:

```sh
REPO_ROOT="$(git rev-parse --show-toplevel)"
Rscript project-docs/release/run_uat_course_workflow.R \
  "$REPO_ROOT/engager_VERSION.tar.gz"
```

Optionally provide a persistent output directory:

```sh
REPO_ROOT="$(git rev-parse --show-toplevel)"
Rscript project-docs/release/run_uat_course_workflow.R \
  "$REPO_ROOT/engager_VERSION.tar.gz" \
  /tmp/engager-uat-course-workflow
```

## Expected Pass Criteria

The script should finish with `UAT PASS` and should report an output directory
and `UAT_EVIDENCE.md` file.

A passing run confirms:

- The tarball installs into an isolated library.
- `engager` is loaded from that isolated library.
- The installed package version matches the supplied tarball version.
- Bundled synthetic course transcripts and roster fixtures are discoverable.
- Installed onboarding uses the `engager` identity and progressive guidance
  names only exported functions.
- The installed namespace exactly matches the supported allowlist, including
  only the two approved attendance/reporting exports from this feature family.
- One or more installed VTT transcript files load and process successfully.
- The installed beginner workflow completes with non-empty metrics, a plot,
  and a non-empty CSV export.
- Course-level summary metrics contain non-empty plausible data.
- Exact name matching runs and links at least one transcript speaker to the
  synthetic roster.
- Multi-session attendance preserves chronological ordering, uses the approved
  denominators, and keeps unmatched speakers separate from roster attendance.
- Aggregate attendance output is the default; participant detail appears only
  after an explicit supported transformation.
- Aggregate and masked attendance reports contain no checked raw synthetic
  roster identifiers, transcript text, or source paths.
- Unresolved-name output is written without raw names by default.
- Privacy review and privacy report generation complete.
- Supported identifier transformations remove recognized raw identifiers,
  preserve missing values, reject unsafe aggregation, and require an explicit
  hash salt.
- Exported summary/report outputs do not contain obvious raw synthetic course
  identifiers checked by the script.
- Required vignettes are discoverable from the installed package.

## Expected Fail Criteria

Treat the UAT as failed if any of these occur:

- The tarball cannot be installed.
- The loaded package path is not inside the isolated UAT library.
- Installed fixtures are missing.
- Installed onboarding uses the former package identity or advertises
  non-exported functions.
- The namespace differs from the supported export allowlist.
- Transcript loading, processing, summarization, beginner workflow, name
  matching, attendance analysis, attendance reporting, privacy review, privacy
  report generation, or exports fail.
- Expected output files are missing or empty.
- Exported summary/report files contain obvious raw synthetic course identifiers
  where the UAT expects masked output.
- Identifier transformation accepts the withdrawn aggregation mode, accepts
  hash mode without a salt, or transforms missing identifiers into values.
- Required vignettes are not discoverable from the installed package.

## Known Non-Blocking Warnings

The privacy review helper is a technical screening tool. It may report
identifier-like column names such as `name` or `name_raw` even when exported
values are masked. That result should be recorded in the UAT evidence, but it
is not by itself a UAT failure when raw identifiers are absent from the exported
files.

The synthetic fixtures include unmatched non-roster speakers, such as the
instructor or guests. Unresolved-name output is expected as long as it is
written through the privacy-safe unresolved-name path.

## Release evidence

Before a CRAN submission, paste a concise summary into the active release
ledger using the canonical template in
`project-docs/release/UAT_RESULT_TEMPLATE.md`.

Include:

- Package version.
- Tarball path.
- R version and OS.
- Exact command run.
- Pass/fail result.
- Output directory and generated artifact list.
- Privacy review result, including whether the helper flagged identifier-like
  columns.
- Confirmation that exported summary/report outputs did not contain obvious
  raw synthetic course identifiers.
- Confirmation that the CRAN tarball stayed clean after `.Rbuildignore`
  inspection.
- Any blockers or follow-up issues recommended.

## Limits

This UAT uses bundled synthetic fixtures only. It does not validate real
institutional workflows, does not use real/private course data, and does not
determine or certify FERPA or other legal compliance. Institutions remain
responsible for policy review, authorization, access controls, disclosure
decisions, retention, and legal compliance.

## Result Template

Use `project-docs/release/UAT_RESULT_TEMPLATE.md` as the canonical result
template for release evidence.

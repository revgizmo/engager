# engager 0.1.1

* Added `analyze_multi_session_attendance()` for deterministic, exact
  roster-based attendance across multiple WebVTT sessions, with explicit
  cancellation, denominator, threshold, and unmatched-speaker semantics.
* Added `generate_attendance_report()` for deterministic aggregate Markdown
  reports by default. Participant detail requires an explicit masking, hashing,
  or pseudonymization method; raw participant detail is not available.
* Added installed synthetic attendance fixtures, public workflow guidance, and
  installed-tarball UAT for the complete three-session workflow.

# engager 0.1.0

## Initial CRAN Submission

* Renamed the package from `zoomstudentengagement` to `engager`.
* Added core transcript loading, processing, summarization, plotting, privacy
  masking, and metric writing workflows for Zoom/WebVTT transcripts.
* Added an exact name-matching MVP with privacy-safe unresolved-name export:
  `detect_unmatched_names()`, `match_names_workflow()`, and
  `write_unresolved()`.
* Added privacy review helpers and documentation with explicit
  institutional-review caveats.
* Limited the supported v0.1.0 identifier transformations to masking, hashing
  with an explicit caller-provided salt, and pseudonymization. Missing and blank
  identifiers remain missing or blank; unsafe aggregation is rejected.
* Kept multi-session attendance and attendance-report generation internal until
  their roster, threshold, and chart semantics receive installed-workflow UAT.
* Made CSV metric exports omit raw transcript/comment text by default; raw
  comments now require an explicit local-review export with privacy disabled.
* Added release validation targets for R CMD check, exported API coverage,
  lint, build, tarball inspection, and performance regression review.

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
* Made CSV metric exports omit raw transcript/comment text by default; raw
  comments now require an explicit local-review export with privacy disabled.
* Added release validation targets for R CMD check, exported API coverage,
  lint, build, tarball inspection, and performance regression review.

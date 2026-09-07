# Synthetic performance measurement contract

This repository infrastructure contract supports issue #471. It measures the
installed package without changing its public API or result schemas. It does
not detect regressions, establish new accepted thresholds, migrate baselines,
or authorize optimization or release actions.

## Workloads

Each scenario runs five times, each in a fresh `Rscript --vanilla` process.
Inputs are deterministic synthetic data created or copied into temporary
directories. Setup and cleanup do not write package outputs into the repository.

| Scenario | Operation and input | Assertions |
| --- | --- | --- |
| `analyze_files_1` | `analyze_transcripts(write = FALSE)`, one copy of bundled `ideal_course_session1.vtt` | 1 processed file, 8 output rows |
| `analyze_files_50` | Same operation, 50 copies | 50 processed files, 400 output rows |
| `analyze_files_500` | Same operation, 500 copies | 500 processed files, 4,000 output rows |
| `process_vtt_1mib` | `process_zoom_transcript()`, consolidation and dead air disabled; one generated VTT targeting 1,048,576 bytes | One processed file; one output row per generated cue |
| `consolidate_rows_10000` | `consolidate_transcript()` with default pause; 10,000 in-memory rows, consecutive pairs share a speaker | 5,000 output rows |
| `summarize_rows_10000` | `summarize_transcript_metrics(transcript_df = ..., comments_format = "count")`; same 10,000 rows | 10 output rows; total segments 10,000, duration 10,000 seconds, words 40,000 |

The bundled fixture has 1,018 bytes, 13 cues, and eight speakers. The original
file-count workloads and coarse elapsed budgets remain: 10, 120, and 1,200
seconds respectively. Every repetition must meet its scenario's budget; a
median cannot hide a failure. `BUDGET_1`, `BUDGET_50`, and `BUDGET_500` retain
positive numeric overrides, recorded in the result. These are historical CI
ceilings, not newly accepted user performance requirements. The three added
scenarios have no new performance thresholds.

The generated VTT uses ASCII with LF line endings, eight fixed synthetic
speakers, one-second contiguous cues, and a fixed four-word comment template.
Generation stops after the first cue that reaches the target: overshoot is less
than one generated cue. Results report the actual byte count, cue count, final
cue size, and SHA-256 of the exact file bytes. File-count cases record total
bytes/cues and the SHA-256 of the common source file copied to every input.
The in-memory cases use ten fixed synthetic speakers with contiguous one-second
rows and four words per row. They have no input file: file count, file bytes,
cues and target bytes are zero; SHA-256 is `none`. Rows describe the 10,000-row
input; for VTT inputs, rows are zero and cues describe the input instead.

## Measurement semantics

`elapsed_seconds` is operation wall time from R's elapsed process clock. It
excludes dependency loading, fixture construction, and result assertions.

`max_rss_kib` is the **absolute maximum resident set size** reported by GNU
Linux `/usr/bin/time -v`, in KiB. It includes the R interpreter, dependencies,
input construction, operation, assertions, and worker JSON serialization. It
is not package-only allocation, allocation totals, a GC delta, or an increase
from a process baseline. Fresh processes avoid inherited R heap history but
do not isolate filesystem caches or host contention. Measurements depend on
R/dependency versions and runner hardware. The runner label and architecture
identify the hosted configuration; they are not a hardware equivalence claim.

The reference environment is GitHub-hosted Ubuntu with R release. The controller
requires Linux and GNU time, validates its exit status and positive RSS, and
fails rather than substituting macOS/BSD time or an allocation estimate. The
120-minute step timeout accommodates five repetitions of the existing coarse
budgets; it is not a new performance threshold.

## Artifact schema and failure behavior

One `measurements.json` is uploaded only after the whole run succeeds. Schema
`1.0.0` contains:

- `metadata`: exact checked-out commit, installed package version, R version,
  OS, architecture, runner configuration, Actions run ID/attempt, UTC start time.
- `semantics`: fixed timing, RSS, process-isolation and non-regression labels.
- `observations`: exactly six scenarios times repetitions 1–5, with every
  observation retained. Each has its scenario/repetition identity, synthetic
  workload parameters, elapsed seconds, absolute peak RSS, processed-file and
  output-row counts, expected counts, successful assertion flag and status.
- `summaries`: scenario, observation count, median/min/max for elapsed and RSS.
- `budgets_seconds`: the three effective historical file-count ceilings.
- `status`: `passed`; failed or partial runs do not publish a result artifact.

Strict validation rejects missing/extra/duplicate object keys, invalid
identities, missing/nonfinite measurements, nonpositive RSS, mismatched fixture
metadata, incomplete or duplicate repetitions, false assertions, altered
summaries, or exceeded budgets. JSON round-trip validation precedes publication.
Missing dependencies and failed subprocesses fail the run. Worker logs and GNU
time reports remain temporary and are never uploaded. The upload names one JSON
file explicitly; it does not glob a directory of fixtures or logs.

Artifacts carry numeric counts, hashes and constrained metadata, not transcript
or comment text, raw synthetic participant identifiers, filenames or absolute
paths. This is a benchmark artifact boundary, not a claim of anonymity, legal
compliance, or institutional approval. Arbitrary free-form metadata is rejected.

## Reproduction

From the repository root, install this checkout into an isolated temporary R
library using `R CMD INSTALL --library=<temporary-library> .`, and make that
library available to parent and child processes via `R_LIBS_USER`. Dependencies
must already be available or installed into that temporary library.

```sh
Rscript scripts/benchmarks/test_measurement_contract.R
Rscript scripts/benchmarks/measurement_contract.R run /tmp/measurements.json
Rscript scripts/benchmarks/measurement_contract.R validate /tmp/measurements.json
```

Choose a new output file; the controller refuses to overwrite an existing one.
Local runs use runner/run ID `local` unless explicitly supplied. A macOS smoke
can source `measurement_contract.R` and call `benchmark_observation(scenario,
1L)` for selected scenarios. Such a smoke checks workload behavior only and
cannot produce reference RSS evidence or a complete accepted artifact. Test
suite fabricated numbers exercise validation only and are never measurements.

The Benchmarks PR workflow checks out the exact PR head, installs that checkout,
runs contract tests and all 30 measurements, revalidates the result and uploads
only the validated JSON. Required package R-CMD-check and Coverage remain
separate gates. Successful measurements do not imply review approval, merge,
issue closure, release readiness, or acceptance of new budgets.

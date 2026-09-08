# Descriptive comparison contract

This repository tool compares two explicitly chosen measurement JSON artifacts
for issue #471. It does not choose, admit, replace, or update a baseline. Its
output is descriptive evidence, never a passed/no-regression verdict, a trusted
baseline decision, or acceptance of performance thresholds.

The [measurement contract](MEASUREMENT_CONTRACT.md) and its schema `1.0.0` remain
unchanged. Package code, public exports, package output schemas, dependencies,
workflows, old baseline files, and existing budgets are outside this tranche.

## Inputs and provenance

Supply exactly five positional arguments:

```sh
Rscript scripts/benchmarks/compare_measurements.R \
  BASELINE_JSON BASELINE_SHA256 CANDIDATE_JSON CANDIDATE_SHA256 OUTPUT_JSON
```

Both SHA-256 arguments must be explicit lowercase 64-digit hexadecimal strings
bound to the intended files. The tool reads each file into memory once, hashes
those exact raw bytes, and parses that same snapshot. Whitespace and line-ending
changes therefore change the checksum. A checksum establishes byte identity,
not authenticity of a claimed source or GitHub run. No network lookup occurs.

Run from the repository root, or use the comparator's absolute path from another
working directory. It locates its own repository helpers and restores the
caller's working directory; it cannot accidentally source a different checkout's
legacy benchmark controller.

The existing strict validator checks both full inputs, including all six
scenarios, all five repetition identities per scenario, workload parameters and
hashes, semantics, finite measurements, file/row assertions, and budget evidence.
The comparator independently recomputes summaries from observations and requires
exact numeric agreement, including changes below the existing validator's
floating-point tolerance. An invalid input emits no comparison file. Runtime
dependencies of the existing validator, including an installed package with the
contract's bundled synthetic fixture, must be available.

The output retains each input's raw-byte SHA-256, measurement schema version,
commit, package/R version, OS/architecture/runner label, run ID/attempt and UTC
timestamp. Commit, run and timestamp differences are provenance, not reasons to
reject compatibility. Identical commits from distinct runs may be compared;
source-tree equivalence is not inferred because it is not recorded in inputs.
The caller chooses orientation; no chronological ordering is required.

## Compatibility and identity

For two valid inputs, the following recorded evidence must agree exactly:

- Package version, R version, OS, architecture and runner label.
- Scenario/workload definitions and measurement semantics.
- All effective historical budget values. Each input must independently pass
  its recorded budgets; the comparator never substitutes the current shell's
  budget environment variables.

Different package versions are conservatively non-comparable in this tranche.
Changing this rule requires a separately documented comparison policy.

A self-comparison is not evidence from two runs. Equal raw hashes add
`identical_artifact`; equal hosted run ID and attempt add `same_run_identity`,
even if bytes or commit metadata differ. Reformatting the same artifact does not
make an independent run. Distinct attempts of the same hosted run may be compared.
An input with a `local` run ID or attempt adds `unverifiable_run_identity` because
schema 1.0.0 provides no unique local execution identity. It remains a valid
measurement artifact but cannot establish two distinct runs for this comparator.

Non-comparability reasons are fixed codes in deterministic order: artifact
identity, run identity, environment fields in package/R/OS/architecture/runner
order, semantics, budgets, then workloads in contract scenario order. Codes are
`environment_mismatch_<field>`, `semantics_mismatch`, `budget_mismatch`, and
`workload_mismatch_<scenario>` as applicable. Invalid schema-1.0.0 workloads or
semantics normally fail input validation before compatibility evaluation.

Matching visible fields permits **descriptive differences only**. Every report
lists the same unresolved evidence limitations: dependency versions, runner
image, hardware identity, and a standalone measurement-harness fingerprint are
unrecorded. The comparator cannot infer equivalent runtimes, calibrated noise,
causality, improvement, or a regression threshold from matching runner labels.
`regression_verdict` is always `not_assessed`; `trusted_baseline` is always false.

## Arithmetic and output

Comparison schema `1.0.0` is separate from measurement schema `1.0.0`. A completed
report contains `tool_status: completed`, `disposition: descriptive_only`, an
empty reasons array, fixed limitations, both provenance records and budgets,
and six scenario objects. Each scenario compares median, minimum and maximum
elapsed seconds and absolute whole-process peak RSS KiB, recomputed over five
observations per input.

Each statistic records:

- `baseline` and `candidate`: the recomputed values.
- `difference`: candidate minus baseline in the original units, retaining sign.
- `absolute_difference`: the magnitude of that difference.
- `ratio`: candidate divided by baseline when finite and baseline is nonzero.
- `ratio_status`: `defined`, `zero_baseline`, `both_zero`, or `nonfinite_ratio`.

An undefined ratio is JSON null, including zero divided by zero; it is never
silently replaced with 0, 1, infinity, or a regression verdict. Absolute
arithmetic remains available. Numbers are serialized with 17-digit precision
and verified by a JSON round trip. Reports contain no execution timestamp of
their own, so the same ordered input bytes produce deterministic output bytes.

A non-comparable report retains the validated provenance, budgets, limitations
and reason codes, sets `tool_status: not_comparable` and
`disposition: non_comparable`, and has an empty scenarios array. It emits no
numeric cross-run comparison. Invalid input produces no report at all.

Only validated metadata and generated numeric results/fixed codes are copied to
the JSON output. Input/output paths, basenames, raw synthetic identifiers,
transcript/comment text and arbitrary error messages are not copied. CLI errors
use bounded role/reason codes without echoing source data or filesystem paths.

The output must not exist. Publication writes a temporary sibling, validates
its JSON round trip, then uses a hard link to create the requested destination
without replacement. Existing files, directories and dangling symlinks are
preserved, including if a destination appears during publication. Filesystems
without hard-link support fail closed; there is no overwrite fallback. The
output directory must already exist. No source artifact or baseline is mutated.

## CLI exit codes and validation

| Exit | Meaning | Output |
| --- | --- | --- |
| 0 | Tool completed a descriptive comparison | Descriptive JSON; no regression acceptance |
| 2 | Invalid arguments, checksum, input, or unavailable runtime | No new report |
| 3 | Valid inputs are non-comparable | JSON with reasons and no comparison values |
| 4 | Output could not be created safely | Existing destination preserved |

The library function `compare_measurements()` returns the report after safe
publication; callers must inspect its disposition. The CLI maps that disposition
to the exit codes above. Tool success and performance acceptance are separate.

```sh
Rscript scripts/benchmarks/test_compare_measurements.R
Rscript scripts/pre-pr-validation.R
```

Focused tests fabricate synthetic validator fixtures in temporary directories;
these numbers are test inputs, not measured evidence or baseline candidates.
Coverage includes corrupted/duplicate/partial inputs, checksum/provenance binding,
environment/workload/budget drift, arithmetic and zero baselines, self-comparison,
output safety, deterministic JSON and actual CLI exits from a different cwd.
Genuine hosted artifacts may be used for a demonstration outside Git, with their
explicit checksums. No measured artifact or generated comparison is committed.
Workflow integration, additional metadata collection, threshold calibration,
baseline admission and regression enforcement remain separate work.

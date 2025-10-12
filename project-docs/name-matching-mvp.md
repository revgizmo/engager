# Name Matching MVP — Master Task Document

## Context
We are building a **privacy-first, exact name matching subsystem** for an R package destined for CRAN.  
Requirements: CRAN compliance, deterministic hashing, FERPA-safe defaults, and extension points for fuzzy matching later.  
This file defines all tasks (0–9). Each task must be executed **independently, one at a time**.  
Trigger by saying in Cursor:  
`Please complete Task X from @name-matching-mvp.md`

---

## Task 0: Pre-flight Check (Environment Sanity)
### Goal
Verify the R environment and baseline health before coding.

### Requirements
Run and capture the following commands:

```bash
# Environment details
R -q -e "sessionInfo(); stringi::stri_info()" > audits/env_check.txt 2>&1

# Build check
R CMD build . > audits/build_check.txt 2>&1

# Package check
R CMD check engager_*.tar.gz > audits/check_r_cmd_check.txt 2>&1

# Test suite
R -q -e "testthat::test_dir('tests/testthat', reporter = 'summary')" > audits/check_tests.txt 2>&1

# Documentation
R -q -e "pkgdown::build_site(preview=FALSE)" > audits/check_pkgdown.txt 2>&1
```

### Deliverables

* `audits/env_check.txt`
* `audits/build_check.txt`
* `audits/check_r_cmd_check.txt`
* `audits/check_tests.txt`
* `audits/check_pkgdown.txt`

### Abort Conditions

* Any command fails (non-zero exit, segfault, or >0 errors in check/tests).
* If failed, STOP and summarize in `audits/preflight-summary.md`.
* Do not continue to Task 1 until Task 0 is green.

---

## Task 1: Skeleton Loader (Green PR Guarantee)

### Goal

Implement the minimal `load_roster()` function with schema validation only.

### Requirements

* Input: tibble/data.frame with at least `preferred_name`.
* Output: same tibble, invisible.
* Abort if `preferred_name` missing, raise `engager_schema_error`.
* Add roxygen docs with @title, @param, @return, @export, examples (synthetic).
* Add tests for happy path and missing column.
* No hashing, no normalization, no aliases yet.
* Must pass `R CMD check` with 0 errors/warnings.

### Deliverables

* `R/load_roster.R`
* `tests/testthat/test-load_roster.R`
* `man/load_roster.Rd`

### Abort Conditions

* If `R CMD check` fails → STOP and summarize, do not continue.

---

## Task 2: Aliases + Derived Columns

### Goal

Expand `load_roster()` to support aliases and derived columns.

### Requirements

* Parse `aliases` string into `list<chr>` (default delimiter `;`, autodetect `,`/`|`).
* Add derived columns: `canonical_name`, `name_hash`, `alias_hashes`, `all_name_hashes` (values can be NA for now).
* Add schema validation: `preferred_name` required, `student_id` unique if present.
* Update docs with details.
* Add tests for alias parsing, derived columns creation.

### Deliverables

* Update `R/load_roster.R`
* Update `tests/testthat/test-load_roster.R`

---

## Task 3: Normalization Core

### Goal

Implement robust normalization for names.

### Requirements

* `normalize_name()` pipeline: NFKD → strip diacritics → casefold(full) → trim → collapse whitespace → NFC.
* Use `stringi` for ICU-backed ops.
* Add determinism tests for diacritics, Turkish İ/ı, German ß/SS.
* Add `engager_spec` attribute to outputs with normalization metadata.
* Update docs with description of normalization.

### Deliverables

* `R/name_matching_internal.R` (add normalize_name)
* `tests/testthat/test-normalization.R`

---

## Task 4: Hashing Core

### Goal

Implement secure deterministic hashing.

### Requirements

* `hash_canonical_name()` supporting SHA-256 and HMAC-SHA-256.
* Secrets precedence: function arg > `Sys.getenv("ENGAGER_NAME_HASH_KEY")` > option.
* Add audit metadata: algo, ICU version, spec_version.
* Determinism tests: with/without key, reproducibility.

### Deliverables

* `R/name_matching_internal.R` (add hashing)
* `tests/testthat/test-hashing.R`

---

## Task 5: Exact Matching Workflow

### Goal

Implement the main workflow and index.

### Requirements

* `build_roster_hash_index()` → map hash → student_id; detect collisions.
* `prepare_transcript_names()` → normalize & hash transcript speakers.
* `match_names_exact()` → assign ids or unresolved with reasons.
* `safe_name_matching_workflow()` → returns class `engager_match` with list: transcripts_with_ids, unresolved, audit.
* Typed errors: `engager_schema_error`, `engager_collision_error`.
* S3 `print()` shows summary counts, `summary()` redacted details.

### Deliverables

* `R/name_matching_workflow.R`
* `tests/testthat/test-exact-matching.R`
* `tests/testthat/test-collisions.R`

---

## Task 6: Privacy Guardrails

### Goal

Add safe unresolved reporting.

### Requirements

* `write_unresolved()` → hashed-only by default.
* Raw export requires both `include_raw=TRUE` AND `options(engager.allow_raw_name_exports=TRUE)`.
* Violations raise `engager_privacy_error`.
* Add snapshot redaction helper for tests.

### Deliverables

* `R/write_unresolved.R`
* `tests/testthat/test-privacy.R`

---

## Task 7: Docs & Vignettes

### Goal

Document the subsystem and provide examples.

### Requirements

* Roxygen docs complete for all public functions.
* Vignette `01-getting-started.Rmd` → load_roster → safe_name_matching_workflow → detect_unmatched_names.
* Vignette `02-essential-functions.Rmd` → list exported functions under “Name Matching.”
* New pkgdown page: Security & Privacy (with NIST + Unicode citations).
* All examples synthetic, quick to run.

### Deliverables

* `vignettes/01-getting-started.Rmd`
* `vignettes/02-essential-functions.Rmd`

---

## Task 8: CI Matrix & Snapshot Redaction

### Goal

Strengthen testing and CI.

### Requirements

* GitHub Actions matrix: Linux + macOS; R-release + R-devel.
* Add snapshot redaction helper.
* All checks must pass green.

### Deliverables

* `.github/workflows/R-CMD-check.yaml` updated
* `tests/testthat/helper-redaction.R`

---

## Task 9: Fuzzy Stub Only

### Goal

Add API scaffolding for fuzzy matching.

### Requirements

* `match_strategy` option accepted by workflows; default `"exact"`.
* `match_names_fuzzy()` stub that aborts with “Not implemented.”
* No behavior change otherwise.

### Deliverables

* `R/name_matching_internal.R` (stub)
* `tests/testthat/test-fuzzy-stub.R`


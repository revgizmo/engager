# Cursor Task: Privacy-First Exact Name Matching MVP (CRAN-ready)

## Context

We are building a **strict, privacy-first** name-matching subsystem for an R package destined for CRAN. MVP must implement **only exact matching on hashed, normalized names**. Architect clean **extension points** so fuzzy matching can be added later **without API breaks**. Prioritize **determinism, FERPA-friendly defaults, and CRAN compliance**.

Repo language: **R** (tidyverse + testthat + roxygen2).
Current vignette flow: Setup → Load Transcripts → Load Roster → **Clean Names (Name Matching)** → Analyze → Validate (FERPA) → Report.

## Objectives

1. Implement exact matching on **hashed, normalized names** with a hardened, CRAN-friendly UX.
2. Add minimal scaffolding for future fuzzy matching **without changing public APIs later**.
3. Enforce a roster schema that uses a **single list column for aliases** (avoid row blow-ups).
4. Ensure **no raw names** appear in logs or outputs by default; unresolved reporting is opt-in and hashed-only by default.
5. Add tests, docs, and vignettes; keep pkgdown/CI green across Linux + macOS.

## Non-Goals (for now)

* No fuzzy matching implementation. Only stubs and options placeholders.
* No expansion of matching beyond exact hash equivalence.

---

## Rules of Engagement (Cursor)

* Create a **feature branch**: `feat/name-matching-mvp`.
* Open **GitHub Issues** (labeled `name-matching`, `privacy`, `mvp`) with acceptance criteria & checklists below. Cross-link PR(s) to issues.
* Make **small, reviewable PRs** grouped by topic (schema+loader, normalization+hashing, match workflow, tests, docs).
* Keep changes **idempotent**; rerunning scripts should be safe.
* Do **not** print or snapshot **raw names** unless a test explicitly opts in.
* Use **synthetic data** in docs and tests.
* If something is ambiguous, add a checkbox in the issue and proceed with the conservative default.

---

## High-Level Deliverables

* **Public API (exported)**

  * `load_roster(path, ..., schema="engager_v1", key=NULL, delimiter=";", include_formal_as_alias=FALSE)`
  * `detect_unmatched_names(transcripts_df, roster_df, options=list())`
  * `safe_name_matching_workflow(transcripts_df, roster_df, options=list())`
  * `write_unresolved(unresolved_tbl, path, include_raw=FALSE, overwrite=FALSE)` (opt-in writer)
* **Internal helpers (not exported)**

  * `normalize_name()`, `hash_canonical_name()`, `build_roster_hash_index()`,
    `prepare_transcript_names()`, `match_names_exact()`, `build_match_audit()`,
    `aliases_long()` (internal), `match_names_fuzzy()` **stub** (abort with clear message)
* **Files**

  * `R/load_roster.R`
  * `R/name_matching_workflow.R` (workflow + detect)
  * `R/name_matching_internal.R` (helpers + fuzzy stub)
  * `R/write_unresolved.R`
  * Vignettes: `vignettes/01-getting-started.Rmd`, `vignettes/02-essential-functions.Rmd`
  * Tests (see matrix below)

---

## Security & Privacy Enhancements to Implement

* **Secrets precedence**: `key` function arg > `Sys.getenv("ENGAGER_NAME_HASH_KEY")` > `getOption("engager.name_hash_key", NULL)`.
* **Spec stamping**: attach attributes like `engager_spec` to returns (`schema`, `norm_chain`, `hash_algo`, `hmac_used`, `icu_version`, `spec_version="1"`).
* **S3 class**: return from `safe_name_matching_workflow()` as class `engager_match` with `print()` (counts only, redacted) and `summary()` (still redacted by default).
* **Typed errors** with `rlang::abort(class=...)`: `engager_schema_error`, `engager_collision_error`, `engager_privacy_error`.
* **Output knobs**: `options$include_name_hash = FALSE` by default; omit `name_hash` from `transcripts_with_ids` unless explicitly requested.
* **Normalization**: ICU-backed via `stringi`; Unicode pipeline: NFKD → strip combining marks → full casefold → trim → collapse whitespace → NFC; UTF-8 in/out.
* **Aliases parsing**: autodetect delimiters (`;`, `,`, `|`) with `delimiter=` override; trim; drop blanks.
* **Collision policy**: strict—ambiguous hashes are unresolved with reason `"collision_ambiguous"`.

---

## GitHub Issues to Create (with Acceptance Criteria)

### 1) Schema & Loader (`load_roster()`)

**Goal:** Enforce `engager_v1` roster schema; compute canonical + hashes; build `all_name_hashes`.
**Done when:**

* `preferred_name` required; `student_id` optional but unique if present; `formal_name`, `transcript_name` optional; `aliases` parsed to **list<chr>** (no row explosion).
* Adds derived: `canonical_name`, `name_hash`, `alias_hashes` (list<chr>), `all_name_hashes` (list<chr>).
* Validates and **flags collisions** in roster (no matches assigned).
* Spec attributes attached; uses secrets precedence rule.
* roxygen docs with synthetic examples.
* Tests: schema happy path, duplicates, alias parsing, collisions.

### 2) Normalization & Hashing Core

**Goal:** Deterministic, locale-safe normalization and hashing.
**Done when:**

* `normalize_name()` implements NFKD→strip→casefold(full)→trim→collapse\_ws→NFC via `stringi`.
* `hash_canonical_name()` supports SHA-256 and HMAC-SHA-256 (hex).
* Reads key via precedence; records algo/icu/spec in audit/attrs.
* Tests: diacritics (`José`/`Zoë`), composed vs decomposed, Turkish `İ/ı`, German `ß/SS`; determinism with/without key.

### 3) Exact Matching Index & Workflow

**Goal:** Exact join on hashes; privacy-first UX.
**Done when:**

* `build_roster_hash_index()` maps each hash → unique `student_id` (or collision bucket).
* `prepare_transcript_names()` normalizes & hashes transcript speakers.
* `match_names_exact()` assigns ids; unresolved reasons: `"no_candidate"` / `"collision_ambiguous"`.
* `safe_name_matching_workflow()` returns **`engager_match`** object: `list(transcripts_with_ids, unresolved, audit)`; quiet single-line message; S3 `print` and `summary`.
* `detect_unmatched_names()` returns unresolved table with `name_hash`, `occurrence_n`, `first_seen_at`, `reason`, `guidance`.
* Tests: integration path, counts, no raw names by default.

### 4) Safe Writer Utility (`write_unresolved()`)

**Goal:** Opt-in, hashed-only export by default.
**Done when:**

* Writes only hashes/reasons unless `include_raw=TRUE` **and** `options(engager.allow_raw_name_exports=TRUE)` set; else abort with `engager_privacy_error`.
* Tests: default hashed-only, guard rails on raw export.

### 5) Docs & Vignettes

**Goal:** CRAN-safe, pkgdown-friendly docs.
**Done when:**

* Function docs: title/desc/params/returns/examples (@family name-matching, @seealso).
* Vignettes:

  * `01-getting-started.Rmd`: `load_roster()` → `safe_name_matching_workflow()` → `detect_unmatched_names()` (synthetic, short).
  * `02-essential-functions.Rmd`: Name Matching category lists exported functions; downlit autolinks.
* New pkgdown page: **Security & Privacy** (hashing rationale, HMAC guidance, `.Renviron` example, threat model summary, citations listed at bottom).
* All examples run quickly; use `eval=TRUE`, synthetic data.

### 6) Testing, Snapshots, CI Matrix

**Goal:** Robust cross-platform coverage; no leaks.
**Done when:**

* Tests per matrix below; add **snapshot redaction helper** to strip raw names/hashes from snapshots unless explicitly allowed.
* GitHub Actions matrix: Linux + macOS; R-release + R-devel.
* All checks pass; pkgdown builds green.

### 7) Fuzzy Strategy Stub (No Implementation)

**Goal:** Future-proof API without bloat.
**Done when:**

* `match_strategy` option accepted by workflow/detect, default `"exact"`.
* `match_names_fuzzy()` exists and **aborts** with a clear “not implemented” message.
* No behavior change otherwise.

---

## Coding Tasks (Implementation Order)

1. Create branch `feat/name-matching-mvp`.
2. Implement **Issue #1** (Schema & Loader) + tests.
3. Implement **Issue #2** (Normalization/Hashing) + tests.
4. Implement **Issue #3** (Index, Exact Match, Workflow, S3 class, errors) + tests.
5. Implement **Issue #4** (Writer) + tests.
6. Implement **Issue #5** (Docs & Vignettes) with synthetic examples.
7. Implement **Issue #6** (Snapshot redaction, CI matrix).
8. Implement **Issue #7** (Fuzzy stub + `match_strategy` option).
9. Run full `R CMD check`; ensure pkgdown site builds; fix warnings/notes.
10. Open PR(s), link issues, provide summary and before/after screenshots of vignettes.

---

## Test Matrix (create files as listed)

* `tests/testthat/test-load_roster.R`

  * Required/optional columns; alias parsing (`;`, `,`, `|`); duplicate `student_id`; empty preferred\_name error; collisions flagged.
* `tests/testthat/test-normalization.R`

  * Diacritics, composed vs decomposed; Turkish `İ/ı`; German `ß/SS`; whitespace collapsing; determinism of normalization.
* `tests/testthat/test-exact-matching.R`

  * preferred/formal/aliases exact matches; unresolved reasons; counts.
* `tests/testthat/test-collisions.R`

  * Multi-student same hash → unresolved `collision_ambiguous`; strict policy enforced.
* `tests/testthat/test-privacy-defaults.R`

  * No raw names in console, unresolved, or snapshots by default; writer guardrails.
* `tests/testthat/test-determinism.R`

  * Same inputs + same key → identical outputs/audits; different key → different hashes consistently.
* `tests/testthat/test-workflow-integration.R`

  * End-to-end with synthetic roster/transcripts; class `engager_match` methods `print()`/`summary()`; spec attributes present.

---

## Definition of Done (per PR)

* All acceptance criteria for the targeted issue(s) checked.
* `R CMD check` passes locally and in CI on Linux + macOS.
* Docs build: pkgdown renders vignettes; site stays green.
* No raw names leaked in logs/snapshots; unresolved exports hashed-only by default.
* Backwards-compatible public API; fuzzy stub present but inactive.

---

## Citations to include on pkgdown “Security & Privacy”

* NIST **FIPS 180-4** – *Secure Hash Standard (SHS)* (SHA-256).
* NIST **SP 800-107 Rev.1** – *Recommendation for Applications Using Approved Hash Algorithms* (HMAC guidance).
* Unicode **UAX #15** – *Unicode Normalization Forms* (NFKD/NFC & canonical equivalence).

(Include hyperlinks in the pkgdown page; keep to 2–3 authoritative links.)

---

## Housekeeping & Quick Notes

* Keep `include_formal_as_alias = FALSE` by default.
* Do **not** expose `aliases_long()` publicly.
* Do **not** implement a strategy registry yet; just accept `match_strategy = "exact"` and keep the stub.
* Add a brief `NEWS.md` entry under “Unreleased” describing the new exact name-matching subsystem and privacy defaults.

---

## Prompts the Agent May Ask (pre-filled answers)

* **Q:** Where to read `ENGAGER_NAME_HASH_KEY`?
  **A:** `Sys.getenv("ENGAGER_NAME_HASH_KEY")`; function arg overrides env; option is last resort.
* **Q:** May I add `stringi` / `openssl` (or `digest`) to `Imports:`?
  **A:** Yes—`stringi` and either `openssl` or `digest` are allowed. Prefer `openssl` for HMAC.
* **Q:** Any constraints on example data sizes?
  **A:** Keep examples tiny and fast; synthetic only.

---

**Proceed to:**

1. Open issues with the above titles/criteria.
2. Push branch `feat/name-matching-mvp`.
3. Implement in the order listed.
4. Open PR(s) that reference issues.

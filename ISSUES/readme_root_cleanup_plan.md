# Issue: Cleanup README Generation and Root Directory for CRAN Submission

## Summary
- Rework `README.Rmd`/`README.md` to focus on CRAN-ready onboarding content, fix broken navigation, and remove internal-only workflow notes.
- Restore a trustworthy documentation index (or update all references) so README and docs landing pages stop linking to missing files.
- Audit root-level artifacts, relocate or retire non-package assets, and ensure the README automation in `scripts/pre-pr.sh` keeps working after the cleanup.

## Evidence of the Current Problems
- README still highlights internal Cursor automation and other developer workflows that do not belong in a CRAN-facing document.【F:README.Rmd†L47-L64】
- Multiple README links are broken (`PROJECT.md`, `DOCUMENTATION.md`, `PR_REVIEW_PROMPT_GENERATOR_OPTIMIZED.md`), and those files no longer exist at the repository root.【F:README.Rmd†L33-L37】【F:README.Rmd†L205-L225】【F:README.md†L39-L66】【F:README.md†L268-L283】【73f6ff†L1-L4】【6ed3cc†L1-L3】【425164†L1-L3】
- `docs/README.md` points to recursive paths and back to the missing `DOCUMENTATION.md`, so contributors lack a single reliable index.【F:docs/README.md†L8-L59】
- The root directory mixes backups, analysis artifacts, helper scripts, and large data files alongside package sources, obscuring what actually ships to CRAN.【218b46†L1-L21】
- `scripts/pre-pr-validation.R` invokes `devtools::build_readme()` automatically, so any restructuring must keep the README build workflow intact.【F:scripts/pre-pr-validation.R†L121-L143】

## Proposed Work Plan

### 1. Modernize the README for CRAN
- Draft a CRAN-friendly outline (package overview, installation from CRAN + GitHub, minimal quick-start, key links) and confirm which advanced sections belong elsewhere.
- Move Cursor/agent workflow guidance into an appropriate developer doc (e.g., `docs/development/` or `CONTRIBUTING.md`) while leaving a short pointer for contributors.
- Replace or remove references to missing files (`PROJECT.md`, `DOCUMENTATION.md`, `PR_REVIEW_PROMPT_GENERATOR_OPTIMIZED.md`) and ensure all remaining links resolve.
- Refresh badges and ensure they use HTTPS URLs without typos (current coverage badge link starts with `h` + newline in the knitted output).
- Knit the README with `devtools::build_readme()` and verify the generated Markdown renders correctly on GitHub (Table of Contents, fenced code, emoji headings, etc.).
- Run a link checker (e.g., `lychee` or `markdownlint` via CI or local container) against the regenerated README to confirm no regressions.

### 2. Restore Documentation Navigation
- Decide whether to reinstate `DOCUMENTATION.md` as a curated index (leveraging the historical structure in `docs/planning/ISSUE_CLEANUP_AND_ORGANIZATION_PLAN.md`) or retarget all links to `docs/README.md`/pkgdown.
- If recreating `DOCUMENTATION.md`, gather the current high-value docs (development guides, planning audits, CRAN readiness notes) and describe maintenance expectations; otherwise, remove the link everywhere and emphasize the pkgdown site + `docs/README.md`.
- Fix `docs/README.md` so every link has a clean path (no duplicated `docs/development/...`) and ensure it no longer references the absent `DOCUMENTATION.md`.
- Audit other docs that point to `PROJECT.md` or backup files and update them to the chosen status/roadmap document.

### 3. Clean Up the Repository Root
- Inventory every non-standard root artifact and classify it as backup, analysis output, dataset, one-off script, or documentation checklist. Key items include `PROJECT.md.backup.*`, `NAMESPACE.new`, `function_audit_report*.rds`, `function_dependencies_diagram.md`, `session_mapping.csv`, `test_data_*.rds`, `Rplots.pdf`, `coverage_report.html`, `PR_522_APPROVAL_CHECKLIST.md`, and the various `fix_*.R` helpers.【218b46†L1-L21】
- For each category, decide on a destination:
  - Move historical backups and diffs into `backups/` (with dated subfolders) or prune superseded copies.
  - Relocate large datasets and generated artifacts into `inst/extdata/`, `tests/testthat/fixtures/`, or a new `dev/artifacts/` directory and update any scripts/tests that load them.
  - Consolidate ad-hoc maintenance scripts under `scripts/maintenance/` (or similar) and document their purpose.
  - Shift documentation checklists/diagrams into `docs/` with contextual filenames.
- Update `.Rbuildignore` patterns once files move so the package build excludes only what it should, and drop ignore rules for removed assets.【F:.Rbuildignore†L1-L120】
- Confirm Git ignores or archives cover any new directories to avoid bloating the package tarball.

### 4. Safeguards and Regression Checks
- Run `scripts/pre-pr.sh` (or `Rscript scripts/pre-pr-validation.R`) to ensure README rebuilding, documentation, and context scripts still pass after reorganization.【F:scripts/pre-pr-validation.R†L121-L143】
- Execute `devtools::check()` (or the project’s preferred pre-PR validation workflow) to verify relocating files didn’t break examples, tests, or vignettes.
- Update contributor documentation (e.g., `CONTRIBUTING.md` or `docs/development/README.md`) to explain the new layout and where to find development-only resources.
- Coordinate with pkgdown/site deployment if any moved docs should appear on the published site (update `_pkgdown.yml` navigation as needed).

## Deliverables
- Updated README Rmd/MD pair aligned with CRAN expectations and passing automated link checks.
- A maintained documentation index strategy (restored `DOCUMENTATION.md` or revised links) reflected consistently across README and docs landing pages.
- Root directory free of stray backups/artifacts, with files moved to documented homes and supporting ignores updated.
- Validation notes confirming `devtools::build_readme()` and pre-PR tooling continue to succeed post-cleanup.

## Open Questions for the Implementing Agent
- Should we automate documentation index generation (e.g., script to rebuild `DOCUMENTATION.md`) or rely on manual updates with review gates?
- Which of the large `.rds` datasets are required for tests/vignettes versus historical analysis, and can any be regenerated or downloaded on demand?
- Do we want a dedicated `dev/` (or similar) workspace for future analysis artifacts to prevent root clutter from returning?

# ISSUE 509 — Implementation Guide: Formalize Package Rename (zoomstudentengagement → engager)

## Overview
This guide defines concrete steps to complete the rename from `zoomstudentengagement` to `engager` with minimal risk and full compliance.

## Preconditions
- Ensure local validation is green: `Rscript scripts/pre-pr-validation.R`.
- Confirm branch workflow (feature branch) and never commit to `main` directly.

## Step-by-Step Plan

### 1) Consolidate Existing Work (Phase 1)
1. Use or update branch: `cursor/rename-r-package-to-engager-6334`.
2. Compare with `origin/rename/engager`; cherry-pick or merge if differences exist.
3. Replace lingering `zoomstudentengagement` mentions in:
   - `DESCRIPTION`, `R/`, `tests/`, `vignettes/`, `man/`, `README*`, `NEWS.md`.
   - Options in `R/zzz.R`: `zoomstudentengagement.*` → `engager.*`.
4. Add a NEWS entry announcing the rename (no API changes).

### 2) Validate (Phase 2)
1. Run: `Rscript scripts/pre-pr-validation.R`.
2. Run: `R CMD build .` then `R CMD check --as-cran --no-manual ./*_*.tar.gz`.
3. Build vignettes and pkgdown; verify links.
4. Ensure tests/examples run and are updated for `engager`.

### 3) Repository Rename (Phase 3)
1. In GitHub, Settings → General → Rename repository to `engager`.
2. Update:
   - `DESCRIPTION` URLs
   - README badges/links
   - `pkgdown.yml` `url:`
3. Re-run validations.

### 4) CRAN Submission (Phase 4)
1. Final validations; ensure 0 ERROR/0 WARNING.
2. Submit as `engager`; monitor and respond to CRAN.

## Commands
```
Rscript scripts/pre-pr-validation.R
R -q -e "roxygen2::roxygenise()"
R CMD build .
R CMD check --as-cran --no-manual ./*_*.tar.gz
```

## Success Criteria
- All references updated, tests/docs green, repo renamed, links fixed, CRAN submission accepted.

## Links
- Issue #509
- PR #460 (rename PR)
- docs/development/ISSUE_509_CONSOLIDATED_PLAN.md



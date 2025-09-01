# CRAN Release Plan

**Last updated:** 2025-09-01

This document outlines the minimal steps required to submit `zoomstudentengagement` version 0.1.0 to CRAN.

1. **Trim and stabilize the public API**
   - Internalize non-essential helpers and target a concise exported surface (~16 core functions).

2. **Prepare package metadata for a 0.1.0 release**
   - Update `DESCRIPTION` to Version 0.1.0 and add a matching `NEWS.md` entry documenting the initial release.

3. **Resolve outstanding quality issues**
   - Raise test coverage above 90%, fix all `R CMD check` notes, and eliminate test warnings.

4. **Refresh user documentation**
   - Restructure `README.Rmd`, ensure vignettes reflect the pared-down API, and regenerate documentation with `roxygen2`.

5. **Run full pre-submission checks and build**
   - Format with `styler`, lint with `lintr`, then run `devtools::document()`, `devtools::test()`, `covr::package_coverage()`, `devtools::check()`, and `devtools::build()`.

6. **Tag and submit**
   - Tag release (`v0.1.0`), create `cran-comments.md`, submit via CRAN's web form, and monitor for reviewer feedback.


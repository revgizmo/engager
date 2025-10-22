
## engager AI Coding Agent Instructions

This guide enables AI agents to be immediately productive in the engager R package codebase. It merges project-specific conventions, workflows, and architectural knowledge from `.cursorrules`, `README.md`, `perf/README.md`, and `project-docs/development/README.md`.

### Big Picture Architecture
- **R package for Zoom transcript analysis**: Focused on participation equity, privacy, and CRAN compliance.
- **Key directories**: `R/` (functions), `man/` (docs), `tests/testthat/` (unit tests), `inst/extdata/` (test data), `perf/` (performance CI), `docs/` (documentation), `scripts/` (automation).
- **Major components**:
  - Transcript loading/processing (`load_zoom_transcript`, `process_zoom_transcript`)
  - Engagement metrics (`summarize_transcript_metrics`)
  - Name matching/cleaning (`make_clean_names_df`)
  - Privacy masking (`set_privacy_defaults`, global `engager.privacy_level`)
  - Visualization/reporting (`plot_users`, `run_student_reports`)

### Developer Workflows
- **Pre-PR validation** (run before every PR):
  - `styler::style_pkg()`
  - `lintr::lint_package()`
  - `devtools::document()`
  - `devtools::build_readme()`
  - `devtools::spell_check()`
  - `devtools::test()`
  - `covr::package_coverage()`
  - `devtools::check()`
  - `devtools::build()`
- **Performance testing**: Use scripts in `perf/scripts/` and update baselines in `perf/baselines/`.
- **Context generation**: `./scripts/context-for-new-chat.sh` or `Rscript scripts/context-for-new-chat.R`.
- **Temporary CI policy**: If CI is blocked, maintainers may self-merge PRs if both pre-PR validation and context scripts succeed locally (see Issue #406).

### Project-Specific Conventions
- **Style**: Tidyverse style guide, `<-` for assignment, snake_case for functions/variables, camelCase for data frame columns.
- **Documentation**: All exported functions require complete roxygen2 docs (`@param`, `@return`, `@examples`, `@export`).
- **Testing**: One test file per R file, descriptive names, use `testthat`, aim for >90% coverage.
- **Privacy**: Mask identifiers by default; never expose student data. Use privacy-aware plotting and reporting.
- **Error handling**: Use `stop()`, `warning()`, `message()` with clear, actionable messages.
- **Git workflow**: Conventional commits (`type(scope): description`), feature branches from `develop`, link PRs to issues, use admin override for protected branch merges if needed.

### Integration Points & External Dependencies
- **Core R packages**: data.table, dplyr, ggplot2, lubridate, magrittr, purrr, readr, rlang, stringr, tibble, tidyr, tidyselect.
- **Development**: testthat, covr, knitr, rmarkdown, styler, lintr.
- **Performance CI**: `{bench}` for timing, JSON baselines for regression detection.

### Examples of Key Patterns
- **Privacy masking**:
  ```r
  set_privacy_defaults("mask")  # default, safe
  plot_users(metrics, mask_by = "name")
  ```
- **Diagnostics**:
  ```r
  options(engager.verbose = TRUE)
  # disables in CI/non-interactive
  ```
- **Performance regression check**:
  ```r
  source("perf/scripts/check-performance-regression.R")
  check_performance_regression()
  ```

### References
- See `docs/README.md` for documentation index.
- See `CONTRIBUTING.md` for contribution/review checklist.
- See `perf/README.md` for performance CI details.
- See `.cursorrules` for full style and workflow rules.

---
**Feedback:** If any section is unclear or missing, please specify which workflows, conventions, or architectural details need further explanation.
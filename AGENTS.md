# AGENTS.md — Zoom Student Engagement (AI Agent Guide)

These instructions guide automated or AI-assisted contributors. They apply to
the entire repository unless a nested `AGENTS.md` overrides them.

## Project Overview
- **Purpose**: Analyze Zoom transcripts to measure student engagement using R.
- **Key directories**:
  - `R/`: Core package functions
  - `tests/`: Unit tests using `testthat`
  - `man/`: Generated documentation
  - `data/`: Example or synthetic transcripts

## Environment Setup & Dependencies
- Requires R ≥ 4.1.0 with dependencies listed in `DESCRIPTION`.
- Install dependencies:

  ```bash
  Rscript -e "remotes::install_deps(dep = TRUE)"
  ```

- Run all R commands via `Rscript`; do **not** launch the R shell directly.

## Build & Test Commands
- Load package: `Rscript -e "devtools::load_all()"`
- Run tests: `Rscript -e "devtools::test()"`
- Package checks: `Rscript -e "devtools::check()"`
- Pre-PR validation: `Rscript scripts/pre-pr-validation.R`

## Code Style & Documentation
- Follow the [tidyverse style guide](https://style.tidyverse.org/).
- Use `<-` for assignment, snake_case for names, and keep lines ≤ 80 characters.
- Format code with `Rscript -e "styler::style_pkg()"` and lint with
  `Rscript -e "lintr::lint_package()"`.
- Document exported functions with roxygen2. After editing R files run:

  ```bash
  Rscript -e "devtools::document()"
  Rscript -e "devtools::build_readme()"   # when README needs rebuilding
  ```

## Testing Guidelines
- All new or modified functionality requires `testthat` tests.
- Ensure tests cover transcript parsing and engagement metrics.
- Run `Rscript -e "devtools::test()"` and
  `Rscript scripts/pre-pr-validation.R` before opening a pull request.

## Pull Request Guidelines
- Use feature branches and keep commits focused. Commit messages follow
  `<type>(<scope>): <description>`.
- Branch naming: `feature/<name>` or `bugfix/<issue-number>`.
- PR titles: `[zoomstudentengagement] Short descriptive title`.
- PR descriptions should state *what changed*, *why it matters*, and *how to
  test*.

## Failure Handling & Edge Cases
- Clearly document assumptions about transcript formats (e.g., missing
  timestamps or speaker tags) and emit warnings when appropriate.

## Privacy & Data
- Never commit or log real student data. Use anonymized or synthetic examples
  and respect FERPA requirements.

## External References
- Full documentation: `README.md`
- Issue tracker: <https://github.com/revgizmo/zoomstudentengagement/issues>
- Tidyverse style guide: <https://style.tidyverse.org/>

## Agent-Specific Notes
- Do not modify files in `man/` unless accompanying source changes require
  regenerated documentation.
- New functions must include roxygen2 docs and unit tests.
- Check for other `AGENTS.md` files in subdirectories; their instructions take
  precedence within their scope.


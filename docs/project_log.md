# Project Log

This log documents improvement cycles (bugs, debt, metrics, visuals) and any
process improvements implemented to make the repository easier to maintain.

## 2025-08-28 — Process Improvements: Pre-commit + Contribution Workflow

- Added `.pre-commit-config.yaml` with:
  - Base hygiene hooks (trailing whitespace, EOF, YAML, mixed line endings)
  - Local hook delegating to `scripts/pre-commit.sh` to run `styler` and `lintr`
- Updated `CONTRIBUTING.md` with pre-commit setup and usage instructions
- Established this `docs/project_log.md` to record future improvement cycles

Why this matters:
- Standardizes formatting and linting before commits to reduce CI churn
- Gives contributors a clear, repeatable pre-PR workflow
- Creates an auditable history of process improvements

How to test:
- Install hooks with `pre-commit install`
- Run on all files with `pre-commit run --all-files`
- Make a small edit to an `.R` file and commit to see styling/lint enforced


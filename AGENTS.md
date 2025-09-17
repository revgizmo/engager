# AGENTS.md
## Environment
Use local runner. Assume R + renv are installed.

## Setup
R -q -e "install.packages('renv', repos='https://cloud.r-project.org'); renv::restore()"

## Lint & Docs
R -q -e "styler::style_pkg(); roxygen2::roxygenise()"

## Tests
R -q -e "devtools::test()"

## CRAN checks
R -q -e "rcmdcheck::rcmdcheck(error_on='warning')"

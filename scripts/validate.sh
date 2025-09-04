#!/usr/bin/env bash
# Run the validation toolchain without editing package files.

set -euo pipefail

export MAKEFLAGS="-j$(nproc)"
export R_DEFAULT_NUM_THREADS="$(nproc)"
# speed up & make results more deterministic in CI
export _R_CHECK_CRAN_INCOMING_=false
export _R_CHECK_FORCE_SUGGESTS_=false

echo ">> roxygenise"
Rscript -e 'options(repos=c(CRAN="https://cloud.r-project.org")); roxygen2::roxygenise()'

echo ">> lintr (non-fatal)"
set +e
Rscript -e 'lintr::lint_package()'
LINT_STATUS=$?
set -e
if [ $LINT_STATUS -ne 0 ]; then
  echo "lintr reported issues (non-fatal for CI)."
fi

echo ">> R CMD build (skipping vignettes for CI speed)"
R CMD build --no-build-vignettes .

TARBALL=$(ls -t ./*.tar.gz | head -n1)
echo "Built: $TARBALL"

echo ">> R CMD check (skip vignettes/manual; use all cores)"
R CMD check --as-cran --ignore-vignettes --no-manual "$TARBALL"

echo ">> done"

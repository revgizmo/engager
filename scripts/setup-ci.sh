#!/usr/bin/env bash
# Prepare a fast, minimal environment for building/checking the package.
# Safe for GitHub Actions, local CI, and ChatGPT Agent runs.

set -euo pipefail

# Speed up compiles
export MAKEFLAGS="-j$(nproc)"

echo ">> apt-get: system prerequisites"
sudo apt-get update -y
# qpdf -> CRAN checks; libcurl/ssl/xml2 -> common deps for Imports/devtools
sudo apt-get install -y --no-install-recommends \
  qpdf \
  r-base-dev \
  libcurl4-openssl-dev \
  libssl-dev \
  libxml2-dev

# (Optional) If you know you’ll never build vignettes in CI, you can skip pandoc/tex entirely.
# If you DO want vignettes, uncomment the next line:
# sudo apt-get install -y --no-install-recommends pandoc

echo ">> R: install dev toolchain and package Imports"
# NOTE: keep the dev set small; avoid `dependencies=TRUE`
Rscript - <<'RSCRIPT'
options(repos = c(CRAN = "https://cloud.r-project.org"))
# Fast install helper
install_if_missing <- function(pkgs) {
  ip <- rownames(installed.packages())
  need <- setdiff(pkgs, ip)
  if (length(need)) {
    install.packages(
      need,
      dependencies = c("Depends","Imports"),
      Ncpus = max(1L, parallel::detectCores() - 1L)
    )
  }
}

# Dev/test toolchain (small on purpose)
dev_pkgs <- c(
  "remotes",      # to install Imports from DESCRIPTION
  "roxygen2",
  "testthat",
  "rcmdcheck",
  "lintr",
  "styler",
  "knitr",        # needed if you ever build vignettes locally
  "rmarkdown"     # "
)
install_if_missing(dev_pkgs)

# Install package Imports (but not Suggests) from DESCRIPTION
remotes::install_deps(dependencies = c("Depends","Imports"),
                       upgrade = "never",
                       quiet = FALSE)
RSCRIPT

echo ">> setup complete"

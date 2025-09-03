#!/usr/bin/env bash
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
  r-base r-base-dev build-essential git curl ca-certificates pandoc \
  libcurl4-openssl-dev libssl-dev libxml2-dev libgit2-dev \
  libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev
Rscript -e 'options(repos=c(CRAN="https://cloud.r-project.org")); pkgs <- c(
  "devtools","roxygen2","testthat","lintr","styler","pkgdown","rmarkdown","remotes",
  "withr","jsonlite","httr","cli"
); ip <- rownames(installed.packages()); install.packages(setdiff(pkgs, ip))'
# Optional LaTeX commented out intentionally

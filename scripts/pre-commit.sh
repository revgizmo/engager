#!/usr/bin/env bash
set -euo pipefail

# Find staged R files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(R|r|Rmd)$' || true)

if [ -z "$STAGED_FILES" ]; then
  echo "No staged R files to lint/style."
  exit 0
fi

export STAGED="$STAGED_FILES"

echo "Styling staged R files with styler..."
Rscript --vanilla -e "
  files <- strsplit(Sys.getenv('STAGED'), '\n')[[1]]
  files <- files[nzchar(files)]
  if (length(files) > 0) {
    styler::style_file(files, transformers = styler::tidyverse_style(), cache = FALSE)
  }
"

# Re-stage files that may have been modified by styler (skippable in sandboxes)
if [ "${SKIP_RESTAGE:-}" != "1" ]; then
  git add $STAGED_FILES
fi

echo "Running lintr on staged files..."
Rscript --vanilla -e "
  files <- strsplit(Sys.getenv('STAGED'), '\n')[[1]]
  files <- files[nzchar(files)]
  lints <- unlist(lapply(files, lintr::lint))
  if (length(lints) > 0) {
    print(lints)
    quit(status = 1)
  }
  cat('No lints found.\n')
"

echo "Done."

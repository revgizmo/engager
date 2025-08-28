#!/bin/bash

# Run pre-PR validation then refresh context files
# Usage: ./scripts/pre-pr.sh [args passed to pre-pr-validation.R]

set -euo pipefail

Rscript scripts/pre-pr-validation.R "$@"

# Refresh context files for Cursor
./scripts/save-context.sh

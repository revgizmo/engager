#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
exec Rscript "$repo_root/scripts/pre-pr-validation.R" "$@"

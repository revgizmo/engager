# Repository scripts

The only normative pre-pull-request entry point is:

```sh
Rscript scripts/pre-pr-validation.R
```

`scripts/pre-pr.sh` is a shell wrapper around the same non-mutating validator.
The coverage workflow uses `scripts/check-export-coverage.R` together with
`project-docs/release/supported-exports.txt`.

Other scripts are task-specific or historical utilities. They do not define
development policy, supported APIs, release readiness, or privacy guarantees.
Read and validate a script before using it, and never run real or private course
data through repository automation.

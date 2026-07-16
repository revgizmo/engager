# Development documentation index

This page routes contributors to the current authority surfaces. Historical
files in this directory are retained temporarily for evidence and will be
reviewed in a separate cleanup pull request; they do not override the documents
below.

## Normative policy

- [CONTRIBUTING.md](../../CONTRIBUTING.md) — development, review, validation,
  merge, CI-degraded, and release-mutation policy.
- [AGENTS.md](../../AGENTS.md) — concise repository-wide execution boundaries
  for coding agents.

## Product and release direction

- [Roadmap](../ROADMAP.md) — product philosophy, supported release surface,
  feature horizons, and promotion rules.
- [0.1.1 release plan](../release/V0_1_1_RELEASE_PLAN.md) — bounded attendance
  and reporting tranches, branch isolation, and release gates.
- [Installed-package UAT](../release/UAT_COURSE_WORKFLOW.md) — synthetic-fixture
  validation of the built tarball.
- [CRAN compliance checklist](../release/CRAN_COMPLIANCE_CHECKLIST.md) — CRAN
  candidate evidence requirements.

## Canonical commands

Run the non-mutating local validator:

```sh
Rscript scripts/pre-pr-validation.R
```

When R or roxygen comments change, intentionally regenerate documentation and
commit the result before validation:

```r
devtools::document()
```

Lint is currently advisory. Required hosted gates are strict `R-CMD-check` and
`Coverage`; the latter also checks the namespace against
`project-docs/release/supported-exports.txt` and enforces the current 85%
all-supported-export coverage floor. Required CI validates committed package
files without regenerating documentation. The existing roxygen 7.3.3 drift is
reconciled on `develop` after 0.1.0 acceptance before a drift gate is enabled.

## Handoffs

For a bounded agent-to-agent transfer, use
[AI_AGENT_HANDOFF_TEMPLATE.md](AI_AGENT_HANDOFF_TEMPLATE.md) only after adding
the current branch/worktree, exact scope, acceptance checks, prohibited
actions, data boundary, and GitHub mutation boundary.

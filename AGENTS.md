# Agent instructions

These instructions apply to the entire repository.

1. Read [CONTRIBUTING.md](CONTRIBUTING.md),
   [project-docs/ROADMAP.md](project-docs/ROADMAP.md), and the relevant release
   plan before changing files.
2. Reconcile live issues, pull requests, branches, worktrees, and the target
   branch before taking ownership. Use one bounded branch and dedicated
   worktree per implementation lane.
3. Keep `main` on the stable release/CRAN lane. Target 0.1.1 feature work to
   `develop`; never carry unfinished development into a 0.1.0 remediation.
4. Use only bundled or newly created synthetic data. Do not inspect, copy, or
   commit real course data or generated validation outputs.
5. Preserve technical privacy language. Do not claim anonymity, FERPA or legal
   compliance, or institutional approval.
6. Treat public API, privacy/schema contracts, repository rulesets, release
   promotion, and external release mutations as governed work requiring the
   authorization described in `CONTRIBUTING.md`.
7. Automated review is evidence, not approval. Address actionable findings or
   explicitly document why they do not apply; resolve all review threads.
8. Run the smallest relevant checks and the canonical validator before
   closeout. Generate roxygen documentation intentionally and commit any
   resulting `NAMESPACE` or `man/` changes.
9. Do not routinely use admin bypass. Do not mutate GitHub from a read-only
   assignment.

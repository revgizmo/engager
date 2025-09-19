# PR 534 Approval Checklist

PR: https://github.com/revgizmo/engager/pull/534
Title: [engager] ensure pkgdown site rebuilds with engager branding
Head: codex/remove-references-to-zoom-student-engagement → Base: main

## Preconditions
- [ ] PR rebased on latest `main` and conflicts resolved
- [ ] CI workflows green (checks passing)
- [ ] Not a draft PR

## CRAN Compliance
- [ ] R CMD check: 0 errors, 0 warnings
- [ ] devtools::test(): all tests pass
- [ ] Coverage ≥ 90% (covr)
- [ ] devtools::check_examples(): all examples run
- [ ] devtools::spell_check(): no issues
- [ ] devtools::build(): succeeds

## Documentation and Branding
- [ ] `_pkgdown.yml` updated for Engager branding
- [ ] README and vignettes reflect Engager
- [ ] Pkgdown site builds cleanly and shows Engager
- [ ] `docs/brand-reference-audit.md` reviewed and blockers resolved

## Code Quality and Style
- [ ] styler::style_pkg() applied
- [ ] lintr::lint_package() warnings addressed
- [ ] No legacy `zoomstudentengagement` identifiers remain

## Security and Privacy
- [ ] No secrets in workflows or code
- [ ] No sensitive data in examples or docs

## Merge
- [ ] Squash merge prepared with clear message
- [ ] Post-merge pkgdown publish verified
- [ ] Feature branch cleaned up



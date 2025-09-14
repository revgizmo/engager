## Issue #509 — Package Rename Consolidated Plan (zoomstudentengagement → engager)

### Objective
Formalize and complete the rename from `zoomstudentengagement` to `engager` with a seamless user transition, preserved repo history, and CRAN-ready compliance.

### Current Status
- Rename initiative tracked in Issue #509 (this document).
- Open PR: #460 “Rename r package to engager” (`cursor/rename-r-package-to-engager-6334`).
- Duplicate/parallel branch noted: `origin/rename/engager`.
- Repository analysis records rename branches: `docs/analysis/repository-branch-analysis.md`.

### Goals
- Single-source truth for rename scope, tasks, and validation.
- Zero user breakage; automatic redirects after GitHub repo rename.
- CRAN compliance maintained: 0 ERROR/0 WARNING; NOTES only if unavoidable.

### Non-Goals
- No API behavior changes beyond namespace/package identity.
- No dependency updates unrelated to the rename.

### Phases and Timeline (Guideline)
1. Phase 1 — Consolidation (1–2 days)
   - Consolidate PR #460 with any duplicate work.
   - Inventory/replace lingering `zoomstudentengagement` references.
   - Verify CRAN name availability for `engager`.

2. Phase 2 — Validation (1–2 days)
   - Run full test suite, vignettes, examples.
   - Run full R CMD check (as-cran) locally and in CI.
   - Validate pkgdown build and links.

3. Phase 3 — Repository Rename (1 day)
   - Use GitHub Settings → Rename repository to `engager`.
   - Update DESCRIPTION URLs, README badges, pkgdown `url:`.

4. Phase 4 — CRAN Submission (1–2 days)
   - Final validation; submit as `engager`.
   - Monitor/resolve CRAN feedback.

### Best-Practices Checklist
#### Pre-rename
- [ ] Confirm `engager` availability on CRAN and in reverse-deps search.
- [ ] Green pre-PR validation: `Rscript scripts/pre-pr-validation.R`.
- [ ] Full `R CMD check --as-cran` (multi-platform via CI).

#### Code & Docs
- [ ] `DESCRIPTION` Package/Title/URL, `LICENSE` if required.
- [ ] `R/zzz.R` options: `zoomstudentengagement.*` → `engager.*`.
- [ ] Tests/examples/vignettes `library()`/`package=` updated.
- [ ] `README.md`/`README.Rmd`/`NEWS.md` rename announcement.
- [ ] `pkgdown.yml` `url:` and titles.

#### Repository
- [ ] GitHub repo rename (auto-redirects preserve links).
- [ ] Update badges and CI references (actions badges, coverage, pkgdown).
- [ ] Ensure branch protection continues to apply post-rename.

#### Communication
- [ ] Migration note: update `library(engager)`.
- [ ] Changelog entry and repo banner (temporary).

### Validation
- Pre-PR script: `Rscript scripts/pre-pr-validation.R` (must pass).
- Tests: `Rscript -e "devtools::test()"`.
- Examples/Vignettes: build without errors; examples runnable.
- Check: `R CMD check --as-cran --no-manual` tarball.

### Risks & Mitigations
- Name conflict on CRAN → pre-check name availability; fallback name list.
- Broken links post-rename → batch-update URLs; verify pkgdown and badges.
- CI drift → validate workflows after repo rename.

### Success Criteria
- Package identity updated everywhere; tests/docs green.
- Repo renamed; redirects functional; links updated.
- CRAN submission accepted under `engager`.

### References
- PR #460 — Rename PR.
- `docs/analysis/repository-branch-analysis.md` — branch inventory.
- Issue #509 — master tracking issue.






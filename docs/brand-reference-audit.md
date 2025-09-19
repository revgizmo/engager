# Brand Reference Audit (Engager Rename)

This document lists remaining references to the former **Zoom Student Engagement** name that
were not updated automatically. Most of these items are historical documents or generated
artifacts where a simple global replacement is risky. Please review them manually.

## Summary of Updates
- Package source code, man pages, and test scripts now use the `engager.*` option prefix and
  load the `engager` package.
- Developer tooling and helper scripts were updated to reference the new repository name and
  package identifier.
- High-visibility documentation (README files, docs index, performance guidelines, feature
  overview, and inst templates) now reflects the Engager branding.
- Active vignettes (those without the `.disabled` suffix) reference `engager` throughout;
  draft vignettes remain tagged below for manual updates before re-enabling.

## Items Requiring Manual Review

| Area | Approx. occurrences | Notes |
| --- | --- | --- |
| `docs/development/` | ~730 | Large collection of planning guides, completion summaries, and historical instructions authored before the rename. Many reference old GitHub issues, PR titles, or workflow names. Update selectively to preserve historical accuracy. |
| `docs/analysis/` | ~120 | Archived analysis reports and checklists retain the old branding. Confirm whether these archives should be updated or left as-is. |
| `docs/planning/` | ~46 | Roadmaps and audit plans still mention the former package name. Adjust when revising the underlying plans. |
| `docs/implementation/` | ~27 | Implementation guides reference legacy setup commands (e.g., Docker images). Validate before editing, especially if scripts depend on historical image tags. |
| `docs/reviews/`, `docs/research/`, `docs/audit/` | ~25 combined | Review reports and research notes include the prior name for context. Update when republishing. |
| Vignettes (`vignettes/*.Rmd.disabled`) | multiple | Disabled vignette drafts still load `zoomstudentengagement`. When re-enabling, switch the library calls and narrative text to Engager. |
| `coverage_report.html` | many | Generated coverage artifact still contains the old option prefix inside rendered code snippets. Regenerate the report after running the updated test suite. |
| `Project_Handoff_*` documents | several | Handoff packages contain explicit rename instructions for future teams. Confirm whether to retain the historical framing or update to Engager. |
| Rename audit docs (`docs/rename-engager-plan.md`, `docs/rename-engager-result.md`) | 15 | These track the rename project and intentionally document the legacy name. No action needed unless rewriting history. |
| `README.Rmd` / `NEWS.md` notes | 2 | Rename notes intentionally mention the former package identifier for context. |

## Follow-up Considerations
- **Hash salt change:** `hash_name_consistently()` now defaults to the salt
  string `"engager"`. This preserves branding but changes deterministic hashes.
  Validate any stored fixtures or downstream systems that expect the previous
  hash outputs.
- **Automated artifacts:** Regenerate coverage reports, pkgdown site, and other
  derived assets once R tooling is available so that generated HTML/PDF files
  inherit the new branding.
- **GitHub Pages workflow:** The `pages` workflow now runs `pkgdown::clean_site()`
  and a full rebuild to ensure the published site removes legacy
  `zoomstudentengagement` articles once the action runs on `main`.
- **Historical accuracy:** Many documents above describe past work. Consider
  whether preserving the historical product name is desirable before editing.


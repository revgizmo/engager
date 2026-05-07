# Label and Milestone Audit

Generated: 2026-05-07

This audit is a dry-run proposal for normalizing the open GitHub issue backlog. It does not mutate GitHub labels, milestones, or issue state.

## Issue Snapshot

- Open issues represented: 128
- Issues with no current labels: 10
- Issues with current milestones: 9

## Current Label Counts

| Label | Count |
|---|---:|
| `priority:medium` | 48 |
| `enhancement` | 42 |
| `docs` | 28 |
| `documentation` | 19 |
| `area:core` | 17 |
| `priority: high` | 17 |
| `area:infrastructure` | 16 |
| `CRAN:submission` | 14 |
| `area:testing` | 14 |
| `refactor` | 14 |
| `priority:high` | 12 |
| `area:documentation` | 11 |
| `priority: medium` | 10 |
| `priority:low` | 9 |
| `performance` | 8 |
| `readme` | 8 |
| `privacy` | 7 |
| `reference` | 5 |
| `ci` | 4 |
| `pkgdown` | 4 |
| `CRAN-blocker` | 2 |
| `FERPA` | 2 |
| `bug` | 2 |
| `epic` | 2 |
| `status:blocked` | 2 |
| `test` | 2 |
| `vignettes` | 2 |
| `CRAN:review` | 1 |
| `coverage` | 1 |
| `data` | 1 |
| `ethical` | 1 |
| `faq` | 1 |
| `status:in-progress` | 1 |
| `tracking` | 1 |
| `tutorial` | 1 |

## Canonical Label Mapping

| Current label | Canonical label |
|---|---|
| `docs` | `documentation` |
| `readme` | `documentation` |
| `pkgdown` | `documentation` |
| `reference` | `documentation` |
| `vignettes` | `documentation` |
| `faq` | `documentation` |
| `test` | `area:testing` |
| `priority: high` | `priority:high` |
| `priority: medium` | `priority:medium` |
| `FERPA` | `privacy` |

## Proposed Canonical Label Counts

| Label | Count |
|---|---:|
| `status:ready` | 96 |
| `priority:medium` | 93 |
| `enhancement` | 57 |
| `documentation` | 48 |
| `area:documentation` | 43 |
| `area:infrastructure` | 38 |
| `area:core` | 35 |
| `priority:high` | 29 |
| `area:testing` | 24 |
| `performance` | 16 |
| `status:needs-triage` | 15 |
| `CRAN:submission` | 14 |
| `privacy` | 14 |
| `refactor` | 14 |
| `status:superseded-candidate` | 14 |
| `ci` | 12 |
| `priority:low` | 8 |
| `bug` | 3 |
| `CRAN-blocker` | 2 |
| `epic` | 2 |
| `status:blocked` | 2 |
| `CRAN:review` | 1 |
| `coverage` | 1 |
| `data` | 1 |
| `ethical` | 1 |
| `status:in-progress` | 1 |
| `tracking` | 1 |
| `tutorial` | 1 |

## Proposed Lane Counts

| Lane | Count |
|---|---:|
| `archive` | 5 |
| `core` | 9 |
| `cran` | 16 |
| `docs` | 40 |
| `infrastructure` | 16 |
| `performance` | 15 |
| `privacy` | 7 |
| `testing` | 20 |

## Proposed Action Counts

| Action | Count |
|---|---:|
| `comment` | 18 |
| `keep` | 3 |
| `relabel` | 93 |
| `supersede-candidate` | 14 |

## Proposed Milestone Counts

| Milestone | Count |
|---|---:|
| `0.1.x stabilization` | 41 |
| `0.2.0 product` | 23 |
| `Backlog archive` | 19 |
| `CRAN external checks` | 6 |
| `Documentation refresh` | 39 |

## Release Gate Notes

- Keep `#4`, `#153`, and `#154` active under `CRAN external checks` until explicit release-owner disposition.
- Treat `#215`, `#220`, `#228`, `#229`, `#277`, `#282`, `#300`, `#301`, `#394`, `#469`, and `#471` as superseded candidates by PR `#557` unless fresh validation contradicts that evidence.
- Treat `#288`, `#296`, and `#297` as optional external validation unless the release owner requires them before submission.
- Treat `#395` and `#397` as post-CRAN follow-up, not active release blockers.

## Known Review Hotspots

- `#4` is intentionally kept as the release-control umbrella even though much of its checklist appears satisfied by PR `#557`; close it only after actual CRAN submission or explicit release-owner direction.
- `#153` and `#154` remain the highest-signal CRAN gate decisions because they represent FERPA/privacy validation and institutional adoption guidance.
- `#394` is marked as a low-confidence superseded candidate; review it carefully before treating it as closed by PR `#557`.
- `#288`, `#296`, and `#297` are classified as optional external validation rather than superseded because the release owner may still require additional external checks.
- `status:superseded-candidate` is a review marker only. It must not be converted into a live closure without a human-approved comment linking the canonical PR or issue.

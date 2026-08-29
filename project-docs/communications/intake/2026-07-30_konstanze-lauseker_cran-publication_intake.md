# Incoming email intake — `engager` 0.1.0 CRAN publication

## Source

- Sender: Konstanze Lauseker, CRAN
- Received: 2026-07-30
- Raw record:
  [inbox/2026-07-30_konstanze-lauseker_cran-publication.md](../inbox/2026-07-30_konstanze-lauseker_cran-publication.md)
- Release ledger: [issue #4](https://github.com/revgizmo/engager/issues/4)

## Classification

Release acceptance and publication event. This changes the authoritative
0.1.0 state from CRAN review to public availability.

## Verified interpretation

The reviewer message says the package is “on its way to CRAN.” Independent
verification on 2026-07-30 established that:

- the public CRAN package page is live;
- version `0.1.0` is published with date 2026-07-30;
- the public source archive is downloadable;
- the initial CRAN check matrix reported six `OK` results and no failures;
- macOS binaries were available while Windows binaries were still pending;
- the published archive differs from the submitted archive only through CRAN
  metadata normalization and its generated `MD5` manifest;
- installed-package UAT from the published source archive passes using bundled
  synthetic fixtures.

A follow-up verification on 2026-08-29 established that the official CRAN
matrix reported 13 of 13 results `OK`, with no flags, and that Windows binaries
were available. The matrix page was last updated at 2026-08-29 18:51:37 CEST.

## Action items

| Owner | Target | Action | Status | Source |
|---|---|---|---|---|
| Orchestrator | 2026-07-30 | Reconcile public page, source archive, checksums, extracted contents, and source commit | Complete | CRAN page/source plus this email |
| Orchestrator | 2026-07-30 | Run isolated installed-package UAT from the published source archive | Complete — PASS | `run_uat_course_workflow.R` |
| Orchestrator | 2026-08-29 | Refresh draft PR #584 with final matrix evidence and current release gates | Complete | This intake |
| Orchestrator | 2026-07-31 | Post a non-closing publication/UAT update to issue #4 | Complete | [Issue #4 interim closeout](https://github.com/revgizmo/engager/issues/4#issuecomment-5142654688) |
| Maintainer/orchestrator | 2026-08-29 | Refresh the CRAN matrix after 48 hours and inspect every reported platform | Complete — 13/13 `OK` | [CRAN check matrix](https://cran.r-project.org/web/checks/check_results_engager.html) |
| Orchestrator | After explicit approval | Add the final 13/13 matrix evidence to issue #4 without closing it | Pending approval | Issue #4 ledger policy |
| Maintainer | After matrix review | Separately authorize annotated `v0.1.0` tag at `6214c031...` | Pending approval | `CONTRIBUTING.md` |
| Maintainer | After tag verification | Separately authorize GitHub release publication | Pending approval | `CONTRIBUTING.md` |
| Maintainer | After release verification | Separately authorize issue #4 closure | Pending approval | `CONTRIBUTING.md` |
| Development lane | 2026-08-01 | Forward-port the CRAN documentation/write-safety remediation to `develop`, including issue #438 path validation | Complete — PR #591 | [PR #591](https://github.com/revgizmo/engager/pull/591) |

## Decisions and boundaries

- The published CRAN checksum and submitted checksum are both retained; byte
  inequality is explained rather than normalized away.
- The accepted Git tag target remains exact package-source commit
  `6214c0316d39154140bdba064266119007bff41a`.
- The later evidence commit is not the tag target.
- No real or private course data is used for validation.
- Publication does not authorize a tag, GitHub release, issue closure,
  `develop` promotion, or 0.1.2 implementation.

## Open gates

- The final 13/13 matrix evidence has not yet been added to issue #4; that
  GitHub mutation requires separate explicit approval.
- Tag, release, and ledger closure require separate explicit approvals.
- Fresh-user 0.1.1 QA remains pending; the refreshed QA tarball is not the
  final CRAN candidate.

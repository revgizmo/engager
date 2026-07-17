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
- the early CRAN check matrix reports six `OK` results and no failures;
- macOS binaries are available while Windows binaries are still pending;
- the published archive differs from the submitted archive only through CRAN
  metadata normalization and its generated `MD5` manifest;
- installed-package UAT from the published source archive passes using bundled
  synthetic fixtures.

## Action items

| Owner | Target | Action | Status | Source |
|---|---|---|---|---|
| Orchestrator | 2026-07-30 | Reconcile public page, source archive, checksums, extracted contents, and source commit | Complete | CRAN page/source plus this email |
| Orchestrator | 2026-07-30 | Run isolated installed-package UAT from the published source archive | Complete — PASS | `run_uat_course_workflow.R` |
| Orchestrator | 2026-07-30 | Update draft PR #584 with final acceptance evidence and current release gates | In progress | This intake |
| Orchestrator | 2026-07-30 | Post a non-closing publication/UAT update to issue #4 after the updated PR is published | Pending | Issue #4 ledger policy |
| Maintainer/orchestrator | On or after 2026-08-01 10:20 PDT | Refresh the CRAN matrix after 48 hours and inspect every reported platform | Pending | 0.1.1 release plan |
| Maintainer | After matrix review | Separately authorize annotated `v0.1.0` tag at `6214c031...` | Pending approval | `CONTRIBUTING.md` |
| Maintainer | After tag verification | Separately authorize GitHub release publication | Pending approval | `CONTRIBUTING.md` |
| Maintainer | After release verification | Separately authorize issue #4 closure | Pending approval | `CONTRIBUTING.md` |
| Development lane | Before rebuilding 0.1.1 | Forward-port the CRAN documentation/write-safety remediation to `develop`, including issue #438 path validation | Pending separate tranche | 0.1.1 release plan |

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

- The CRAN check matrix is still populating; the six observed results are all
  `OK`, but they are not yet the 48-hour final snapshot.
- Windows binary availability is pending. This is not a source-package blocker.
- Tag, release, and ledger closure require separate explicit approvals.

# `engager` 0.1.0 CRAN Acceptance Closeout

Status: CRAN publication verified; installed-package UAT passed; release
mutations remain pending.

Last reconciled: 2026-07-30 against the public CRAN package page, published
source tarball, current CRAN check matrix, `origin/main`, and issue #4.

## Decision

`engager` 0.1.0 is publicly available from CRAN. The package identity,
published archive contents, accepted source commit, and installed workflow are
reconciled. Do not close the release ledger yet: wait at least 48 hours from
publication for the CRAN check matrix to populate, then inspect every reported
platform before requesting the final tag, GitHub release, and issue-close
approvals.

This packet does not authorize or perform any release mutation.

## Accepted release identity

| Item | Verified value |
|---|---|
| Package | `engager` |
| Version | `0.1.0` |
| Publication date | 2026-07-30 |
| Public page | <https://cran.r-project.org/package=engager> |
| Public source | <https://cran.r-project.org/src/contrib/engager_0.1.0.tar.gz> |
| CRAN DOI | <https://doi.org/10.32614/CRAN.package.engager> |
| Submitted source SHA-256 | `21e6ecddeed86dad177708d7b7f3bf1df79059f769dedc0e0439e995e2fa5e74` |
| Published source SHA-256 | `0051326ad8e0d648969a56b7d374ba9bb4560ffe0f380e201ec6d07ac860468b` |
| Accepted package-source commit | `6214c0316d39154140bdba064266119007bff41a` |
| Main evidence commit | `4b72bb0cefeb1dfa4fe21efb87a87a5c2610fdfa` |
| Package remediation PR | [#587](https://github.com/revgizmo/engager/pull/587) |
| Evidence PR | [#588](https://github.com/revgizmo/engager/pull/588) |
| CRAN ledger | [#4](https://github.com/revgizmo/engager/issues/4) |

The submitted artifact remains at:

`/Users/piper/Downloads/engager-cran-0.1.0-remediation-6214c03/engager_0.1.0.tar.gz`

## Gate A — public publication: PASS

The public package page and source tarball resolve and report version `0.1.0`,
the accepted single-quoted `WebVTT` title, Conor Healy as maintainer, and
publication date 2026-07-30.

The published and submitted archive checksums differ because CRAN repackaged
standard metadata. Extracted recursive comparison found no difference in R
code, documentation, tests, vignettes, fixtures, or other package content.
Differences were limited to:

- removal of the build-only `Roxygen: list(markdown = TRUE)` field;
- addition of `Repository: CRAN`;
- addition of `Date/Publication: 2026-07-30 17:20:16 UTC`;
- addition of CRAN's generated `MD5` manifest.

The published checksum is authoritative for the CRAN-hosted archive. The
submitted checksum remains the provenance record for the maintainer-uploaded
artifact.

## Gate B — installed published-package UAT: PASS

Command:

```sh
Rscript project-docs/release/run_uat_course_workflow.R \
  /private/tmp/engager_0.1.0-cran-published.tar.gz \
  /private/tmp/engager-cran-published-uat-20260730-v1
```

Evidence:

- installed package version: `0.1.0`;
- R: R 4.5.3 (2026-03-11);
- platform: `aarch64-apple-darwin20`;
- installed namespace: exact 35-function supported export allowlist;
- guidance: 22 expert functions and 31 onboarding calls checked;
- fixtures: 3 bundled synthetic sessions and 34 transcript rows;
- workflows: beginner, composable, summary, plotting, matching, privacy review,
  and export paths passed;
- identifier checks: unsafe aggregation rejected, caller-provided hash salt
  required, missing identifiers preserved, and exported-artifact raw-identifier
  scan passed;
- installed vignettes: getting started, essential functions, plotting, and
  privacy/ethics review discovered;
- final disposition: `UAT PASS`.

The privacy screen's `passed` field remains `FALSE` because it flags the
identifier-like in-memory column names `name` and `name_raw`. The exported
artifact scan passed. This is technical review evidence, not a claim of
anonymity or legal/institutional compliance.

No real or private course data was used.

## Gate C — accepted source provenance: PASS

Commit `6214c0316d39154140bdba064266119007bff41a` is reachable on `main` and is
the exact source used to build the submitted remediation artifact. The later
commit `4b72bb0cefeb1dfa4fe21efb87a87a5c2610fdfa` changes only package-excluded
release evidence.

The accepted tag target must therefore be `6214c0316d39154140bdba064266119007bff41a`,
not the later evidence commit and not any 0.1.1 development commit.

## Gate D — CRAN check matrix: IN PROGRESS

At the 2026-07-30 reconciliation, the public matrix reported six results and
all six were `OK`:

- R-devel Fedora clang;
- R-devel Fedora gcc;
- R-release macOS arm64;
- R-release macOS x86_64;
- R-oldrel macOS arm64;
- R-oldrel macOS x86_64.

This is a positive but still early snapshot. Wait until at least
2026-08-01 10:20 PDT, refresh the matrix, and inspect every reported platform.
Windows binaries were not yet available at this reconciliation; binary
availability is not itself a source-package release blocker.

## Gate E — ledger and public release closeout: PENDING APPROVAL

After Gate D passes, post the final verification to issue #4 with:

- CRAN page and publication date;
- submitted and published checksums and the explained metadata-only difference;
- accepted source and evidence commits;
- installed published-tarball UAT result and R/platform;
- final CRAN check-matrix disposition;
- tag and GitHub release links when those actions are complete.

Keep issue #4 open until all separately approved release actions finish.

## Separately approved release actions

Perform these sequentially only after the 48-hour CRAN matrix review.

### 1. Create and push the annotated tag

Approval must name `v0.1.0` and source commit
`6214c0316d39154140bdba064266119007bff41a`.

```sh
test -z "$(git tag --list v0.1.0)"
test -z "$(git ls-remote --tags origin refs/tags/v0.1.0)"
git tag -a v0.1.0 \
  6214c0316d39154140bdba064266119007bff41a \
  -m "engager 0.1.0"
git rev-list -n 1 v0.1.0
git push origin v0.1.0
```

### 2. Publish the GitHub release

Use the verified tag. Do not attach a locally rebuilt tarball; CRAN remains the
authoritative R package distribution.

````markdown
# engager 0.1.0

First CRAN release of `engager`, an R package for analyzing participation in
locally held WebVTT course transcripts.

## Included

- WebVTT loading, processing, and consolidation
- speaker-level engagement metrics and plots
- privacy-supporting metric exports
- exact roster matching and unresolved-name review
- explicit masking, salted hashing, and pseudonymization transformations
- beginner, composable, and batch transcript workflows

Privacy-supporting transformations and review helpers are technical controls.
They do not establish anonymity, legal compliance, or institutional approval.

Install from CRAN with:

```r
install.packages("engager")
```
````

### 3. Close issue #4

Issue closure requires separate explicit approval after the tag and GitHub
release are verified. The closing comment must link the CRAN page, both
checksum records, installed UAT result, tag, GitHub release, and final check
matrix.

## Post-closeout unlock

Only after the 0.1.0 tag, GitHub release, and issue #4 closure may the completed
0.1.1 candidate be considered for governed `develop`-to-`main` promotion. The
CRAN documentation/write-safety remediation must first be forward-ported to
`develop` and the 0.1.1 candidate rebuilt and revalidated.

No 0.1.2 implementation is authorized by this closeout.

## Decision table

| Gate | Status | Next action |
|---|---|---|
| Public page and source | PASS | Preserve URLs and publication date |
| Published archive reconciliation | PASS | Record both checksums and CRAN metadata changes |
| Installed published-package UAT | PASS | Preserve evidence summary |
| Accepted source provenance | PASS | Tag only `6214c031...` after approval |
| 48-hour CRAN matrix | IN PROGRESS | Refresh on or after 2026-08-01 10:20 PDT |
| Annotated tag | PENDING APPROVAL | Create only after matrix review |
| GitHub release | PENDING APPROVAL | Publish from verified tag |
| Issue #4 closure | PENDING APPROVAL | Close only after durable evidence is linked |

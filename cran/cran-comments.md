# CRAN Comments for engager 0.1.1

## Package Information

- **Package**: engager
- **Version**: 0.1.1
- **Submission type**: Update following the initial 0.1.0 release
- **Current status**: Forward-port validated locally; hosted checks and fresh-user
  QA pending; not approved for upload

## Release Summary

This release adds two public functions:

- `analyze_multi_session_attendance()` performs deterministic exact
  roster-based attendance analysis across multiple WebVTT sessions.
- `generate_attendance_report()` creates aggregate Markdown reports by
  default. Participant detail requires an explicit masking, hashing, or
  pseudonymization method; raw participant detail is not available.

The release does not add fuzzy matching, generic aggregate anonymization,
longitudinal student profiles, risk scoring, or new transcript formats.

## Candidate Reset

The earlier 0.1.1 candidate was fully validated before `engager` 0.1.0 was
accepted by CRAN:

- package-content commit:
  `645112b102f26aeaa57f1ffb8fed68ddb6c14987`;
- source-tarball SHA-256:
  `74c309818893c5938f7ee8ba3b623cee2501b390bf7b2b2038682d5f4c54f392`;
- full tests, installed-package UAT, tarball inspection, hosted checks,
  R-devel win-builder, and R-release win-builder passed for that artifact.

That artifact is now **superseded for release purposes** because the
CRAN-requested documentation and explicit-write remediation from 0.1.0 must be
forward-ported to the 0.1.1 source. The former checksum remains historical
provenance only and must not be uploaded or described as the current release
candidate.

## Forward-Port Boundary

The refreshed source must:

- preserve the exact 37-function 0.1.1 export allowlist;
- retain the approved multi-session attendance and report schemas;
- make beginner, quick, and batch analysis read-only by default;
- require explicit caller-selected destinations for file-writing operations;
- contain runnable examples and complete argument and return documentation;
- use only bundled synthetic fixtures and temporary validation destinations.

The forward-port adds no feature, dependency, export, transcript format,
privacy claim, or legal or institutional compliance determination.

## Validation Status

- [x] Generated documentation is current and the export allowlist is exactly 37
      functions
- [x] Full tests pass with no failures (68 expected warning-path assertions and
      5 documented skips)
- [x] Local `R CMD check --as-cran` completes with no errors or warnings and
      only explained notes
- [x] Default workflows create no files or directories without explicit paths
- [x] Explicit temporary destinations produce the expected artifacts
- [x] Source tarball builds and passes hygiene inspection (289 entries; no
      prohibited project, local, nested-archive, or generated artifacts)
- [x] Installed-package UAT passes, including attendance and reporting
- [ ] Required hosted Linux, Windows, macOS, `R-CMD-check`, and `Coverage` pass
- [ ] Fresh-user QA passes for the refreshed artifact
- [ ] Current R-devel and secondary remote checks pass near the release window
- [ ] A new exact source commit and SHA-256 are recorded
- [ ] Maintainer approves the exact refreshed checksum for promotion

No GO disposition, CRAN upload, tag, GitHub release, or release promotion is
authorized by this reset record.

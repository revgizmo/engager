# CRAN Comments for engager Package

## Package Information

- **Package**: engager
- **Version**: 0.1.0
- **Submission type**: Initial CRAN submission

## Test Environments

- **Local**: macOS Tahoe 26.5.2, R 4.5.3 (2026-03-11), aarch64-apple-darwin20
- **GitHub Actions baseline**: Ubuntu, Windows, and macOS with R release
- **Initial R-devel win-builder**: Windows Server 2022 x64, R Under development
  (2026-07-10 r90234 ucrt)

## CRAN Reviewer Response

The initial submission received this request from Uwe Ligges:

> Possibly misspelled words in DESCRIPTION:
> WebVTT (3:49, 10:5)
>
> Please single quote software names in both Title and Description fields
> of the DESCRIPTION file.
>
> Is there some reference about the method you can add in the Description
> field in the form Authors (year) <doi:10.....> or link tom the format in
> the form <https://.....>?

In response, the Title and Description now single-quote `WebVTT` and `Zoom`,
and the Description links to the W3C specification for the WebVTT format:
<https://www.w3.org/TR/webvtt1/>. The package calculates descriptive
transcript-derived participation metrics rather than implementing a named
published research method. `WebVTT` and `reviewable` were also added to the
package spelling wordlist.

## R CMD Check Results

- **Errors**: 0
- **Warnings**: 0
- **Notes**: 1

The package note is the expected informational `New submission` note. A
canonical local check with incoming feasibility disabled completed with 0
errors, 0 warnings, and 0 notes. A network-enabled check of the exact
replacement tarball completed with 0 errors, 0 warnings, and 2 notes: `New
submission` and the local machine's outdated HTML Tidy. The previously reported
`WebVTT` and `reviewable` spelling flags are no longer present.

## Reverse Dependencies

- **None** (new package)

## Additional Notes

- The full local test suite passes with 0 failures, 67 expected warnings, and
  5 documented skips. Four are diagnostic placeholder tests and one covers an
  internal empty-session-mapping edge case.
- An installed-package UAT installs the source tarball into an isolated library
  and exercises bundled synthetic transcript discovery, beginner and advanced
  workflows, name matching, privacy review, CSV/report outputs, onboarding
  guidance, the exact 35-function export allowlist, bounded identifier
  transformations, and all installed vignettes.
- Installed-package checks verify that plot labels are masked for `mask`,
  `privacy_standard`, and `privacy_strict`; labels remain visible only for the
  explicit `none` setting, and vector privacy input is normalized before
  masking.
- The UAT uses synthetic fixtures only and writes artifacts outside the source
  repository.
- Privacy-supporting defaults mask recognized structured identifier fields;
  free transcript text and contextual disclosure risks still require local
  review.
- Metric CSV exports omit raw transcript/comment text by default.
- Privacy and FERPA-oriented documentation is guidance only and does not
  certify legal or institutional compliance.
- The release-candidate tarball contains 270 entries. Inspection found no
  project-only release documents, development scripts, nested archives,
  `.Rcheck` directories, local libraries, generated UAT output, or private
  transcript/roster paths.
- The replacement release candidate was built from package-content commit
  `67918c4904c072e91f378f3bb3677d2ffdd35bda`. Its SHA-256 is
  `2a8087a2b315fac48de8fa8239465d7360152dacf0c725d803e5cdeb50ce6ae1`.
- Prior hosted baseline checks passed for R CMD check on Ubuntu,
  Windows, and macOS, lint, package coverage, and pkgdown Pages deployment.
  Overall coverage was 89.35%; coverage across the declared strategic exported
  API was 93.33%.
- The replacement installed-package UAT passed, and tarball inspection again
  found 270 clean entries with no project-only or private/local artifacts.
- The exact replacement tarball was submitted to R-devel win-builder; its
  emailed result is pending.

## Validation Status

- [x] Local tests passing
- [x] Local `R CMD check --as-cran` completed at 0/0/0
- [x] Examples and vignettes pass under `R CMD check`
- [x] Source tarball builds and installs successfully
- [x] Installed-package UAT passes
- [x] Tarball hygiene inspection passes
- [x] Release-surface remediation PR #566 merged with passing CI
- [x] Feature-surface hardening and final product-voice/privacy review complete
- [ ] Replacement R-devel win-builder check complete
- [ ] Maintainer final release disposition recorded

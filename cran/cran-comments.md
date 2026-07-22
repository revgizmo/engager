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
- **Replacement R-devel win-builder**: Windows Server 2022 x64, R Under
  development (2026-07-12 r90242 ucrt)
- **Remediation R-devel win-builder**: Windows Server 2022 x64, R Under
  development (2026-07-20 r90283 ucrt)

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

## Subsequent CRAN Reviewer Response

The resubmission received the following documentation and write-safety request
from Konstanze Lauseker:

> Please add \value to .Rd files regarding exported methods and explain the
> functions results in the documentation. Please write about the structure of
> the output (class) and also what the output means. (If a function does not
> return a value, please document that too, e.g. \value{No return value, called
> for side effects} or similar)
>
> You have examples for unexported functions. Please either omit these examples
> or export these functions.
>
> Some code lines in examples are commented out. Please never do that. Ideally
> find toy examples that can be regularly executed and checked.
>
> Please unwrap the examples if they are executable in < 5 sec, or replace
> \dontrun{} with \donttest{}.
>
> Please ensure that your functions do not write by default or in your
> examples/vignettes/tests in the user's home filespace (including the package
> directory and getwd()). This is not allowed by CRAN policies. Please omit any
> default path in writing functions. In your examples/vignettes/tests you can
> write to tempdir().

In response, all 35 exported functions now document the class, structure, and
meaning of their return values or their console side effects. Examples were
removed from unexported functions. All remaining examples are runnable with
bundled synthetic fixtures and temporary destinations; no `\dontrun{}` or
commented executable examples remain. Analysis workflows now return results in
memory without writing by default, and writer functions require an explicit
destination. Tests cover the documentation contract, default no-write behavior,
explicit writer failures and success paths, temporary test destinations, and
source-tarball metadata exclusions.

## R CMD Check Results

- **Errors**: 0
- **Warnings**: 0
- **Notes**: 1

The package note is the expected informational `New submission` note. A
canonical local check with incoming feasibility disabled completed with 0
errors, 0 warnings, and 0 notes. A network-enabled check of the exact
replacement tarball completed with 0 errors, 0 warnings, and 2 notes: `New
submission` and the local machine's outdated HTML Tidy. Replacement R-devel
win-builder completed with 0 errors, 0 warnings, and 1 incoming-feasibility
note: `New submission` plus `reviewable` as a possible misspelling. `reviewable`
is an intentional English word. The reviewer-reported `WebVTT` flag is no
longer present.

The exact documentation/write-safety remediation tarball completed local
`R CMD check --as-cran --no-manual` with 0 errors, 0 warnings, and 2
environment-only notes: network access was unavailable for incoming URL checks,
and the local environment could not verify the current time. Package
installation, code/documentation consistency, examples, tests, and vignettes
all passed.

The exact merged-`main` remediation tarball completed R-devel win-builder with
0 errors, 0 warnings, and 1 incoming-feasibility note: `New submission` plus
`reviewable` as a possible misspelling. `reviewable` is intentional. Package
installation, examples, 2,573 test expectations, vignettes, and PDF/HTML manuals
passed on Windows Server 2022; the 64 expected warnings and 27 documented
CRAN/platform skips did not become package-check warnings.

## Reverse Dependencies

- **None** (new package)

## Additional Notes

- The full local test suite passes with 0 failures, 68 expected warnings, and
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
- The prior replacement release-candidate tarball contained 270 entries.
  Inspection found no
  project-only release documents, development scripts, nested archives,
  `.Rcheck` directories, local libraries, generated UAT output, or private
  transcript/roster paths.
- The prior replacement release candidate was built from package-content commit
  `67918c4904c072e91f378f3bb3677d2ffdd35bda`. Its SHA-256 is
  `2a8087a2b315fac48de8fa8239465d7360152dacf0c725d803e5cdeb50ce6ae1`.
- Prior hosted baseline checks passed for R CMD check on Ubuntu,
  Windows, and macOS, lint, package coverage, and pkgdown Pages deployment.
  Overall coverage was 89.35%; coverage across the declared strategic exported
  API was 93.33%.
- The replacement installed-package UAT passed, and tarball inspection again
  found 270 clean entries with no project-only or private/local artifacts.
- The exact replacement tarball passed R-devel win-builder installation,
  examples, tests, vignettes, and PDF/HTML manual checks.
- The final documentation/write-safety remediation artifact was built from
  exact merged-`main` commit `6214c0316d39154140bdba064266119007bff41a`.
  Its SHA-256 is
  `21e6ecddeed86dad177708d7b7f3bf1df79059f769dedc0e0439e995e2fa5e74`.
- The remediation tarball contains 270 entries. Inspection found no Git
  worktree metadata, project-only release documents, development scripts,
  nested archives, `.Rcheck` directories, local libraries, generated UAT
  output, or private transcript/roster paths. The bundled
  `example_section_names_lookup.csv` remains a synthetic installed fixture.
- The exact remediation tarball passed installed-package UAT in an isolated
  library, including the 35-function export allowlist, synthetic beginner and
  advanced workflows, name matching, identifier transformation, plots,
  explicit CSV/report writes, and installed vignette discovery.
- Optional beginner-workflow output directories and the internal section-name
  lookup writer now reject malformed destinations before creating files or
  directories. Runnable UX examples restore the caller's option state, and a
  syntax-aware test gate checks common filesystem writers for literal
  destinations.

## Validation Status

- [x] Local tests passing
- [x] Exact remediation tarball completed local `R CMD check --as-cran` at
  0 errors, 0 warnings, and 2 environment-only notes
- [x] Examples and vignettes pass under `R CMD check`
- [x] Source tarball builds and installs successfully
- [x] Installed-package UAT passes
- [x] Tarball hygiene inspection passes
- [x] Release-surface remediation PR #566 merged with passing CI
- [x] Feature-surface hardening and final product-voice/privacy review complete
- [x] Replacement R-devel win-builder check complete
- [x] Remediation R-devel win-builder check complete
- [ ] Maintainer final release disposition recorded

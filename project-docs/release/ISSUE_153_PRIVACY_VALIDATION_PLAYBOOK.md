# Issue #153 Privacy Validation Playbook

Purpose: validate that `engager` can be run on institutionally authorized
real-world data without leaking raw or identifiable data into package files,
CRAN artifacts, or shareable outputs.

This is a privacy-oriented release validation. It is not legal advice and does
not certify FERPA compliance.

## 1. Reviewer Prerequisites

The reviewer should be a competent R user with:

- Authorized access to the validation transcript and roster data.
- Permission to run local analysis under institutional policy.
- Ability to inspect CSV, plot, report, and log outputs for identifiers.
- No need for GitHub issue, label, PR, or CRAN access.

Do not put raw validation data in the package repository.

## 2. Local Setup

Clone or open the repository, then switch to the release branch:

```sh
cd /path/to/zoomstudentengagement
git fetch --all --prune
git switch codex/cran-gate-reconciliation
git status --short
```

Confirm `git status --short` does not show raw data files you added.

Install or check dependencies:

```r
install.packages(c("devtools", "testthat", "readr", "dplyr", "tibble"))
devtools::load_all()
```

## 3. Prepare A Private Working Directory

Create a directory outside the repository:

```r
validation_dir <- "~/engager-153-validation"
dir.create(validation_dir, recursive = TRUE, showWarnings = FALSE)

data_dir <- file.path(validation_dir, "private-inputs")
output_dir <- file.path(validation_dir, "outputs")
dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
```

Place institutionally authorized files in `private-inputs/`, for example:

```text
~/engager-153-validation/private-inputs/
  session1.vtt
  session2.vtt
  roster.csv
```

Do not copy these files into the package repository.

## 4. Record Non-Sensitive Run Metadata

Fill this in before running:

```r
validation_record <- list(
  reviewer = "<name/role>",
  review_date = as.character(Sys.Date()),
  institution_or_unit = "<non-sensitive unit name or omit>",
  repo_branch = system("git branch --show-current", intern = TRUE),
  repo_commit = system("git rev-parse HEAD", intern = TRUE),
  data_authorized = "<yes/no + short non-sensitive note>",
  privacy_level = "privacy_strict"
)

str(validation_record)
```

## 5. Run Package Validation

Use the strictest practical package privacy setting unless there is a documented
reason not to.

```r
library(engager)

set_privacy_defaults("privacy_strict")

transcript_files <- list.files(
  data_dir,
  pattern = "[.]vtt$",
  full.names = TRUE
)

stopifnot(length(transcript_files) > 0)

roster_path <- file.path(data_dir, "roster.csv")
stopifnot(file.exists(roster_path))

roster <- readr::read_csv(roster_path, show_col_types = FALSE)
```

Run a small transcript processing pass:

```r
processed <- lapply(transcript_files, function(path) {
  raw <- load_zoom_transcript(path)
  processed <- process_zoom_transcript(raw)
  metrics <- summarize_transcript_metrics(processed)
  ensure_privacy(metrics, privacy_level = "privacy_strict")
})

names(processed) <- basename(transcript_files)
```

Write outputs only to the private validation output directory:

```r
for (nm in names(processed)) {
  safe_name <- gsub("[^A-Za-z0-9_.-]", "_", nm)
  readr::write_csv(
    processed[[nm]],
    file.path(output_dir, paste0(safe_name, "_metrics.csv"))
  )
}
```

Run privacy checks on generated objects:

```r
privacy_checks <- lapply(processed, function(x) {
  validate_privacy_compliance(
    x,
    privacy_level = "privacy_strict",
    stop_on_violation = FALSE
  )
})

print(privacy_checks)
```

Optional FERPA-oriented helper review:

```r
ferpa_reviews <- lapply(processed, function(x) {
  validate_ferpa_compliance(x)
})

lapply(ferpa_reviews, function(x) {
  list(
    compliant = x$compliant,
    pii_detected = x$pii_detected,
    recommendations = x$recommendations
  )
})
```

## 6. Manual Output Review

Inspect every file under:

```r
output_dir
```

Check for:

- Student names.
- Instructor names, if not intended for sharing.
- Email addresses.
- Student IDs or SIS/LMS IDs.
- Meeting IDs.
- Phone numbers.
- Addresses.
- Course section identifiers that would expose a small group.
- Small-cell outputs, especially counts of 1 or 2.
- Raw transcript text that includes identifiable context.
- Logs or temp files containing raw rows.

Useful local scan:

```r
output_files <- list.files(output_dir, recursive = TRUE, full.names = TRUE)

identifier_patterns <- c(
  email = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}",
  phone = "\\b\\(?[0-9]{3}\\)?[-. ]?[0-9]{3}[-. ]?[0-9]{4}\\b",
  likely_id = "\\b[0-9]{6,}\\b"
)

scan_results <- lapply(output_files, function(path) {
  txt <- paste(readLines(path, warn = FALSE), collapse = "\n")
  hits <- vapply(identifier_patterns, grepl, logical(1), x = txt)
  data.frame(file = path, pattern = names(hits), hit = as.logical(hits))
})

scan_results <- do.call(rbind, scan_results)
subset(scan_results, hit)
```

A clean scan is helpful but not sufficient. Manual review is still required.

## 7. Confirm Package Surface Is Clean

From the repository root, build and inspect the tarball:

```sh
R CMD build .
```

Then in R:

```r
tarball <- list.files(pattern = "^engager_.*[.]tar[.]gz$", full.names = TRUE)
tarball <- tarball[order(file.info(tarball)$mtime, decreasing = TRUE)][1]

files <- utils::untar(tarball, list = TRUE)
rel <- sub("^engager/", "", files)

bad <- rel == ".DS_Store" |
  endsWith(rel, "/.DS_Store") |
  startsWith(rel, "engager.Rcheck/") |
  endsWith(rel, ".backup") |
  endsWith(rel, "~") |
  startsWith(rel, "inst/extdata/transcripts/") |
  rel %in% c(
    "inst/extdata/roster.csv",
    "inst/extdata/transcripts_summary.csv",
    "inst/extdata/transcripts_session_summary.csv",
    "inst/new_analysis_template.Rmd",
    "inst/Zoom_Student_Engagement_Analysis_student_summary_report.Rmd",
    "inst/Zoom_Student_Engagement_Analysis_student_summary_report.Rmd.backup"
  )

files[bad]
```

Expected result:

```r
character(0)
```

## 8. Do Not Share Sensitive Evidence

Do not attach or paste:

- Raw transcripts.
- Rosters.
- Named output rows.
- Screenshots with identifiers.
- Meeting IDs.
- Local paths that reveal sensitive course names, if applicable.

Share only summary evidence.

## 9. Final Sign-Off Template

Complete this text:

```text
For issue #153, I reviewed a real-world, institutionally authorized validation
run for engager.

Reviewer:
Review date:
Branch:
Commit:
Privacy level used:
Input data location: private local/institutional storage only
Output review location: private local/institutional storage only

I confirm:
- The validation data was authorized for this review.
- The reviewer had appropriate access under local policy.
- Raw transcripts and rosters were kept outside the package repository.
- Generated outputs were reviewed for direct identifiers.
- Generated outputs were reviewed for indirect or small-cell disclosure risks.
- CSVs, plots/reports if generated, logs, and temporary outputs were considered.
- Sensitive validation evidence remains outside GitHub, CRAN, and the package repository.
- The package tarball was checked for raw or institution-specific data.
- Retention/disposal expectations were reviewed under local policy.

Decision:
[ ] Approved for CRAN release privacy gate
[ ] Not approved
[ ] Approved after follow-ups listed below

Follow-ups or limitations:
-

This is a release privacy review summary, not a legal compliance certification.
```


- [engager](#engager)
  - [Documentation](#documentation)
  - [Quick Start](#quick-start)
    - [Installation](#installation)
    - [One-function beginner workflow](#one-function-beginner-workflow)
    - [Composable workflow](#composable-workflow)
    - [Multi-session attendance and
      reports](#multi-session-attendance-and-reports)
  - [Vignettes](#vignettes)
  - [What the Package Does](#what-the-package-does)
  - [Key Functions](#key-functions)
    - [Core Processing](#core-processing)
    - [Data Management](#data-management)
    - [Name Matching (Exact MVP)](#name-matching-exact-mvp)
    - [Analysis and Visualization](#analysis-and-visualization)
    - [Multi-Session Attendance and
      Reports](#multi-session-attendance-and-reports-1)
    - [Diagnostics](#diagnostics)
  - [Typical Workflow](#typical-workflow)
  - [Privacy Defaults](#privacy-defaults)
  - [Contributing](#contributing)
  - [License](#license)
  - [Links](#links)

<!-- README.md is generated from README.Rmd. Please edit that file -->

> **Note:** This README.md is automatically generated from README.Rmd.
> After making changes to README.Rmd, run `devtools::build_readme()` to
> update the README.md.

# engager

<!-- badges: start -->

[![coverage](https://img.shields.io/github/actions/workflow/status/revgizmo/engager/coverage.yaml?branch=main&label=coverage)](https://github.com/revgizmo/engager/actions/workflows/coverage.yaml)
<!-- badges: end -->

`engager` analyzes participation in Zoom WebVTT transcripts and produces
privacy-supporting metrics, summaries, plots, and export files for
instructor review.

## Documentation

- **Installed help**: run `help(package = "engager")`
- **Package vignettes**: run `browseVignettes(package = "engager")`
- **[Issue tracker and contribution
  discussion](https://github.com/revgizmo/engager/issues)**

## Quick Start

### Installation

``` r
devtools::install_github("revgizmo/engager")
```

### One-function beginner workflow

``` r
library(engager)

transcript_file <- system.file(
  "extdata/test_transcripts/intro_statistics_week1.vtt",
  package = "engager"
)
results <- basic_transcript_analysis(
  transcript_file,
  output_dir = tempfile("engager-basic-")
)
head(results$analysis)
print(results$plots)
```

### Composable workflow

``` r
library(engager)

transcript_file <- system.file(
  "extdata/test_transcripts/intro_statistics_week1.vtt",
  package = "engager"
)

# Load and process once
transcript <- load_zoom_transcript(transcript_file)
processed <- process_zoom_transcript(transcript_df = transcript)

# Summarize the processed data
metrics <- summarize_transcript_metrics(
  transcript_df = processed,
  names_exclude = c("dead_air")
)

# Plot and export with privacy-supporting defaults
plot <- plot_users(metrics, metric = "n", facet_by = "none", mask_by = "name")
print(plot)
invisible(write_metrics(
  metrics,
  what = "engagement",
  path = tempfile(fileext = ".csv")
))
```

### Multi-session attendance and reports

Use the bundled synthetic attendance fixtures to try the complete course
workflow. The analysis object contains local roster identifiers and
should be treated as sensitive working data. The default report is
aggregate and contains no participant identifiers or transcript text.

``` r
attendance_dir <- system.file(
  "extdata/attendance-contract",
  package = "engager"
)
roster <- utils::read.csv(
  file.path(attendance_dir, "roster.csv"),
  stringsAsFactors = FALSE
)
roster$eligible <- tolower(roster$eligible) == "true"
sessions <- data.frame(
  session_id = sprintf("session-%02d", 1:3),
  transcript_file = file.path(
    attendance_dir,
    sprintf("session-%02d.vtt", 1:3)
  ),
  status = "recorded",
  session_at = as.POSIXct(
    c(
      "2026-01-10 09:00:00",
      "2026-01-17 09:00:00",
      "2026-01-24 09:00:00"
    ),
    tz = "UTC"
  )
)

attendance <- suppressWarnings(analyze_multi_session_attendance(
  sessions,
  roster,
  min_attendance_threshold = 2 / 3
))

aggregate_report <- generate_attendance_report(attendance)
cat(aggregate_report, sep = "\n")

# Participant detail is available only with an explicit transformation.
masked_report <- generate_attendance_report(
  attendance,
  detail = "participant",
  identifier_method = "mask"
)
```

## Vignettes

For detailed workflows and examples, see the package vignettes:

- **Getting Started**: see
  `vignette("getting-started", package = "engager")`
- **Plotting and Analysis**: see
  `vignette("plotting", package = "engager")`
- **Essential Functions**: see
  `vignette("essential-functions", package = "engager")`
- **Privacy, Ethics, and Institutional Review**: see
  `vignette("privacy-ethics-review", package = "engager")`

## What the Package Does

The `engager` package provides tools for:

1.  **Loading and Processing Zoom Transcripts**: Convert Zoom
    .transcript.vtt files into analyzable data
2.  **Calculating Engagement Metrics**: Measure participation by
    speaker/student
3.  **Name Matching and Cleaning**: Match transcript names to student
    rosters
4.  **Visualization**: Create plots to analyze participation patterns
5.  **Multi-Session Attendance**: Analyze exact roster attendance with
    explicit denominator and unmatched-speaker semantics
6.  **Exporting**: Write privacy-supporting participation metrics,
    summaries, and aggregate attendance reports

**Note**: The package specifically processes `.transcript.vtt` files
(the canonical Zoom transcript files). Other Zoom file types like
`.cc.vtt` (closed captions) and `.newChat.txt` (chat logs) are not
currently supported but may be added in future versions.

## Key Functions

### Core Processing

- `load_zoom_transcript()` - Load raw Zoom transcript files
  (.transcript.vtt)
- `process_zoom_transcript()` - Process and consolidate transcript data
- `summarize_transcript_metrics()` - Calculate engagement metrics
- `summarize_transcript_files()` - Batch process multiple transcripts

### Data Management

- `load_roster()` - Load student enrollment data
- `detect_unmatched_names()` - Identify transcript names that need
  review
- `match_names_workflow()` - Apply the supported exact name-matching
  workflow

### Name Matching (Exact MVP)

Use `match_names_workflow()` for exact hash-based matching:

``` r
library(engager)
roster <- tibble::tibble(
  preferred_name = c("Alice Smith", "Bob Jones"),
  student_id = c("S1", "S2"),
  aliases = c("A Smith; Alice S", NA_character_)
)
transcripts <- tibble::tibble(
  speaker = c("alice smith", "carol"),
  timestamp = as.POSIXct(c("2025-01-01 10:00:00", "2025-01-01 10:01:00"), tz = "UTC")
)
res <- match_names_workflow(transcripts, roster, options = list(match_strategy = "exact"))
res
```

### Analysis and Visualization

- `plot_users()` - Unified plotting with privacy-aware options
- `summarize_transcript_files()` - Generate metrics for multiple
  transcript files

### Multi-Session Attendance and Reports

- `analyze_multi_session_attendance()` - Analyze exact roster attendance
  across sessions
- `generate_attendance_report()` - Generate aggregate Markdown by
  default or explicitly transformed participant detail

### Diagnostics

Most functions are quiet by default to keep examples/tests clean. You
can enable optional diagnostics:

``` r
# Enable package-wide diagnostics
options(engager.verbose = TRUE)

# Run an exported workflow with diagnostics enabled
summarize_transcript_metrics(transcript_file_path = transcript_file)

# Turn diagnostics back off
options(engager.verbose = FALSE)
```

## Typical Workflow

1.  **Setup**: Configure analysis parameters
2.  **Load Transcripts**: Import and process Zoom transcript files
3.  **Load Roster**: Import student enrollment data
4.  **Clean Names**: Match transcript names to student records
5.  **Analyze**: Calculate metrics and create visualizations
6.  **Export**: Write privacy-supporting metrics and summaries; save
    returned plot objects explicitly

Multi-session attendance reports are reviewable and aggregate by
default; participant detail requires an explicit masking, hashing, or
pseudonymization method. The package does not provide longitudinal
individual-student reporting or risk scoring.

## Privacy Defaults

This package uses privacy-supporting defaults. On load, it sets the
session option `engager.privacy_level` to `"mask"` (unless you set it
yourself). Supported summaries, plots, and writers use this option to
mask recognized structured identifier columns with labels such as
`Student 01`. Masking does not redact names or other identifiers
embedded in free transcript text, and it is not a legal or institutional
compliance determination.

To change the option temporarily for an authorized workflow, save and
restore its prior value:

``` r
library(engager)
old_privacy_level <- getOption("engager.privacy_level", "mask")
options(engager.privacy_level = "none")
# ... analysis that may include identifiable outputs ...
options(engager.privacy_level = old_privacy_level)
```

Common structured fields considered for masking include
`preferred_name`, `name`, `first_last`, `name_raw`, `student_id`, and
`email`. Inspect all outputs before storing or sharing them.

See `vignette("privacy-ethics-review", package = "engager")` for
privacy, ethics, and institutional review considerations.

## Contributing

We welcome contributions. Start with the [issue
tracker](https://github.com/revgizmo/engager/issues).

## License

This package is licensed under the MIT License. See the CRAN license
stub in [LICENSE](LICENSE); the standard MIT terms accompany the
distributed package.

## Links

- **GitHub Repository**: <https://github.com/revgizmo/engager>
- **Issues**: <https://github.com/revgizmo/engager/issues>

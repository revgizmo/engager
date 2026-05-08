
- [engager](#engager)
  - [📚 Documentation](#books-documentation)
  - [🚀 Quick Start](#rocket-quick-start)
    - [Installation](#installation)
    - [5-minute whole-game example](#5-minute-whole-game-example)
    - [Basic Example](#basic-example)
  - [📖 Vignettes](#open_book-vignettes)
  - [🎯 What the Package Does](#dart-what-the-package-does)
  - [🔧 Key Functions](#wrench-key-functions)
    - [Core Processing](#core-processing)
    - [Data Management](#data-management)
    - [Name Matching (Exact MVP)](#name-matching-exact-mvp)
    - [Analysis and Visualization](#analysis-and-visualization)
    - [Diagnostics and interactive
      prompts](#diagnostics-and-interactive-prompts)
  - [📊 Typical Workflow](#bar_chart-typical-workflow)
  - [🔒 Privacy Defaults](#lock-privacy-defaults)
  - [Development](#development)
    - [Pull Request Review](#pull-request-review)
  - [🤝 Contributing](#handshake-contributing)
  - [📄 License](#page_facing_up-license)
  - [🔗 Links](#link-links)

<!-- README.md is generated from README.Rmd. Please edit that file -->

> **Note:** This README.md is automatically generated from README.Rmd.
> After making changes to README.Rmd, run `devtools::build_readme()` to
> update the README.md.

# engager

**Note:** Renamed from `zoomstudentengagement` to `engager` (no API
changes).

<!-- badges: start -->

[![coverage](https://img.shields.io/github/actions/workflow/status/revgizmo/engager/coverage.yaml?branch=main&label=coverage)](https://github.com/revgizmo/engager/actions/workflows/coverage.yaml)
<!-- badges: end -->

The goal of `engager` is to allow instructors to gain insights into
student engagement, with a particular focus on participation equity,
from Zoom transcripts of recorded course sessions.

## 📚 Documentation

- **[docs/README.md](docs/README.md)** - Complete documentation index
- **[docs/features/feature-index.md](docs/features/feature-index.md)** -
  Comprehensive feature documentation
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute
- **[docs/development/ISSUE_MANAGEMENT_QUICK_REFERENCE.md](docs/development/ISSUE_MANAGEMENT_QUICK_REFERENCE.md)** -
  Quick guide for issue management

## 🚀 Quick Start

### Installation

``` r
devtools::install_github("revgizmo/engager")
```

### 5-minute whole-game example

``` r
library(engager)

# 1) Compute metrics for a single transcript
transcript_file <- system.file(
  "extdata/test_transcripts/intro_statistics_week1.vtt",
  package = "engager"
)
metrics <- summarize_transcript_metrics(transcript_file_path = transcript_file)

# 2) Plot one metric with privacy-supporting defaults
#    (outputs a bar chart with a minimal theme)
plot <- plot_users(metrics, metric = "session_ct", facet_by = "none", mask_by = "name")
print(plot)

# 3) Write masked metrics to CSV
invisible(write_metrics(metrics, what = "engagement", path = "engagement_metrics.csv"))
```

### Basic Example

``` r
library(engager)

# Load and process a transcript
transcript_file <- system.file(
  "extdata/test_transcripts/intro_statistics_week1.vtt",
  package = "engager"
)

# Calculate engagement metrics
metrics <- summarize_transcript_metrics(
  transcript_file_path = transcript_file,
  names_exclude = c("dead_air")
)

# View results
head(metrics)
```

## 📖 Vignettes

For detailed workflows and examples, see the package vignettes:

- **Getting Started**: see
  `vignette("getting-started", package = "engager")`
- **Plotting and Analysis**: see
  `vignette("plotting", package = "engager")`
- **Essential Functions**: see
  `vignette("essential-functions", package = "engager")`
- **Privacy and Ethical Use**: see
  `vignette("ferpa-ethics", package = "engager")`

## 🎯 What the Package Does

The `engager` package provides tools for:

1.  **Loading and Processing Zoom Transcripts**: Convert Zoom
    .transcript.vtt files into analyzable data
2.  **Calculating Engagement Metrics**: Measure participation by
    speaker/student
3.  **Name Matching and Cleaning**: Match transcript names to student
    rosters
4.  **Visualization**: Create plots to analyze participation patterns
5.  **Reporting**: Generate individual student reports

**Note**: The package specifically processes `.transcript.vtt` files
(the canonical Zoom transcript files). Other Zoom file types like
`.cc.vtt` (closed captions) and `.newChat.txt` (chat logs) are not
currently supported but may be added in future versions.

## 🔧 Key Functions

### Core Processing

- `load_zoom_transcript()` - Load raw Zoom transcript files
  (.transcript.vtt)
- `process_zoom_transcript()` - Process and consolidate transcript data
- `summarize_transcript_metrics()` - Calculate engagement metrics
- `summarize_transcript_files()` - Batch process multiple transcripts

### Data Management

- `load_roster()` - Load student enrollment data
- `make_clean_names_df()` - Match transcript names to student records
- `create_session_mapping()` - Map recordings to courses (advanced)

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
- `make_transcripts_summary_df()` - Generate summary statistics

### Diagnostics and interactive prompts

Most functions are quiet by default to keep examples/tests clean. You
can enable optional diagnostics:

``` r
# Enable package-wide diagnostics
options(engager.verbose = TRUE)

# Or enable per-call diagnostics where supported
load_zoom_recorded_sessions_list(
  data_folder = ".",
  transcripts_folder = "transcripts",
  verbose = TRUE
)

# Turn diagnostics back off
options(engager.verbose = FALSE)
```

Interactive prompts (e.g., in `create_session_mapping()` when assigning
unmatched recordings) are only shown in interactive sessions. In
non-interactive runs (e.g., CI), prompts are suppressed and a quiet
fallback is used.

See also: `CONTRIBUTING.md` Diagnostic Output Policy.

## 📊 Typical Workflow

1.  **Setup**: Configure analysis parameters
2.  **Load Transcripts**: Import and process Zoom transcript files
3.  **Load Roster**: Import student enrollment data
4.  **Clean Names**: Match transcript names to student records
5.  **Analyze**: Calculate metrics and create visualizations
6.  **Report**: Generate insights and reports

## 🔒 Privacy Defaults

This package uses privacy-supporting defaults. On load, it sets the
global option `engager.privacy_level` to `"mask"` (unless you set it
yourself). This means identifiers like names and student IDs are masked
to labels such as `Student 01` in summaries, plots, and writers.

To change behavior temporarily (not recommended for student data):

``` r
library(engager)
set_privacy_defaults("none")  # will emit a warning
# ... analysis that may include identifiable outputs ...
set_privacy_defaults("mask")  # restore safe default
```

Masked by default: `preferred_name`, `name`, `first_last`, `name_raw`,
`student_id`, `email`.

See `vignette("ferpa-ethics", package = "engager")` for privacy and
ethical use guidance.

## Development

### Pull Request Review

This project uses a lightweight PR review process focused on CRAN
submission readiness and privacy risk review. See
[CONTRIBUTING.md](CONTRIBUTING.md) for the review checklist and
criteria.

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md)
for details.

## 📄 License

This package is licensed under the MIT License. See the CRAN stub in
[LICENSE](LICENSE) and the full text in [LICENSE.md](LICENSE.md).

## 🔗 Links

- **GitHub Repository**: <https://github.com/revgizmo/engager>
- **Issues**: <https://github.com/revgizmo/engager/issues>
- **Project Status**:
  [docs/development/PROJECT.md](docs/development/PROJECT.md)

test_that("tests do not leave artifacts in working directory", {
  # Create and remove a temp file to ensure cleanup patterns work
  tmp <- tempfile("zse_artifact_", fileext = ".txt")
  writeLines("test", tmp)
  expect_true(file.exists(tmp))
  unlink(tmp)
  expect_false(file.exists(tmp))

  # Default analysis must not create this historical output in getwd().
  expect_false(file.exists("engagement_metrics.csv"))
})

test_that("CRAN build surface excludes local and institution-specific artifacts", {
  package_root <- normalizePath(test_path("../.."), mustWork = TRUE)
  build_ignore_path <- file.path(package_root, ".Rbuildignore")
  skip_if_not(file.exists(build_ignore_path), ".Rbuildignore is only available in the source tree")

  build_ignore <- readLines(build_ignore_path, warn = FALSE)
  build_ignore <- build_ignore[nzchar(build_ignore)]
  build_ignore <- build_ignore[!startsWith(trimws(build_ignore), "#")]

  expect_ignored <- function(path) {
    expect_true(
      any(vapply(build_ignore, function(pattern) grepl(pattern, path, perl = TRUE), logical(1))),
      info = paste("Expected .Rbuildignore to exclude", path)
    )
  }

  disallowed_paths <- c(
    "inst/extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt",
    "inst/extdata/transcripts/GMT20240124-202901_Recording.cc.vtt",
    "inst/extdata/transcripts/zoomus_recordings__20240124.csv",
    "inst/extdata/roster.csv",
    "inst/extdata/section_names_lookup.csv",
    "inst/extdata/transcripts_summary.csv",
    "inst/extdata/transcripts_session_summary.csv",
    "inst/new_analysis_template.Rmd",
    "inst/Zoom_Student_Engagement_Analysis_student_summary_report.Rmd",
    "inst/Zoom_Student_Engagement_Analysis_student_summary_report.Rmd.backup",
    "engager.Rcheck/00check.log",
    "project-docs/release/CRAN_VALIDATION_REPORT.md",
    "cran/cran-comments.md",
    ".github/workflows/coverage.yaml",
    ".DS_Store"
  )

  invisible(lapply(disallowed_paths, expect_ignored))

  cran_facing_files <- c(
    file.path(package_root, "README.md"),
    list.files(file.path(package_root, "R"), pattern = "[.]R$", recursive = TRUE, full.names = TRUE),
    list.files(file.path(package_root, "vignettes"), pattern = "[.]Rmd$", recursive = TRUE, full.names = TRUE)
  )
  cran_facing_text <- paste(unlist(lapply(cran_facing_files, readLines, warn = FALSE)), collapse = "\n")

  expect_false(grepl("extdata/transcripts/GMT20240124-202901_Recording[.]transcript[.]vtt", cran_facing_text))
})

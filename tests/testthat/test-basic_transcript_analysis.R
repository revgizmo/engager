test_that("basic_transcript_analysis errors when file missing", {
  missing <- tempfile(fileext = ".vtt")
  expect_false(file.exists(missing))
  expect_error(
    basic_transcript_analysis(missing, tempfile()),
    "File not found"
  )
})

test_that("basic_transcript_analysis creates output dir and returns structured result", {
  withr::local_options(engager.privacy_level = "mask")
  # Prepare a temp file path and output dir
  tf <- tempfile(fileext = ".vtt")
  writeLines(c("WEBVTT", "\n", "00:00:00.000 --> 00:00:01.000", "Hello"), tf)
  outdir <- file.path(tempdir(), paste0("out_", as.integer(runif(1, 1, 1e6))))
  expect_false(dir.exists(outdir))

  fake_transcript <- tibble::tibble(
    name = c("Alice", "Bob"),
    comment = c("Hi", "There"),
    start = c(0, 1),
    end = c(1, 2),
    duration = c(1, 1),
    wordcount = c(1, 1)
  )
  fake_processed <- fake_transcript
  fake_analysis <- tibble::tibble(user = c("Alice", "Bob"), metric = c(1, 2))
  fake_plots <- list()

  with_mocked_bindings(
    load_zoom_transcript = function(path) {
      expect_true(file.exists(path))
      fake_transcript
    },
    process_zoom_transcript = function(transcript_file_path = "", transcript_df = NULL, ...) {
      expect_equal(transcript_file_path, "")
      expect_true(is.data.frame(transcript_df))
      fake_processed
    },
    summarize_transcript_metrics = function(transcript_file_path = "", transcript_df = NULL, ...) {
      expect_equal(transcript_file_path, "")
      expect_true(is.data.frame(transcript_df))
      fake_analysis
    },
    plot_users = function(analysis, metric, student_col, facet_by, privacy_level, ...) {
      expect_true(is.data.frame(analysis))
      expect_equal(metric, "wordcount")
      expect_equal(student_col, "name")
      expect_equal(facet_by, "none")
      expect_equal(privacy_level, "none")
      fake_plots
    },
    write_metrics = function(analysis, what, path, privacy_level, comments_policy, ...) {
      expect_true(is.data.frame(analysis))
      expect_equal(what, "engagement")
      expect_equal(path, file.path(outdir, "engagement_metrics.csv"))
      expect_equal(privacy_level, "privacy_strict")
      expect_equal(comments_policy, "omit")
      invisible(NULL)
    },
    {
      res <- basic_transcript_analysis(tf, outdir, privacy_level = "high")
      expect_true(dir.exists(outdir))
      expect_type(res, "list")
      expect_true(all(c("analysis", "plots", "output_dir", "transcript_file", "privacy_level") %in% names(res)))
      expect_equal(res$output_dir, outdir)
      expect_equal(res$transcript_file, tf)
      expect_equal(res$privacy_level, "high")
      expect_equal(getOption("engager.privacy_level"), "mask")
    }
  )
})

test_that("basic_transcript_analysis runs the installed synthetic workflow", {
  withr::local_options(engager.privacy_level = "mask")
  transcript_file <- system.file(
    "extdata/test_transcripts/ideal_course_session1.vtt",
    package = "engager"
  )
  expect_true(nzchar(transcript_file))
  output_dir <- withr::local_tempdir()
  raw_names <- unique(load_zoom_transcript(transcript_file)$name)

  result <- basic_transcript_analysis(transcript_file, output_dir, privacy_level = "high")

  expect_s3_class(result$analysis, "tbl_df")
  expect_gt(nrow(result$analysis), 0)
  expect_s3_class(result$plots, "ggplot")
  output_path <- file.path(output_dir, "engagement_metrics.csv")
  expect_true(file.exists(output_path))
  exported <- utils::read.csv(output_path, check.names = FALSE)
  expect_gt(nrow(exported), 0)
  expect_false("comments" %in% names(exported))
  export_text <- tolower(paste(unlist(exported), collapse = "\n"))
  identifier_hits <- raw_names[vapply(
    raw_names,
    function(name) grepl(tolower(name), export_text, fixed = TRUE),
    logical(1)
  )]
  expect_length(identifier_hits, 0)
  expect_equal(result$plots$data$name, result$analysis$name)
  expect_equal(getOption("engager.privacy_level"), "mask")
})

test_that("basic workflow keeps medium and low exports masked", {
  withr::local_options(engager.privacy_level = "mask")
  transcript_file <- system.file(
    "extdata/test_transcripts/ideal_course_session1.vtt",
    package = "engager"
  )
  raw_names <- unique(load_zoom_transcript(transcript_file)$name)
  output_root <- withr::local_tempdir()

  for (level in c("medium", "low")) {
    result <- basic_transcript_analysis(
      transcript_file,
      file.path(output_root, level),
      privacy_level = level
    )
    output_path <- file.path(output_root, level, "engagement_metrics.csv")
    exported <- utils::read.csv(output_path, check.names = FALSE)
    export_text <- tolower(paste(unlist(exported), collapse = "\n"))
    identifier_hits <- raw_names[vapply(
      raw_names,
      function(name) grepl(tolower(name), export_text, fixed = TRUE),
      logical(1)
    )]
    expect_length(identifier_hits, 0)
    expect_equal(result$plots$data$name, result$analysis$name)
    expect_equal(getOption("engager.privacy_level"), "mask")
  }
})

test_that("basic privacy levels map to supported masking levels", {
  expect_equal(normalize_basic_privacy_level("high"), "privacy_strict")
  expect_equal(normalize_basic_privacy_level("medium"), "privacy_standard")
  expect_equal(normalize_basic_privacy_level("low"), "mask")
  expect_error(normalize_basic_privacy_level("none"), "must be one of")
  expect_error(normalize_basic_privacy_level(c("high", "low")), "must be one of")
})

test_that("quick_analysis delegates to basic_transcript_analysis", {
  tf <- tempfile(fileext = ".vtt")
  writeLines(c("WEBVTT", "\n", "00:00:00.000 --> 00:00:01.000", "Hello"), tf)
  called <- FALSE
  with_mocked_bindings(
    basic_transcript_analysis = function(transcript_file, output_dir = NULL, privacy_level = "high") {
      called <<- TRUE
      expect_equal(transcript_file, tf)
      expect_null(output_dir)
      list(
        analysis = tibble::tibble(), plots = list(), output_dir = output_dir,
        transcript_file = transcript_file, privacy_level = privacy_level
      )
    },
    {
      res <- quick_analysis(tf)
      expect_true(called)
      expect_null(res$output_dir)
      expect_equal(res$transcript_file, tf)
    }
  )
})

test_that("quick_analysis runs a bundled transcript without source-tree assumptions", {
  withr::local_options(engager.privacy_level = "mask")
  work_dir <- withr::local_tempdir()
  withr::local_dir(work_dir)
  transcript_file <- system.file(
    "extdata/test_transcripts/ideal_course_session1.vtt",
    package = "engager"
  )

  result <- quick_analysis(transcript_file)

  expect_s3_class(result$analysis, "tbl_df")
  expect_length(list.files(work_dir, all.files = TRUE, no.. = TRUE), 0)
  expect_equal(getOption("engager.privacy_level"), "mask")
})

test_that("default beginner and batch workflows do not write", {
  withr::local_options(engager.privacy_level = "mask")
  work_dir <- withr::local_tempdir()
  withr::local_dir(work_dir)
  transcript_dir <- system.file("extdata/test_transcripts", package = "engager")
  files <- file.path(
    transcript_dir,
    c("ideal_course_session1.vtt", "ideal_course_session2.vtt")
  )
  before <- list.files(work_dir, all.files = TRUE, no.. = TRUE, recursive = TRUE)

  basic <- basic_transcript_analysis(files[[1]])
  batch <- batch_basic_analysis(files)

  expect_null(basic$output_dir)
  expect_true(all(vapply(batch, function(x) is.null(x$output_dir), logical(1))))
  expect_identical(
    list.files(work_dir, all.files = TRUE, no.. = TRUE, recursive = TRUE),
    before
  )
})

test_that("batch_basic_analysis validates and processes multiple files", {
  files <- c(tempfile(fileext = ".vtt"), tempfile(fileext = ".vtt"))
  lapply(files, function(f) writeLines(c("WEBVTT", "\n", "00:00:00.000 --> 00:00:01.000", "Hello"), f))
  outdir <- file.path(tempdir(), paste0("batch_", as.integer(runif(1, 1, 1e6))))

  called <- 0L
  with_mocked_bindings(
    basic_transcript_analysis = function(transcript_file, output_dir = NULL, privacy_level = "high") {
      called <<- called + 1L
      if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
      list(analysis = tibble::tibble(), output_dir = output_dir, transcript_file = transcript_file)
    },
    {
      res <- batch_basic_analysis(files, outdir, privacy_level = "medium")
      expect_equal(length(res), length(files))
      expect_equal(called, length(files))
      # Expect per-file subdirectories to be created
      expect_true(dir.exists(file.path(outdir, "session_1")))
      expect_true(dir.exists(file.path(outdir, "session_2")))
    }
  )
})

test_that("batch_basic_analysis runs bundled transcripts into isolated session directories", {
  withr::local_options(engager.privacy_level = "mask")
  transcript_dir <- system.file("extdata/test_transcripts", package = "engager")
  files <- file.path(
    transcript_dir,
    c("ideal_course_session1.vtt", "ideal_course_session2.vtt")
  )
  output_dir <- withr::local_tempdir()

  results <- batch_basic_analysis(files, output_dir, privacy_level = "medium")

  expect_length(results, 2)
  expect_true(all(vapply(results, function(x) is.null(x$error), logical(1))))
  expect_true(file.exists(file.path(output_dir, "session_1", "engagement_metrics.csv")))
  expect_true(file.exists(file.path(output_dir, "session_2", "engagement_metrics.csv")))
  expect_equal(getOption("engager.privacy_level"), "mask")
})

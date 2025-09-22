

test_that("basic_transcript_analysis errors when file missing", {
  missing <- tempfile(fileext = ".vtt")
  expect_false(file.exists(missing))
  expect_error(
    basic_transcript_analysis(missing, tempfile()),
    "File not found"
  )
})

test_that("basic_transcript_analysis creates output dir and returns structured result", {
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
    process_zoom_transcript = function(df, ...) {
      expect_true(is.data.frame(df))
      fake_processed
    },
    analyze_transcripts = function(df, ...) {
      expect_true(is.data.frame(df))
      fake_analysis
    },
    plot_users = function(analysis, ...) {
      expect_true(is.data.frame(analysis))
      fake_plots
    },
    write_metrics = function(analysis, path, ...) {
      expect_true(is.data.frame(analysis))
      expect_true(dir.exists(path))
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
    }
  )
})

test_that("quick_analysis delegates to basic_transcript_analysis", {
  tf <- tempfile(fileext = ".vtt")
  writeLines(c("WEBVTT", "\n", "00:00:00.000 --> 00:00:01.000", "Hello"), tf)
  called <- FALSE
  with_mocked_bindings(
    basic_transcript_analysis = function(transcript_file, output_dir = "output", privacy_level = "high") {
      called <<- TRUE
      if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
      expect_equal(transcript_file, tf)
      expect_equal(output_dir, "quick_output")
      list(analysis = tibble::tibble(), plots = list(), output_dir = output_dir,
           transcript_file = transcript_file, privacy_level = privacy_level)
    },
    {
      res <- quick_analysis(tf)
      expect_true(called)
      expect_equal(res$output_dir, "quick_output")
      expect_equal(res$transcript_file, tf)
    }
  )
})

test_that("batch_basic_analysis validates and processes multiple files", {
  files <- c(tempfile(fileext = ".vtt"), tempfile(fileext = ".vtt"))
  lapply(files, function(f) writeLines(c("WEBVTT", "\n", "00:00:00.000 --> 00:00:01.000", "Hello"), f))
  outdir <- file.path(tempdir(), paste0("batch_", as.integer(runif(1, 1, 1e6))))

  called <- 0L
  with_mocked_bindings(
    basic_transcript_analysis = function(transcript_file, output_dir = "output", privacy_level = "high") {
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

# Comprehensive tests for write_metrics function
# Additional tests to improve coverage

test_that("write_metrics handles NULL data", {
  expect_error(write_metrics(data = NULL), "`data` must be a tibble")
})

test_that("write_metrics handles non-tibble input", {
  expect_error(write_metrics(data = data.frame(x = 1)), "`data` must be a tibble")
})

test_that("write_metrics handles different 'what' parameters", {
  test_data <- tibble::tibble(
    name = "Student1",
    comment_count = 5,
    total_duration = hms::as_hms("00:05:00"),
    wordcount = 100
  )

  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE)

  # Test engagement
  result1 <- write_metrics(test_data, what = "engagement", path = tmp)
  expect_true(file.exists(tmp))
  expect_s3_class(result1, "tbl_df")

  # Test summary
  tmp2 <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp2), add = TRUE)
  result2 <- write_metrics(test_data, what = "summary", path = tmp2)
  expect_true(file.exists(tmp2))

  # Test session_summary
  tmp3 <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp3), add = TRUE)
  result3 <- write_metrics(test_data, what = "session_summary", path = tmp3)
  expect_true(file.exists(tmp3))
})

test_that("write_metrics omits raw comments by default", {
  test_data <- tibble::tibble(
    name = c("Alice Johnson", "Bob Lee"),
    comments = list(
      c("Alice Johnson should not be in privacy-safe exports", "How are you?"),
      c("Bob Lee should not be in privacy-safe exports", "Thanks")
    ),
    comment_count = 2,
    total_duration = hms::as_hms("00:02:00")
  )

  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE)

  result <- write_metrics(test_data, path = tmp)
  written <- readr::read_csv(tmp, show_col_types = FALSE)
  file_text <- paste(readLines(tmp, warn = FALSE), collapse = "\n")

  expect_true(file.exists(tmp))
  expect_s3_class(result, "tbl_df")
  expect_false("comments" %in% names(written))
  expect_false(grepl("Alice Johnson|Bob Lee|How are you\\?|Thanks", file_text))
})

test_that("write_metrics supports explicit comments_count exports", {
  test_data <- tibble::tibble(
    name = c("Student1", "Student2"),
    comments = list(c("Hello", "How are you?"), character()),
    comment_count = c(2, 0)
  )

  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE)

  result <- write_metrics(test_data, comments_policy = "count", path = tmp)
  written <- readr::read_csv(tmp, show_col_types = FALSE)
  file_text <- paste(readLines(tmp, warn = FALSE), collapse = "\n")

  expect_s3_class(result, "tbl_df")
  expect_false("comments" %in% names(written))
  expect_true("comments_count" %in% names(written))
  expect_equal(written$comments_count, c(2L, 0L))
  expect_false(grepl("Hello|How are you", file_text))
})

test_that("write_metrics blocks raw comment text for privacy-safe levels", {
  test_data <- tibble::tibble(
    name = "Student1",
    comments = list(c("Hello from Alice Johnson")),
    comment_count = 1
  )

  for (level in c("mask", "privacy_standard", "privacy_strict")) {
    tmp <- tempfile(fileext = ".csv")
    on.exit(unlink(tmp), add = TRUE)

    expect_error(
      write_metrics(
        test_data,
        comments_policy = "text",
        privacy_level = level,
        path = tmp
      ),
      "only allowed when `privacy_level = \"none\"`"
    )
  }
})

test_that("write_metrics permits raw comment text only with privacy disabled", {
  test_data <- tibble::tibble(
    name = "Alice Johnson",
    comments = list(c("Alice Johnson spoke a peer's name")),
    comment_count = 1
  )

  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE)

  warnings <- character()
  result <- withCallingHandlers(
    write_metrics(
      test_data,
      comments_policy = "text",
      privacy_level = "none",
      path = tmp
    ),
    warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )

  written <- readr::read_csv(tmp, show_col_types = FALSE)
  expect_s3_class(result, "tbl_df")
  expect_true("comments" %in% names(written))
  expect_match(written$comments[[1]], "Alice Johnson")
  expect_true(any(grepl("Raw comments may contain", warnings)))
  expect_true(any(grepl("Privacy disabled", warnings)))
})

test_that("write_metrics keeps comments_format as a deprecated alias", {
  test_data <- tibble::tibble(
    name = "Student1",
    comments = list(c("Hello", "How are you?")),
    comment_count = 2
  )

  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE)

  expect_warning(
    result <- write_metrics(test_data, comments_format = "count", path = tmp),
    "deprecated"
  )
  written <- readr::read_csv(tmp, show_col_types = FALSE)

  expect_s3_class(result, "tbl_df")
  expect_false("comments" %in% names(written))
  expect_equal(written$comments_count, 2L)

  expect_warning(
    expect_error(
      write_metrics(test_data, comments_format = "text", path = tempfile(fileext = ".csv")),
      "only allowed"
    ),
    "deprecated"
  )
})

test_that("write_metrics handles different privacy levels", {
  test_data <- tibble::tibble(
    name = "John Smith",
    comments = list(c("John Smith named Jane Doe out loud")),
    comment_count = 5,
    total_duration = hms::as_hms("00:05:00")
  )

  # Test mask privacy level
  tmp1 <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp1), add = TRUE)
  result1 <- write_metrics(test_data, privacy_level = "mask", path = tmp1)
  expect_true(file.exists(tmp1))
  expect_false("comments" %in% names(readr::read_csv(tmp1, show_col_types = FALSE)))
  expect_false(any(grepl("John Smith|Jane Doe", readLines(tmp1, warn = FALSE))))

  # Test privacy_standard privacy level
  tmp2 <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp2), add = TRUE)
  result2 <- write_metrics(test_data, privacy_level = "privacy_standard", path = tmp2)
  expect_true(file.exists(tmp2))
  expect_false("comments" %in% names(readr::read_csv(tmp2, show_col_types = FALSE)))
  expect_false(any(grepl("John Smith|Jane Doe", readLines(tmp2, warn = FALSE))))

  # Test privacy_strict privacy level
  tmp3 <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp3), add = TRUE)
  result3 <- write_metrics(test_data, privacy_level = "privacy_strict", path = tmp3)
  expect_true(file.exists(tmp3))
  expect_false("comments" %in% names(readr::read_csv(tmp3, show_col_types = FALSE)))
  expect_false(any(grepl("John Smith|Jane Doe", readLines(tmp3, warn = FALSE))))
})

test_that("write_metrics supports deprecated FERPA privacy aliases", {
  test_data <- tibble::tibble(
    name = "John Smith",
    comments = list(c("John Smith named Jane Doe out loud")),
    comment_count = 1
  )

  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE)

  expect_warning(
    result <- write_metrics(test_data, privacy_level = "ferpa_strict", path = tmp),
    "deprecated"
  )
  written <- readr::read_csv(tmp, show_col_types = FALSE)

  expect_s3_class(result, "tbl_df")
  expect_false("comments" %in% names(written))
  expect_false(any(grepl("John Smith|Jane Doe", readLines(tmp, warn = FALSE))))
})

test_that("write_metrics creates parent directories", {
  test_data <- tibble::tibble(
    name = "Student1",
    comment_count = 5
  )

  # Create a path with non-existent parent directory
  tmp_dir <- tempfile()
  tmp_file <- file.path(tmp_dir, "subdir", "output.csv")
  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  result <- write_metrics(test_data, path = tmp_file)
  expect_true(file.exists(tmp_file))
  expect_true(dir.exists(dirname(tmp_file)))
})

test_that("write_metrics uses default filename when path is NULL", {
  test_data <- tibble::tibble(
    name = "Student1",
    comment_count = 5
  )

  # Change to temp directory to avoid cluttering current directory
  old_wd <- getwd()
  tmp_dir <- tempdir()
  setwd(tmp_dir)
  on.exit(
    {
      setwd(old_wd)
      unlink("engagement_metrics.csv")
    },
    add = TRUE
  )

  result <- write_metrics(test_data, what = "engagement")
  expect_true(file.exists("engagement_metrics.csv"))
})

test_that("write_metrics handles empty tibble", {
  empty_data <- tibble::tibble(
    name = character(0),
    comment_count = numeric(0)
  )

  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE)

  result <- write_metrics(empty_data, path = tmp)
  expect_true(file.exists(tmp))
  expect_equal(nrow(result), 0)
})

test_that("write_metrics handles data with list columns", {
  test_data <- tibble::tibble(
    name = "Student1",
    comments = list(c("Hello", "World")),
    metadata = list(list(type = "student", id = 123)),
    comment_count = 2
  )

  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE)

  expect_warning(
    result <- write_metrics(test_data, path = tmp),
    "Converting list columns to JSON strings:"
  )
  expect_true(file.exists(tmp))
  expect_s3_class(result, "tbl_df")
  written <- readr::read_csv(tmp, show_col_types = FALSE)
  expect_false("comments" %in% names(written))
})

test_that("write_metrics handles invalid 'what' parameter", {
  test_data <- tibble::tibble(
    name = "Student1",
    comment_count = 5
  )

  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE)

  expect_error(write_metrics(test_data, what = "invalid", path = tmp))
})

test_that("write_metrics handles invalid comments_format parameter", {
  test_data <- tibble::tibble(
    name = "Student1",
    comment_count = 5
  )

  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE)

  expect_error(write_metrics(test_data, comments_format = "invalid", path = tmp))
})

test_that("write_metrics returns data invisibly", {
  test_data <- tibble::tibble(
    name = "Student1",
    comment_count = 5
  )

  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE)

  result <- write_metrics(test_data, path = tmp)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
})

test_that("write_metrics handles file write errors gracefully", {
  test_data <- tibble::tibble(
    name = "Student1",
    comment_count = 5
  )

  # Try to write to a directory (should fail)
  tmp_dir <- tempdir()
  expect_error(suppressWarnings(write_metrics(test_data, path = tmp_dir)))
})

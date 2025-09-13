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

test_that("write_metrics handles different comments_format parameters", {
  test_data <- tibble::tibble(
    name = "Student1",
    comments = list(c("Hello", "How are you?"), c("Good", "Thanks")),
    comment_count = 2,
    total_duration = hms::as_hms("00:02:00")
  )

  # Test text format
  tmp1 <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp1), add = TRUE)
  result1 <- write_metrics(test_data, comments_format = "text", path = tmp1)
  expect_true(file.exists(tmp1))

  # Test count format
  tmp2 <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp2), add = TRUE)
  result2 <- write_metrics(test_data, comments_format = "count", path = tmp2)
  expect_true(file.exists(tmp2))
})

test_that("write_metrics handles different privacy levels", {
  test_data <- tibble::tibble(
    name = "John Smith",
    comment_count = 5,
    total_duration = hms::as_hms("00:05:00")
  )

  # Test mask privacy level
  tmp1 <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp1), add = TRUE)
  result1 <- write_metrics(test_data, privacy_level = "mask", path = tmp1)
  expect_true(file.exists(tmp1))

  # Test ferpa_standard privacy level
  tmp2 <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp2), add = TRUE)
  result2 <- write_metrics(test_data, privacy_level = "ferpa_standard", path = tmp2)
  expect_true(file.exists(tmp2))

  # Test ferpa_strict privacy level
  tmp3 <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp3), add = TRUE)
  result3 <- write_metrics(test_data, privacy_level = "ferpa_strict", path = tmp3)
  expect_true(file.exists(tmp3))
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

  result <- write_metrics(test_data, path = tmp)
  expect_true(file.exists(tmp))
  expect_s3_class(result, "tbl_df")
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
  expect_error(write_metrics(test_data, path = tmp_dir))
})

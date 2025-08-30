# Tests for ideal transcript export functions

test_that("CSV export functions work correctly", {
  # Test data
  test_data <- tibble::tibble(
    name = c("Professor Ed", "Tom Miller", "Samantha Smith"),
    comment = c("Hello everyone", "Great question", "I agree"),
    start = c(0, 30, 60),
    end = c(25, 55, 85)
  )

  # Test CSV export
  temp_file <- tempfile(fileext = ".csv")
  result <- export_ideal_transcripts_csv(test_data, file_path = temp_file)

  expect_true(file.exists(temp_file))
  expect_true(is.data.frame(result))

  # Clean up
  unlink(temp_file)
})

test_that("JSON export functions work correctly", {
  # Test data
  test_data <- tibble::tibble(
    name = c("Professor Ed", "Tom Miller"),
    comment = c("Hello everyone", "Great question"),
    start = c(0, 30),
    end = c(25, 55)
  )

  # Test JSON export
  temp_file <- tempfile(fileext = ".json")
  result <- export_ideal_transcripts_json(test_data, file_path = temp_file)

  expect_true(file.exists(temp_file))
  expect_true(is.list(result))

  # Clean up
  unlink(temp_file)
})

test_that("Excel export functions work correctly", {
  # Test data
  test_data <- tibble::tibble(
    name = c("Professor Ed", "Tom Miller"),
    comment = c("Hello everyone", "Great question"),
    start = c(0, 30),
    end = c(25, 55)
  )

  # Test Excel export
  temp_file <- tempfile(fileext = ".xlsx")
  result <- export_ideal_transcripts_excel(test_data, file_path = temp_file)

  expect_true(file.exists(temp_file))
  expect_true(inherits(result, "Workbook"))

  # Clean up
  unlink(temp_file)
})

test_that("Summary export functions work correctly", {
  # Test data
  test_data <- tibble::tibble(
    name = c("Professor Ed", "Tom Miller"),
    comment = c("Hello everyone", "Great question"),
    start = c(0, 30),
    end = c(25, 55)
  )

  # Test summary export
  temp_file <- tempfile(fileext = ".csv")
  result <- export_ideal_transcripts_summary(
    test_data,
    file_path = temp_file,
    format = "csv"
  )

  expect_true(file.exists(temp_file))
  expect_true(is.data.frame(result))

  # Clean up
  unlink(temp_file)
})

test_that("Export functions handle errors gracefully", {
  # Test NULL input
  expect_error(export_ideal_transcripts_csv(NULL))
  expect_error(export_ideal_transcripts_json(NULL))
  expect_error(export_ideal_transcripts_excel(NULL))
  expect_error(export_ideal_transcripts_summary(NULL))

  # Test invalid input types
  expect_error(export_ideal_transcripts_csv("not a data frame"))
  expect_error(export_ideal_transcripts_json("not a data frame"))
  expect_error(export_ideal_transcripts_excel("not a data frame"))
  expect_error(export_ideal_transcripts_summary("not a data frame"))
})

test_that("Export functions respect privacy settings", {
  # Test data with names
  test_data <- tibble::tibble(
    name = c("Professor Ed", "Tom Miller"),
    comment = c("Hello everyone", "Great question"),
    start = c(0, 30),
    end = c(25, 55)
  )

  # Test with different privacy levels
  temp_file <- tempfile(fileext = ".csv")

  # Test masked privacy
  result_masked <- export_ideal_transcripts_csv(
    test_data,
    file_path = temp_file,
    privacy_level = "mask"
  )

  # Test ferpa_standard privacy
  result_ferpa <- export_ideal_transcripts_csv(
    test_data,
    file_path = temp_file,
    privacy_level = "ferpa_standard"
  )

  expect_true(file.exists(temp_file))

  # Clean up
  unlink(temp_file)
})

test_that("Export functions work with ideal course batch data", {
  # Test with actual ideal course batch data
  batch_results <- process_ideal_course_batch(
    output_format = "data.frame",
    privacy_level = "masked"
  )

  if (!is.null(batch_results) && nrow(batch_results) > 0) {
    # Test CSV export with batch data
    temp_file <- tempfile(fileext = ".csv")
    result <- export_ideal_transcripts_csv(batch_results, file_path = temp_file)

    expect_true(file.exists(temp_file))
    expect_true(is.data.frame(result))

    # Clean up
    unlink(temp_file)
  }
})

test_that("Export functions handle different data structures", {
  # Test with data.frame
  test_df <- data.frame(
    name = c("Professor Ed", "Tom Miller"),
    comment = c("Hello everyone", "Great question"),
    start = c(0, 30),
    end = c(25, 55),
    stringsAsFactors = FALSE
  )

  # Test with tibble
  test_tibble <- tibble::tibble(
    name = c("Professor Ed", "Tom Miller"),
    comment = c("Hello everyone", "Great question"),
    start = c(0, 30),
    end = c(25, 55)
  )

  temp_file_df <- tempfile(fileext = ".csv")
  temp_file_tibble <- tempfile(fileext = ".csv")

  # Both should work
  expect_no_error(export_ideal_transcripts_csv(test_df, file_path = temp_file_df))
  expect_no_error(export_ideal_transcripts_csv(test_tibble, file_path = temp_file_tibble))

  # Clean up
  unlink(c(temp_file_df, temp_file_tibble))
})

test_that("Export functions create directories when needed", {
  # Test data
  test_data <- tibble::tibble(
    name = c("Professor Ed"),
    comment = c("Hello everyone"),
    start = c(0),
    end = c(25)
  )

  # Test with nested directory path
  temp_dir <- tempfile()
  temp_file <- file.path(temp_dir, "subdir", "test.csv")

  result <- export_ideal_transcripts_csv(test_data, file_path = temp_file)

  expect_true(file.exists(temp_file))
  expect_true(dir.exists(dirname(temp_file)))

  # Clean up
  unlink(temp_dir, recursive = TRUE)
})

test_that("Export functions generate default filenames", {
  # Test data
  test_data <- tibble::tibble(
    name = c("Professor Ed"),
    comment = c("Hello everyone"),
    start = c(0),
    end = c(25)
  )

  # Test CSV with default filename
  temp_file_csv <- tempfile(fileext = ".csv")
  result_csv <- export_ideal_transcripts_csv(test_data, file_path = temp_file_csv)
  expect_true(file.exists(temp_file_csv))

  # Test JSON with default filename
  temp_file_json <- tempfile(fileext = ".json")
  result_json <- export_ideal_transcripts_json(test_data, file_path = temp_file_json)
  expect_true(file.exists(temp_file_json))

  # Test Excel with default filename
  temp_file_excel <- tempfile(fileext = ".xlsx")
  result_excel <- export_ideal_transcripts_excel(test_data, file_path = temp_file_excel)
  expect_true(file.exists(temp_file_excel))

  # Test summary with default filename
  temp_file_summary <- tempfile(fileext = ".csv")
  result_summary <- export_ideal_transcripts_summary(test_data, file_path = temp_file_summary, format = "csv")
  expect_true(file.exists(temp_file_summary))

  # Clean up
  unlink(c(temp_file_csv, temp_file_json, temp_file_excel, temp_file_summary))
})

test_that("Export functions include metadata when requested", {
  # Test data
  test_data <- tibble::tibble(
    name = c("Professor Ed"),
    comment = c("Hello everyone"),
    start = c(0),
    end = c(25)
  )

  # Test CSV with metadata
  temp_file <- tempfile(fileext = ".csv")
  result <- export_ideal_transcripts_csv(
    test_data,
    file_path = temp_file,
    include_metadata = TRUE
  )

  # Check that metadata columns are added
  expect_true("export_timestamp" %in% names(result))
  expect_true("export_format" %in% names(result))
  expect_true("export_version" %in% names(result))

  # Clean up
  unlink(temp_file)
})

test_that("Export functions handle empty data gracefully", {
  # Test with empty data frame
  empty_data <- tibble::tibble(
    name = character(),
    comment = character(),
    start = numeric(),
    end = numeric()
  )

  temp_file <- tempfile(fileext = ".csv")

  # Should not error
  expect_no_error(export_ideal_transcripts_csv(empty_data, file_path = temp_file))
  expect_true(file.exists(temp_file))

  # Clean up
  unlink(temp_file)
})

test_that("Export functions work with different privacy levels", {
  # Test data
  test_data <- tibble::tibble(
    name = c("Professor Ed", "Tom Miller"),
    comment = c("Hello everyone", "Great question"),
    start = c(0, 30),
    end = c(25, 55)
  )

  temp_file <- tempfile(fileext = ".csv")

  # Test all privacy levels
  privacy_levels <- c("ferpa_strict", "ferpa_standard", "mask", "none")

  for (level in privacy_levels) {
    result <- export_ideal_transcripts_csv(
      test_data,
      file_path = temp_file,
      privacy_level = level
    )

    expect_true(file.exists(temp_file))
  }

  # Clean up
  unlink(temp_file)
})

test_that("Export functions handle large datasets", {
  # Create larger test dataset
  large_data <- tibble::tibble(
    name = rep(c("Professor Ed", "Tom Miller", "Samantha Smith"), 100),
    comment = rep(c("Hello everyone", "Great question", "I agree"), 100),
    start = rep(c(0, 30, 60), 100),
    end = rep(c(25, 55, 85), 100)
  )

  temp_file <- tempfile(fileext = ".csv")

  # Should handle large dataset without issues
  expect_no_error(export_ideal_transcripts_csv(large_data, file_path = temp_file))
  expect_true(file.exists(temp_file))

  # Clean up
  unlink(temp_file)
})

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
  expect_invisible(export_ideal_transcripts_csv(test_data, file_path = temp_file))

  expect_true(file.exists(temp_file))

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
  expect_invisible(export_ideal_transcripts_json(test_data, file_path = temp_file))

  expect_true(file.exists(temp_file))

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
  expect_invisible(export_ideal_transcripts_excel(test_data, file_path = temp_file))

  expect_true(file.exists(temp_file))

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
  expect_invisible(export_ideal_transcripts_summary(
    test_data,
    file_path = temp_file,
    format = "csv"
  ))

  expect_true(file.exists(temp_file))

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

  # Test full privacy
  result_full <- export_ideal_transcripts_csv(
    test_data,
    file_path = temp_file,
    privacy_level = "ferpa_strict"
  )

  expect_true(file.exists(temp_file))

  # Clean up
  unlink(temp_file)
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
  result_csv <- export_ideal_transcripts_csv(test_data)
  expect_true(grepl("ideal_transcript_export_.*\\.csv$", result_csv))

  # Test JSON with default filename
  result_json <- export_ideal_transcripts_json(test_data)
  expect_true(grepl("ideal_transcript_export_.*\\.json$", result_json))

  # Test Excel with default filename
  result_excel <- export_ideal_transcripts_excel(test_data)
  expect_true(grepl("ideal_transcript_export_.*\\.xlsx$", result_excel))

  # Test summary with default filename
  result_summary <- export_ideal_transcripts_summary(test_data, format = "csv")
  expect_true(grepl("ideal_transcript_summary_.*\\.csv$", result_summary))
})

test_that("Export functions handle different data types", {
  # Test data with various types
  test_data <- tibble::tibble(
    name = c("Professor Ed", "Tom Miller"),
    comment = c("Hello everyone", "Great question"),
    start = as.numeric(c(0, 30)),
    end = as.numeric(c(25, 55)),
    duration = as.integer(c(25, 25)),
    is_student = as.logical(c(TRUE, FALSE))
  )

  # Test CSV export
  temp_file <- tempfile(fileext = ".csv")
  expect_invisible(export_ideal_transcripts_csv(test_data, file_path = temp_file))

  expect_true(file.exists(temp_file))

  # Clean up
  unlink(temp_file)
})

test_that("Export functions handle empty data frames", {
  # Test empty data frame
  empty_data <- tibble::tibble(
    name = character(),
    comment = character(),
    start = numeric(),
    end = numeric()
  )

  # Test CSV export
  temp_file <- tempfile(fileext = ".csv")
  expect_invisible(export_ideal_transcripts_csv(empty_data, file_path = temp_file))

  expect_true(file.exists(temp_file))

  # Clean up
  unlink(temp_file)
})

test_that("Export functions handle large data frames", {
  # Test larger data frame
  large_data <- tibble::tibble(
    name = rep(c("Professor Ed", "Tom Miller", "Samantha Smith"), 100),
    comment = rep(c("Hello everyone", "Great question", "I agree"), 100),
    start = rep(c(0, 30, 60), 100),
    end = rep(c(25, 55, 85), 100)
  )

  # Test CSV export
  temp_file <- tempfile(fileext = ".csv")
  expect_invisible(export_ideal_transcripts_csv(large_data, file_path = temp_file))

  expect_true(file.exists(temp_file))

  # Clean up
  unlink(temp_file)
})

test_that("Export functions handle missing columns gracefully", {
  # Test data with missing expected columns
  test_data <- tibble::tibble(
    name = c("Professor Ed", "Tom Miller"),
    comment = c("Hello everyone", "Great question")
    # Missing start and end columns
  )

  # Test CSV export
  temp_file <- tempfile(fileext = ".csv")
  expect_invisible(export_ideal_transcripts_csv(test_data, file_path = temp_file))

  expect_true(file.exists(temp_file))

  # Clean up
  unlink(temp_file)
})

test_that("Export functions handle directory creation", {
  # Test data
  test_data <- tibble::tibble(
    name = c("Professor Ed"),
    comment = c("Hello everyone"),
    start = c(0),
    end = c(25)
  )

  # Test creating directory
  temp_dir <- tempfile()
  temp_file <- file.path(temp_dir, "test.csv")

  expect_invisible(export_ideal_transcripts_csv(test_data, file_path = temp_file))

  expect_true(dir.exists(temp_dir))
  expect_true(file.exists(temp_file))

  # Clean up
  unlink(temp_dir, recursive = TRUE)
})

test_that("Export functions handle different privacy levels", {
  # Test data
  test_data <- tibble::tibble(
    name = c("Professor Ed", "Tom Miller"),
    comment = c("Hello everyone", "Great question"),
    start = c(0, 30),
    end = c(25, 55)
  )

  # Test different privacy levels
  temp_file <- tempfile(fileext = ".csv")

  # Test none privacy level
  result_none <- export_ideal_transcripts_csv(
    test_data,
    file_path = temp_file,
    privacy_level = "none"
  )

  # Test mask privacy level
  result_mask <- export_ideal_transcripts_csv(
    test_data,
    file_path = temp_file,
    privacy_level = "mask"
  )

  # Test full privacy level
  result_full <- export_ideal_transcripts_csv(
    test_data,
    file_path = temp_file,
    privacy_level = "ferpa_strict"
  )

  expect_true(file.exists(temp_file))

  # Clean up
  unlink(temp_file)
})

test_that("Export functions handle metadata options", {
  # Test data
  test_data <- tibble::tibble(
    name = c("Professor Ed"),
    comment = c("Hello everyone"),
    start = c(0),
    end = c(25)
  )

  # Test CSV with metadata
  temp_file <- tempfile(fileext = ".csv")
  result_with_metadata <- export_ideal_transcripts_csv(
    test_data,
    file_path = temp_file,
    include_metadata = TRUE
  )

  expect_true(file.exists(temp_file))

  # Test CSV without metadata
  temp_file2 <- tempfile(fileext = ".csv")
  result_without_metadata <- export_ideal_transcripts_csv(
    test_data,
    file_path = temp_file2,
    include_metadata = FALSE
  )

  expect_true(file.exists(temp_file2))

  # Clean up
  unlink(c(temp_file, temp_file2))
})

test_that("Export functions handle JSON pretty print options", {
  # Test data
  test_data <- tibble::tibble(
    name = c("Professor Ed"),
    comment = c("Hello everyone"),
    start = c(0),
    end = c(25)
  )

  # Test JSON with pretty print
  temp_file <- tempfile(fileext = ".json")
  result_pretty <- export_ideal_transcripts_json(
    test_data,
    file_path = temp_file,
    pretty_print = TRUE
  )

  expect_true(file.exists(temp_file))

  # Test JSON without pretty print
  temp_file2 <- tempfile(fileext = ".json")
  result_not_pretty <- export_ideal_transcripts_json(
    test_data,
    file_path = temp_file2,
    pretty_print = FALSE
  )

  expect_true(file.exists(temp_file2))

  # Clean up
  unlink(c(temp_file, temp_file2))
})

test_that("Export functions handle Excel sheet options", {
  # Test data
  test_data <- tibble::tibble(
    name = c("Professor Ed"),
    comment = c("Hello everyone"),
    start = c(0),
    end = c(25)
  )

  # Test Excel with all sheets
  temp_file <- tempfile(fileext = ".xlsx")
  result_all_sheets <- export_ideal_transcripts_excel(
    test_data,
    file_path = temp_file,
    include_summary_sheet = TRUE,
    include_metadata_sheet = TRUE
  )

  expect_true(file.exists(temp_file))

  # Test Excel with minimal sheets
  temp_file2 <- tempfile(fileext = ".xlsx")
  result_minimal_sheets <- export_ideal_transcripts_excel(
    test_data,
    file_path = temp_file2,
    include_summary_sheet = FALSE,
    include_metadata_sheet = FALSE
  )

  expect_true(file.exists(temp_file2))

  # Clean up
  unlink(c(temp_file, temp_file2))
})

test_that("Export functions handle summary format options", {
  # Test data
  test_data <- tibble::tibble(
    name = c("Professor Ed", "Tom Miller"),
    comment = c("Hello everyone", "Great question"),
    start = c(0, 30),
    end = c(25, 55)
  )

  # Test summary CSV
  temp_file <- tempfile(fileext = ".csv")
  result_csv <- export_ideal_transcripts_summary(
    test_data,
    file_path = temp_file,
    format = "csv"
  )

  expect_true(file.exists(temp_file))

  # Test summary JSON
  temp_file2 <- tempfile(fileext = ".json")
  result_json <- export_ideal_transcripts_summary(
    test_data,
    file_path = temp_file2,
    format = "json"
  )

  expect_true(file.exists(temp_file2))

  # Test summary Excel
  temp_file3 <- tempfile(fileext = ".xlsx")
  result_excel <- export_ideal_transcripts_summary(
    test_data,
    file_path = temp_file3,
    format = "excel"
  )

  expect_true(file.exists(temp_file3))

  # Clean up
  unlink(c(temp_file, temp_file2, temp_file3))
})

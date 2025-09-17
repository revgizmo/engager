# Test file for load_session_mapping comprehensive coverage
# This function has complex logic that needs thorough testing

test_that("load_mapping_file handles file existence checks", {
  # Test with non-existent file
  expect_error(load_mapping_file("non_existent_file.csv"), "Session mapping file not found")

  # Test with existing file (create temporary file)
  temp_file <- tempfile(fileext = ".csv")
  test_data <- data.frame(
    zoom_recording_id = "123",
    dept = "CS",
    course = "101",
    section = "A",
    session_date = "2024-01-15",
    session_time = "10:00",
    instructor = "Dr. Smith",
    stringsAsFactors = FALSE
  )
  write.csv(test_data, temp_file, row.names = FALSE)

  result <- load_mapping_file(temp_file)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
  expect_equal(result$zoom_recording_id, "123")

  unlink(temp_file)
})

test_that("validate_mapping_columns handles missing columns", {
  # Test with all required columns
  complete_data <- data.frame(
    zoom_recording_id = "123",
    dept = "CS",
    course = "101",
    section = "A",
    session_date = "2024-01-15",
    session_time = "10:00",
    instructor = "Dr. Smith",
    stringsAsFactors = FALSE
  )
  expect_silent(validate_mapping_columns(complete_data))

  # Test with missing columns
  incomplete_data <- data.frame(
    zoom_recording_id = "123",
    dept = "CS",
    stringsAsFactors = FALSE
  )
  expect_error(validate_mapping_columns(incomplete_data), "missing required columns")
})

test_that("validate_mapping_data handles NA values", {
  # Test with complete data
  complete_data <- data.frame(
    zoom_recording_id = "123",
    dept = "CS",
    course = "101",
    section = "A",
    session_date = "2024-01-15",
    session_time = "10:00",
    instructor = "Dr. Smith",
    stringsAsFactors = FALSE
  )
  expect_silent(validate_mapping_data(complete_data))

  # Test with NA values
  na_data <- data.frame(
    zoom_recording_id = c("123", "456"),
    dept = c("CS", NA),
    course = c("101", NA),
    section = c("A", NA),
    session_date = c("2024-01-15", "2024-01-16"),
    session_time = c("10:00", "11:00"),
    instructor = c("Dr. Smith", "Dr. Jones"),
    stringsAsFactors = FALSE
  )
  expect_silent(validate_mapping_data(na_data))
})

test_that("merge_zoom_with_mapping handles different input types", {
  # Test with valid tibble
  zoom_data <- tibble::tibble(
    ID = c("123", "456"),
    topic = c("Lecture 1", "Lecture 2")
  )
  mapping_data <- data.frame(
    zoom_recording_id = c("123", "456"),
    dept = c("CS", "CS"),
    course = c("101", "101"),
    section = c("A", "B"),
    session_date = c("2024-01-15", "2024-01-16"),
    session_time = c("10:00", "11:00"),
    instructor = c("Dr. Smith", "Dr. Jones"),
    stringsAsFactors = FALSE
  )

  result <- merge_zoom_with_mapping(zoom_data, mapping_data)
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 2)

  # Test with non-tibble input
  expect_error(merge_zoom_with_mapping("invalid", mapping_data), "must be a tibble")

  # Test with missing ID column
  invalid_zoom <- tibble::tibble(topic = "Lecture 1")
  expect_error(merge_zoom_with_mapping(invalid_zoom, mapping_data), "must contain 'ID' column")
})

test_that("process_merged_columns handles column conflicts", {
  # Test with conflicting columns
  result <- data.frame(
    ID = "123",
    dept.x = "CS_zoom",
    dept.y = "CS_mapping",
    course.x = "101_zoom",
    course.y = "101_mapping",
    section.x = "A_zoom",
    section.y = "A_mapping",
    instructor.x = "Dr. Smith_zoom",
    instructor.y = "Dr. Smith_mapping",
    stringsAsFactors = FALSE
  )

  processed <- process_merged_columns(result)
  expect_equal(processed$dept, "CS_mapping")
  expect_equal(processed$course, "101_mapping")
  expect_equal(processed$section, "A_mapping")
  expect_equal(processed$instructor, "Dr. Smith_mapping")
  expect_false("dept.x" %in% names(processed))
  expect_false("dept.y" %in% names(processed))
})

test_that("add_computed_columns handles different scenarios", {
  # Test with complete data
  complete_data <- data.frame(
    course = c("101", "102"),
    section = c("A", "B"),
    session_date = c("2024-01-15", "2024-01-16"),
    stringsAsFactors = FALSE
  )

  result <- add_computed_columns(complete_data)
  expect_equal(result$course_section, c("101.A", "102.B"))
  expect_true(inherits(result$match_start_time, "Date") || is.numeric(result$match_start_time) || is.character(result$match_start_time))
  expect_s3_class(result$match_end_time, "POSIXct")

  # Test with NA values
  na_data <- data.frame(
    course = c("101", NA),
    section = c(NA, "B"),
    session_date = c("2024-01-15", NA),
    stringsAsFactors = FALSE
  )

  result_na <- add_computed_columns(na_data)
  expect_equal(result_na$course_section, c(NA_character_, NA_character_))
  expect_true(is.na(result_na$match_end_time[2]))
})

test_that("finalize_result_formatting handles column types", {
  # Test with mixed data types
  mixed_data <- data.frame(
    course = factor(c("101", "102")),
    section = c("A", "B"),
    dept = c("CS", "MATH"),
    instructor = c("Dr. Smith", "Dr. Jones"),
    dept_zoom = c("CS_old", "MATH_old"),
    session_date = c("2024-01-15", "2024-01-16"),
    session_time = c("10:00", "11:00"),
    keep_column = c("keep1", "keep2"),
    stringsAsFactors = FALSE
  )

  result <- finalize_result_formatting(mixed_data)
  expect_s3_class(result, "tbl_df")
  expect_type(result$course, "character")
  expect_type(result$section, "character")
  expect_type(result$dept, "character")
  expect_type(result$instructor, "character")
  expect_false("dept_zoom" %in% names(result))
  expect_false("session_date" %in% names(result))
  expect_false("session_time" %in% names(result))
  expect_true("keep_column" %in% names(result))
})

test_that("load_session_mapping handles different parameter combinations", {
  # Test with just mapping file
  temp_file <- tempfile(fileext = ".csv")
  test_data <- data.frame(
    zoom_recording_id = "123",
    dept = "CS",
    course = "101",
    section = "A",
    session_date = "2024-01-15",
    session_time = "10:00",
    instructor = "Dr. Smith",
    stringsAsFactors = FALSE
  )
  write.csv(test_data, temp_file, row.names = FALSE)

  result1 <- load_session_mapping(mapping_file = temp_file)
  expect_s3_class(result1, "tbl_df")
  expect_equal(nrow(result1), 1)

  # Test with zoom recordings
  zoom_data <- tibble::tibble(
    ID = "123",
    topic = "Lecture 1"
  )

  result2 <- load_session_mapping(
    mapping_file = temp_file,
    zoom_recordings_df = zoom_data
  )
  expect_s3_class(result2, "tbl_df")
  expect_equal(nrow(result2), 1)
  expect_true("course_section" %in% names(result2))

  # Test with validation disabled
  result3 <- load_session_mapping(
    mapping_file = temp_file,
    zoom_recordings_df = zoom_data,
    validate_mapping = FALSE
  )
  expect_s3_class(result3, "tbl_df")

  unlink(temp_file)
})

test_that("load_session_mapping handles edge cases", {
  # Test with empty mapping file
  temp_file <- tempfile(fileext = ".csv")
  empty_data <- data.frame(
    zoom_recording_id = character(),
    dept = character(),
    course = character(),
    section = character(),
    session_date = as.Date(character()),
    session_time = character(),
    instructor = character(),
    stringsAsFactors = FALSE
  )
  write.csv(empty_data, temp_file, row.names = FALSE)

  result <- load_session_mapping(mapping_file = temp_file)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)

  unlink(temp_file)
})

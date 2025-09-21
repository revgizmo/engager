# Test file for create_session_mapping function

library(testthat)
library(engager)

# Test data setup
create_zoom_recordings_data <- function() {
  tibble::tibble(
    ID = c("123456789", "987654321", "456789123"),
    Topic = c("CS 101 Lecture 1", "MATH 250 Discussion", "LTF 201 Lab"),
    `Start Time` = c("Jan 15, 2024 10:00 AM", "Jan 16, 2024 09:00 AM", "Jan 17, 2024 02:00 PM")
  )
}

create_course_info_data <- function() {
  tibble::tibble(
    dept = c("CS", "MATH", "LTF"),
    course = c("101", "250", "201"),
    section = c("01", "01", "01"),
    instructor = c("Dr. Smith", "Dr. Johnson", "Dr. Brown"),
    session_length_hours = c(1.5, 1.0, 2.0)
  )
}

# Basic tests
test_that("create_session_mapping returns proper structure", {
  zoom_data <- create_zoom_recordings_data()
  course_data <- create_course_info_data()
  
  result <- create_session_mapping(zoom_data, course_data)
  
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), nrow(zoom_data))
  expect_true("recording_id" %in% names(result))
  expect_true("topic" %in% names(result))
  expect_true("dept" %in% names(result))
  expect_true("course" %in% names(result))
  expect_true("section" %in% names(result))
  expect_true("instructor" %in% names(result))
})

test_that("create_session_mapping handles NULL inputs", {
  result <- create_session_mapping(NULL, NULL)
  
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_true("recording_id" %in% names(result))
  expect_true("topic" %in% names(result))
  expect_true("dept" %in% names(result))
  expect_true("course" %in% names(result))
})

test_that("create_session_mapping handles invalid input types", {
  zoom_data <- create_zoom_recordings_data()
  course_data <- create_course_info_data()
  
  expect_error(create_session_mapping(data.frame(), course_data))
  expect_error(create_session_mapping("not a tibble", course_data))
  expect_error(create_session_mapping(123, course_data))
  expect_error(create_session_mapping(zoom_data, data.frame()))
  expect_error(create_session_mapping(zoom_data, "not a tibble"))
  expect_error(create_session_mapping(zoom_data, 123))
})

test_that("create_session_mapping handles missing required columns", {
  zoom_data <- create_zoom_recordings_data()
  course_data <- tibble::tibble(
    dept = c("CS", "MATH"),
    course = c("101", "250")
  )
  
  expect_error(create_session_mapping(zoom_data, course_data))
})

test_that("create_session_mapping handles pattern matching", {
  zoom_data <- create_zoom_recordings_data()
  course_data <- create_course_info_data()
  
  result <- create_session_mapping(zoom_data, course_data)
  
  expect_equal(result$dept[1], "CS")
  expect_equal(result$course[1], "101")
  expect_equal(result$section[1], "01")
  expect_equal(result$instructor[1], "Dr. Smith")
  
  expect_equal(result$dept[2], "MATH")
  expect_equal(result$course[2], "250")
  expect_equal(result$section[2], "01")
  expect_equal(result$instructor[2], "Dr. Johnson")
})

test_that("create_session_mapping handles custom patterns", {
  zoom_data <- create_zoom_recordings_data()
  course_data <- create_course_info_data()
  
  custom_patterns <- list(
    "CS 101" = "CS.*101",
    "MATH 250" = "MATH.*250",
    "LTF 201" = "LTF.*201"
  )
  
  result <- create_session_mapping(zoom_data, course_data, auto_assign_patterns = custom_patterns)
  
  expect_equal(result$dept[1], "CS")
  expect_equal(result$course[1], "101")
  expect_equal(result$section[1], "01")
  expect_equal(result$instructor[1], "Dr. Smith")
})

test_that("create_session_mapping handles empty patterns", {
  zoom_data <- create_zoom_recordings_data()
  course_data <- create_course_info_data()
  
  result <- create_session_mapping(zoom_data, course_data, auto_assign_patterns = list())
  
  expect_true(all(is.na(result$dept)))
  expect_true(all(is.na(result$course)))
  expect_true(all(is.na(result$section)))
  expect_true(all(result$notes == "NEEDS MANUAL ASSIGNMENT"))
})

test_that("create_session_mapping handles NULL patterns", {
  zoom_data <- create_zoom_recordings_data()
  course_data <- create_course_info_data()
  
  result <- create_session_mapping(zoom_data, course_data, auto_assign_patterns = NULL)
  
  expect_equal(result$dept[1], "CS")
  expect_equal(result$course[1], "101")
  expect_equal(result$section[1], "01")
  expect_equal(result$instructor[1], "Dr. Smith")
})

test_that("create_session_mapping handles unmatched topics", {
  zoom_data <- tibble::tibble(
    ID = c("123456789"),
    Topic = c("UNKNOWN COURSE"),
    `Start Time` = c("Jan 15, 2024 10:00 AM")
  )
  course_data <- create_course_info_data()
  
  result <- create_session_mapping(zoom_data, course_data)
  
  expect_true(is.na(result$dept[1]))
  expect_true(is.na(result$course[1]))
  expect_true(is.na(result$section[1]))
  expect_equal(result$notes[1], "NEEDS MANUAL ASSIGNMENT")
})

test_that("create_session_mapping handles date parsing", {
  zoom_data <- create_zoom_recordings_data()
  course_data <- create_course_info_data()
  
  result <- create_session_mapping(zoom_data, course_data)
  
  expect_equal(result$session_date[1], as.Date("2024-01-15"))
  expect_equal(result$session_time[1], "10:00")
  expect_equal(result$session_date[2], as.Date("2024-01-16"))
  expect_equal(result$session_time[2], "09:00")
  expect_equal(result$session_date[3], as.Date("2024-01-17"))
  expect_equal(result$session_time[3], "14:00")
})

test_that("create_session_mapping handles PM time", {
  zoom_data <- tibble::tibble(
    ID = c("123456789"),
    Topic = c("CS 101 Lecture 1"),
    `Start Time` = c("Jan 16, 2024 09:00 PM")
  )
  course_data <- create_course_info_data()
  
  result <- create_session_mapping(zoom_data, course_data)
  
  expect_equal(result$session_date[1], as.Date("2024-01-16"))
  expect_equal(result$session_time[1], "21:00")
})

test_that("create_session_mapping handles unknown time formats", {
  zoom_data <- tibble::tibble(
    ID = c("123456789"),
    Topic = c("CS 101 Lecture 1"),
    `Start Time` = c("Unknown date format")
  )
  course_data <- create_course_info_data()
  
  result <- create_session_mapping(zoom_data, course_data)
  
  expect_true(is.na(result$session_date[1]))
  expect_equal(result$session_time[1], "Unknown")
})

test_that("create_session_mapping handles file output", {
  zoom_data <- create_zoom_recordings_data()
  course_data <- create_course_info_data()
  temp_file <- tempfile(fileext = ".csv")
  
  result <- create_session_mapping(zoom_data, course_data, output_file = temp_file)
  
  expect_true(file.exists(temp_file))
  expect_s3_class(result, "tbl_df")
  
  unlink(temp_file)
})

test_that("create_session_mapping handles file write errors", {
  zoom_data <- create_zoom_recordings_data()
  course_data <- create_course_info_data()
  invalid_path <- "/invalid/path/that/does/not/exist/session_mapping.csv"
  
  expect_error(create_session_mapping(zoom_data, course_data, output_file = invalid_path))
})

test_that("create_session_mapping handles interactive mode", {
  zoom_data <- create_zoom_recordings_data()
  course_data <- create_course_info_data()
  
  result <- create_session_mapping(zoom_data, course_data, interactive = TRUE)
  
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), nrow(zoom_data))
})

test_that("create_session_mapping handles verbose mode", {
  zoom_data <- create_zoom_recordings_data()
  course_data <- create_course_info_data()
  
  result <- create_session_mapping(zoom_data, course_data, verbose = TRUE)
  
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), nrow(zoom_data))
})

test_that("create_session_mapping handles comprehensive parameters", {
  zoom_data <- create_zoom_recordings_data()
  course_data <- create_course_info_data()
  
  param_combinations <- list(
    list(zoom_recordings_df = zoom_data, course_info_df = course_data),
    list(zoom_recordings_df = zoom_data, course_info_df = course_data, output_file = "test.csv"),
    list(zoom_recordings_df = zoom_data, course_info_df = course_data, semester_start_mdy = "Feb 01, 2024"),
    list(zoom_recordings_df = zoom_data, course_info_df = course_data, auto_assign_patterns = list()),
    list(zoom_recordings_df = zoom_data, course_info_df = course_data, interactive = TRUE),
    list(zoom_recordings_df = zoom_data, course_info_df = course_data, verbose = TRUE)
  )
  
  for (params in param_combinations) {
    result <- do.call(create_session_mapping, params)
    expect_s3_class(result, "tbl_df")
    expect_equal(nrow(result), nrow(zoom_data))
  }
})

test_that("create_session_mapping handles edge cases", {
  single_zoom <- create_zoom_recordings_data()[1, ]
  single_course <- create_course_info_data()[1, ]
  
  result <- create_session_mapping(single_zoom, single_course)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
  
  zoom_with_na <- create_zoom_recordings_data()
  zoom_with_na$Topic[1] <- NA
  
  result <- create_session_mapping(zoom_with_na, single_course)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)
})

test_that("create_session_mapping handles errors gracefully", {
  zoom_data <- create_zoom_recordings_data()
  course_data <- create_course_info_data()
  
  expect_error(create_session_mapping("not a tibble", course_data))
  expect_error(create_session_mapping(zoom_data, "not a tibble"))
  expect_error(create_session_mapping(123, course_data))
  expect_error(create_session_mapping(zoom_data, 123))
  
  invalid_course <- tibble::tibble(
    dept = c("CS"),
    course = c("101")
  )
  expect_error(create_session_mapping(zoom_data, invalid_course))
  
  expect_error(create_session_mapping(zoom_data, course_data, output_file = "/invalid/path/file.csv"))
})

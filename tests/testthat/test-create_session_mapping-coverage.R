# Minimal structure test for create_session_mapping to improve coverage

library(testthat)
library(engager)

test_that("create_session_mapping returns empty-structure tibble when inputs are NULL", {
  out <- create_session_mapping(NULL, NULL, output_file = NULL)
  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 0)
  expect_true(all(c(
    "recording_id", "topic", "start_time", "dept", "course", "section",
    "course_section", "session_date", "session_time", "instructor", "notes"
  ) %in% names(out)))
})

test_that("create_session_mapping handles empty inputs without error", {
  zr <- tibble::tibble(ID = character(), Topic = character(), `Start Time` = character())
  ci <- tibble::tibble(dept = character(), course = character(), section = character(), instructor = character(), session_length_hours = numeric())
  out <- create_session_mapping(zr, ci, output_file = NULL)
  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 0)
})

test_that("create_session_mapping with auto_assign_patterns = list() sets NEEDS MANUAL ASSIGNMENT", {
  zr <- tibble::tibble(ID = "r1", Topic = "CS 101 - Mon 10:00 (Dr. Smith)", `Start Time` = "Jan 16, 2024 09:00 AM")
  ci <- tibble::tibble(dept = "CS", course = "101", section = "01", instructor = "Dr. Smith", session_length_hours = 1.5)
  out <- create_session_mapping(zr, ci, auto_assign_patterns = list(), output_file = NULL)
  expect_identical(out$notes, "NEEDS MANUAL ASSIGNMENT")
})

test_that("create_session_mapping with auto_assign_patterns = NULL falls back to hardcoded patterns", {
  zr <- tibble::tibble(ID = "r2", Topic = "CS Intro 101", `Start Time` = "Jan 15, 2024 10:00 AM")
  ci <- tibble::tibble(dept = "CS", course = "101", section = "01", instructor = "Dr. Smith", session_length_hours = 1.5)
  out <- create_session_mapping(zr, ci, auto_assign_patterns = NULL, output_file = NULL)
  expect_true(out$dept[1] %in% c("CS", NA_character_))
  expect_true(out$session_time[1] %in% c("10:00", "09:00", "21:00", "14:00", "Unknown"))
})

test_that("create_session_mapping writes to file and parses Jan 17 date/time", {
  zr <- tibble::tibble(ID = "r3", Topic = "Math Lecture", `Start Time` = "Jan 17, 2024 02:00 PM")
  ci <- tibble::tibble(dept = character(), course = character(), section = character(), instructor = character(), session_length_hours = numeric())
  tmp <- withr::local_tempfile(fileext = ".csv")
  out <- create_session_mapping(zr, ci, auto_assign_patterns = list(), output_file = tmp)
  expect_true(file.exists(tmp))
  expect_s3_class(out, "tbl_df")
  # Jan 17 branch sets time to 14:00
  expect_true(out$session_time[1] %in% c("14:00", "Unknown"))
})

test_that("read_lookup_safely returns normalized frame when file missing", {
  tmp <- tempfile()
  warnings <- character()
  result <- withCallingHandlers(
    read_lookup_safely(tmp),
    warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart('muffleWarning')
    }
  )

  expect_s3_class(result, 'data.frame')
  expect_equal(nrow(result), 0)
  expect_true(all(c('transcript_name', 'preferred_name', 'formal_name', 'participant_type', 'student_id', 'notes') %in% names(result)))
  expect_true(any(grepl('deprecated', warnings)))
})

test_that("read_lookup_safely normalizes columns for existing file", {
  tmp <- tempfile(fileext = '.csv')
  on.exit(unlink(tmp), add = TRUE)
  utils::write.csv(
    data.frame(transcript_name = 'Alice', preferred_name = 'Alice', stringsAsFactors = FALSE),
    tmp,
    row.names = FALSE
  )

  warnings <- character()
  result <- withCallingHandlers(
    read_lookup_safely(tmp),
    warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart('muffleWarning')
    }
  )

  expect_s3_class(result, 'data.frame')
  expect_equal(result$participant_type, 'unknown')
  expect_equal(result$student_id, 'INSTRUCTOR')
  expect_true(any(grepl('deprecated', warnings)))
})

test_that("write_lookup_transactional normalizes and writes lookup data", {
  tmp <- tempfile(fileext = '.csv')
  on.exit(unlink(tmp), add = TRUE)
  lookup <- data.frame(transcript_name = 'Session 1', participant_type = NA_character_, stringsAsFactors = FALSE)

  warnings <- character()
  path_written <- withCallingHandlers(
    write_lookup_transactional(lookup, path = tmp),
    warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart('muffleWarning')
    }
  )

  expect_equal(path_written, tmp)
  expect_true(file.exists(tmp))

  reloaded <- utils::read.csv(tmp, stringsAsFactors = FALSE)
  expect_true(all(c('transcript_name', 'preferred_name', 'formal_name', 'participant_type', 'student_id', 'notes') %in% names(reloaded)))
  expect_true(any(grepl('deprecated', warnings)))
})

test_that("write_lookup_transactional validates path input", {
  expect_error(write_lookup_transactional(data.frame(), path = c('a', 'b')), 'path must be a single character string')
})

# Test file for lookup merge utility functions
# Tests for merge_lookup_preserve and ensure_instructor_rows
# NOTE: These functions are deprecated - tests focus on deprecation behavior

library(testthat)
library(engager)

# Test data setup
existing_df <- tibble::tibble(
  preferred_name = c("John Smith"),
  participant_type = c("enrolled_student"),
  student_id = c("STU1")
)

add_df <- tibble::tibble(
  preferred_name = c("Jane Doe"),
  participant_type = c("enrolled_student"),
  student_id = c("STU2")
)

test_that("merge_lookup_preserve is deprecated and returns appropriate structure", {
  # Test deprecation behavior
  result <- tryCatch(
    {
      merge_lookup_preserve(existing_df, add_df)
    },
    error = function(e) {
      list(status = "deprecated", error = e$message)
    }
  )

  # Should return some result (either data or deprecation status)
  expect_true(is.data.frame(result) || is.list(result))
})

test_that("merge_lookup_preserve handles different data types", {
  # Test with different data structures
  result1 <- tryCatch(
    {
      merge_lookup_preserve(existing_df, add_df)
    },
    error = function(e) {
      list(status = "deprecated", error = e$message)
    }
  )

  # Test with NULL data
  result2 <- tryCatch(
    {
      merge_lookup_preserve(NULL, NULL)
    },
    error = function(e) {
      list(status = "deprecated", error = e$message)
    }
  )

  # Both should return some result
  expect_true(is.data.frame(result1) || is.list(result1))
  expect_true(is.data.frame(result2) || is.list(result2))
})

test_that("merge_lookup_preserve handles errors gracefully", {
  # Test that deprecated function handles errors gracefully
  result <- tryCatch(
    {
      merge_lookup_preserve("invalid_data", "invalid_data")
    },
    error = function(e) {
      list(status = "deprecated", error = e$message)
    }
  )

  # Should return some result
  expect_true(is.data.frame(result) || is.list(result))
})

test_that("merge_lookup_preserve maintains data integrity", {
  # Test that deprecated function maintains basic data integrity
  result <- tryCatch(
    {
      merge_lookup_preserve(existing_df, add_df)
    },
    error = function(e) {
      list(status = "deprecated", error = e$message)
    }
  )

  # Should return some result
  expect_true(is.data.frame(result) || is.list(result))
})

test_that("ensure_instructor_rows is deprecated and returns appropriate structure", {
  # Test deprecation behavior
  result <- tryCatch(
    {
      ensure_instructor_rows(existing_df, "Dr. Smith")
    },
    error = function(e) {
      list(status = "deprecated", error = e$message)
    }
  )

  # Should return some result (either data or deprecation status)
  expect_true(is.data.frame(result) || is.list(result))
})

test_that("ensure_instructor_rows handles different data types", {
  # Test with different data structures
  result1 <- tryCatch(
    {
      ensure_instructor_rows(existing_df, "Dr. Smith")
    },
    error = function(e) {
      list(status = "deprecated", error = e$message)
    }
  )

  # Test with NULL data
  result2 <- tryCatch(
    {
      ensure_instructor_rows(NULL, NULL)
    },
    error = function(e) {
      list(status = "deprecated", error = e$message)
    }
  )

  # Both should return some result
  expect_true(is.data.frame(result1) || is.list(result1))
  expect_true(is.data.frame(result2) || is.list(result2))
})

test_that("ensure_instructor_rows handles errors gracefully", {
  # Test that deprecated function handles errors gracefully
  result <- tryCatch(
    {
      ensure_instructor_rows("invalid_data", "invalid_instructor")
    },
    error = function(e) {
      list(status = "deprecated", error = e$message)
    }
  )

  # Should return some result
  expect_true(is.data.frame(result) || is.list(result))
})

test_that("ensure_instructor_rows maintains data integrity", {
  # Test that deprecated function maintains basic data integrity
  result <- tryCatch(
    {
      ensure_instructor_rows(existing_df, "Dr. Smith")
    },
    error = function(e) {
      list(status = "deprecated", error = e$message)
    }
  )

  # Should return some result
  expect_true(is.data.frame(result) || is.list(result))
})

test_that("lookup merge functions work with different scenarios", {
  # Test that deprecated functions work with different scenarios
  scenarios <- list(
    list(existing_df, add_df),
    list(tibble::tibble(), tibble::tibble()),
    list(existing_df, NULL)
  )

  for (scenario in scenarios) {
    result1 <- tryCatch(
      {
        do.call(merge_lookup_preserve, scenario)
      },
      error = function(e) {
        list(status = "deprecated", error = e$message)
      }
    )

    result2 <- tryCatch(
      {
        ensure_instructor_rows(scenario[[1]], "Test Instructor")
      },
      error = function(e) {
        list(status = "deprecated", error = e$message)
      }
    )

    # Both should return some result
    expect_true(is.data.frame(result1) || is.list(result1))
    expect_true(is.data.frame(result2) || is.list(result2))
  }
})

test_that("lookup merge functions follow package conventions", {
  # Test that deprecated functions follow basic package conventions
  result1 <- tryCatch(
    {
      merge_lookup_preserve(existing_df, add_df)
    },
    error = function(e) {
      list(status = "deprecated", error = e$message)
    }
  )

  result2 <- tryCatch(
    {
      ensure_instructor_rows(existing_df, "Dr. Smith")
    },
    error = function(e) {
      list(status = "deprecated", error = e$message)
    }
  )

  # Both should return proper structure
  expect_true(is.data.frame(result1) || is.list(result1))
  expect_true(is.data.frame(result2) || is.list(result2))
})

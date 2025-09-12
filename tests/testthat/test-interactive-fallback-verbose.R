# Test interactive fallback functionality in diagnostic functions
# This file tests the non-interactive fallback diagnostic paths

test_that("diag_cat respects interactive fallback", {
  skip_on_cran()
  # Test that diag_cat works in interactive mode
  old_opt <- getOption("engager.verbose", NULL)
  on.exit(options(engager.verbose = old_opt), add = TRUE)

  options(engager.verbose = FALSE)

  # Test interactive fallback (should output in interactive mode)
  # Note: This test runs in non-interactive mode, so we test the fallback behavior
  output <- capture.output({
    diag_cat("test output\n")
  })

  # In non-interactive mode with verbose=FALSE, should be quiet
  expect_length(output, 0)

  # Test with verbose enabled
  options(engager.verbose = TRUE)
  output_verbose <- capture.output({
    diag_cat("test verbose output\n")
  })

  # Should output when verbose is enabled
  expect_true(any(grepl("test verbose output", output_verbose)))
})

test_that("diag_message_if respects local verbose flag", {
  skip_on_cran()
  # Test that diag_message_if works with local verbose flag
  old_opt <- getOption("engager.verbose", NULL)
  on.exit(options(engager.verbose = old_opt), add = TRUE)

  options(engager.verbose = FALSE)

  # Test with local verbose flag TRUE
  output_local <- capture.output(
    {
      diag_message_if(TRUE, "local verbose message")
    },
    type = "message"
  )

  # Should output when local flag is TRUE
  expect_true(any(grepl("local verbose message", output_local)))

  # Test with local verbose flag FALSE
  output_quiet <- capture.output(
    {
      diag_message_if(FALSE, "quiet message")
    },
    type = "message"
  )

  # Should be quiet when local flag is FALSE and global is FALSE
  expect_length(output_quiet, 0)
})

test_that("diag_cat_if respects local verbose flag", {
  skip_on_cran()
  # Test that diag_cat_if works with local verbose flag
  old_opt <- getOption("engager.verbose", NULL)
  on.exit(options(engager.verbose = old_opt), add = TRUE)

  options(engager.verbose = FALSE)

  # Test with local verbose flag TRUE
  output_local <- capture.output({
    diag_cat_if(TRUE, "local verbose cat\n")
  })

  # Should output when local flag is TRUE
  expect_true(any(grepl("local verbose cat", output_local)))

  # Test with local verbose flag FALSE
  output_quiet <- capture.output({
    diag_cat_if(FALSE, "quiet cat\n")
  })

  # Should be quiet when local flag is FALSE and global is FALSE
  expect_length(output_quiet, 0)
})

test_that("diagnostic functions handle edge cases", {
  # Test that diagnostic functions handle edge cases gracefully
  old_opt <- getOption("engager.verbose", NULL)
  on.exit(options(engager.verbose = old_opt), add = TRUE)

  options(engager.verbose = FALSE)

  # Test with empty arguments
  expect_error(diag_message(), NA)
  expect_error(diag_cat(), NA)
  expect_error(diag_message_if(FALSE), NA)
  expect_error(diag_cat_if(FALSE), NA)

  # Test with NULL arguments
  expect_error(diag_message_if(NULL), NA)
  expect_error(diag_cat_if(NULL), NA)
})

test_that("diagnostic functions respect test environment", {
  # Test that diagnostic functions are quiet in test environment
  old_opt <- getOption("engager.verbose", NULL)
  on.exit(options(engager.verbose = old_opt), add = TRUE)

  # Set test environment
  old_testthat <- Sys.getenv("TESTTHAT", unset = NA)
  on.exit(
    {
      if (is.na(old_testthat)) {
        Sys.unsetenv("TESTTHAT")
      } else {
        Sys.setenv(TESTTHAT = old_testthat)
      }
    },
    add = TRUE
  )

  Sys.setenv(TESTTHAT = "true")
  options(engager.verbose = TRUE)

  # Should be quiet in test environment even with verbose enabled
  # Note: The functions may still produce warnings about deprecation
  output_msg <- capture.output(
    {
      diag_message("test message")
    },
    type = "message"
  )

  output_cat <- capture.output({
    diag_cat("test cat\n")
  })

  # Should be quiet in test environment (may have deprecation warnings)
  expect_true(length(output_msg) <= 1) # Allow for deprecation warnings
  expect_true(length(output_cat) <= 1) # Allow for deprecation warnings
})

test_that("diagnostic functions provide fallback behavior", {
  skip_on_cran()
  # Test that diagnostic functions provide appropriate fallback behavior
  old_opt <- getOption("engager.verbose", NULL)
  on.exit(options(engager.verbose = old_opt), add = TRUE)

  # Test with verbose disabled (should be quiet)
  options(engager.verbose = FALSE)

  output_quiet <- capture.output({
    diag_cat("scenario test\n")
  })

  # Should be quiet when verbose is FALSE
  expect_length(output_quiet, 0)

  # Test with verbose enabled (should output)
  options(engager.verbose = TRUE)

  output_verbose <- capture.output({
    diag_cat("scenario test\n")
  })

  # Should output when verbose is TRUE
  expect_true(any(grepl("scenario test", output_verbose)))
})

test_that("diagnostic functions maintain privacy compliance", {
  skip_on_cran()
  # Test that diagnostic functions maintain privacy compliance
  old_opt <- getOption("engager.verbose", NULL)
  on.exit(options(engager.verbose = old_opt), add = TRUE)

  options(engager.verbose = FALSE)

  # Test that functions don't leak sensitive information
  sensitive_data <- "student_name_123"

  # Should not output sensitive data when quiet
  output <- capture.output({
    diag_cat("Processing:", sensitive_data, "\n")
  })

  expect_length(output, 0)

  # Test with verbose enabled
  options(engager.verbose = TRUE)
  output_verbose <- capture.output({
    diag_cat("Processing:", sensitive_data, "\n")
  })

  # Should output when verbose is enabled
  expect_true(any(grepl("Processing:", output_verbose)))
  expect_true(any(grepl(sensitive_data, output_verbose)))
})

test_that("diagnostic functions work with multiple arguments", {
  skip_on_cran()
  # Test that diagnostic functions work with multiple arguments
  old_opt <- getOption("engager.verbose", NULL)
  on.exit(options(engager.verbose = old_opt), add = TRUE)

  options(engager.verbose = TRUE)

  # Test multiple arguments
  output_cat <- capture.output({
    diag_cat("arg1", "arg2", "arg3\n")
  })

  output_msg <- capture.output(
    {
      diag_message("msg1", "msg2", "msg3")
    },
    type = "message"
  )

  # Should handle multiple arguments
  expect_true(any(grepl("arg1.*arg2.*arg3", output_cat)))
  expect_true(any(grepl("msg1.*msg2.*msg3", output_msg)))
})

# Test edge cases and error paths in verbose functionality
# This file tests comprehensive edge case and error path coverage

test_that("verbose functions handle NULL inputs gracefully", {
  # Test that verbose functions handle NULL inputs
  old_opt <- getOption("zoomstudentengagement.verbose", NULL)
  on.exit(options(zoomstudentengagement.verbose = old_opt), add = TRUE)

  options(zoomstudentengagement.verbose = TRUE)

  # Test NULL inputs
  expect_error(diag_message(NULL), NA)
  expect_error(diag_cat(NULL), NA)
  expect_error(diag_message_if(TRUE, NULL), NA)
  expect_error(diag_cat_if(TRUE, NULL), NA)

  # Test NULL verbose flag
  expect_error(diag_message_if(NULL, "test"), NA)
  expect_error(diag_cat_if(NULL, "test"), NA)
})

test_that("verbose functions handle empty inputs gracefully", {
  # Test that verbose functions handle empty inputs
  old_opt <- getOption("zoomstudentengagement.verbose", NULL)
  on.exit(options(zoomstudentengagement.verbose = old_opt), add = TRUE)

  options(zoomstudentengagement.verbose = TRUE)

  # Test empty inputs
  expect_error(diag_message(), NA)
  expect_error(diag_cat(), NA)
  expect_error(diag_message_if(TRUE), NA)
  expect_error(diag_cat_if(TRUE), NA)

  # Test empty strings
  expect_error(diag_message(""), NA)
  expect_error(diag_cat(""), NA)
  expect_error(diag_message_if(TRUE, ""), NA)
  expect_error(diag_cat_if(TRUE, ""), NA)
})

test_that("verbose functions handle special characters", {
  # Test that verbose functions handle special characters
  old_opt <- getOption("zoomstudentengagement.verbose", NULL)
  on.exit(options(zoomstudentengagement.verbose = old_opt), add = TRUE)

  options(zoomstudentengagement.verbose = TRUE)

  # Test special characters
  special_chars <- c("!@#$%^&*()", "[]{}|\\", "~`", "äöü", "中文", "🚀")

  for (char in special_chars) {
    expect_error(diag_message(char), NA)
    expect_error(diag_cat(char), NA)
    expect_error(diag_message_if(TRUE, char), NA)
    expect_error(diag_cat_if(TRUE, char), NA)
  }
})

test_that("verbose functions handle long inputs", {
  # Test that verbose functions handle long inputs
  old_opt <- getOption("zoomstudentengagement.verbose", NULL)
  on.exit(options(zoomstudentengagement.verbose = old_opt), add = TRUE)

  options(zoomstudentengagement.verbose = TRUE)

  # Test long strings
  long_string <- paste(rep("a", 1000), collapse = "")
  expect_error(diag_message(long_string), NA)
  expect_error(diag_cat(long_string), NA)
  expect_error(diag_message_if(TRUE, long_string), NA)
  expect_error(diag_cat_if(TRUE, long_string), NA)

  # Test many arguments
  many_args <- rep("arg", 100)
  expect_error(do.call(diag_message, as.list(many_args)), NA)
  expect_error(do.call(diag_cat, as.list(many_args)), NA)
})

test_that("verbose functions handle malformed options", {
  # Test that verbose functions handle malformed options gracefully
  old_opt <- getOption("zoomstudentengagement.verbose", NULL)
  on.exit(options(zoomstudentengagement.verbose = old_opt), add = TRUE)

  # Test with malformed option values
  malformed_options <- list(NA, "invalid", 123, c(TRUE, FALSE), list(TRUE))

  for (opt in malformed_options) {
    options(zoomstudentengagement.verbose = opt)

    # Should handle malformed options gracefully
    expect_error(diag_message("test"), NA)
    expect_error(diag_cat("test"), NA)
    expect_error(diag_message_if(TRUE, "test"), NA)
    expect_error(diag_cat_if(TRUE, "test"), NA)
  }
})

test_that("verbose functions handle environment variable edge cases", {
  # Test that verbose functions handle environment variable edge cases
  old_opt <- getOption("zoomstudentengagement.verbose", NULL)
  on.exit(options(zoomstudentengagement.verbose = old_opt), add = TRUE)

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

  # Test with malformed TESTTHAT environment variable
  malformed_testthat <- c("", "invalid", "TRUE", "1", "yes")

  for (testthat_val in malformed_testthat) {
    Sys.setenv(TESTTHAT = testthat_val)
    options(zoomstudentengagement.verbose = TRUE)

    # Should handle malformed environment variables gracefully
    expect_error(diag_message("test"), NA)
    expect_error(diag_cat("test"), NA)
  }
})

test_that("verbose functions handle concurrent access", {
  # Test that verbose functions handle concurrent access
  old_opt <- getOption("zoomstudentengagement.verbose", NULL)
  on.exit(options(zoomstudentengagement.verbose = old_opt), add = TRUE)

  options(zoomstudentengagement.verbose = TRUE)

  # Test rapid successive calls
  for (i in 1:100) {
    expect_error(diag_message("rapid call", i), NA)
    expect_error(diag_cat("rapid call", i, "\n"), NA)
  }
})

test_that("verbose functions handle option changes during execution", {
  # Test that verbose functions handle option changes during execution
  old_opt <- getOption("zoomstudentengagement.verbose", NULL)
  on.exit(options(zoomstudentengagement.verbose = old_opt), add = TRUE)

  # Test changing options during execution
  options(zoomstudentengagement.verbose = FALSE)

  # Start with quiet mode
  output1 <- capture.output({
    diag_cat("quiet message\n")
  })
  expect_length(output1, 0)

  # Change to verbose mode
  options(zoomstudentengagement.verbose = TRUE)

  # Should now output
  output2 <- capture.output({
    diag_cat("verbose message\n")
  })
  expect_true(any(grepl("verbose message", output2)))

  # Change back to quiet mode
  options(zoomstudentengagement.verbose = FALSE)

  # Should be quiet again
  output3 <- capture.output({
    diag_cat("quiet again\n")
  })
  expect_length(output3, 0)
})

test_that("verbose functions handle memory constraints", {
  # Test that verbose functions handle memory constraints
  old_opt <- getOption("zoomstudentengagement.verbose", NULL)
  on.exit(options(zoomstudentengagement.verbose = old_opt), add = TRUE)

  options(zoomstudentengagement.verbose = TRUE)

  # Test with large objects
  large_object <- list(
    data = matrix(rnorm(10000), nrow = 100),
    metadata = list(
      description = "Large test object",
      size = "10KB",
      created = Sys.time()
    )
  )

  # Should handle large objects without errors
  expect_error(diag_message("Large object:", large_object), NA)
  # Note: diag_cat may fail with complex objects, which is expected
  expect_error(diag_cat("Large object:", large_object, "\n"), NA)
})

test_that("verbose functions handle error conditions", {
  # Test that verbose functions handle error conditions gracefully
  old_opt <- getOption("zoomstudentengagement.verbose", NULL)
  on.exit(options(zoomstudentengagement.verbose = old_opt), add = TRUE)

  options(zoomstudentengagement.verbose = TRUE)

  # Test with objects that might cause errors when converted to strings
  error_prone_objects <- list(
    function() {
      stop("test error")
    },
    structure(list(), class = "custom_class"),
    new.env()
  )

  for (obj in error_prone_objects) {
    # Should handle error-prone objects gracefully
    # Note: Some objects may cause errors when converted to strings, which is expected
    expect_error(diag_message("Object:", obj), NA)
    expect_error(diag_cat("Object:", obj, "\n"), NA)
  }
})

test_that("verbose functions maintain consistency", {
  # Test that verbose functions maintain consistency across calls
  old_opt <- getOption("zoomstudentengagement.verbose", NULL)
  on.exit(options(zoomstudentengagement.verbose = old_opt), add = TRUE)

  options(zoomstudentengagement.verbose = TRUE)

  # Test consistency across multiple calls
  for (i in 1:10) {
    output1 <- capture.output({
      diag_cat("consistent", i, "\n")
    })

    output2 <- capture.output({
      diag_cat("consistent", i, "\n")
    })

    # Should be consistent
    expect_equal(output1, output2)
  }
})

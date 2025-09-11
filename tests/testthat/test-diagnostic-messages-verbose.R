# Test diagnostic message handling and privacy compliance
# This file tests diagnostic message handling and privacy compliance

test_that("diagnostic messages respect privacy defaults", {
  # Test that diagnostic messages respect privacy defaults
  old_opt <- getOption("engager.verbose", NULL)
  on.exit(options(engager.verbose = old_opt), add = TRUE)

  # Test default privacy behavior (quiet by default)
  options(engager.verbose = NULL)

  output <- capture.output({
    diag_cat("sensitive information\n")
  })

  # Should be quiet by default
  expect_length(output, 0)

  # Test with explicit FALSE
  options(engager.verbose = FALSE)

  output_false <- capture.output({
    diag_cat("sensitive information\n")
  })

  # Should be quiet when explicitly set to FALSE
  expect_length(output_false, 0)
})

test_that("diagnostic messages handle sensitive data appropriately", {
  # Test that diagnostic messages handle sensitive data appropriately
  old_opt <- getOption("engager.verbose", NULL)
  on.exit(options(engager.verbose = old_opt), add = TRUE)

  # Test with sensitive data
  sensitive_data <- list(
    student_names = c("John Doe", "Jane Smith", "Bob Johnson"),
    student_ids = c("12345", "67890", "11111"),
    grades = c("A", "B", "C"),
    personal_info = list(
      age = c(20, 21, 22),
      email = c("john@example.com", "jane@example.com", "bob@example.com")
    )
  )

  # Test quiet mode (default)
  options(engager.verbose = FALSE)

  output_quiet <- capture.output({
    diag_cat("Processing student data:", sensitive_data, "\n")
  })

  # Should be quiet in default mode
  expect_length(output_quiet, 0)

  # Test verbose mode (opt-in)
  options(engager.verbose = TRUE)

  output_verbose <- capture.output({
    diag_cat("Processing student data:", sensitive_data, "\n")
  })

  # Should output when explicitly enabled
  expect_true(length(output_verbose) > 0)
})

test_that("diagnostic messages respect FERPA compliance", {
  # Test that diagnostic messages respect FERPA compliance
  old_opt <- getOption("engager.verbose", NULL)
  on.exit(options(engager.verbose = old_opt), add = TRUE)

  # Test FERPA-sensitive information
  ferpa_data <- list(
    student_records = data.frame(
      name = c("Student A", "Student B"),
      id = c("12345", "67890"),
      grade = c("A", "B"),
      attendance = c(95, 87)
    ),
    transcript_data = list(
      courses = c("Math 101", "English 102"),
      credits = c(3, 3),
      gpa = c(3.5, 3.2)
    )
  )

  # Test default behavior (should be quiet)
  options(engager.verbose = FALSE)

  output_default <- capture.output({
    diag_cat("FERPA data:", ferpa_data, "\n")
  })

  # Should be quiet by default to protect privacy
  expect_length(output_default, 0)

  # Test with explicit opt-in
  options(engager.verbose = TRUE)

  output_opt_in <- capture.output({
    diag_cat("FERPA data:", ferpa_data, "\n")
  })

  # Should output when explicitly opted in
  expect_true(length(output_opt_in) > 0)
})

test_that("diagnostic messages handle anonymized data", {
  # Test that diagnostic messages handle anonymized data appropriately
  old_opt <- getOption("engager.verbose", NULL)
  on.exit(options(engager.verbose = old_opt), add = TRUE)

  # Test with anonymized data
  anonymized_data <- list(
    participant_count = 25,
    session_duration = 90,
    engagement_metrics = c(0.8, 0.7, 0.9),
    anonymized_ids = c("P001", "P002", "P003")
  )

  # Test quiet mode
  options(engager.verbose = FALSE)

  output_quiet <- capture.output({
    diag_cat("Anonymized data:", anonymized_data, "\n")
  })

  # Should be quiet in default mode
  expect_length(output_quiet, 0)

  # Test verbose mode
  options(engager.verbose = TRUE)

  output_verbose <- capture.output({
    diag_cat("Anonymized data:", anonymized_data, "\n")
  })

  # Should output when explicitly enabled
  expect_true(length(output_verbose) > 0)
})

test_that("diagnostic messages handle error messages appropriately", {
  # Test that diagnostic messages handle error messages appropriately
  old_opt <- getOption("engager.verbose", NULL)
  on.exit(options(engager.verbose = old_opt), add = TRUE)

  # Test error messages
  error_messages <- c(
    "Error processing student data",
    "Failed to load transcript file",
    "Invalid student ID format",
    "Missing required fields"
  )

  # Test quiet mode (default)
  options(engager.verbose = FALSE)

  for (error_msg in error_messages) {
    output <- capture.output({
      diag_cat("ERROR:", error_msg, "\n")
    })

    # Should be quiet in default mode
    expect_length(output, 0)
  }

  # Test verbose mode
  options(engager.verbose = TRUE)

  for (error_msg in error_messages) {
    output <- capture.output({
      diag_cat("ERROR:", error_msg, "\n")
    })

    # Should output when explicitly enabled
    expect_true(any(grepl("ERROR:", output)))
    expect_true(any(grepl(error_msg, output)))
  }
})

test_that("diagnostic messages handle warning messages appropriately", {
  # Test that diagnostic messages handle warning messages appropriately
  old_opt <- getOption("engager.verbose", NULL)
  on.exit(options(engager.verbose = old_opt), add = TRUE)

  # Test warning messages
  warning_messages <- c(
    "Low engagement detected",
    "Missing attendance data",
    "Incomplete transcript",
    "Potential data quality issue"
  )

  # Test quiet mode (default)
  options(engager.verbose = FALSE)

  for (warning_msg in warning_messages) {
    output <- capture.output({
      diag_cat("WARNING:", warning_msg, "\n")
    })

    # Should be quiet in default mode
    expect_length(output, 0)
  }

  # Test verbose mode
  options(engager.verbose = TRUE)

  for (warning_msg in warning_messages) {
    output <- capture.output({
      diag_cat("WARNING:", warning_msg, "\n")
    })

    # Should output when explicitly enabled
    expect_true(any(grepl("WARNING:", output)))
    expect_true(any(grepl(warning_msg, output)))
  }
})

test_that("diagnostic messages handle info messages appropriately", {
  # Test that diagnostic messages handle info messages appropriately
  old_opt <- getOption("engager.verbose", NULL)
  on.exit(options(engager.verbose = old_opt), add = TRUE)

  # Test info messages
  info_messages <- c(
    "Processing transcript file",
    "Calculating engagement metrics",
    "Generating report",
    "Analysis complete"
  )

  # Test quiet mode (default)
  options(engager.verbose = FALSE)

  for (info_msg in info_messages) {
    output <- capture.output({
      diag_cat("INFO:", info_msg, "\n")
    })

    # Should be quiet in default mode
    expect_length(output, 0)
  }

  # Test verbose mode
  options(engager.verbose = TRUE)

  for (info_msg in info_messages) {
    output <- capture.output({
      diag_cat("INFO:", info_msg, "\n")
    })

    # Should output when explicitly enabled
    expect_true(any(grepl("INFO:", output)))
    expect_true(any(grepl(info_msg, output)))
  }
})

test_that("diagnostic messages maintain privacy in test environment", {
  # Test that diagnostic messages maintain privacy in test environment
  old_opt <- getOption("engager.verbose", NULL)
  on.exit(options(engager.verbose = old_opt), add = TRUE)

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

  # Set test environment
  Sys.setenv(TESTTHAT = "true")
  options(engager.verbose = TRUE)

  # Test with sensitive data in test environment
  sensitive_data <- "student_name_123"

  output <- capture.output({
    diag_cat("Sensitive data:", sensitive_data, "\n")
  })

  # Should be quiet in test environment even with verbose enabled
  expect_length(output, 0)

  # Test message output in test environment
  output_msg <- capture.output(
    {
      diag_message("Sensitive data:", sensitive_data)
    },
    type = "message"
  )

  # Should be quiet in test environment
  expect_length(output_msg, 0)
})

test_that("diagnostic messages handle mixed content appropriately", {
  # Test that diagnostic messages handle mixed content appropriately
  old_opt <- getOption("engager.verbose", NULL)
  on.exit(options(engager.verbose = old_opt), add = TRUE)

  # Test mixed content (safe and sensitive)
  mixed_content <- list(
    safe_info = "Processing complete",
    sensitive_info = "Student John Doe (ID: 12345)",
    metrics = c(0.8, 0.7, 0.9),
    timestamp = Sys.time()
  )

  # Test quiet mode (default)
  options(engager.verbose = FALSE)

  output_quiet <- capture.output({
    diag_cat("Mixed content:", mixed_content, "\n")
  })

  # Should be quiet in default mode
  expect_length(output_quiet, 0)

  # Test verbose mode
  options(engager.verbose = TRUE)

  output_verbose <- capture.output({
    diag_cat("Mixed content:", mixed_content, "\n")
  })

  # Should output when explicitly enabled
  expect_true(length(output_verbose) > 0)
})

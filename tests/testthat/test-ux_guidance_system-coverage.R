# Coverage-focused tests for UX guidance helpers

test_that("show_getting_started prints key onboarding guidance", {
  output <- capture.output(show_getting_started())
  expect_true(any(grepl("Getting Started", output, fixed = TRUE)))
  expect_true(any(grepl("BASIC WORKFLOW", output, fixed = TRUE)))
  expect_true(any(grepl("QUICK START", output, fixed = TRUE)))
})

test_that("show_workflow_help lists multiple workflow options", {
  output <- capture.output(show_workflow_help())
  expect_true(any(grepl("Available Workflows", output, fixed = TRUE)))
  expect_true(any(grepl("Batch Workflow", output, fixed = TRUE)))
  expect_true(any(grepl("Advanced Workflows", output, fixed = TRUE)))
})

test_that("show_privacy_guidance emphasizes privacy best practices", {
  output <- capture.output(show_privacy_guidance())
  expect_true(any(grepl("Privacy & Ethics Guidance", output, fixed = TRUE)))
  expect_true(any(grepl("ensure_privacy()", output, fixed = TRUE)))
  expect_true(any(grepl("FERPA", output)))
})

test_that("show_troubleshooting provides actionable suggestions", {
  output <- capture.output(show_troubleshooting())
  expect_true(any(grepl("Troubleshooting Guide", output, fixed = TRUE)))
  expect_true(any(grepl("Common Issues", output, fixed = TRUE)))
  expect_true(any(grepl("Getting More Help", output, fixed = TRUE)))
})

test_that("show_function_help handles unknown functions gracefully", {
  dummy_ns <- new.env(parent = emptyenv())
  output <- testthat::with_mocked_bindings(
    capture.output(show_function_help("totally_missing")),
    asNamespace = function(ns) {
      expect_equal(ns, "zoomstudentengagement")
      dummy_ns
    },
    .package = "engager"
  )
  expect_true(any(grepl("Function 'totally_missing' not found", output, fixed = TRUE)))
  expect_true(any(grepl("TIP: Try: show_available_functions()", output, fixed = TRUE)))
})

test_that("show_function_help categorizes essential functions", {
  dummy_ns <- new.env(parent = emptyenv())
  dummy_ns$basic_transcript_analysis <- function(...) NULL
  output <- testthat::with_mocked_bindings(
    capture.output(show_function_help("basic_transcript_analysis")),
    asNamespace = function(ns) {
      expect_equal(ns, "zoomstudentengagement")
      dummy_ns
    },
    .package = "engager"
  )
  expect_true(any(grepl("Essential Function", output, fixed = TRUE)))
  expect_true(any(grepl("TIP: Usage Examples", output, fixed = TRUE)))
})

test_that("show_function_help falls back to generic labeling when uncategorized", {
  dummy_ns <- new.env(parent = emptyenv())
  dummy_ns$custom_helper <- function(...) NULL
  output <- testthat::with_mocked_bindings(
    capture.output(show_function_help("custom_helper")),
    asNamespace = function(ns) {
      expect_equal(ns, "zoomstudentengagement")
      dummy_ns
    },
    .package = "engager"
  )
  expect_true(any(grepl("Function:  custom_helper", output, fixed = TRUE)))
})

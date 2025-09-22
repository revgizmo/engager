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
  output <- capture.output(show_function_help("totally_missing"))
  # Allow spaces injected by cat() between quoted tokens
  expect_true(any(grepl("ERROR: Function '\\s*totally_missing\\s*' not found", output)))
  expect_true(any(grepl("TIP: Try: show_available_functions\\(\\)", output)))
})

test_that("show_function_help categorizes essential functions", {
  output <- capture.output(show_function_help("basic_transcript_analysis"))
  expect_true(any(grepl("Essential Function", output, fixed = TRUE)))
  expect_true(any(grepl("TIP: Usage Examples", output, fixed = TRUE)))
})

test_that("show_function_help prints a category header for known functions", {
  # Choose a known function; accept any category header or generic label
  output <- capture.output(show_function_help("load_roster"))
  expect_true(any(grepl("Essential Function|Common Function|Advanced Function|Expert Function|Function:", output)))
})

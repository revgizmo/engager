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
  expect_true(any(grepl("review_privacy_risks()", output, fixed = TRUE)))
})

test_that("show_troubleshooting provides actionable suggestions", {
  output <- capture.output(show_troubleshooting())
  expect_true(any(grepl("Troubleshooting Guide", output, fixed = TRUE)))
  expect_true(any(grepl("Common Issues", output, fixed = TRUE)))
  expect_true(any(grepl("Getting More Help", output, fixed = TRUE)))
})

test_that("exported onboarding recommends only callable public functions", {
  format_error_output <- tryCatch(
    user_friendly_error(stop("invalid transcript format"), "loading transcript"),
    error = function(e) conditionMessage(e)
  )
  expect_match(format_error_output, "show_function_help\\('load_zoom_transcript'\\)")
  expect_false(grepl("validate_schema", format_error_output, fixed = TRUE))

  outputs <- c(
    capture.output(show_getting_started()),
    format_error_output,
    capture.output(show_workflow_help()),
    capture.output(show_privacy_guidance()),
    capture.output(show_troubleshooting()),
    unlist(lapply(
      c("load", "process", "analyze", "visualize", "export", "privacy", "batch", "validate"),
      function(task) capture.output(find_function_for_task(task))
    )),
    unlist(lapply(
      c("new user", "batch", "privacy", "visual", "export", "error"),
      function(context) capture.output(get_smart_recommendations(context))
    )),
    capture.output(show_available_functions("expert")),
    capture.output(show_function_categories())
  )
  matches <- unlist(regmatches(
    outputs,
    gregexpr("[A-Za-z][A-Za-z0-9_.:]*[(]", outputs, perl = TRUE)
  ))
  calls <- sort(unique(sub("[(]$", "", matches)))
  allowed_external_calls <- c("c", "list.files", "utils::help", "vignette")
  unexpected_calls <- setdiff(
    calls,
    c(getNamespaceExports("engager"), allowed_external_calls)
  )

  expect_length(unexpected_calls, 0)
})

test_that("show_function_help handles unknown functions gracefully", {
  dummy_ns <- new.env(parent = emptyenv())
  # Mock the engager namespace lookup so we can exercise
  # show_function_help() logic without depending on real namespace contents.
  output <- testthat::with_mocked_bindings(
    capture.output(show_function_help("totally_missing")),
    asNamespace = function(ns) {
      expect_equal(ns, "engager")
      dummy_ns
    },
    .package = "base"
  )
  expect_true(any(grepl("ERROR: Function .* totally_missing .* not found", output)))
  expect_true(any(grepl("TIP: Try: show_available_functions\\(\\)", output)))
})

test_that("show_function_help categorizes essential functions", {
  dummy_ns <- new.env(parent = emptyenv())
  dummy_ns$basic_transcript_analysis <- function(...) NULL
  # Reuse mocked namespace binding to avoid depending on the actual package namespace.
  output <- testthat::with_mocked_bindings(
    capture.output(show_function_help("basic_transcript_analysis")),
    asNamespace = function(ns) {
      expect_equal(ns, "engager")
      dummy_ns
    },
    .package = "base"
  )
  expect_true(any(grepl("Essential Function", output, fixed = TRUE)))
  expect_true(any(grepl("TIP: Usage Examples", output, fixed = TRUE)))
  expect_true(any(grepl("DOCS: Documentation", output, fixed = TRUE)))
  expect_false(any(grepl("No documentation available", output, fixed = TRUE)))
})

test_that("show_function_help falls back to generic labeling when uncategorized", {
  dummy_ns <- new.env(parent = emptyenv())
  dummy_ns$custom_helper <- function(...) NULL
  # Reuse mocked namespace binding to avoid depending on the actual package namespace.
  output <- testthat::with_mocked_bindings(
    capture.output(show_function_help("custom_helper")),
    asNamespace = function(ns) {
      expect_equal(ns, "engager")
      dummy_ns
    },
    .package = "base"
  )
  expect_true(any(grepl("Function:\\s+custom_helper", output)))
  expect_true(any(grepl("No documentation available", output, fixed = TRUE)))
})

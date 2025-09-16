test_that("scope reduction accessors expose expected constants", {
  expect_type(get_essential_functions(), "character")
  expect_true(length(get_essential_functions()) >= 1)
  expect_identical(get_essential_functions(), engager:::ESSENTIAL_FUNCTIONS)

  expect_type(get_deprecated_functions(), "character")
  expect_identical(get_deprecated_functions(), engager:::DEPRECATED_FUNCTIONS)

  expect_type(get_internal_functions(), "character")
  expect_identical(get_internal_functions(), engager:::INTERNAL_FUNCTIONS)
})

test_that("get_scope_reduction_summary reports consistent metrics", {
  summary <- get_scope_reduction_summary()

  expect_true(all(c(
    "current_functions", "target_functions", "essential_functions",
    "deprecated_functions", "internal_functions",
    "reduction_percentage", "functions_to_remove"
  ) %in% names(summary)))

  expect_equal(summary$essential_functions, length(get_essential_functions()))
  expect_equal(summary$deprecated_functions, length(get_deprecated_functions()))
  expect_equal(summary$internal_functions, length(get_internal_functions()))

  expected_reduction <- round((summary$current_functions - summary$target_functions) /
    summary$current_functions * 100, 1)
  expect_equal(summary$reduction_percentage, expected_reduction)
  expect_equal(summary$functions_to_remove, summary$current_functions - summary$target_functions)
})

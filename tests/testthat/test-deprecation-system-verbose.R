# Test verbose branches in deprecation system
# This file tests the diagnostic output and verbose functionality

test_that("deprecation warning generation works correctly", {
  skip_on_cran()
  # Test basic deprecation warning
  warning_msg <- add_deprecation_warning("old_function")
  expect_true(is.character(warning_msg))
  expect_true(grepl("deprecated", warning_msg))
  expect_true(grepl("old_function", warning_msg))
  expect_true(grepl("2.0.0", warning_msg))

  # Test deprecation warning with replacement
  warning_msg_with_replacement <- add_deprecation_warning("old_function", "new_function")
  expect_true(grepl("new_function", warning_msg_with_replacement))
  expect_true(grepl("instead", warning_msg_with_replacement))

  # Test deprecation warning with custom version
  warning_msg_custom <- add_deprecation_warning("old_function", "new_function", "1.5.0")
  expect_true(grepl("1.5.0", warning_msg_custom))
})

test_that("migration guide generation works correctly", {
  skip_on_cran()
  # Test migration guide generation
  deprecated_functions <- c("old_function1", "old_function2")
  migration_recommendations <- list(
    old_function1 = "Use new_function1 instead",
    old_function2 = "Use new_function2 instead"
  )

  # Test without verbose (should be silent)
  output_silent <- capture.output({
    guide_silent <- generate_migration_guide(deprecated_functions, migration_recommendations)
  })
  expect_true(length(output_silent) == 0)

  # Test with verbose enabled
  old_option <- getOption("zoomse.verbose", FALSE)
  options(zoomse.verbose = TRUE)
  on.exit(options(zoomse.verbose = old_option))

  output_verbose <- capture.output(
    {
      guide_verbose <- generate_migration_guide(deprecated_functions, migration_recommendations)
    },
    type = "message"
  )

  # Should produce output when verbose is enabled
  expect_true(length(output_verbose) > 0)
  expect_true(any(grepl("Generating migration guide", output_verbose)))

  # Should generate guide content
  expect_true(is.character(guide_verbose))
  expect_true(grepl("Migration Guide", guide_verbose))
  expect_true(grepl("old_function1", guide_verbose))
  expect_true(grepl("old_function2", guide_verbose))
})

test_that("namespace update for deprecation works", {
  skip_on_cran()
  # Test namespace update function
  mock_functions <- c("function1", "function2", "function3")
  mock_deprecated <- c("function2")

  # Test that namespace update works
  expect_error(update_namespace_for_deprecation(mock_functions, mock_deprecated), NA)
})

test_that("deprecation system handles edge cases", {
  skip_on_cran()
  # Test with empty inputs
  empty_functions <- character(0)
  empty_deprecated <- character(0)
  empty_recommendations <- list()

  # Should handle empty inputs gracefully
  expect_error(generate_migration_guide(empty_functions, empty_recommendations), NA)
  expect_error(update_namespace_for_deprecation(empty_functions, empty_deprecated), NA)

  # Test with NULL inputs
  expect_error(add_deprecation_warning(NULL), NA)
  expect_error(add_deprecation_warning("test", NULL), NA)
})

test_that("deprecation system respects quiet mode", {
  # Test that deprecation functions can run without verbose output when needed
  deprecated_functions <- c("test_function")
  migration_recommendations <- list(test_function = "Use new_test_function instead")

  # Should be able to generate guide without errors
  expect_error(generate_migration_guide(deprecated_functions, migration_recommendations), NA)

  # Should be able to update namespace without errors
  expect_error(update_namespace_for_deprecation(c("test_function"), character(0)), NA)
})

test_that("deprecation warnings are properly formatted", {
  # Test warning message formatting
  warning_msg <- add_deprecation_warning("test_function", "replacement_function", "1.0.0")

  # Should contain all required elements
  expect_true(grepl("Function 'test_function' is deprecated", warning_msg))
  expect_true(grepl("will be removed in version 1.0.0", warning_msg))
  expect_true(grepl("Use 'replacement_function' instead", warning_msg))
  expect_true(grepl("See \\?test_function for migration guidance", warning_msg))
})

test_that("migration guide includes all necessary sections", {
  # Test comprehensive migration guide
  deprecated_functions <- c("old_func1", "old_func2")
  migration_recommendations <- list(
    old_func1 = "Use new_func1 instead",
    old_func2 = "Use new_func2 instead"
  )

  guide <- generate_migration_guide(deprecated_functions, migration_recommendations)

  # Should include all necessary sections
  expect_true(grepl("# Function Migration Guide", guide))
  expect_true(grepl("migrate from deprecated functions", guide))
  expect_true(grepl("old_func1", guide))
  expect_true(grepl("old_func2", guide))
  expect_true(grepl("new_func1", guide))
  expect_true(grepl("new_func2", guide))
})

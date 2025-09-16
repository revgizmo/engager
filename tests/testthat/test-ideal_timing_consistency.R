test_that("vldtdltmngcnsstncy requires transcript data", {
  warnings <- character()

  expect_error(
    withCallingHandlers(
      vldtdltmngcnsstncy(NULL),
      warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    ),
    "transcript_data cannot be NULL"
  )

  expect_true(any(grepl("deprecated", warnings)))
})

test_that("vldtdltmngcnsstncy detects missing timing columns", {
  data_missing <- tibble::tibble(name = c("Speaker"))

  warnings <- character()
  result <- withCallingHandlers(
    vldtdltmngcnsstncy(data_missing),
    warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )

  expect_equal(result$status, "FAIL")
  expect_true("missing_timing_columns" %in% names(result$issues))
  expect_true(any(grepl("deprecated", warnings)))
})

test_that("vldtdltmngcnsstncy returns pass for consistent timing data", {
  consistent <- tibble::tibble(
    name = c("Instructor", "Student", "Instructor"),
    start = c(0, 60, 120),
    end = c(30, 90, 150)
  )

  warnings <- character()
  result <- withCallingHandlers(
    vldtdltmngcnsstncy(consistent),
    warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )

  expect_equal(result$status, "PASS")
  expect_equal(result$timing_analysis$total_entries, nrow(consistent))
  expect_equal(result$timing_analysis$avg_entry_duration, mean(consistent$end - consistent$start))
  expect_true(any(grepl("deprecated", warnings)))
})

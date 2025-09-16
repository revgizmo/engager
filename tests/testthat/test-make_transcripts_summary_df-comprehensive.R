# Test file for make_transcripts_summary_df comprehensive coverage
# This function has complex logic that needs thorough testing

test_that("make_transcripts_summary_df handles complex grouping scenarios", {
  # Test with multiple sections and names
  complex_data <- tibble::tibble(
    section = c("A", "A", "A", "B", "B", "B", "C", "C"),
    preferred_name = c("Alice", "Bob", "Alice", "Alice", "Charlie", "Alice", "Bob", "Bob"),
    n = c(1, 2, 3, 4, 5, 6, 7, 8),
    duration = c(10, 20, 30, 40, 50, 60, 70, 80),
    wordcount = c(100, 200, 300, 400, 500, 600, 700, 800)
  )
  
  result <- make_transcripts_summary_df(complex_data)
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
  expect_true(all(c("section", "preferred_name", "session_ct", "n", "duration", 
                   "wordcount", "wpm", "perc_n", "perc_duration", "perc_wordcount") %in% names(result)))
})

test_that("make_transcripts_summary_df handles NA values in calculations", {
  # Test with NA values in different columns
  na_data <- tibble::tibble(
    section = c("A", "A", "B", "B"),
    preferred_name = c("Alice", "Bob", "Alice", "Bob"),
    n = c(1, NA, 3, 4),
    duration = c(NA, 20, 30, NA),
    wordcount = c(100, 200, NA, 400)
  )
  
  result <- make_transcripts_summary_df(na_data)
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
  
  # Check that calculations handle NAs correctly
  expect_true(all(is.finite(result$n) | is.na(result$n)))
  expect_true(all(is.finite(result$duration) | is.na(result$duration)))
  expect_true(all(is.finite(result$wordcount) | is.na(result$wordcount)))
})

test_that("make_transcripts_summary_df handles zero values correctly", {
  # Test with zero values that could cause division issues
  zero_data <- tibble::tibble(
    section = c("A", "A", "B", "B"),
    preferred_name = c("Alice", "Bob", "Alice", "Bob"),
    n = c(0, 1, 0, 2),
    duration = c(0, 10, 0, 20),
    wordcount = c(0, 100, 0, 200)
  )
  
  result <- make_transcripts_summary_df(zero_data)
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
  
  # Check that zero durations don't cause infinite wpm
  expect_true(all(is.finite(result$wpm) | is.na(result$wpm)))
})

test_that("make_transcripts_summary_df handles single row inputs", {
  # Test with single row
  single_row <- tibble::tibble(
    section = "A",
    preferred_name = "Alice",
    n = 1,
    duration = 10,
    wordcount = 100
  )
  
  result <- make_transcripts_summary_df(single_row)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
  expect_equal(result$perc_n, 100)
  expect_equal(result$perc_duration, 100)
  expect_equal(result$perc_wordcount, 100)
})

test_that("make_transcripts_summary_df handles multiple sections efficiently", {
  # Test with multiple sections to ensure grouping works correctly
  multi_section_data <- tibble::tibble(
    section = c("A", "A", "B", "B", "C", "C"),
    preferred_name = c("Alice", "Bob", "Alice", "Bob", "Alice", "Bob"),
    n = c(1, 2, 3, 4, 5, 6),
    duration = c(10, 20, 30, 40, 50, 60),
    wordcount = c(100, 200, 300, 400, 500, 600)
  )
  
  result <- make_transcripts_summary_df(multi_section_data)
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
  expect_true(nrow(result) <= 6)  # Should be grouped by section and name
})

test_that("make_transcripts_summary_df handles edge case group_id creation", {
  # Test with special characters in names that could affect group_id creation
  special_data <- tibble::tibble(
    section = c("A|B", "A|B", "C&D", "C&D"),
    preferred_name = c("John|Doe", "Jane&Smith", "John|Doe", "Jane&Smith"),
    n = c(1, 2, 3, 4),
    duration = c(10, 20, 30, 40),
    wordcount = c(100, 200, 300, 400)
  )
  
  result <- make_transcripts_summary_df(special_data)
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
})

test_that("make_transcripts_summary_df handles sorting correctly", {
  # Test that results are sorted by duration descending
  sort_data <- tibble::tibble(
    section = c("A", "A", "A"),
    preferred_name = c("Alice", "Bob", "Charlie"),
    n = c(1, 2, 3),
    duration = c(30, 10, 20),  # Alice should be first after sorting
    wordcount = c(300, 100, 200)
  )
  
  result <- make_transcripts_summary_df(sort_data)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)
  expect_equal(result$preferred_name[1], "Alice")  # Highest duration first
  expect_equal(result$duration[1], 30)
})

test_that("make_transcripts_summary_df handles non-tibble inputs", {
  # Test with NULL input
  result1 <- make_transcripts_summary_df(NULL)
  expect_null(result1)
  
  # Test with non-tibble data frame
  df_data <- data.frame(
    section = c("A", "A"),
    preferred_name = c("Alice", "Bob"),
    n = c(1, 2),
    duration = c(10, 20),
    wordcount = c(100, 200)
  )
  
  result2 <- make_transcripts_summary_df(df_data)
  expect_null(result2)  # Function only works with tibbles
})

test_that("make_transcripts_summary_df handles percentage calculations edge cases", {
  # Test with all zeros in a section
  all_zero_data <- tibble::tibble(
    section = c("A", "A", "B", "B"),
    preferred_name = c("Alice", "Bob", "Alice", "Bob"),
    n = c(0, 0, 1, 2),
    duration = c(0, 0, 10, 20),
    wordcount = c(0, 0, 100, 200)
  )
  
  result <- make_transcripts_summary_df(all_zero_data)
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
  
  # Check that zero totals don't cause division by zero
  section_a_rows <- result[result$section == "A", ]
  if (nrow(section_a_rows) > 0) {
    expect_true(all(is.finite(section_a_rows$perc_n) | is.na(section_a_rows$perc_n)))
    expect_true(all(is.finite(section_a_rows$perc_duration) | is.na(section_a_rows$perc_duration)))
    expect_true(all(is.finite(section_a_rows$perc_wordcount) | is.na(section_a_rows$perc_wordcount)))
  }
})

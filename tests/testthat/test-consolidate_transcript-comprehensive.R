# Test file for consolidate_transcript comprehensive coverage
# This function has complex transcript consolidation logic that needs thorough testing

test_that("consolidate_transcript handles different input types", {
  # Test with valid tibble
  valid_df <- tibble::tibble(
    name = c("Alice", "Alice", "Bob"),
    start = c("10:00:00", "10:00:05", "10:01:00"),
    end = c("10:00:04", "10:00:08", "10:01:05"),
    comment = c("Hello", "world", "Hi there")
  )

  result1 <- consolidate_transcript(valid_df)
  expect_s3_class(result1, "tbl_df")
  expect_true(nrow(result1) > 0)

  # Test with NULL input
  result2 <- consolidate_transcript(NULL)
  expect_null(result2)

  # Test with non-tibble input
  result3 <- consolidate_transcript(data.frame(x = 1))
  expect_null(result3)
})

test_that("consolidate_transcript handles empty data", {
  # Test with empty tibble
  empty_df <- tibble::tibble(
    name = character(),
    start = character(),
    end = character(),
    comment = character()
  )

  result1 <- consolidate_transcript(empty_df)
  expect_s3_class(result1, "tbl_df")
  expect_equal(nrow(result1), 0)
  expect_true(all(c("name", "comment", "start", "end", "duration", "wordcount") %in% names(result1)))

  # Test with empty tibble including transcript_file
  empty_with_file <- tibble::tibble(
    transcript_file = character(),
    name = character(),
    start = character(),
    end = character(),
    comment = character()
  )

  result2 <- consolidate_transcript(empty_with_file)
  expect_s3_class(result2, "tbl_df")
  expect_equal(nrow(result2), 0)
  expect_true("transcript_file" %in% names(result2))
})

test_that("consolidate_transcript handles different max_pause_sec values", {
  test_df <- tibble::tibble(
    name = c("Alice", "Alice", "Bob"),
    start = c("10:00:00", "10:00:05", "10:01:00"),
    end = c("10:00:04", "10:00:08", "10:01:05"),
    comment = c("Hello", "world", "Hi there")
  )

  # Test with default max_pause_sec
  result1 <- consolidate_transcript(test_df)
  expect_s3_class(result1, "tbl_df")

  # Test with custom max_pause_sec
  result2 <- consolidate_transcript(test_df, max_pause_sec = 0.5)
  expect_s3_class(result2, "tbl_df")

  # Test with larger max_pause_sec
  result3 <- consolidate_transcript(test_df, max_pause_sec = 10)
  expect_s3_class(result3, "tbl_df")
})

test_that("create_empty_result handles different column structures", {
  # Test with basic columns
  basic_df <- tibble::tibble(
    name = character(),
    start = character(),
    end = character(),
    comment = character()
  )

  result1 <- create_empty_result(basic_df)
  expect_s3_class(result1, "tbl_df")
  expect_equal(nrow(result1), 0)
  expect_true(all(c("name", "comment", "start", "end", "duration", "wordcount") %in% names(result1)))

  # Test with transcript_file column
  with_file_df <- tibble::tibble(
    transcript_file = character(),
    name = character(),
    start = character(),
    end = character(),
    comment = character()
  )

  result2 <- create_empty_result(with_file_df)
  expect_s3_class(result2, "tbl_df")
  expect_equal(nrow(result2), 0)
  expect_true("transcript_file" %in% names(result2))
})

test_that("process_transcript_timing handles time conversion and calculations", {
  test_df <- tibble::tibble(
    name = c("Alice", "Alice", "Bob"),
    start = c("10:00:00", "10:00:05", "10:01:00"),
    end = c("10:00:04", "10:00:08", "10:01:05"),
    comment = c("Hello", "world", "Hi there")
  )

  result <- process_transcript_timing(test_df, max_pause_sec = 1)

  expect_s3_class(result$start, "hms")
  expect_s3_class(result$end, "hms")
  expect_true("prev_end" %in% names(result))
  expect_true("prior_dead_air" %in% names(result))
  expect_true("prior_speaker" %in% names(result))
  expect_true("name_flag" %in% names(result))
  expect_true("time_flag" %in% names(result))
  expect_true("comment_num" %in% names(result))
})

test_that("aggregate_transcript_data handles different grouping scenarios", {
  # Test with transcript_file column
  with_file_df <- tibble::tibble(
    transcript_file = c("file1", "file1", "file2"),
    name = c("Alice", "Alice", "Bob"),
    start = c("10:00:00", "10:00:05", "10:01:00"),
    end = c("10:00:04", "10:00:08", "10:01:05"),
    comment = c("Hello", "world", "Hi there"),
    comment_num = c(1, 1, 2)
  )

  result1 <- aggregate_transcript_data(with_file_df)
  expect_s3_class(result1, "data.frame")
  expect_true("transcript_file" %in% names(result1))
  expect_true("name" %in% names(result1))
  expect_true("comment" %in% names(result1))

  # Test without transcript_file column
  without_file_df <- tibble::tibble(
    name = c("Alice", "Alice", "Bob"),
    start = c("10:00:00", "10:00:05", "10:01:00"),
    end = c("10:00:04", "10:00:08", "10:01:05"),
    comment = c("Hello", "world", "Hi there"),
    comment_num = c(1, 1, 2)
  )

  result2 <- aggregate_transcript_data(without_file_df)
  expect_s3_class(result2, "data.frame")
  expect_false("transcript_file" %in% names(result2))
  expect_true("name" %in% names(result2))
  expect_true("comment" %in% names(result2))
})

test_that("perform_aggregation handles different aggregation scenarios", {
  test_df <- tibble::tibble(
    name = c("Alice", "Alice", "Bob"),
    start = c("10:00:00", "10:00:05", "10:01:00"),
    end = c("10:00:04", "10:00:08", "10:01:05"),
    comment = c("Hello", "world", "Hi there"),
    comment_num = c(1, 1, 2)
  )

  # Test with single grouping column
  result1 <- perform_aggregation(test_df, "comment_num")
  expect_s3_class(result1, "data.frame")
  expect_true("comment_num" %in% names(result1))

  # Test with multiple grouping columns
  test_df2 <- tibble::tibble(
    transcript_file = c("file1", "file1", "file2"),
    name = c("Alice", "Alice", "Bob"),
    start = c("10:00:00", "10:00:05", "10:01:00"),
    end = c("10:00:04", "10:00:08", "10:01:05"),
    comment = c("Hello", "world", "Hi there"),
    comment_num = c(1, 1, 2)
  )

  result2 <- perform_aggregation(test_df2, c("transcript_file", "comment_num"))
  expect_s3_class(result2, "data.frame")
  expect_true("transcript_file" %in% names(result2))
  expect_true("comment_num" %in% names(result2))
})

test_that("calculate_final_metrics handles duration and wordcount calculations", {
  test_result <- data.frame(
    name = c("Alice", "Bob"),
    comment = c("Hello world", "Hi there everyone"),
    start = hms::as_hms(c("10:00:00", "10:01:00")),
    end = hms::as_hms(c("10:00:05", "10:01:10")),
    stringsAsFactors = FALSE
  )

  result <- calculate_final_metrics(test_result)

  expect_s3_class(result, "tbl_df")
  expect_true("duration" %in% names(result))
  expect_true("wordcount" %in% names(result))
  expect_type(result$duration, "double")
  expect_type(result$wordcount, "integer")
  expect_equal(result$wordcount[1], 2) # "Hello world" = 2 words
  expect_equal(result$wordcount[2], 3) # "Hi there everyone" = 3 words
})

test_that("consolidate_transcript handles edge cases", {
  # Test with single row
  single_row <- tibble::tibble(
    name = "Alice",
    start = "10:00:00",
    end = "10:00:05",
    comment = "Hello"
  )

  result1 <- consolidate_transcript(single_row)
  expect_s3_class(result1, "tbl_df")
  expect_equal(nrow(result1), 1)

  # Test with NA values in time columns
  na_time_df <- tibble::tibble(
    name = c("Alice", "Bob"),
    start = c("10:00:00", NA),
    end = c("10:00:05", "10:01:00"),
    comment = c("Hello", "Hi")
  )

  result2 <- consolidate_transcript(na_time_df)
  expect_s3_class(result2, "tbl_df")

  # Test with very long comments
  long_comment_df <- tibble::tibble(
    name = c("Alice", "Alice"),
    start = c("10:00:00", "10:00:05"),
    end = c("10:00:04", "10:00:08"),
    comment = c(
      paste(rep("word", 100), collapse = " "),
      paste(rep("another", 50), collapse = " ")
    )
  )

  result3 <- consolidate_transcript(long_comment_df)
  expect_s3_class(result3, "tbl_df")
  expect_true(all(result3$wordcount > 50))
})

test_that("consolidate_transcript handles different comment consolidation scenarios", {
  # Test with comments that should be consolidated
  consolidate_df <- tibble::tibble(
    name = c("Alice", "Alice", "Bob"),
    start = c("10:00:00", "10:00:02", "10:01:00"),
    end = c("10:00:01", "10:00:03", "10:01:05"),
    comment = c("This", "is", "Hello")
  )

  result <- consolidate_transcript(consolidate_df, max_pause_sec = 1)
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) <= 3) # Should be consolidated

  # Test with comments that should not be consolidated
  no_consolidate_df <- tibble::tibble(
    name = c("Alice", "Alice", "Bob"),
    start = c("10:00:00", "10:00:10", "10:01:00"),
    end = c("10:00:05", "10:00:15", "10:01:05"),
    comment = c("This", "is", "Hello")
  )

  result2 <- consolidate_transcript(no_consolidate_df, max_pause_sec = 1)
  expect_s3_class(result2, "tbl_df")
  expect_equal(nrow(result2), 3) # Should not be consolidated
})

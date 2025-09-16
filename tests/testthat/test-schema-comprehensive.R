# Test file for schema comprehensive coverage
# This function has validation logic that needs thorough testing

test_that("validate_schema handles different input types", {
  # Test with valid data.frame
  valid_df <- data.frame(
    name = "John",
    age = 25,
    stringsAsFactors = FALSE
  )
  expect_silent(validate_schema(valid_df, required_cols = c("name", "age")))
  
  # Test with valid tibble
  valid_tibble <- tibble::tibble(
    name = "John",
    age = 25
  )
  expect_silent(validate_schema(valid_tibble, required_cols = c("name", "age")))
  
  # Test with non-data.frame input
  expect_error(validate_schema("invalid", required_cols = c("name")), "must be a data.frame or tibble")
  expect_error(validate_schema(NULL, required_cols = c("name")), "must be a data.frame or tibble")
  expect_error(validate_schema(list(a = 1), required_cols = c("name")), "must be a data.frame or tibble")
})

test_that("validate_schema handles missing columns", {
  # Test with all required columns present
  complete_df <- data.frame(
    name = "John",
    age = 25,
    city = "NYC",
    stringsAsFactors = FALSE
  )
  expect_silent(validate_schema(complete_df, required_cols = c("name", "age")))
  
  # Test with some missing columns
  incomplete_df <- data.frame(
    name = "John",
    stringsAsFactors = FALSE
  )
  expect_error(validate_schema(incomplete_df, required_cols = c("name", "age")), "Missing required columns")
  
  # Test with all columns missing
  empty_df <- data.frame(stringsAsFactors = FALSE)
  expect_error(validate_schema(empty_df, required_cols = c("name", "age")), "Missing required columns")
  
  # Test with no required columns
  expect_silent(validate_schema(complete_df, required_cols = character()))
})

test_that("validate_schema handles type validation", {
  # Test with correct types
  typed_df <- data.frame(
    name = "John",
    age = 25L,
    active = TRUE,
    score = 85.5,
    stringsAsFactors = FALSE
  )
  types <- list(
    name = "character",
    age = "integer",
    active = "logical",
    score = "numeric"
  )
  expect_silent(validate_schema(typed_df, required_cols = names(types), types = types))
  
  # Test with incorrect types
  wrong_types_df <- data.frame(
    name = 123,  # Should be character
    age = "25",  # Should be integer
    stringsAsFactors = FALSE
  )
  wrong_types <- list(
    name = "character",
    age = "integer"
  )
  expect_error(validate_schema(wrong_types_df, required_cols = names(wrong_types), types = wrong_types), "has type")
  
  # Test with NULL types (should skip type validation)
  expect_silent(validate_schema(typed_df, required_cols = c("name", "age"), types = NULL))
})

test_that("validate_schema handles edge cases", {
  # Test with empty data frame
  empty_df <- data.frame(stringsAsFactors = FALSE)
  expect_silent(validate_schema(empty_df, required_cols = character()))
  
  # Test with single column
  single_col_df <- data.frame(name = "John", stringsAsFactors = FALSE)
  expect_silent(validate_schema(single_col_df, required_cols = "name"))
  
  # Test with many columns
  many_cols_df <- data.frame(
    col1 = 1, col2 = 2, col3 = 3, col4 = 4, col5 = 5,
    col6 = 6, col7 = 7, col8 = 8, col9 = 9, col10 = 10,
    stringsAsFactors = FALSE
  )
  expect_silent(validate_schema(many_cols_df, required_cols = paste0("col", 1:10)))
  
  # Test with special column names (using simpler names to avoid issues)
  special_df <- data.frame(
    col_with_underscores = 1,
    col.with.dots = 2,
    stringsAsFactors = FALSE
  )
  expect_silent(validate_schema(special_df, required_cols = c("col_with_underscores", "col.with.dots")))
})

test_that("validate_schema handles type edge cases", {
  # Test with factor columns
  factor_df <- data.frame(
    name = factor("John"),
    category = factor("A"),
    stringsAsFactors = FALSE
  )
  factor_types <- list(
    name = "factor",
    category = "factor"
  )
  expect_silent(validate_schema(factor_df, required_cols = names(factor_types), types = factor_types))
  
  # Test with Date columns
  date_df <- data.frame(
    name = "John",
    birth_date = as.Date("1990-01-01"),
    stringsAsFactors = FALSE
  )
  date_types <- list(
    name = "character",
    birth_date = "Date"
  )
  expect_silent(validate_schema(date_df, required_cols = names(date_types), types = date_types))
  
  # Test with POSIXct columns
  posix_df <- data.frame(
    name = "John",
    timestamp = as.POSIXct("2024-01-01 12:00:00"),
    stringsAsFactors = FALSE
  )
  posix_types <- list(
    name = "character",
    timestamp = "POSIXct"
  )
  expect_silent(validate_schema(posix_df, required_cols = names(posix_types), types = posix_types))
})

test_that("validate_schema handles partial type validation", {
  # Test with some columns having type validation, others not
  mixed_df <- data.frame(
    name = "John",
    age = 25,
    city = "NYC",
    stringsAsFactors = FALSE
  )
  partial_types <- list(
    name = "character",
    age = "numeric"
    # city is not in types, so should be skipped
  )
  expect_silent(validate_schema(mixed_df, required_cols = c("name", "age", "city"), types = partial_types))
  
  # Test with types for non-existent columns
  non_existent_types <- list(
    name = "character",
    non_existent = "character"
  )
  expect_silent(validate_schema(mixed_df, required_cols = "name", types = non_existent_types))
})

test_that("zse_schema contains expected schemas", {
  # Test that zse_schema is properly defined
  expect_type(zse_schema, "list")
  expect_true("transcript" %in% names(zse_schema))
  expect_true("roster" %in% names(zse_schema))
  
  # Test transcript schema
  expect_equal(zse_schema$transcript$required, c("timestamp", "speaker", "text"))
  expect_equal(zse_schema$transcript$types$timestamp, "hms")
  expect_equal(zse_schema$transcript$types$speaker, "character")
  expect_equal(zse_schema$transcript$types$text, "character")
  
  # Test roster schema
  expect_equal(zse_schema$roster$required, c("student_id", "preferred_name"))
  expect_equal(zse_schema$roster$types$student_id, "character")
  expect_equal(zse_schema$roster$types$preferred_name, "character")
})

test_that("validate_schema returns invisible TRUE", {
  # Test that function returns invisible TRUE
  test_df <- data.frame(name = "John", stringsAsFactors = FALSE)
  result <- validate_schema(test_df, required_cols = "name")
  expect_identical(result, TRUE)
  expect_true(invisible(result))
})

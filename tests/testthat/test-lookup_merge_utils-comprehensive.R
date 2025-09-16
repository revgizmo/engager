# Test file for lookup_merge_utils comprehensive coverage
# This function has complex lookup and merge logic that needs thorough testing

test_that("read_lookup_safely handles different file scenarios", {
  # Test with non-existent file
  result1 <- read_lookup_safely("non_existent_file.csv")
  expect_s3_class(result1, "data.frame")
  expect_equal(nrow(result1), 0)
  
  # Test with existing file (create temporary file)
  temp_file <- tempfile(fileext = ".csv")
  test_data <- data.frame(
    preferred_name = c("John Doe", "Jane Smith"),
    participant_type = c("enrolled_student", "instructor"),
    student_id = c("STU1", "INST1"),
    stringsAsFactors = FALSE
  )
  write.csv(test_data, temp_file, row.names = FALSE)
  
  result2 <- read_lookup_safely(temp_file)
  expect_s3_class(result2, "data.frame")
  expect_equal(nrow(result2), 2)
  
  unlink(temp_file)
})

test_that("write_lookup_transactional handles different scenarios", {
  # Test with valid data
  test_data <- data.frame(
    preferred_name = c("John Doe", "Jane Smith"),
    participant_type = c("enrolled_student", "instructor"),
    student_id = c("STU1", "INST1"),
    stringsAsFactors = FALSE
  )
  
  temp_file <- tempfile(fileext = ".csv")
  
  result1 <- write_lookup_transactional(test_data, temp_file)
  expect_type(result1, "character")
  expect_equal(result1, temp_file)
  
  # Test with NULL data
  result2 <- write_lookup_transactional(NULL, temp_file)
  expect_type(result2, "character")
  expect_equal(result2, temp_file)
  
  # Test with empty data frame
  empty_data <- data.frame()
  result3 <- write_lookup_transactional(empty_data, temp_file)
  expect_type(result3, "character")
  expect_equal(result3, temp_file)
  
  unlink(temp_file)
})

test_that("conditionally_write_lookup handles different allow_write values", {
  test_data <- data.frame(
    preferred_name = c("John Doe", "Jane Smith"),
    participant_type = c("enrolled_student", "instructor"),
    student_id = c("STU1", "INST1"),
    stringsAsFactors = FALSE
  )
  
  temp_file <- tempfile(fileext = ".csv")
  
  # Test with allow_write = TRUE
  result1 <- conditionally_write_lookup(test_data, temp_file, allow_write = TRUE)
  expect_type(result1, "logical")
  expect_equal(result1, TRUE)
  
  # Test with allow_write = FALSE
  result2 <- conditionally_write_lookup(test_data, temp_file, allow_write = FALSE)
  expect_type(result2, "logical")
  expect_equal(result2, FALSE)
  
  # Test with allow_write = NULL
  result3 <- conditionally_write_lookup(test_data, temp_file, allow_write = NULL)
  expect_type(result3, "logical")
  expect_equal(result3, FALSE)
  
  unlink(temp_file)
})

test_that("lookup_merge_utils functions handle edge cases", {
  # Test with invalid file paths
  result1 <- read_lookup_safely("")
  expect_s3_class(result1, "data.frame")
  expect_equal(nrow(result1), 0)
  
  # Test with NULL path (should error)
  expect_error(read_lookup_safely(NULL), "path must be a single character string")
  
  # Test with invalid data types (should error)
  expect_error(write_lookup_transactional("invalid_data", "test.csv"), "invalid 'times' argument")
  expect_error(conditionally_write_lookup("invalid_data", "test.csv", allow_write = TRUE), "invalid 'times' argument")
})

test_that("lookup_merge_utils functions handle file system errors", {
  # Test with read-only directory (if possible)
  read_only_file <- "/readonly/test.csv"
  result1 <- read_lookup_safely(read_only_file)
  expect_s3_class(result1, "data.frame")
  expect_equal(nrow(result1), 0)
  
  # Test with invalid file path for writing (should error)
  invalid_path <- "/invalid/path/that/does/not/exist/test.csv"
  test_data <- data.frame(x = 1)
  
  expect_error(write_lookup_transactional(test_data, invalid_path), "cannot open the connection")
  expect_error(conditionally_write_lookup(test_data, invalid_path, allow_write = TRUE), "cannot open the connection")
})

test_that("lookup_merge_utils functions handle large datasets", {
  # Test with large dataset
  large_data <- data.frame(
    preferred_name = paste0("Student_", 1:1000),
    participant_type = rep("enrolled_student", 1000),
    student_id = paste0("STU_", 1:1000),
    stringsAsFactors = FALSE
  )
  
  temp_file <- tempfile(fileext = ".csv")
  
  result1 <- write_lookup_transactional(large_data, temp_file)
  expect_type(result1, "character")
  expect_equal(result1, temp_file)
  
  result2 <- conditionally_write_lookup(large_data, temp_file, allow_write = TRUE)
  expect_type(result2, "logical")
  expect_equal(result2, TRUE)
  
  unlink(temp_file)
})

test_that("lookup_merge_utils functions handle special characters", {
  # Test with special characters in data
  special_data <- data.frame(
    preferred_name = c("José María", "François", "Müller", "北京"),
    participant_type = c("enrolled_student", "instructor", "ta", "guest"),
    student_id = c("STU1", "INST1", "TA1", "GUEST1"),
    stringsAsFactors = FALSE
  )
  
  temp_file <- tempfile(fileext = ".csv")
  
  result1 <- write_lookup_transactional(special_data, temp_file)
  expect_type(result1, "character")
  expect_equal(result1, temp_file)
  
  result2 <- conditionally_write_lookup(special_data, temp_file, allow_write = TRUE)
  expect_type(result2, "logical")
  expect_equal(result2, TRUE)
  
  unlink(temp_file)
})

test_that("lookup_merge_utils functions handle NA values", {
  # Test with NA values in data
  na_data <- data.frame(
    preferred_name = c("John Doe", NA, "Jane Smith"),
    participant_type = c("enrolled_student", "instructor", NA),
    student_id = c("STU1", NA, "STU2"),
    stringsAsFactors = FALSE
  )
  
  temp_file <- tempfile(fileext = ".csv")
  
  result1 <- write_lookup_transactional(na_data, temp_file)
  expect_type(result1, "character")
  expect_equal(result1, temp_file)
  
  result2 <- conditionally_write_lookup(na_data, temp_file, allow_write = TRUE)
  expect_type(result2, "logical")
  expect_equal(result2, TRUE)
  
  unlink(temp_file)
})

test_that("lookup_merge_utils functions handle different file extensions", {
  test_data <- data.frame(x = 1, y = 2)
  
  # Test with different file extensions
  extensions <- c(".csv", ".txt", ".tsv", ".data")
  
  for (ext in extensions) {
    temp_file <- tempfile(fileext = ext)
    
    result1 <- write_lookup_transactional(test_data, temp_file)
    expect_type(result1, "character")
    expect_equal(result1, temp_file)
    
    result2 <- conditionally_write_lookup(test_data, temp_file, allow_write = TRUE)
    expect_type(result2, "logical")
    expect_equal(result2, TRUE)
    
    unlink(temp_file)
  }
})

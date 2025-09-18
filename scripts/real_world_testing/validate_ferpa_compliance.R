#!/usr/bin/env Rscript
# FERPA Compliance Validation Script
# Addresses Issue #153: Real-world FERPA compliance validation
#
# This script validates that the engager package maintains
# FERPA compliance when processing real educational data.
#
# CRITICAL: This script should be run in a secure environment with proper
# data handling protocols. Never run in LLM/IDE environments.

suppressPackageStartupMessages({
  library(engager)
  library(dplyr)
  library(tibble)
  library(testthat)
})

# Configuration
cat("=== FERPA Compliance Validation ===\n")
cat("Package Version:", packageVersion("engager"), "\n")
cat("Date:", Sys.time(), "\n\n")

# Test 1: Basic FERPA Compliance Validation
test_ferpa_compliance_basic <- function() {
  cat("Test 1: Basic FERPA Compliance Validation\n")
  cat("==========================================\n")
  
  # Create test data with PII
  test_data_with_pii <- tibble(
    student_id = c("12345", "67890", "11111"),
    preferred_name = c("Alice Johnson", "Bob Smith", "Carol Davis"),
    email = c("alice@university.edu", "bob@university.edu", "carol@university.edu"),
    participation_score = c(85, 92, 78),
    phone_number = c("555-1234", "555-5678", "555-9012"),
    address = c("123 Main St", "456 Oak Ave", "789 Pine Rd")
  )
  
  # Test educational institution compliance
  cat("Testing educational institution compliance...\n")
  edu_result <- validate_ferpa_compliance(
    test_data_with_pii, 
    institution_type = "educational"
  )
  
  # Validate results
  expect_false(edu_result$compliant, "Data with PII should not be compliant")
  expect_true(length(edu_result$pii_detected) > 0, "Should detect PII fields")
  expect_true("student_id" %in% edu_result$pii_detected, "Should detect student_id")
  expect_true("preferred_name" %in% edu_result$pii_detected, "Should detect names")
  expect_true("email" %in% edu_result$pii_detected, "Should detect email")
  expect_true(length(edu_result$recommendations) > 0, "Should provide recommendations")
  expect_true(any(grepl("FERPA", edu_result$institution_guidance)), "Should mention FERPA")
  
  cat("✓ Educational institution compliance test PASSED\n")
  
  # Test research institution compliance
  cat("Testing research institution compliance...\n")
  research_result <- validate_ferpa_compliance(
    test_data_with_pii, 
    institution_type = "research"
  )
  
  expect_false(research_result$compliant, "Data with PII should not be compliant")
  expect_true(any(grepl("IRB", research_result$institution_guidance)), "Should mention IRB")
  
  cat("✓ Research institution compliance test PASSED\n")
  
  # Test clean data
  cat("Testing clean data compliance...\n")
  clean_data <- tibble(
    section = c("A", "B", "C"),
    participation_score = c(85, 92, 78),
    avg_duration = c(120, 95, 150)
  )
  
  clean_result <- validate_ferpa_compliance(clean_data, institution_type = "educational")
  expect_true(clean_result$compliant, "Clean data should be compliant")
  expect_equal(length(clean_result$pii_detected), 0, "Should detect no PII")
  
  cat("✓ Clean data compliance test PASSED\n\n")
}

# Test 2: Privacy Level Validation
test_privacy_levels <- function() {
  cat("Test 2: Privacy Level Validation\n")
  cat("================================\n")
  
  # Create test transcript data
  test_transcript <- tibble(
    name = c("Dr. Smith", "Alice Johnson", "Bob Smith", "dead_air"),
    message = c("Welcome to class", "I have a question", "I agree", ""),
    timestamp = c("00:00:10", "00:01:15", "00:02:30", "00:03:00"),
    duration = c(5, 10, 8, 0)
  )
  
  # Test ferpa_strict level
  cat("Testing ferpa_strict privacy level...\n")
  set_privacy_defaults("ferpa_strict")
  
  strict_metrics <- summarize_transcript_metrics(test_transcript)
  strict_names <- strict_metrics$name
  
  # Should mask instructor names (Dr. Smith)
  instructor_masked <- !any(grepl("Dr\\. Smith", strict_names))
  expect_true(instructor_masked, "ferpa_strict should mask instructor names")
  
  cat("✓ ferpa_strict level test PASSED\n")
  
  # Test ferpa_standard level
  cat("Testing ferpa_standard privacy level...\n")
  set_privacy_defaults("ferpa_standard")
  
  standard_metrics <- summarize_transcript_metrics(test_transcript)
  standard_names <- standard_metrics$name
  
  # Should mask instructor names
  instructor_masked <- !any(grepl("Dr\\. Smith", standard_names))
  expect_true(instructor_masked, "ferpa_standard should mask instructor names")
  
  cat("✓ ferpa_standard level test PASSED\n")
  
  # Test mask level
  cat("Testing mask privacy level...\n")
  set_privacy_defaults("mask")
  
  mask_metrics <- summarize_transcript_metrics(test_transcript)
  mask_names <- mask_metrics$name
  
  # Should preserve instructor names but mask student names
  instructor_preserved <- any(grepl("Dr\\. Smith", mask_names))
  expect_true(instructor_preserved, "mask should preserve instructor names")
  
  # Student names should be masked
  students_masked <- !any(grepl("Alice Johnson|Bob Smith", mask_names))
  expect_true(students_masked, "mask should mask student names")
  
  cat("✓ mask level test PASSED\n")
  
  # Test none level (for validation only)
  cat("Testing none privacy level...\n")
  set_privacy_defaults("none")
  
  none_metrics <- summarize_transcript_metrics(test_transcript)
  none_names <- none_metrics$name
  
  # Should expose all names
  all_names_exposed <- any(grepl("Alice Johnson|Bob Smith|Dr\\. Smith", none_names))
  expect_true(all_names_exposed, "none should expose all names")
  
  cat("✓ none level test PASSED\n\n")
}

# Test 3: Data Retention Policy Validation
test_data_retention <- function() {
  cat("Test 3: Data Retention Policy Validation\n")
  cat("========================================\n")
  
  # Create test data with timestamps
  test_data <- tibble(
    student_id = c("12345", "67890"),
    name = c("Alice Johnson", "Bob Smith"),
    participation_date = as.Date(c("2024-01-15", "2024-01-16")),
    score = c(85, 92)
  )
  
  # Test academic year retention
  cat("Testing academic year retention policy...\n")
  retention_result <- check_data_retention_policy(
    test_data,
    retention_period = "academic_year"
  )
  
  expect_true(is.list(retention_result), "Should return list")
  expect_true("compliant" %in% names(retention_result), "Should have compliant field")
  expect_true("recommendations" %in% names(retention_result), "Should have recommendations")
  
  cat("✓ Academic year retention test PASSED\n")
  
  # Test semester retention
  cat("Testing semester retention policy...\n")
  semester_result <- check_data_retention_policy(
    test_data,
    retention_period = "semester"
  )
  
  expect_true(is.list(semester_result), "Should return list")
  
  cat("✓ Semester retention test PASSED\n")
  
  # Test custom retention
  cat("Testing custom retention policy...\n")
  custom_result <- check_data_retention_policy(
    test_data,
    retention_period = "custom",
    custom_retention_days = 30
  )
  
  expect_true(is.list(custom_result), "Should return list")
  
  cat("✓ Custom retention test PASSED\n\n")
}

# Test 4: Privacy Compliance Validation
test_privacy_compliance <- function() {
  cat("Test 4: Privacy Compliance Validation\n")
  cat("=====================================\n")
  
  # Test with clean data (should pass)
  cat("Testing privacy compliance with clean data...\n")
  clean_data <- tibble(
    name = c("Student_01", "Student_02", "Instructor_01"),
    score = c(85, 92, 100)
  )
  
  # This should pass
  tryCatch({
    validate_privacy_compliance(clean_data, privacy_level = "ferpa_strict")
    cat("✓ Clean data privacy validation PASSED\n")
  }, error = function(e) {
    stop("Clean data should pass privacy validation: ", e$message)
  })
  
  # Test with real names (should fail)
  cat("Testing privacy compliance with real names...\n")
  real_name_data <- tibble(
    name = c("John Smith", "Jane Doe", "Dr. Johnson"),
    score = c(85, 92, 100)
  )
  
  # This should detect violations
  tryCatch({
    validate_privacy_compliance(real_name_data, privacy_level = "ferpa_strict")
    stop("Should have detected privacy violations")
  }, error = function(e) {
    if (grepl("privacy violation", e$message, ignore.case = TRUE)) {
      cat("✓ Privacy violation detection PASSED\n")
    } else {
      stop("Unexpected error in privacy validation: ", e$message)
    }
  })
  
  # Test with specific real names
  cat("Testing privacy compliance with specific real names...\n")
  specific_names <- c("Alice Johnson", "Bob Smith")
  
  tryCatch({
    validate_privacy_compliance(clean_data, real_names = specific_names)
    cat("✓ Specific names validation PASSED\n")
  }, error = function(e) {
    stop("Specific names validation failed: ", e$message)
  })
  
  cat("\n")
}

# Test 5: Export Security Validation
test_export_security <- function() {
  cat("Test 5: Export Security Validation\n")
  cat("==================================\n")
  
  # Create test data with masked names
  set_privacy_defaults("mask")
  
  test_transcript <- tibble(
    name = c("Dr. Smith", "Alice Johnson", "Bob Smith", "dead_air"),
    message = c("Welcome to class", "I have a question", "I agree", ""),
    timestamp = c("00:00:10", "00:01:15", "00:02:30", "00:03:00"),
    duration = c(5, 10, 8, 0)
  )
  
  metrics <- summarize_transcript_metrics(test_transcript)
  
  # Test CSV export
  cat("Testing CSV export security...\n")
  temp_file <- tempfile(fileext = ".csv")
  
  tryCatch({
    write.csv(metrics, temp_file, row.names = FALSE)
    
    # Read back and check for real names
    exported_content <- readLines(temp_file)
    exported_text <- paste(exported_content, collapse = " ")
    
    # Should not contain real student names
    has_real_names <- any(grepl("Alice Johnson|Bob Smith", exported_text))
    expect_false(has_real_names, "Exported CSV should not contain real student names")
    
    cat("✓ CSV export security test PASSED\n")
  }, finally = {
    if (file.exists(temp_file)) unlink(temp_file)
  })
  
  # Test metrics export
  cat("Testing metrics export security...\n")
  temp_metrics_file <- tempfile(fileext = ".csv")
  
  tryCatch({
    write_engagement_metrics(metrics, temp_metrics_file)
    
    # Read back and check for real names
    exported_content <- readLines(temp_metrics_file)
    exported_text <- paste(exported_content, collapse = " ")
    
    # Should not contain real student names
    has_real_names <- any(grepl("Alice Johnson|Bob Smith", exported_text))
    expect_false(has_real_names, "Exported metrics should not contain real student names")
    
    cat("✓ Metrics export security test PASSED\n")
  }, finally = {
    if (file.exists(temp_metrics_file)) unlink(temp_metrics_file)
  })
  
  cat("\n")
}

# Test 6: International Name Support
test_international_names <- function() {
  cat("Test 6: International Name Support\n")
  cat("==================================\n")
  
  # Test with international names
  international_transcript <- tibble(
    name = c("Dr. Smith", "李小明", "田中太郎", "김민수", "محمد أحمد", "Иван Петров"),
    message = c("Welcome", "Hello", "Hi", "Good morning", "مرحبا", "Привет"),
    timestamp = c("00:00:10", "00:01:15", "00:02:30", "00:03:00", "00:04:00", "00:05:00"),
    duration = c(5, 10, 8, 12, 6, 9)
  )
  
  # Test with different privacy levels
  privacy_levels <- c("ferpa_strict", "ferpa_standard", "mask", "none")
  
  for (level in privacy_levels) {
    cat("Testing international names with", level, "privacy level...\n")
    
    set_privacy_defaults(level)
    
    tryCatch({
      metrics <- summarize_transcript_metrics(international_transcript)
      
      # Should process without errors
      expect_true(nrow(metrics) > 0, "Should process international names")
      expect_true("name" %in% names(metrics), "Should have name column")
      
      cat("✓", level, "level with international names PASSED\n")
    }, error = function(e) {
      stop("International names test failed for ", level, ": ", e$message)
    })
  }
  
  cat("\n")
}

# Test 7: Edge Case Validation
test_edge_cases <- function() {
  cat("Test 7: Edge Case Validation\n")
  cat("============================\n")
  
  # Test empty data
  cat("Testing empty data handling...\n")
  empty_transcript <- tibble(
    name = character(0),
    message = character(0),
    timestamp = character(0),
    duration = numeric(0)
  )
  
  tryCatch({
    metrics <- summarize_transcript_metrics(empty_transcript)
    expect_true(nrow(metrics) == 0, "Should handle empty data gracefully")
    cat("✓ Empty data handling PASSED\n")
  }, error = function(e) {
    stop("Empty data handling failed: ", e$message)
  })
  
  # Test single row data
  cat("Testing single row data...\n")
  single_transcript <- tibble(
    name = "Dr. Smith",
    message = "Welcome to class",
    timestamp = "00:00:10",
    duration = 5
  )
  
  tryCatch({
    metrics <- summarize_transcript_metrics(single_transcript)
    expect_true(nrow(metrics) == 1, "Should handle single row data")
    cat("✓ Single row data handling PASSED\n")
  }, error = function(e) {
    stop("Single row data handling failed: ", e$message)
  })
  
  # Test data with only dead_air
  cat("Testing data with only dead_air...\n")
  dead_air_transcript <- tibble(
    name = c("dead_air", "dead_air", "dead_air"),
    message = c("", "", ""),
    timestamp = c("00:00:10", "00:01:15", "00:02:30"),
    duration = c(5, 10, 8)
  )
  
  tryCatch({
    metrics <- summarize_transcript_metrics(dead_air_transcript)
    # Should exclude dead_air by default
    expect_true(nrow(metrics) == 0, "Should exclude dead_air by default")
    cat("✓ Dead air handling PASSED\n")
  }, error = function(e) {
    stop("Dead air handling failed: ", e$message)
  })
  
  cat("\n")
}

# Test 8: Performance Validation
test_performance <- function() {
  cat("Test 8: Performance Validation\n")
  cat("==============================\n")
  
  # Create larger test dataset
  cat("Testing performance with larger dataset...\n")
  n_rows <- 1000
  
  large_transcript <- tibble(
    name = rep(c("Dr. Smith", "Student_01", "Student_02", "Student_03"), length.out = n_rows),
    message = rep(c("Welcome", "Question", "Answer", "Comment"), length.out = n_rows),
    timestamp = paste0("00:", sprintf("%02d:%02d", (1:n_rows) %/% 60, (1:n_rows) %% 60)),
    duration = sample(1:20, n_rows, replace = TRUE)
  )
  
  # Measure processing time
  start_time <- Sys.time()
  
  tryCatch({
    metrics <- summarize_transcript_metrics(large_transcript)
    end_time <- Sys.time()
    
    processing_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
    
    # Should complete within reasonable time (adjust threshold as needed)
    expect_true(processing_time < 30, paste("Processing took", processing_time, "seconds, should be < 30"))
    expect_true(nrow(metrics) > 0, "Should process large dataset")
    
    cat("✓ Large dataset processing PASSED (", round(processing_time, 2), "seconds)\n")
  }, error = function(e) {
    stop("Large dataset processing failed: ", e$message)
  })
  
  cat("\n")
}

# Main execution
main <- function() {
  cat("Starting FERPA Compliance Validation...\n\n")
  
  # Run all tests
  test_ferpa_compliance_basic()
  test_privacy_levels()
  test_data_retention()
  test_privacy_compliance()
  test_export_security()
  test_international_names()
  test_edge_cases()
  test_performance()
  
  cat("=== FERPA Compliance Validation Complete ===\n")
  cat("All tests PASSED - Package maintains FERPA compliance\n")
  cat("Date:", Sys.time(), "\n")
  
  # Return success
  invisible(TRUE)
}

# Run if called directly
if (!interactive()) {
  main()
}

# Test script for main branch comparison

# Redirect output to file
sink("main_branch_test_output.txt")

cat("=== TESTING MAIN BRANCH ===\n")
cat("Timestamp:", Sys.time(), "\n\n")

library(engager)

transcript_file <- system.file("extdata/transcripts/", "GMT20240124-202901_Recording.transcript.vtt", package = "engager")
cat("Using transcript file:", transcript_file, "\n")

# Test 1: Load transcript
cat("\n--- Test 1: Load transcript ---\n")
transcript <- load_zoom_transcript(transcript_file)
cat("Transcript loaded with", nrow(transcript), "comments\n")
cat("Transcript columns:", paste(names(transcript), collapse = ", "), "\n")
cat("First few rows:\n")
print(head(transcript, 3))

# Test 2: Check consolidation step
cat("\n--- Test 2: Test consolidation ---\n")
tryCatch({
  consolidated <- consolidate_transcript(transcript)
  cat("Consolidated transcript has", nrow(consolidated), "rows\n")
  cat("Consolidated columns:", paste(names(consolidated), collapse = ", "), "\n")
  cat("Column lengths:", paste(sapply(consolidated, length), collapse = ", "), "\n")
}, error = function(e) {
  cat("Error in consolidate_transcript:", e$message, "\n")
  cat("Error traceback:\n")
  traceback()
})

# Test 3: Test full processing
cat("\n--- Test 3: Test full processing ---\n")
tryCatch({
  processed <- process_zoom_transcript(
    transcript_df = transcript,
    add_dead_air = TRUE,
    consolidate_comments = TRUE
  )
  cat("Processed transcript has", nrow(processed), "rows\n")
  cat("Processed columns:", paste(names(processed), collapse = ", "), "\n")

  # Show first few rows
  cat("First few processed rows:\n")
  print(head(processed, 3))
}, error = function(e) {
  cat("Error in process_zoom_transcript:", e$message, "\n")
  cat("Error traceback:\n")
  traceback()
})

# Test 4: Test aggregation directly
cat("\n--- Test 4: Test aggregation logic ---\n")
if (nrow(transcript) > 0) {
  # Add comment_num for testing aggregation
  transcript$comment_num <- cumsum(c(TRUE, diff(as.numeric(transcript$start)) > 0))
  cat("Added comment_num, unique values:", length(unique(transcript$comment_num)), "\n")

  tryCatch({
    agg_test <- aggregate_transcript_data(transcript)
    cat("Aggregation result:\n")
    cat("  Rows:", nrow(agg_test), "\n")
    cat("  Columns:", ncol(agg_test), "\n")
    cat("  Column names:", paste(names(agg_test), collapse = ", "), "\n")
    cat("  Column lengths:", paste(sapply(agg_test, length), collapse = ", "), "\n")

    # Show structure
    cat("Structure:\n")
    str(agg_test)
  }, error = function(e) {
    cat("Error in aggregate_transcript_data:", e$message, "\n")
    cat("Error traceback:\n")
    traceback()
  })
}

cat("\n=== MAIN BRANCH TEST COMPLETE ===\n")
sink()

cat("Main branch test output saved to: main_branch_test_output.txt\n")

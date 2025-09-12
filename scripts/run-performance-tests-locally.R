#!/usr/bin/env Rscript

#' Local Performance Testing Script
#' 
#' This script runs performance tests locally without the overhead of CI/CD.
#' It's designed for development use and can be run when performance testing is needed.
#' 
#' Usage:
#'   Rscript scripts/run-performance-tests-locally.R [iterations] [output_file]
#' 
#' Examples:
#'   Rscript scripts/run-performance-tests-locally.R
#'   Rscript scripts/run-performance-tests-locally.R 10 performance_results.rds

# Check if we're in the right directory
if (!file.exists("DESCRIPTION")) {
  stop("Please run this script from the package root directory")
}

# Check if required packages are available
required_packages <- c("devtools", "microbenchmark", "pryr")
missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

if (length(missing_packages) > 0) {
  cat("Installing missing packages:", paste(missing_packages, collapse = ", "), "\n")
  install.packages(missing_packages)
}

# Load the benchmark script
source("scripts/benchmark-ideal-transcripts.R")

# Get command line arguments
args <- commandArgs(trailingOnly = TRUE)
iterations <- if (length(args) >= 1) as.numeric(args[1]) else 5
output_file <- if (length(args) >= 2) args[2] else "local_performance_results.rds"

cat("=== LOCAL PERFORMANCE TESTING ===\n")
cat("Package:", read.dcf("DESCRIPTION")[1, "Package"], "\n")
cat("Version:", read.dcf("DESCRIPTION")[1, "Version"], "\n")
cat("Iterations:", iterations, "\n")
cat("Output file:", output_file, "\n")
cat("Timestamp:", as.character(Sys.time()), "\n\n")

# Run the benchmarks
tryCatch({
  results <- benchmark_ideal_transcripts(
    iterations = iterations,
    output_file = output_file
  )
  
  cat("\n=== PERFORMANCE TESTING COMPLETED SUCCESSFULLY ===\n")
  cat("Results saved to:", output_file, "\n")
  
}, error = function(e) {
  cat("\n=== PERFORMANCE TESTING FAILED ===\n")
  cat("Error:", e$message, "\n")
  cat("This is expected if the package is not in development mode.\n")
  cat("Try running: devtools::load_all() first, or install the package.\n")
  quit(status = 1)
})

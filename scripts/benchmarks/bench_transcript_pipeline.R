#!/usr/bin/env Rscript

if (!requireNamespace("engager", quietly = TRUE)) {
  stop("engager must be installed before running benchmarks")
}

args <- commandArgs(trailingOnly = TRUE)
# Optional arg: base temp dir
base_dir <- if (length(args) >= 1) args[[1]] else tempdir()
if (!dir.exists(base_dir)) {
  dir.create(base_dir, recursive = TRUE)
}
base_dir <- normalizePath(base_dir)

sample <- system.file("extdata/test_transcripts/ideal_course_session1.vtt",
                      package = "engager")
if (sample == "") {
  stop("Sample transcript not found in installed package")
}

sizes <- c(1, 50, 500)
# Budgets in seconds (env override)
budget_1 <- as.numeric(Sys.getenv("BUDGET_1", "10"))
budget_50 <- as.numeric(Sys.getenv("BUDGET_50", "120"))
budget_500 <- as.numeric(Sys.getenv("BUDGET_500", "1200"))
results <- list()

for (n in sizes) {
  dir_name <- paste0("bench_transcripts_", n)
  dir_n <- file.path(base_dir, dir_name)
  if (!dir.exists(dir_n)) dir.create(dir_n, recursive = TRUE)
  # Populate folder with n copies
  for (i in seq_len(n)) {
    copied <- file.copy(
      sample,
      file.path(dir_n, sprintf("copy_%03d.transcript.vtt", i)),
      overwrite = TRUE
    )
    if (!copied) stop("Failed to create benchmark transcript fixture")
  }
  cat(sprintf("\nProcessing %d files in %s...\n", n, dir_n))
  t0 <- Sys.time()
  old_wd <- setwd(base_dir)
  metrics <- tryCatch(
    engager::analyze_transcripts(dir_name, write = FALSE),
    finally = setwd(old_wd)
  )
  t1 <- Sys.time()
  if (!is.data.frame(metrics)) {
    stop(sprintf("Benchmark returned no metrics for %d files", n))
  }
  processed_files <- length(unique(metrics$transcript_file))
  if (processed_files != n) {
    stop(sprintf(
      "Benchmark processed %d of %d requested files",
      processed_files,
      n
    ))
  }
  dt <- as.numeric(difftime(t1, t0, units = "secs"))
  cat(sprintf("Elapsed: %.2f sec\n", dt))
  results[[as.character(n)]] <- list(
    n = n,
    files = processed_files,
    seconds = dt,
    rows = nrow(metrics)
  )
}

cat("\nSummary:\n")
summary_tbl <- do.call(rbind, lapply(results, function(x) unlist(x)))
print(summary_tbl)

# Enforce simple budgets
violations <- c()
if (results[["1"]][["seconds"]] > budget_1) violations <- c(violations, sprintf("1-file budget exceeded: %.2fs > %.2fs", results[["1"]][["seconds"]], budget_1))
if (results[["50"]][["seconds"]] > budget_50) violations <- c(violations, sprintf("50-file budget exceeded: %.2fs > %.2fs", results[["50"]][["seconds"]], budget_50))
if (results[["500"]][["seconds"]] > budget_500) violations <- c(violations, sprintf("500-file budget exceeded: %.2fs > %.2fs", results[["500"]][["seconds"]], budget_500))

if (length(violations) > 0) {
  cat("\nPerformance budget violations:\n")
  for (v in violations) cat("- ", v, "\n", sep = "")
  quit(status = 1)
}

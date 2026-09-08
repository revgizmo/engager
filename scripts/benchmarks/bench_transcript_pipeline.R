#!/usr/bin/env Rscript
# Sourceable workload functions; the controller owns processes and artifacts.
benchmark_dependencies <- function() {
  for (package in c("engager", "jsonlite", "digest", "tibble", "hms")) {
    if (!requireNamespace(package, quietly = TRUE)) {
      stop("Required benchmark dependency unavailable: ", package)
    }
  }
}

benchmark_scenarios <- function() {
  c("analyze_files_1", "analyze_files_50", "analyze_files_500",
    "process_vtt_1mib", "consolidate_rows_10000", "summarize_rows_10000")
}

benchmark_identity <- function(scenario, repetition) {
  stopifnot(is.character(scenario), length(scenario) == 1L,
            !is.na(scenario), scenario %in% benchmark_scenarios(),
            is.numeric(repetition), length(repetition) == 1L,
            is.finite(repetition), repetition %in% seq_len(5))
}

benchmark_mib_fixture <- function(path) {
  # ASCII, LF, deterministic timestamps, alternating fixed synthetic speakers.
  timestamp <- function(s) sprintf("%02d:%02d:%02d.000", s %/% 3600,
                                    (s %/% 60) %% 60, s %% 60)
  cue <- function(i) paste0(i, "\n", timestamp(i - 1L), " --> ",
                           timestamp(i), "\nSyntheticSpeaker", (i - 1L) %% 8L,
                           ": Fixed synthetic benchmark cue.\n\n")
  cues <- vapply(seq_len(20000), cue, character(1))
  total <- 8L + cumsum(nchar(cues, type = "bytes"))
  n <- which(total >= 1048576L)[1]
  writeBin(charToRaw(paste0("WEBVTT\n\n", paste0(cues[seq_len(n)], collapse = ""))), path)
  list(cues = n, last_cue_bytes = nchar(cues[n], type = "bytes"))
}

benchmark_input <- function(scenario, root) {
  benchmark_identity(scenario, 1L)
  stopifnot(dir.exists(root))
  workload <- list(generator = "synthetic-v1", file_count = 0L,
                   bytes = 0, rows = 0L, cues = 0L, speakers = 0L,
                   target_bytes = 0L, last_cue_bytes = 0L, sha256 = "none",
                   expected_processed_files = 0L, expected_output_rows = 0L)
  input <- NULL
  if (startsWith(scenario, "analyze_files_")) {
    n <- as.integer(sub("analyze_files_", "", scenario))
    sample <- system.file("extdata/test_transcripts/ideal_course_session1.vtt",
                          package = "engager")
    stopifnot(nzchar(sample), file.exists(sample))
    # Pin the existing bundled workload, including its expected row assertion.
    stopifnot(file.info(sample)$size == 1018L,
              sum(grepl(" --> ", readLines(sample))) == 13L)
    dir.create(file.path(root, "inputs"))
    input <- "inputs"
    for (i in seq_len(n)) {
      stopifnot(file.copy(sample, file.path(root, input,
                        sprintf("copy_%03d.transcript.vtt", i))))
    }
    workload$generator <- "bundled-ideal-session1-v1"
    workload$file_count <- n
    workload$bytes <- n * file.info(sample)$size
    workload$cues <- 13L * n
    workload$speakers <- 8L
    workload$sha256 <- digest::digest(file = sample, algo = "sha256")
    workload$expected_processed_files <- n
    workload$expected_output_rows <- 8L * n
  } else if (scenario == "process_vtt_1mib") {
    input <- file.path(root, "synthetic.transcript.vtt")
    fixture <- benchmark_mib_fixture(input)
    workload$file_count <- 1L
    workload$bytes <- file.info(input)$size
    workload$cues <- fixture$cues
    workload$speakers <- 8L
    workload$target_bytes <- 1048576L
    workload$last_cue_bytes <- fixture$last_cue_bytes
    workload$sha256 <- digest::digest(file = input, algo = "sha256")
    workload$expected_processed_files <- 1L
    workload$expected_output_rows <- fixture$cues
    stopifnot(workload$bytes >= workload$target_bytes,
              workload$bytes - workload$target_bytes < fixture$last_cue_bytes)
  } else {
    n <- 10000L
    i <- seq_len(n)
    # Consecutive pairs share a speaker: consolidation must produce 5,000 rows.
    input <- tibble::tibble(
      name = paste0("SyntheticSpeaker", ((i - 1L) %/% 2L) %% 10L),
      start = hms::hms(i - 1L), end = hms::hms(i),
      comment = rep("Fixed synthetic benchmark cue.", n),
      duration = rep(1, n), wordcount = rep(4L, n)
    )
    workload$rows <- n
    workload$speakers <- 10L
    workload$expected_output_rows <- if (scenario == "consolidate_rows_10000") 5000L else 10L
  }
  list(input = input, workload = workload)
}

benchmark_operation <- function(scenario, input) {
  switch(scenario,
    analyze_files_1 =, analyze_files_50 =, analyze_files_500 =
      engager::analyze_transcripts(input, write = FALSE),
    process_vtt_1mib = engager::process_zoom_transcript(
      input, consolidate_comments = FALSE, add_dead_air = FALSE),
    consolidate_rows_10000 = engager::consolidate_transcript(input),
    summarize_rows_10000 = engager::summarize_transcript_metrics(
      transcript_df = input, comments_format = "count"),
    stop("Invalid scenario")
  )
}

benchmark_observation <- function(scenario, repetition) {
  benchmark_identity(scenario, repetition)
  benchmark_dependencies()
  root <- tempfile("engager-benchmark-")
  stopifnot(dir.create(root))
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  prepared <- benchmark_input(scenario, root)
  old <- setwd(root)
  on.exit(setwd(old), add = TRUE, after = FALSE)
  start <- proc.time()[["elapsed"]]
  result <- benchmark_operation(scenario, prepared$input)
  elapsed <- proc.time()[["elapsed"]] - start
  stopifnot(is.data.frame(result))
  files <- if (prepared$workload$file_count > 0L) {
    stopifnot("transcript_file" %in% names(result), !anyNA(result$transcript_file))
    length(unique(result$transcript_file))
  } else 0L
  stopifnot(files == prepared$workload$expected_processed_files,
            nrow(result) == prepared$workload$expected_output_rows)
  if (scenario == "summarize_rows_10000") {
    stopifnot(sum(result$n) == 10000L, sum(result$duration) == 10000,
              sum(result$wordcount) == 40000L)
  }
  list(scenario = scenario, repetition = repetition, workload = prepared$workload,
       elapsed_seconds = elapsed, processed_files = files,
       output_rows = nrow(result), assertions_passed = TRUE, status = "passed")
}

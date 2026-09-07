#!/usr/bin/env Rscript
source("scripts/benchmarks/measurement_contract.R")
benchmark_dependencies()
checks <- 0L
reject <- function(expr) {
  failed <- inherits(tryCatch(force(expr), error = identity), "error")
  stopifnot(failed)
  checks <<- checks + 1L
}

expected <- measurement_expected()
observations <- list()
for (s in benchmark_scenarios()) for (r in 1:5) {
  w <- expected[[s]]
  observations[[length(observations) + 1L]] <- list(
    scenario = s, repetition = r, workload = w,
    elapsed_seconds = r / 10, processed_files = w$expected_processed_files,
    output_rows = w$expected_output_rows, assertions_passed = TRUE,
    status = "passed", max_rss_kib = 10000 + r
  )
}
# Fabricated observations are solely validator unit fixtures, never measurements.
meta <- measurement_metadata()
meta$os <- "Linux"
x <- list(schema_version = "1.0.0", metadata = meta,
          semantics = measurement_semantics(), observations = observations,
          summaries = measurement_summaries(observations),
          budgets_seconds = list(analyze_files_1 = 10, analyze_files_50 = 120,
                                 analyze_files_500 = 1200), status = "passed")
measurement_validate(x, expected)
stopifnot(x$summaries[[1]]$elapsed_seconds$median == 0.3,
          x$summaries[[1]]$elapsed_seconds$min == 0.1,
          x$summaries[[1]]$elapsed_seconds$max == 0.5)
reject(benchmark_identity("unexpected", 1L))
for (r in list(0, 6, 1.5, NA_real_, "1", c(1, 2))) reject(benchmark_identity(benchmark_scenarios()[1], r))
for (rss in list(character(), "Maximum resident set size (kbytes): 1",
                 c("Maximum resident set size (kbytes): 0", "Exit status: 0"),
                 c("Maximum resident set size (kbytes): 20", "Exit status: 1"),
                 c("Maximum resident set size (kbytes): nope", "Exit status: 0"),
                 c(rep("Maximum resident set size (kbytes): 20", 2), "Exit status: 0"))) {
  reject(measurement_parse_rss(rss))
}
reject(measurement_parse_rss(c("Maximum resident set size (kbytes): 20",
                              "Maximum resident set size (kbytes): malformed", "Exit status: 0")))
reject(measurement_parse_rss(c("Maximum resident set size (kbytes): 20",
                              "Exit status: 0", "Exit status: 1")))
stopifnot(measurement_parse_rss(c("\tMaximum resident set size (kbytes): 12345", "\tExit status: 0")) == 12345)
mutate_reject <- function(change) reject(measurement_validate(change(x), expected))
mutate_reject(function(z) { z$observations <- z$observations[-1]; z })
for (v in c("/tmp/private", "SyntheticSpeaker0")) {
  mutate_reject(function(z) { names(z$observations) <- c(v, as.character(2:30)); z })
  mutate_reject(function(z) { names(z$summaries) <- c(v, as.character(2:6)); z })
  mutate_reject(function(z) { z$metadata$runner <- v; z })
}
for (key in names(x$metadata)) {
  mutate_reject(function(z) { z$metadata[[key]] <- "SyntheticSpeaker0"; z })
}
mutate_reject(function(z) { z$observations[[2]] <- z$observations[[1]]; z })
mutate_reject(function(z) { z$observations[[1]]$scenario <- "bad"; z })
mutate_reject(function(z) { z$observations[[1]]$max_rss_kib <- NULL; z })
for (v in list(NA_real_, Inf, -1, "123", c(1, 2))) {
  mutate_reject(function(z) { z$observations[[1]]$max_rss_kib <- v; z })
  mutate_reject(function(z) { z$observations[[1]]$elapsed_seconds <- v; z })
}
mutate_reject(function(z) { z$observations[[1]]$output_rows <- 1; z })
mutate_reject(function(z) { z$observations[[1]]$processed_files <- 0; z })
mutate_reject(function(z) { z$observations[[1]]$assertions_passed <- FALSE; z })
mutate_reject(function(z) { z$observations[[1]]$status <- "failed"; z })
mutate_reject(function(z) { z$observations[[1]]$workload$sha256 <- strrep("0", 64); z })
mutate_reject(function(z) { z$observations[[16]]$workload$bytes <- 1048575; z })
mutate_reject(function(z) { z$summaries[[1]]$elapsed_seconds$median <- 12; z })
mutate_reject(function(z) { names(z$summaries[[1]])[1] <- "comment"; z })
mutate_reject(function(z) { z$budgets_seconds$analyze_files_1 <- 0.1; z })
mutate_reject(function(z) { z$semantics$rss <- "package-only"; z })
mutate_reject(function(z) { z$metadata$commit <- "unknown"; z })
mutate_reject(function(z) { z$metadata$os <- "Darwin"; z })
# Privacy is an allowlist at every object boundary, including metadata values.
for (v in c("/tmp/private", "C:\\private", "SyntheticSpeaker0",
            "Fixed synthetic benchmark cue.", "Professor Ed")) {
  mutate_reject(function(z) { z$comment <- v; z })
  mutate_reject(function(z) { z$observations[[1]]$identifier <- v; z })
}
for (v in c("/tmp/private", "C:\\private", "../relative", "Free text here")) {
  mutate_reject(function(z) { z$metadata$runner <- v; z })
}
root <- tempfile("engager-contract-tests-")
dir.create(root)
tryCatch({
  json <- file.path(root, "unit-fixture.json")
  jsonlite::write_json(x, json, auto_unbox = TRUE, digits = NA)
  measurement_validate(measurement_read(json), expected)
  encoded <- jsonlite::toJSON(x, auto_unbox = TRUE, digits = NA)
  duplicated <- sub('"schema_version":"1.0.0"',
                    '"schema_version":"1.0.0","schema_version":"1.0.0"',
                    encoded, fixed = TRUE)
  writeLines(duplicated, json)
  reject(measurement_validate(measurement_read(json), expected))
  writeLines('{"broken":', json)
  reject(measurement_read(json))
  writeLines('{"schema_version":"1.0.0","schema_version":"1.0.0"}', json)
  reject(measurement_validate(measurement_read(json), expected))
  a <- file.path(root, "a.vtt")
  b <- file.path(root, "b.vtt")
  fa <- benchmark_mib_fixture(a)
  fb <- benchmark_mib_fixture(b)
  stopifnot(identical(fa, fb),
            identical(digest::digest(file = a, algo = "sha256"),
                      digest::digest(file = b, algo = "sha256")),
            file.info(a)$size >= 1048576,
            file.info(a)$size - 1048576 < fa$last_cue_bytes)
  # A missing runtime dependency is a hard failure, with no skip path.
  original <- requireNamespace
  requireNamespace <- function(package, ...) if (package == "engager") FALSE else original(package, ...)
  reject(benchmark_dependencies())
  rm(requireNamespace)
}, finally = unlink(root, recursive = TRUE))
cat("PASS: measurement contract;", checks, "failure cases rejected\n")

#!/usr/bin/env Rscript
# Repository tooling only; measurement schema 1.0.0 remains unchanged.
comparison_script <- if (sys.nframe() > 0L) {
  sys.frame(1)$ofile
} else {
  sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
}
comparison_root <- normalizePath(file.path(dirname(comparison_script), "..", ".."),
                                 mustWork = TRUE)

comparison_error <- function(code, status = 2L) {
  stop(structure(list(message = code, call = NULL, code = code, status = status),
                 class = c("comparison_error", "error", "condition")))
}

comparison_contract <- function() {
  contract <- new.env(parent = globalenv())
  contract$source <- function(file) sys.source(file, envir = contract)
  old <- setwd(comparison_root)
  on.exit(setwd(old))
  source("scripts/benchmarks/measurement_contract.R", local = contract)
  contract$benchmark_dependencies()
  contract
}

comparison_equal <- function(a, b) {
  isTRUE(all.equal(a, b, tolerance = 0, check.attributes = TRUE))
}

comparison_read <- function(path, checksum, role, contract, expected) {
  if (!is.character(checksum) || length(checksum) != 1L || is.na(checksum) ||
      !grepl("^[a-f0-9]{64}$", checksum)) {
    comparison_error(paste0(role, "_invalid_checksum"))
  }
  bytes <- tryCatch({
    stopifnot(is.character(path), length(path) == 1L, !is.na(path),
              file.exists(path), !dir.exists(path))
    con <- file(path, "rb")
    on.exit(close(con), add = TRUE)
    readBin(con, "raw", n = file.info(path)$size)
  }, error = function(e) comparison_error(paste0(role, "_unreadable_input")))
  # Hash and parse the same in-memory bytes; never reopen after verification.
  actual <- digest::digest(bytes, algo = "sha256", serialize = FALSE)
  if (!identical(actual, checksum)) {
    comparison_error(paste0(role, "_checksum_mismatch"))
  }
  value <- tryCatch({
    text <- rawToChar(bytes)
    stopifnot(jsonlite::validate(text))
    value <- jsonlite::fromJSON(text, simplifyVector = FALSE)
    contract$measurement_validate(value, expected)
    summaries <- contract$measurement_summaries(value$observations)
    stopifnot(comparison_equal(value$summaries, summaries))
    value$summaries <- summaries
    value
  }, error = function(e) comparison_error(paste0(role, "_invalid_measurement")))
  list(sha256 = actual, measurement = value)
}

comparison_reasons <- function(baseline, candidate, contract) {
  a <- baseline$measurement
  b <- candidate$measurement
  reasons <- character()
  if (identical(baseline$sha256, candidate$sha256)) {
    reasons <- c(reasons, "identical_artifact")
  }
  if (a$metadata$run_id == "local" || b$metadata$run_id == "local" ||
      a$metadata$run_attempt == "local" || b$metadata$run_attempt == "local") {
    reasons <- c(reasons, "unverifiable_run_identity")
  } else if (a$metadata$run_id == b$metadata$run_id &&
             a$metadata$run_attempt == b$metadata$run_attempt) {
    reasons <- c(reasons, "same_run_identity")
  }
  for (key in c("package_version", "r_version", "os", "architecture", "runner")) {
    if (!identical(a$metadata[[key]], b$metadata[[key]])) {
      reasons <- c(reasons, paste0("environment_mismatch_", key))
    }
  }
  if (!comparison_equal(a$semantics, b$semantics)) {
    reasons <- c(reasons, "semantics_mismatch")
  }
  if (!comparison_equal(a$budgets_seconds, b$budgets_seconds)) {
    reasons <- c(reasons, "budget_mismatch")
  }
  for (scenario in contract$benchmark_scenarios()) {
    workloads <- function(x) lapply(Filter(function(o) o$scenario == scenario,
                                          x$observations), function(o) o$workload)
    if (!comparison_equal(workloads(a), workloads(b))) {
      reasons <- c(reasons, paste0("workload_mismatch_", scenario))
    }
  }
  reasons
}

comparison_arithmetic <- function(baseline, candidate) {
  stopifnot(is.finite(baseline), is.finite(candidate), baseline >= 0, candidate >= 0)
  ratio <- NULL
  ratio_status <- if (baseline == 0) {
    if (candidate == 0) "both_zero" else "zero_baseline"
  } else {
    value <- candidate / baseline
    if (is.finite(value)) {
      ratio <- value
      "defined"
    } else "nonfinite_ratio"
  }
  list(baseline = baseline, candidate = candidate,
       difference = candidate - baseline,
       absolute_difference = abs(candidate - baseline),
       ratio = ratio, ratio_status = ratio_status)
}

comparison_build <- function(baseline, candidate, contract) {
  reasons <- comparison_reasons(baseline, candidate, contract)
  comparable <- length(reasons) == 0L
  provenance <- function(x) list(sha256 = x$sha256,
                                measurement_schema_version = x$measurement$schema_version,
                                metadata = x$measurement$metadata)
  scenarios <- list()
  if (comparable) {
    scenarios <- lapply(seq_along(contract$benchmark_scenarios()), function(i) {
      a <- baseline$measurement$summaries[[i]]
      b <- candidate$measurement$summaries[[i]]
      metric <- function(key) setNames(lapply(c("median", "min", "max"), function(stat) {
        comparison_arithmetic(a[[key]][[stat]], b[[key]][[stat]])
      }), c("median", "min", "max"))
      list(scenario = a$scenario, observations_per_input = 5L,
           elapsed_seconds = metric("elapsed_seconds"),
           max_rss_kib = metric("max_rss_kib"))
    })
  }
  list(comparison_schema_version = "1.0.0",
       tool_status = if (comparable) "completed" else "not_comparable",
       disposition = if (comparable) "descriptive_only" else "non_comparable",
       reasons = as.list(reasons), regression_verdict = "not_assessed",
       trusted_baseline = FALSE,
       limitations = as.list(c("dependency_versions_unrecorded",
                               "runner_image_unrecorded", "hardware_identity_unrecorded",
                               "measurement_harness_fingerprint_unrecorded")),
       baseline = provenance(baseline), candidate = provenance(candidate),
       baseline_budgets_seconds = baseline$measurement$budgets_seconds,
       candidate_budgets_seconds = candidate$measurement$budgets_seconds,
       scenarios = scenarios)
}

comparison_publish <- function(result, output) {
  # A hard link publishes atomically without replacing even a dangling symlink.
  # Keep the temporary candidate on the same filesystem as the destination.
  tryCatch({
    stopifnot(is.character(output), length(output) == 1L, !is.na(output),
              nzchar(output), !file.exists(output), dir.exists(dirname(output)))
    temporary <- tempfile(".comparison-", tmpdir = dirname(output))
    on.exit(unlink(temporary), add = TRUE)
    jsonlite::write_json(result, temporary, auto_unbox = TRUE, pretty = TRUE,
                        digits = 17, null = "null")
    roundtrip <- jsonlite::fromJSON(temporary, simplifyVector = FALSE)
    stopifnot(comparison_equal(result, roundtrip))
    stopifnot(file.link(temporary, output))
  }, error = function(e) comparison_error("output_not_created", 4L))
  invisible(result)
}

compare_measurements <- function(baseline_path, baseline_sha256, candidate_path,
                                 candidate_sha256, output) {
  suppressWarnings({
    contract <- comparison_contract()
    expected <- contract$measurement_expected()
    baseline <- comparison_read(baseline_path, baseline_sha256, "baseline", contract, expected)
    candidate <- comparison_read(candidate_path, candidate_sha256, "candidate", contract, expected)
    result <- comparison_build(baseline, candidate, contract)
    comparison_publish(result, output)
    result
  })
}

comparison_main <- function(args) {
  tryCatch({
    if (length(args) != 5L) comparison_error("expected_five_arguments")
    result <- do.call(compare_measurements, as.list(args))
    cat("comparison: ", result$disposition, "\n", sep = "")
    if (result$disposition == "descriptive_only") 0L else 3L
  }, error = function(e) {
    known <- inherits(e, "comparison_error")
    cat("comparison: ", if (known) e$code else "runtime_unavailable",
        "\n", sep = "", file = stderr())
    if (known) e$status else 2L
  })
}

if (sys.nframe() == 0L) quit(status = comparison_main(commandArgs(trailingOnly = TRUE)))

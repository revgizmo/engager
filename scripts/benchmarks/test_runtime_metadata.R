#!/usr/bin/env Rscript
source("scripts/benchmarks/measurement_contract.R")

# Fabricated contract evidence only; never measured environment or baseline data.
runtime_test_fixture <- function() {
  bytes <- setNames(lapply(measurement_sources, function(p) charToRaw("synthetic source\n")),
                    names(measurement_sources))
  list(coverage = "benchmark-direct-dependencies-v1",
    platform = list(package_version = "0.1.1", r_version = "4.6.1", os = "Linux",
                    architecture = "x86_64", runner = "ubuntu-latest-X64"),
    dependencies = lapply(runtime_dependencies(), function(p) {
      list(package = p, version = if (p == "engager") "0.1.1" else "1.0.0")
    }),
    image = list(id = "ubuntu24", version = "20260913.1.0"),
    hardware = list(cpu_vendor = "amd", cpu_family = 25, cpu_model = 1,
                    cpu_stepping = 1, logical_cpus = 4, memory_total_kib = 16000000),
    harness = runtime_manifest(bytes))
}

run_runtime_tests <- function() {
  benchmark_dependencies()
  checks <- 0L
  check <- function(ok) { stopifnot(isTRUE(ok)); checks <<- checks + 1L }
  reject <- function(expr) check(inherits(tryCatch(force(expr), error = identity), "error"))
  f <- runtime_test_fixture()
  runtime_validate(f)
  check(!runtime_unknown(f))
  mutate <- function(change) reject(runtime_validate(change(f)))
  mutate(function(x) { x$hostname <- "SyntheticHost"; x })
  mutate(function(x) { x$coverage <- "all-dependencies"; x })
  mutate(function(x) { x$dependencies <- rev(x$dependencies); x })
  mutate(function(x) { x$dependencies[[2]] <- x$dependencies[[1]]; x })
  mutate(function(x) { x$dependencies <- x$dependencies[-1]; x })
  mutate(function(x) { names(x$dependencies) <- runtime_dependencies(); x })
  mutate(function(x) { x$dependencies[[1]]$version <- "private-data"; x })
  mutate(function(x) { x$dependencies[[1]]$package <- "SyntheticSpeaker0"; x })
  mutate(function(x) { x$dependencies[[3]]$version <- "0.1.2"; x })
  mutate(function(x) { x$image$id <- "unknown"; x })
  mutate(function(x) { x$image$version <- "/tmp/private"; x })
  mutate(function(x) { x$hardware$cpu_vendor <- "arbitrary host"; x })
  mutate(function(x) { x$hardware$serial <- "123"; x })
  for (key in c("logical_cpus", "memory_total_kib")) for (value in list(0, -1, Inf, NA_real_, "4", 1.5, 2^51)) {
    mutate(function(x) { x$hardware[[key]] <- value; x })
  }
  mutate(function(x) { x$hardware$cpu_model <- NULL; x })
  mutate(function(x) { x$harness$files <- rev(x$harness$files); x })
  mutate(function(x) { x$harness$files[[2]] <- x$harness$files[[1]]; x })
  mutate(function(x) { x$harness$files[[1]]$sha256 <- strrep("0", 64); x })
  mutate(function(x) { x$harness$sha256 <- strrep("0", 64); x })
  mutate(function(x) { x$harness$files[[1]]$id <- "scripts/private.R"; x })
  mutate(function(x) { x$harness$files[[1]]$path <- "/tmp/private"; x })
  mutate(function(x) { names(x$image) <- c("id", "id"); x })
  for (section in c("image", "hardware")) for (key in names(f[[section]])) {
    x <- f
    x[[section]][key] <- list(NULL)
    runtime_validate(x)
    check(runtime_unknown(x))
    reject(runtime_equal(f, x))
  }
  bytes <- setNames(lapply(measurement_sources, function(p) charToRaw("synthetic source\n")),
                    names(measurement_sources))
  check(identical(runtime_manifest(bytes), runtime_manifest(bytes)))
  reject(runtime_manifest(rev(bytes)))
  original <- runtime_manifest(bytes)
  for (key in names(bytes)) {
    changed <- bytes
    changed[[key]] <- c(changed[[key]], charToRaw(" "))
    check(runtime_manifest(changed)$sha256 != original$sha256)
  }
  expected_hash <- digest::digest(charToRaw(paste0("engager-measurement-harness-v1\n",
    paste0(names(bytes), ":", vapply(bytes, digest::digest, character(1),
      algo = "sha256", serialize = FALSE), "\n", collapse = ""))),
    algo = "sha256", serialize = FALSE)
  check(identical(original$sha256, expected_hash))

  # Exercise Linux selectors with fabricated constrained procfs fields, including
  # heterogeneous/unsupported/malformed values. Never read real identifying data.
  hardware_env <- new.env(parent = environment(runtime_hardware))
  hardware <- runtime_hardware
  environment(hardware) <- hardware_env
  hardware_env$Sys.info <- function() c(sysname = "Linux")
  hardware_env$file.exists <- function(...) TRUE
  cpu_rows <- c("vendor_id : AuthenticAMD", "cpu family : 25", "model : 1", "stepping : 1")
  hardware_env$system2 <- function(command, args, ...) {
    stopifnot(command == "awk")
    if (grepl("MemTotal", args[1], fixed = TRUE)) "16000000" else
      if (grepl("processor", args[1], fixed = TRUE)) "4" else cpu_rows
  }
  check(identical(hardware(), f$hardware))
  cpu_rows <- c(cpu_rows, "model : 2")
  reject(hardware())
  cpu_rows <- c("vendor_id : hostname-private")
  reject(hardware())
  cpu_rows <- character()
  unknown_hardware <- hardware()
  check(is.null(unknown_hardware$cpu_vendor) && is.null(unknown_hardware$cpu_model))
  check(unknown_hardware$logical_cpus == 4 && unknown_hardware$memory_total_kib == 16000000)

  # Capture loaded namespace versions and actual local platform, without claiming
  # Linux RSS. A fresh CLI worker below emits the same versioned runtime shape.
  actual <- runtime_capture(require_reference = FALSE)
  runtime_validate(actual)
  for (d in actual$dependencies) {
    check(identical(d$version, as.character(getNamespaceVersion(d$package))))
  }
  check(identical(actual$harness, runtime_manifest(measurement_source_bytes)))
  root <- tempfile("runtime-tests-")
  stopifnot(dir.create(root))
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  path <- file.path(root, "worker.json")
  log <- file.path(root, "worker.log")
  status <- system2(file.path(R.home("bin"), "Rscript"),
    c("--vanilla", shQuote(file.path(measurement_root, measurement_sources[["controller"]])),
      "worker", "analyze_files_1", "1", shQuote(path)), stdout = log, stderr = log)
  check(status == 0L)
  emitted <- measurement_read(path)
  measurement_validate_observation(emitted, rss = FALSE, runtime = TRUE)
  runtime_equal(actual, emitted$runtime_start)
  runtime_equal(emitted$runtime_start, emitted$runtime_end)
  check(emitted$processed_files == 1L && emitted$output_rows == 8L)
  text <- paste(readLines(path), collapse = "")
  check(!grepl("SyntheticSpeaker|WEBVTT|Professor Ed|/Users/|/home/|/private/|hostname|serial|machine_id", text))

  # Inject capture transitions at the worker boundary. No timing fixture is
  # confused with a real measurement; each mismatch must reject before return.
  worker_env <- new.env(parent = environment(measurement_worker))
  fake_worker <- measurement_worker
  environment(fake_worker) <- worker_env
  worker_env$benchmark_observation <- function(...) list(status = "passed")
  for (section in c("platform", "dependencies", "image", "hardware", "harness")) {
    changed <- f
    if (section == "platform") changed$platform$r_version <- "4.6.2"
    if (section == "dependencies") changed$dependencies[[1]]$version <- "1.0.1"
    if (section == "image") changed$image$version <- "20260914.1.0"
    if (section == "hardware") changed$hardware$logical_cpus <- 8
    if (section == "harness") changed$harness <- runtime_manifest(lapply(bytes, function(b) c(b, charToRaw(" "))))
    calls <- 0L
    worker_env$runtime_capture <- function(...) {
      calls <<- calls + 1L
      if (calls == 1L) f else changed
    }
    reject(fake_worker("analyze_files_1", 1L))
  }
  # Source bytes changed since loading must be rejected, including workflow.
  capture_env <- new.env(parent = environment(runtime_capture))
  capture <- runtime_capture
  environment(capture) <- capture_env
  capture_env$measurement_source_bytes <- lapply(measurement_source_bytes, function(b) c(b, charToRaw(" ")))
  reject(capture(require_reference = FALSE))
  capture_env$measurement_source_bytes <- measurement_source_bytes
  capture_env$runtime_image <- function() list(id = NULL, version = NULL)
  check(runtime_unknown(capture(require_reference = FALSE)))
  reject(capture(require_reference = TRUE))
  cat("PASS: runtime metadata;", checks, "checks including fresh worker metadata\n")
}

if (sys.nframe() == 0L) run_runtime_tests()

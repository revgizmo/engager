# Constrained benchmark evidence, not a full software inventory or machine ID.
runtime_dependencies <- function() {
  c("digest", "dplyr", "engager", "ggplot2", "hms", "jsonlite", "lubridate",
    "magrittr", "openssl", "readr", "rlang", "stringi", "stringr", "tibble", "tidyr")
}

runtime_equal <- function(a, b) {
  stopifnot(isTRUE(all.equal(a, b, tolerance = 0, check.attributes = TRUE)))
  invisible(TRUE)
}

runtime_manifest <- function(bytes) {
  stopifnot(identical(names(bytes), names(measurement_sources)))
  files <- lapply(names(bytes), function(id) {
    stopifnot(is.raw(bytes[[id]]))
    list(id = id, sha256 = digest::digest(bytes[[id]], algo = "sha256", serialize = FALSE))
  })
  list(algorithm = "sha256-manifest-v1", files = files,
       sha256 = runtime_manifest_hash(files))
}

runtime_manifest_hash <- function(files) {
  canonical <- paste0("engager-measurement-harness-v1\n", paste0(vapply(files,
    function(x) paste0(x$id, ":", x$sha256, "\n"), character(1)), collapse = ""))
  digest::digest(charToRaw(canonical), algo = "sha256", serialize = FALSE)
}

runtime_optional_token <- function(value, pattern) {
  if (!is.null(value)) measurement_token(value, pattern)
}

runtime_unknown <- function(x) {
  any(vapply(c(x$image, x$hardware), is.null, TRUE))
}

runtime_validate <- function(x) {
  measurement_keys(x, c("coverage", "platform", "dependencies", "image", "hardware", "harness"))
  stopifnot(identical(x$coverage, "benchmark-direct-dependencies-v1"))
  measurement_keys(x$platform, c("package_version", "r_version", "os", "architecture", "runner"))
  for (key in c("package_version", "r_version")) {
    measurement_token(x$platform[[key]], "^[0-9]+([.-][0-9]+)*$")
  }
  measurement_token(x$platform$os, "^(Linux|Darwin|Windows)$")
  measurement_token(x$platform$architecture, "^(x86_64|aarch64|arm64|i386)$")
  measurement_token(x$platform$runner, "^(local|ubuntu-latest-(X64|ARM64))$")
  stopifnot(is.list(x$dependencies), is.null(names(x$dependencies)),
            length(x$dependencies) == length(runtime_dependencies()))
  for (i in seq_along(runtime_dependencies())) {
    d <- x$dependencies[[i]]
    measurement_keys(d, c("package", "version"))
    stopifnot(identical(d$package, runtime_dependencies()[i]))
    measurement_token(d$version, "^[0-9]+([.-][0-9]+)*$")
  }
  stopifnot(identical(x$dependencies[[3]]$version, x$platform$package_version))
  measurement_keys(x$image, c("id", "version"))
  runtime_optional_token(x$image$id, "^ubuntu[0-9]{2}$")
  runtime_optional_token(x$image$version, "^[0-9]{8}[.][0-9]{1,4}([.][0-9]{1,4})?$")
  measurement_keys(x$hardware, c("cpu_vendor", "cpu_family", "cpu_model", "cpu_stepping",
                               "logical_cpus", "memory_total_kib"))
  runtime_optional_token(x$hardware$cpu_vendor, "^(intel|amd)$")
  for (key in setdiff(names(x$hardware), "cpu_vendor")) {
    value <- x$hardware[[key]]
    if (!is.null(value)) {
      measurement_number(value, integer = TRUE,
                         positive = key %in% c("logical_cpus", "memory_total_kib"))
      stopifnot(value <= if (key == "memory_total_kib") 2^50 else 1048576)
    }
  }
  h <- x$harness
  measurement_keys(h, c("algorithm", "files", "sha256"))
  stopifnot(identical(h$algorithm, "sha256-manifest-v1"), is.list(h$files),
            is.null(names(h$files)), length(h$files) == length(measurement_sources))
  for (i in seq_along(measurement_sources)) {
    measurement_keys(h$files[[i]], c("id", "sha256"))
    stopifnot(identical(h$files[[i]]$id, names(measurement_sources)[i]))
    measurement_token(h$files[[i]]$sha256, "^[a-f0-9]{64}$")
  }
  measurement_token(h$sha256, "^[a-f0-9]{64}$")
  stopifnot(identical(h$sha256, runtime_manifest_hash(h$files)))
  invisible(TRUE)
}

runtime_image <- function() {
  optional <- function(name) {
    value <- Sys.getenv(name, "")
    if (nzchar(value)) value else NULL
  }
  # These two runner-image variables only; never capture an environment dump.
  list(id = optional("ImageOS"), version = optional("ImageVersion"))
}

runtime_hardware <- function() {
  result <- list(cpu_vendor = NULL, cpu_family = NULL, cpu_model = NULL,
                 cpu_stepping = NULL, logical_cpus = NULL, memory_total_kib = NULL)
  if (!identical(unname(Sys.info()[["sysname"]]), "Linux")) return(result)
  # Read only named, nonidentifying fields from procfs into R. No model names,
  # serial fields, hostnames, machine IDs or unrestricted command output.
  selected <- function(program, path) {
    if (!file.exists(path)) return(character())
    value <- system2("awk", c(shQuote(program), shQuote(path)), stdout = TRUE, stderr = FALSE)
    stopifnot(is.null(attr(value, "status")), length(value) <= 65536L)
    value
  }
  cpu <- selected('/^(vendor_id|cpu family|model|stepping)[[:space:]]*:/ {print}', "/proc/cpuinfo")
  field <- function(key, pattern) {
    rows <- grep(paste0("^", key, "[[:space:]]*:"), cpu, value = TRUE)
    if (!length(rows)) return(NULL)
    values <- unique(trimws(sub("^[^:]*:", "", rows)))
    stopifnot(length(values) == 1L)
    measurement_token(values, pattern)
    values
  }
  vendor <- field("vendor_id", "^(GenuineIntel|AuthenticAMD)$")
  if (!is.null(vendor)) {
    result$cpu_vendor <- if (vendor == "GenuineIntel") "intel" else "amd"
    mapping <- c(cpu_family = "cpu family", cpu_model = "model", cpu_stepping = "stepping")
    for (key in names(mapping)) {
      value <- field(mapping[[key]], "^[0-9]{1,6}$")
      result[key] <- list(if (is.null(value)) NULL else as.numeric(value))
    }
  }
  cpus <- selected('/^processor[[:space:]]*:/ {n++} END {print n+0}', "/proc/cpuinfo")
  if (length(cpus)) {
    measurement_token(cpus, "^[0-9]{1,6}$")
    result$logical_cpus <- as.numeric(cpus)
  }
  memory <- selected('/^MemTotal:/ {print $2}', "/proc/meminfo")
  if (length(memory)) {
    measurement_token(memory, "^[0-9]{1,15}$")
    result$memory_total_kib <- as.numeric(memory)
  }
  result
}

runtime_capture <- function(require_reference = identical(Sys.getenv("GITHUB_ACTIONS"), "true")) {
  dependencies <- lapply(runtime_dependencies(), function(package) {
    stopifnot(requireNamespace(package, quietly = TRUE))
    # Namespace versions reflect the code loaded in this process, not a later
    # installed DESCRIPTION that could differ from an already loaded namespace.
    list(package = package, version = as.character(getNamespaceVersion(package)))
  })
  current_bytes <- lapply(file.path(measurement_root, measurement_sources), measurement_raw)
  names(current_bytes) <- names(measurement_sources)
  harness <- runtime_manifest(current_bytes)
  runtime_equal(harness, runtime_manifest(measurement_source_bytes))
  x <- list(coverage = "benchmark-direct-dependencies-v1",
    platform = list(package_version = as.character(getNamespaceVersion("engager")),
      r_version = as.character(getRversion()), os = unname(Sys.info()[["sysname"]]),
      architecture = R.version$arch, runner = Sys.getenv("BENCHMARK_RUNNER", "local")),
    dependencies = dependencies, image = runtime_image(), hardware = runtime_hardware(),
    harness = harness)
  runtime_validate(x)
  if (require_reference) {
    stopifnot(!runtime_unknown(x), identical(x$platform$os, "Linux"),
              grepl("^ubuntu-latest-", x$platform$runner))
  }
  x
}

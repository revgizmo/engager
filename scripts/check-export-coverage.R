#!/usr/bin/env Rscript

fail <- function(...) {
  stop(paste0(...), call. = FALSE)
}

read_allowlist <- function(path) {
  if (!file.exists(path)) {
    fail("Supported-export allowlist not found: ", path)
  }
  entries <- trimws(readLines(path, warn = FALSE))
  entries <- entries[nzchar(entries) & !startsWith(entries, "#")]
  if (length(entries) == 0L) {
    fail("Supported-export allowlist is empty: ", path)
  }
  if (anyDuplicated(entries)) {
    fail("Supported-export allowlist contains duplicates")
  }
  sort(entries)
}

allowlist_path <- "project-docs/release/supported-exports.txt"
threshold <- 85

expected <- read_allowlist(allowlist_path)
invisible(loadNamespace("engager"))
actual <- sort(getNamespaceExports("engager"))
unloadNamespace("engager")

unexpected <- setdiff(actual, expected)
missing <- setdiff(expected, actual)
if (length(unexpected) > 0L || length(missing) > 0L) {
  fail(
    "Namespace differs from supported-export allowlist",
    if (length(unexpected) > 0L) {
      paste0("; unexpected: ", paste(unexpected, collapse = ", "))
    } else {
      ""
    },
    if (length(missing) > 0L) {
      paste0("; missing: ", paste(missing, collapse = ", "))
    } else {
      ""
    }
  )
}

coverage <- covr::package_coverage()
overall <- as.numeric(covr::percent_coverage(coverage))
details <- as.data.frame(coverage)
details <- details[!is.na(details$functions) & nzchar(details$functions), ]

per_export <- lapply(expected, function(function_name) {
  rows <- details[details$functions == function_name, , drop = FALSE]
  total <- nrow(rows)
  covered <- if (total > 0L) sum(rows$value > 0, na.rm = TRUE) else 0L
  data.frame(
    function_name = function_name,
    covered = covered,
    total = max(total, 1L),
    instrumented = total > 0L,
    stringsAsFactors = FALSE
  )
})
per_export <- do.call(rbind, per_export)
supported_coverage <- round(
  100 * sum(per_export$covered) / sum(per_export$total),
  2
)

cat(sprintf("overall_coverage=%.2f\n", overall))
cat(sprintf("supported_export_coverage=%.2f\n", supported_coverage))
uninstrumented <- per_export$function_name[!per_export$instrumented]
if (length(uninstrumented) > 0L) {
  cat(
    "uninstrumented_supported_exports=",
    paste(uninstrumented, collapse = ","),
    "\n",
    sep = ""
  )
}

if (supported_coverage < threshold) {
  fail(
    sprintf(
      "Supported-export coverage %.2f%% is below the %.0f%% threshold",
      supported_coverage,
      threshold
    )
  )
}

cat("[PASS] namespace and supported-export coverage contract\n")

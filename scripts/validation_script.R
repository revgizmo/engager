# validation_script.R - Comprehensive validation for PR 476 implementation
library(devtools)
library(lintr)

cat("🔍 Running PR 476 Implementation Validation...\n\n")

# 1. CRAN Compliance Check
cat("1. Checking CRAN compliance...\n")
check_result <- check()
if (check_result$errors > 0) {
  cat("❌ CRAN check failed with", check_result$errors, "errors\n")
  stop("CRAN compliance check failed")
} else if (check_result$warnings > 0) {
  cat("⚠️  CRAN check has", check_result$warnings, "warnings\n")
} else {
  cat("✅ CRAN check passed (0 errors, 0 warnings)\n")
}

# 2. Test Suite
cat("\n2. Running test suite...\n")
test_result <- test()
if (test_result$failed > 0) {
  cat("❌ Tests failed:", test_result$failed, "failures\n")
} else {
  cat("✅ All tests passed\n")
}

# 3. Linting Check
cat("\n3. Checking code quality...\n")
lint_result <- lint_package()
lint_count <- length(lint_result)
if (lint_count > 50) {
  cat("⚠️  High number of linting issues:", lint_count, "\n")
} else if (lint_count > 0) {
  cat("ℹ️  Linting issues found:", lint_count, "\n")
} else {
  cat("✅ No linting issues found\n")
}

# 4. Non-ASCII Character Check
cat("\n4. Checking for non-ASCII characters...\n")
r_files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
non_ascii_found <- FALSE
for (file in r_files) {
  content <- readLines(file, warn = FALSE)
  for (i in seq_along(content)) {
    if (grepl("[^\x00-\x7F]", content[i])) {
      cat("❌ Non-ASCII character found in", file, "line", i, "\n")
      non_ascii_found <- TRUE
    }
  }
}
if (!non_ascii_found) {
  cat("✅ No non-ASCII characters found\n")
}

# 5. UX Functions Test
cat("\n5. Testing UX functions...\n")
tryCatch({
  load_all()
  show_getting_started()
  show_available_functions()
  cat("✅ UX functions working correctly\n")
}, error = function(e) {
  cat("❌ UX functions test failed:", e$message, "\n")
})

# 6. Logging System Test
cat("\n6. Testing logging system...\n")
tryCatch({
  env1 <- .zse_get_logs_env()
  env1$logs$test <- "test log"
  env2 <- .zse_get_logs_env()
  if (!is.null(env2$logs$test)) {
    cat("✅ Logging system working correctly\n")
  } else {
    cat("❌ Logging system not persistent\n")
  }
}, error = function(e) {
  cat("❌ Logging system test failed:", e$message, "\n")
})

cat("\n🎯 Validation complete!\n")

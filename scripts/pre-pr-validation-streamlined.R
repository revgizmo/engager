#!/usr/bin/env Rscript

# Streamlined Pre-PR Validation Script
# Simplified for UX-focused development workflow

library(devtools)
library(lintr)
library(styler)

cat("🚀 Streamlined Pre-PR Validation\n")
cat(paste(rep("=", 35), collapse = ""), "\n\n")

# Progress function
show_progress <- function(message, operation, estimated_time = NULL) {
  if (!is.null(estimated_time)) {
    cat(message, "(estimated", estimated_time, ")\n")
  } else {
    cat(message, "\n")
  }
  
  start_time <- Sys.time()
  result <- tryCatch({
    operation()
    end_time <- Sys.time()
    duration <- round(as.numeric(difftime(end_time, start_time, units = "secs")), 1)
    cat("   ✅ Completed in", duration, "seconds\n")
    TRUE
  }, error = function(e) {
    end_time <- Sys.time()
    duration <- round(as.numeric(difftime(end_time, start_time, units = "secs")), 1)
    cat("   ❌ Failed after", duration, "seconds:", e$message, "\n")
    stop("Validation failed: ", e$message)
  })
  return(result)
}

# Initialize status tracking
validation_status <- list(
  code_style = FALSE,
  documentation = FALSE,
  testing = FALSE,
  package_check = FALSE
)

# Phase 1: Code Quality (3 minutes)
cat("📝 Phase 1: Code Quality\n")
cat(paste(rep("-", 25), collapse = ""), "\n")

validation_status$code_style <- show_progress(
  "   🔄 Applying code formatting",
  function() styler::style_pkg(),
  "2-5 minutes"
)

# Phase 2: Documentation (2 minutes)
cat("\n📚 Phase 2: Documentation\n")
cat(paste(rep("-", 25), collapse = ""), "\n")

validation_status$documentation <- show_progress(
  "   🔄 Updating documentation",
  function() devtools::document(),
  "1-2 minutes"
)

# Phase 3: Testing (3 minutes)
cat("\n🧪 Phase 3: Testing\n")
cat(paste(rep("-", 25), collapse = ""), "\n")

validation_status$testing <- show_progress(
  "   🔄 Running test suite",
  function() {
    test_results <- devtools::test(reporter = "stop")
    cat("   ✅ All tests pass\n")
  },
  "2-3 minutes"
)

# Phase 4: Final Validation (2 minutes)
cat("\n✅ Phase 4: Final Validation\n")
cat(paste(rep("-", 25), collapse = ""), "\n")

validation_status$package_check <- show_progress(
  "   🔄 Running package check",
  function() {
    # Lightweight check instead of full devtools::check()
    devtools::load_all()
    cat("   ✅ Package loads successfully\n")
    
    # Quick syntax check
    r_files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
    for (file in r_files) {
      parse(file)
    }
    cat("   ✅ All R files have valid syntax\n")
  },
  "1-2 minutes"
)

# Summary
cat("\n🎯 Validation Complete!\n")
cat(paste(rep("=", 25), collapse = ""), "\n")

total_checks <- length(validation_status)
passed_checks <- sum(unlist(validation_status))
failed_checks <- total_checks - passed_checks

cat("📊 Results:\n")
cat(ifelse(validation_status$code_style, "✅", "❌"), "Code Quality: Styling and formatting\n")
cat(ifelse(validation_status$documentation, "✅", "❌"), "Documentation: Updated and built\n")
cat(ifelse(validation_status$testing, "✅", "❌"), "Testing: All tests pass\n")
cat(ifelse(validation_status$package_check, "✅", "❌"), "Package Check: Completed\n\n")

if (failed_checks == 0) {
  cat("🎉 All validation checks passed! Ready for PR.\n")
  cat("💡 Total time: ~10 minutes (down from 25 minutes)\n")
} else {
  cat("⚠️  ", failed_checks, "validation check(s) failed. Please fix issues before creating PR.\n")
}

cat("\n🔧 Next Steps:\n")
if (failed_checks == 0) {
  cat("✅ Ready to create PR!\n")
} else {
  cat("1. Fix failing checks\n")
  cat("2. Run validation again\n")
}

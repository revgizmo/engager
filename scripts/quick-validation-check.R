#!/usr/bin/env Rscript

# Quick Validation Check Script
# Identifies common issues without running full validation
# Use this to quickly diagnose problems

cat("🔍 Quick Validation Check - Identifying Issues...\n\n")

# Load required libraries
library(devtools)

# 1. Check package structure
cat("1. Package Structure Check:\n")
if (file.exists("DESCRIPTION")) {
  cat("   ✅ DESCRIPTION file exists\n")
} else {
  cat("   ❌ DESCRIPTION file missing\n")
  stop("Missing DESCRIPTION file")
}

if (file.exists("NAMESPACE")) {
  cat("   ✅ NAMESPACE file exists\n")
} else {
  cat("   ❌ NAMESPACE file missing\n")
  stop("Missing NAMESPACE file")
}

if (dir.exists("R")) {
  r_files <- list.files("R", pattern = "\\.R$")
  cat("   ✅ R directory exists with", length(r_files), "R files\n")
} else {
  cat("   ❌ R directory missing\n")
  stop("Missing R directory")
}

# 2. Check for obvious syntax errors
cat("\n2. Syntax Check:\n")
syntax_errors <- 0
for (file in list.files("R", pattern = "\\.R$", full.names = TRUE)) {
  tryCatch({
    parse(file)
    cat("   ✅", basename(file), "syntax OK\n")
  }, error = function(e) {
    cat("   ❌", basename(file), "syntax error:", e$message, "\n")
    syntax_errors <<- syntax_errors + 1
  })
}

if (syntax_errors > 0) {
  cat("   🚨", syntax_errors, "syntax error(s) found\n")
} else {
  cat("   ✅ All R files have valid syntax\n")
}

# 3. Check package loading
cat("\n3. Package Loading Check:\n")
tryCatch({
  devtools::load_all()
  cat("   ✅ Package loads successfully\n")
}, error = function(e) {
  cat("   ❌ Package loading failed:", e$message, "\n")
  stop("Package loading failed")
})

# 4. Check namespace exports
cat("\n4. Namespace Check:\n")
tryCatch({
  ns <- getNamespace("engager")
  exports <- getNamespaceExports("engager")
  cat("   ✅ Namespace loaded with", length(exports), "exports\n")
}, error = function(e) {
  cat("   ❌ Namespace check failed:", e$message, "\n")
  stop("Namespace check failed")
})

# 5. Check test files
cat("\n5. Test Files Check:\n")
if (dir.exists("tests")) {
  test_files <- list.files("tests", pattern = "\\.R$", recursive = TRUE)
  cat("   ✅ Tests directory exists with", length(test_files), "test files\n")
} else {
  cat("   ⚠️  Tests directory missing\n")
}

# Summary
cat("\n📊 QUICK VALIDATION SUMMARY:\n")
if (syntax_errors == 0) {
  cat("✅ Package structure looks good\n")
  cat("✅ No syntax errors detected\n")
  cat("✅ Package loads successfully\n")
  cat("✅ Namespace is valid\n")
  cat("\n🎯 Ready for full validation or development\n")
} else {
  cat("❌", syntax_errors, "syntax error(s) found\n")
  cat("🚨 Fix syntax errors before running full validation\n")
}

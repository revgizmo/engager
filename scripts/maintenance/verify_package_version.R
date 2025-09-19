#!/usr/bin/env Rscript

# Package Version Verification Script
# Run this to verify you have the correct version of zoomstudentengagement

cat("🔍 Verifying zoomstudentengagement package version...\n\n")

# Load the package
library(zoomstudentengagement)

# Method 1: Check version
version <- packageVersion("zoomstudentengagement")
cat("✅ Package Version:", as.character(version), "\n")

# Method 2: Check installation path
package_path <- find.package("zoomstudentengagement")
cat("✅ Package Location:", package_path, "\n")

# Method 3: Check installation date
package_info <- packageDescription("zoomstudentengagement")
cat("✅ Package Title:", package_info$Title, "\n")
cat("✅ Package Author:", package_info$Author, "\n")

# Method 4: Verify key functions exist
expected_functions <- c(
  "load_zoom_transcript",
  "process_zoom_transcript", 
  "summarize_transcript_metrics",
  "match_names_to_roster",
  "plot_engagement_summary"
)

cat("\n🔍 Checking for expected functions:\n")
for (func in expected_functions) {
  if (exists(func, where = "package:zoomstudentengagement")) {
    cat("  ✅", func, "\n")
  } else {
    cat("  ❌", func, "(missing)\n")
  }
}

# Method 5: Test error message format (version-specific)
cat("\n🧪 Testing error message format:\n")
empty_file <- tempfile(fileext = ".vtt")
writeLines("", empty_file)

tryCatch({
  load_zoom_transcript(empty_file)
}, error = function(e) {
  expected_message <- "Invalid VTT: expected 'WEBVTT', got ''"
  actual_message <- e$message
  
  if (grepl(expected_message, actual_message, fixed = TRUE)) {
    cat("  ✅ Error message format is correct (version 1.0.0+)\n")
    cat("     Message:", actual_message, "\n")
  } else {
    cat("  ❌ Error message format is incorrect (old version)\n")
    cat("     Expected:", expected_message, "\n")
    cat("     Got:", actual_message, "\n")
  }
})

unlink(empty_file)

# Method 6: Check for version-specific features
cat("\n🔍 Checking for version-specific features:\n")

# Check if privacy functions exist (added in recent versions)
privacy_functions <- c("set_privacy_defaults", "get_privacy_defaults")
for (func in privacy_functions) {
  if (exists(func, where = "package:zoomstudentengagement")) {
    cat("  ✅", func, "(privacy features available)\n")
  } else {
    cat("  ❌", func, "(privacy features missing)\n")
  }
}

# Summary
cat("\n📋 Summary:\n")
if (version >= "1.0.0") {
  cat("✅ You have version 1.0.0 or higher - this is the correct version!\n")
} else {
  cat("❌ You have an older version. Please update to 1.0.0 or higher.\n")
}

cat("\n🎯 Package verification complete!\n")


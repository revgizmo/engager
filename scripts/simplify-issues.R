#!/usr/bin/env Rscript

# Issue Management Simplification Script
# Helps consolidate and organize GitHub issues for better UX

cat("📋 Issue Management Simplification\n")
cat(paste(rep("=", 40), collapse = ""), "\n\n")

# Function to categorize issues
categorize_issues <- function() {
  cat("🔍 Categorizing Issues by Priority and Type\n")
  cat(paste(rep("-", 40), collapse = ""), "\n")
  
  # High Priority Issues (CRAN Blockers)
  high_priority <- c(
    "Issue #394: [PRD] Basic UX Simplification",
    "Issue #393: [PRD] Core Function Audit & Categorization", 
    "Issue #392: [PRD] Success Metrics Definition & Implementation",
    "Issue #298: feat(privacy): name masking helper with docs",
    "Issue #293: test(ingestion): malformed inputs edge cases",
    "Issue #282: Plan: Near-term Simplification for CRAN Readiness",
    "Issue #220: fix: Wrap diagnostic output in test environment checks",
    "Issue #90: Add missing function documentation",
    "Issue #56: Add transcript_file column with intelligent duplicate handling"
  )
  
  # Medium Priority Issues (Post-CRAN)
  medium_priority <- c(
    "Issue #403: enhancement: Apply metric existence guard pattern",
    "Issue #402: test: Expand edge case testing for column validation",
    "Issue #401: docs: Add required columns documentation",
    "Issue #395: [PRD] Post-CRAN Implementation Coordination",
    "Issue #382: refactor: Consolidate type coercion logic",
    "Issue #380: performance: Optimize memory usage for large files",
    "Issue #379: performance: Optimize cross join operations",
    "Issue #378: performance: Implement chunked reading",
    "Issue #375: security: Implement file size limits"
  )
  
  # Low Priority Issues (Nice to Have)
  low_priority <- c(
    "Issue #381: security: Add audit logging for privacy-sensitive operations",
    "Issue #368: refactor: Decompose large functions for better maintainability",
    "Issue #367: style: Address lint warnings and improve code consistency",
    "Issue #366: refactor: Standardize error handling across functions",
    "Issue #364: test: Reduce test warning noise for cleaner output",
    "Issue #345: performance: minor speedups and safety tweaks"
  )
  
  cat("🚨 High Priority (CRAN Blockers):", length(high_priority), "issues\n")
  cat("📊 Medium Priority (Post-CRAN):", length(medium_priority), "issues\n")
  cat("📝 Low Priority (Nice to Have):", length(low_priority), "issues\n\n")
  
  return(list(
    high = high_priority,
    medium = medium_priority,
    low = low_priority
  ))
}

# Function to suggest issue consolidation
suggest_consolidation <- function() {
  cat("🔄 Issue Consolidation Suggestions\n")
  cat(paste(rep("-", 40), collapse = ""), "\n")
  
  consolidations <- list(
    "Performance Issues" = c(
      "Issue #380: performance: Optimize memory usage",
      "Issue #379: performance: Optimize cross join operations", 
      "Issue #378: performance: Implement chunked reading",
      "Issue #345: performance: minor speedups"
    ),
    "Testing Improvements" = c(
      "Issue #402: test: Expand edge case testing",
      "Issue #293: test(ingestion): malformed inputs edge cases",
      "Issue #364: test: Reduce test warning noise"
    ),
    "Documentation Updates" = c(
      "Issue #401: docs: Add required columns documentation",
      "Issue #90: Add missing function documentation"
    ),
    "Code Quality" = c(
      "Issue #367: style: Address lint warnings",
      "Issue #366: refactor: Standardize error handling",
      "Issue #368: refactor: Decompose large functions"
    )
  )
  
  for (category in names(consolidations)) {
    cat("📁", category, ":", length(consolidations[[category]]), "related issues\n")
    for (issue in consolidations[[category]]) {
      cat("   •", issue, "\n")
    }
    cat("\n")
  }
}

# Function to create focused issue roadmap
create_roadmap <- function() {
  cat("🗺️ Focused Issue Roadmap\n")
  cat(paste(rep("-", 40), collapse = ""), "\n")
  
  roadmap <- list(
    "Week 1: CRAN Preparation" = c(
      "Complete Issue #394: Basic UX Simplification",
      "Complete Issue #393: Core Function Audit", 
      "Complete Issue #392: Success Metrics Definition",
      "Complete Issue #220: Diagnostic output fixes"
    ),
    "Week 2: Documentation & Testing" = c(
      "Complete Issue #90: Missing function documentation",
      "Complete Issue #293: Malformed inputs testing",
      "Complete Issue #56: Transcript file column"
    ),
    "Week 3: Post-CRAN Planning" = c(
      "Plan Issue #395: Post-CRAN Implementation",
      "Prioritize performance improvements",
      "Plan scope reduction strategy"
    )
  )
  
  for (week in names(roadmap)) {
    cat("📅", week, "\n")
    for (task in roadmap[[week]]) {
      cat("   ✅", task, "\n")
    }
    cat("\n")
  }
}

# Main execution
cat("🎯 Current Status: 250+ open issues\n")
cat("🎯 Target: 75 focused issues\n")
cat("🎯 Strategy: Consolidate related issues, close outdated ones\n\n")

# Run categorization
categories <- categorize_issues()

# Suggest consolidations
suggest_consolidation()

# Create roadmap
create_roadmap()

cat("💡 Recommendations:\n")
cat("1. Focus on high-priority CRAN blockers first\n")
cat("2. Consolidate related issues into epics\n")
cat("3. Close outdated or duplicate issues\n")
cat("4. Create clear milestones for each phase\n")
cat("5. Use labels to organize by priority and type\n\n")

cat("🔧 Next Steps:\n")
cat("1. Review and update issue priorities\n")
cat("2. Create consolidated epic issues\n")
cat("3. Close outdated issues\n")
cat("4. Update issue labels and milestones\n")
cat("5. Create focused project roadmap\n\n")

cat("✅ Issue management simplification complete!\n")

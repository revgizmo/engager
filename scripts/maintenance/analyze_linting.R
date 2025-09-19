#!/usr/bin/env Rscript

# Analyze linting issues
lint_results <- lintr::lint_package()

# Get linter types
linter_types <- sapply(lint_results, function(x) {
  return(x$linter)
})

# Count issues by type
issue_counts <- table(linter_types)
print("Linting Issues by Type:")
print(issue_counts)

# Get files with most issues
file_issues <- table(sapply(lint_results, function(x) x$filename))
print("\nFiles with Most Issues:")
print(head(sort(file_issues, decreasing = TRUE), 10))

# Show some examples of each type
print("\nExamples of each issue type:")
for (linter_type in names(issue_counts)) {
  cat("\n", linter_type, ":\n")
  examples <- lint_results[sapply(lint_results, function(x) {
    return(x$linter == linter_type)
  })]
  
  for (i in 1:min(3, length(examples))) {
    cat("  ", examples[[i]]$filename, ":", examples[[i]]$line_number, "-", examples[[i]]$message, "\n")
  }
}

#!/usr/bin/env Rscript

# Fix object length issues (names > 30 characters)
library(lintr)

# Get all object length issues
lint_results <- lintr::lint_package()
object_length_issues <- lint_results[sapply(lint_results, function(x) x$linter == "object_length_linter")]

cat("Found", length(object_length_issues), "object length issues\n")

# Group by file
file_issues <- split(object_length_issues, sapply(object_length_issues, function(x) x$filename))

for (file_path in names(file_issues)) {
  cat("Processing", file_path, "with", length(file_issues[[file_path]]), "issues\n")
  
  # Read the file
  lines <- readLines(file_path)
  
  # Sort issues by line number (descending to avoid line number shifts)
  issues <- file_issues[[file_path]]
  line_numbers <- sapply(issues, function(x) x$line_number)
  issues <- issues[order(line_numbers, decreasing = TRUE)]
  
  for (issue in issues) {
    line_num <- issue$line_number
    line_content <- lines[line_num]
    
    cat("  Line", line_num, ":", issue$message, "\n")
    
    # Extract the long name
    name_match <- regmatches(line_content, regexec("([a-zA-Z_][a-zA-Z0-9_]{30,})", line_content))
    if (length(name_match) > 0 && length(name_match[[1]]) > 1) {
      long_name <- name_match[[1]][2]
      cat("    Long name:", long_name, "(", nchar(long_name), "characters)\n")
      
      # Create a shorter version
      if (grepl("generate_", long_name)) {
        short_name <- gsub("generate_", "gen_", long_name)
      } else if (grepl("_validation_", long_name)) {
        short_name <- gsub("_validation_", "_val_", long_name)
      } else if (grepl("_compliance_", long_name)) {
        short_name <- gsub("_compliance_", "_comp_", long_name)
      } else if (grepl("_recommendations", long_name)) {
        short_name <- gsub("_recommendations", "_recs", long_name)
      } else if (grepl("_configuration", long_name)) {
        short_name <- gsub("_configuration", "_config", long_name)
      } else if (grepl("_progressive_", long_name)) {
        short_name <- gsub("_progressive_", "_prog_", long_name)
      } else if (grepl("_disclosure_", long_name)) {
        short_name <- gsub("_disclosure_", "_disc_", long_name)
      } else {
        # Generic shortening - remove vowels and common suffixes
        short_name <- long_name
        short_name <- gsub("_", "", short_name)
        short_name <- gsub("([aeiou])", "", short_name)
        if (nchar(short_name) > 30) {
          short_name <- substr(short_name, 1, 30)
        }
      }
      
      if (nchar(short_name) <= 30) {
        cat("    Shortened to:", short_name, "(", nchar(short_name), "characters)\n")
        # Replace in the line
        lines[line_num] <- gsub(long_name, short_name, line_content)
      } else {
        cat("    Could not shorten sufficiently\n")
      }
    }
  }
  
  # Write the file back
  writeLines(lines, file_path)
}

cat("Object length fixes completed\n")

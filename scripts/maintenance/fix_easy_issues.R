#!/usr/bin/env Rscript

# Fix easy linting issues
library(lintr)

# Get all issues
lint_results <- lintr::lint_package()

# Fix seq_linter issues
seq_issues <- lint_results[sapply(lint_results, function(x) x$linter == "seq_linter")]
cat("Found", length(seq_issues), "seq issues\n")

for (issue in seq_issues) {
  file_path <- issue$filename
  line_num <- issue$line_number
  
  cat("Fixing seq issue in", file_path, "line", line_num, "\n")
  
  lines <- readLines(file_path)
  line_content <- lines[line_num]
  
  # Replace 1:min(...) with seq_len(min(...))
  if (grepl("1:min\\(", line_content)) {
    new_line <- gsub("1:min\\(", "seq_len(min(", line_content)
    lines[line_num] <- new_line
    writeLines(lines, file_path)
    cat("  Fixed:", line_content, "->", new_line, "\n")
  }
}

# Fix assignment_linter issues
assignment_issues <- lint_results[sapply(lint_results, function(x) x$linter == "assignment_linter")]
cat("Found", length(assignment_issues), "assignment issues\n")

for (issue in assignment_issues) {
  file_path <- issue$filename
  line_num <- issue$line_number
  
  cat("Fixing assignment issue in", file_path, "line", line_num, "\n")
  
  lines <- readLines(file_path)
  line_content <- lines[line_num]
  
  # Replace = with <- (but be careful about function parameters)
  if (grepl("\\s=\\s", line_content) && !grepl("function\\(", line_content)) {
    new_line <- gsub("\\s=\\s", " <- ", line_content)
    lines[line_num] <- new_line
    writeLines(lines, file_path)
    cat("  Fixed:", line_content, "->", new_line, "\n")
  }
}

# Fix remaining return_linter issues
return_issues <- lint_results[sapply(lint_results, function(x) x$linter == "return_linter")]
cat("Found", length(return_issues), "return issues\n")

for (issue in return_issues) {
  file_path <- issue$filename
  line_num <- issue$line_number
  
  cat("Fixing return issue in", file_path, "line", line_num, "\n")
  
  lines <- readLines(file_path)
  line_content <- lines[line_num]
  
  # Remove explicit return statements
  if (grepl("return\\(", line_content)) {
    return_match <- regmatches(line_content, regexec("return\\(([^)]+)\\)", line_content))
    if (length(return_match) > 0 && length(return_match[[1]]) > 1) {
      return_value <- return_match[[1]][2]
      # Replace with just the value
      lines[line_num] <- paste0(strrep(" ", nchar(line_content) - nchar(trimws(line_content))), return_value)
      writeLines(lines, file_path)
      cat("  Fixed:", line_content, "->", lines[line_num], "\n")
    }
  }
}

cat("Easy issues fixes completed\n")

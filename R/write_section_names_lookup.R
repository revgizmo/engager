# Internal function - no documentation needed
write_section_names_lookup <-
  function(clean_names_df = NULL,
           data_folder = ".",
           section_names_lookup_file = "section_names_lookup.csv") {
    if (tibble::is_tibble(clean_names_df) &&
        file.exists(data_folder)
    ) {
      # Use base R operations instead of dplyr to avoid segmentation fault
      # Group by the specified columns and count occurrences
      group_cols <- c(
        "course_section", "day", "time", "course", "section",
        "preferred_name", "formal_name", "transcript_name", "student_id"
      )

      # Create a unique identifier for each group
      clean_names_df$group_id <- apply(clean_names_df[, group_cols], 1, paste, collapse = "|")

      # Get the first row from each group (equivalent to summarise)
      result <- clean_names_df[!duplicated(clean_names_df$group_id), group_cols, drop = FALSE]

      # Sort by preferred_name and formal_name using base R
      result <- result[order(result$preferred_name, result$formal_name), , drop = FALSE]

      # Write to CSV
      readr::write_csv(result, file.path(data_folder, section_names_lookup_file))

      # Return the result tibble
      return(tibble::as_tibble(result))
    }
  }

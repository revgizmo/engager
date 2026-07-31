# Internal function - no documentation needed
write_section_names_lookup <-
  function(clean_names_df = NULL,
           data_folder = NULL,
           section_names_lookup_file = "section_names_lookup.csv") {
    if (!tibble::is_tibble(clean_names_df)) {
      return(invisible(NULL))
    }

    if (!is.character(data_folder) || length(data_folder) != 1L ||
        is.na(data_folder) || !nzchar(trimws(data_folder))) {
      stop(
        "`data_folder` must be an explicit non-empty directory path",
        call. = FALSE
      )
    }
    if (!dir.exists(data_folder)) {
      stop("`data_folder` must name an existing directory", call. = FALSE)
    }
    if (!is.character(section_names_lookup_file) ||
        length(section_names_lookup_file) != 1L ||
        is.na(section_names_lookup_file) ||
        !nzchar(trimws(section_names_lookup_file)) ||
        section_names_lookup_file %in% c(".", "..") ||
        grepl("[/\\\\]", section_names_lookup_file)) {
      stop(
        "`section_names_lookup_file` must be a non-empty file name",
        call. = FALSE
      )
    }

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

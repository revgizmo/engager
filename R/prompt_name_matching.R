# Internal function - no documentation needed
prompt_name_matching <- function(unmatched_names = NULL,
                                 privacy_level = getOption(
                                   "engager.privacy_level",
                                   "mask"
                                 ),
                                 data_folder = NULL,
                                 section_names_lookup_file = "section_names_lookup.csv",
                                 include_instructions = TRUE,
                                 write_lookup = FALSE) {
  # Validate inputs
  if (!is.character(unmatched_names)) {
    stop("unmatched_names must be a character vector", call. = FALSE)
  }

  privacy_level <- normalize_privacy_level(privacy_level)

  if (!is.null(data_folder) &&
      (!is.character(data_folder) || length(data_folder) != 1L ||
        is.na(data_folder) || !nzchar(trimws(data_folder)))) {
    stop("data_folder must be NULL or a non-empty character string", call. = FALSE)
  }

  if (!is.character(section_names_lookup_file) ||
      length(section_names_lookup_file) != 1L ||
      is.na(section_names_lookup_file) ||
      !nzchar(trimws(section_names_lookup_file))) {
    stop("section_names_lookup_file must be a single character string", call. = FALSE)
  }

  if (!is.logical(include_instructions) || length(include_instructions) != 1) {
    stop("include_instructions must be a single logical value", call. = FALSE)
  }
  if (!is.logical(write_lookup) || length(write_lookup) != 1 || is.na(write_lookup)) {
    stop("write_lookup must be a single logical value", call. = FALSE)
  }

  # If no unmatched names, return early
  if (length(unmatched_names) == 0) {
    if (getOption("engager.verbose", FALSE)) {
      message("No unmatched names found. Name matching is complete.")
    }
    return(invisible(NULL))
  }

  # Generate privacy-safe guidance
  guidance <- generate_name_matching_guidance(
    unmatched_names,
    privacy_level,
    include_instructions
  )

  # Display guidance to user (quiet by default)
  if (getOption("engager.verbose", FALSE)) {
    cat("\n", guidance, "\n", sep = "")
  }

  # Use existing function to create blank template
  lookup_template <- make_blank_section_names_lookup_csv()

  if (!isTRUE(write_lookup)) {
    return(invisible(lookup_template))
  }

  if (is.null(data_folder)) {
    stop("`data_folder` must be supplied when `write_lookup = TRUE`", call. = FALSE)
  }
  lookup_file_path <- file.path(data_folder, section_names_lookup_file)
  if (!dir.exists(data_folder)) {
    dir.create(data_folder, recursive = TRUE)
  }

  # Save the template to the specified file
  readr::write_csv(lookup_template, lookup_file_path)

  # Return the file path invisibly
  invisible(lookup_file_path)
}

# Internal function - no documentation needed
generate_name_matching_guidance <- function(unmatched_names, privacy_level, include_instructions) {
  # Count unmatched names
  n_unmatched <- length(unmatched_names)

  # Base message
  if (n_unmatched == 1) {
    base_msg <- "Found 1 unmatched name that needs manual mapping."
  } else {
    base_msg <- paste("Found", n_unmatched, "unmatched names that need manual mapping.")
  }

  # Privacy warning if needed
  privacy_msg <- ""
  if (!identical(privacy_level, "none")) {
    privacy_msg <- paste(
      "\n*** PRIVACY WARNING:",
      "Real names will be shown below for matching purposes only.",
      "These names will be masked in all final outputs."
    )
  }

  # Show unmatched names (this is the only place real names should appear)
  names_msg <- paste(
    "\nUnmatched names:",
    paste(unmatched_names, collapse = ", ")
  )

  # Instructions
  instructions_msg <- ""
  if (include_instructions) {
    instructions_msg <- paste(
      "\n\n*** INSTRUCTIONS:",
      "1. Review the in-memory lookup template returned by prompt_name_matching()",
      "2. Choose an explicit output directory and call prompt_name_matching(..., data_folder = output_dir, write_lookup = TRUE) if a CSV template is needed",
      "3. Map each transcript name to the correct roster name",
      "4. Set 'participant_type' to one of:",
      "   - 'instructor' for faculty/staff",
      "   - 'enrolled_student' for students on roster",
      "   - 'guest' for non-enrolled participants",
      "5. Save the file and re-run your analysis",
      "",
      "*** TIP: Use consistent naming across sessions for better matching",
      sep = "\n"
    )
  }

  # Combine all messages
  paste(base_msg, privacy_msg, names_msg, instructions_msg, sep = "")
}

# Compatibility helper for the legacy safe-name-matching workflow. The public
# detect_unmatched_names() API is defined in R/name_matching_workflow.R and
# returns a privacy-safe data frame.
detect_unmatched_names_legacy <- function(transcripts_df,
                                          roster_df,
                                          name_mappings = NULL,
                                          privacy_level = getOption(
                                            "engager.privacy_level",
                                            "mask"
                                          )) {
  if (!is.data.frame(transcripts_df)) {
    stop("transcripts_df must be a data frame", call. = FALSE)
  }
  if (!is.data.frame(roster_df)) {
    stop("roster_df must be a data frame", call. = FALSE)
  }

  transcript_names <- unique(extract_transcript_names(transcripts_df))
  if (length(transcript_names) == 0) {
    stop("transcripts_df must have a recognized speaker/name column", call. = FALSE)
  }

  roster_names <- unique(extract_roster_names(roster_df))
  mapped_names <- if (is.null(name_mappings)) {
    character(0)
  } else {
    unique(extract_mapped_names(name_mappings))
  }

  unmatched <- setdiff(transcript_names, unique(c(roster_names, mapped_names)))
  if (!identical(privacy_level, "none")) {
    unmatched <- hash_name_consistently(unmatched)
  }

  unmatched
}

# Internal function - no documentation needed
extract_transcript_names <- function(transcript_data) {
  # Look for common name columns in transcript data
  name_columns <- c(
    "speaker", "user_name", "transcript_name", "name", "speaker_name",
    "participant_name"
  )
  found_columns <- intersect(name_columns, names(transcript_data))

  if (length(found_columns) == 0) {
    return(character(0))
  }

  # Use the first found column
  names <- transcript_data[[found_columns[1]]]

  # Convert to character and clean
  names <- as.character(names)
  names <- names[!is.na(names) & nchar(trimws(names)) > 0]

  names
}

# Internal function - no documentation needed
extract_roster_names <- function(roster_data) {
  # Look for common name columns in roster data
  name_columns <- c("first_last", "preferred_name", "formal_name", "name", "student_name")
  found_columns <- intersect(name_columns, names(roster_data))

  if (length(found_columns) == 0) {
    return(character(0))
  }

  # Use the first found column
  names <- roster_data[[found_columns[1]]]

  # Convert to character and clean
  names <- as.character(names)
  names <- names[!is.na(names) & nchar(trimws(names)) > 0]

  names
}

# Internal function - no documentation needed
extract_mapped_names <- function(name_mappings) {
  # Look for common name columns in mappings
  name_columns <- c("transcript_name", "preferred_name", "formal_name", "name")
  found_columns <- intersect(name_columns, names(name_mappings))

  if (length(found_columns) == 0) {
    return(character(0))
  }

  # Use the first found column
  names <- name_mappings[[found_columns[1]]]

  # Convert to character and clean
  names <- as.character(names)
  names <- names[!is.na(names) & nchar(trimws(names)) > 0]

  names
}

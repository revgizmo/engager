# Internal function - no documentation needed
prompt_name_matching <- function(unmatched_names = NULL,
                                 privacy_level = getOption(
                                   "zoomstudentengagement.privacy_level",
                                   "mask"
                                 ),
                                 data_folder = ".",
                                 section_names_lookup_file = "section_names_lookup.csv",
                                 include_instructions = TRUE) {

  # Validate inputs
  if (!is.character(unmatched_names)) {
    stop("unmatched_names must be a character vector", call. = FALSE)
  }

  valid_levels <- c("ferpa_strict", "ferpa_standard", "mask", "none")
  if (!privacy_level %in% valid_levels) {
    stop("Invalid privacy_level. Must be one of: ",
      paste(valid_levels, collapse = ", "),
      call. = FALSE
    )
  }

  if (!is.character(data_folder) || length(data_folder) != 1) {
    stop("data_folder must be a single character string", call. = FALSE)
  }

  if (!is.character(section_names_lookup_file) || length(section_names_lookup_file) != 1) {
    stop("section_names_lookup_file must be a single character string", call. = FALSE)
  }

  if (!is.logical(include_instructions) || length(include_instructions) != 1) {
    stop("include_instructions must be a single logical value", call. = FALSE)
  }

  # If no unmatched names, return early
  if (length(unmatched_names) == 0) {
    if (getOption("engager.verbose", FALSE)) {
      message("No unmatched names found. Name matching is complete.")
    }
    return(invisible(NULL))
  }

  # Create data folder if it doesn't exist
  if (!dir.exists(data_folder)) {
    dir.create(data_folder, recursive = TRUE)
    # Created data folder
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

  # Create the lookup file using existing function
  lookup_file_path <- file.path(data_folder, section_names_lookup_file)

  # Use existing function to create blank template
  lookup_template <- make_blank_section_names_lookup_csv()

  # Save the template to the specified file
  readr::write_csv(lookup_template, lookup_file_path)

  # Created lookup file
  # Please edit this file to map the unmatched names, then re-run your analysis.

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
      "1. Open the created 'section_names_lookup.csv' file",
      "2. Add rows for each unmatched name above",
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

# Internal function - no documentation needed
detect_unmatched_names <- function(transcript_data = NULL,
                                   roster_data = NULL,
                                   name_mappings = NULL,
                                   privacy_level = getOption(
                                     "zoomstudentengagement.privacy_level",
                                     "mask"
                                   )) {
  # Validate inputs
  if (!is.data.frame(transcript_data)) {
    stop("transcript_data must be a data frame", call. = FALSE)
  }
  if (!is.data.frame(roster_data)) {
    stop("roster_data must be a data frame", call. = FALSE)
  }

  valid_levels <- c("ferpa_strict", "ferpa_standard", "mask", "none")
  if (!privacy_level %in% valid_levels) {
    stop("Invalid privacy_level. Must be one of: ",
      paste(valid_levels, collapse = ", "),
      call. = FALSE
    )
  }

  # Extract transcript names
  transcript_names <- extract_transcript_names(transcript_data)

  # Extract roster names
  roster_names <- extract_roster_names(roster_data)

  # Extract mapped names (if provided)
  mapped_names <- character(0)
  if (!is.null(name_mappings) && is.data.frame(name_mappings)) {
    mapped_names <- extract_mapped_names(name_mappings)
  }

  # Combine all known names
  known_names <- unique(c(roster_names, mapped_names))

  # Find unmatched names
  unmatched_names <- setdiff(transcript_names, known_names)

  # Remove empty or NA names
  unmatched_names <- unmatched_names[!is.na(unmatched_names) & nchar(trimws(unmatched_names)) > 0]

  # If privacy is enabled, return hashed versions
  if (!identical(privacy_level, "none")) {
    unmatched_names <- hash_name_consistently(unmatched_names)
  }

  # Return unique unmatched names
  unique(unmatched_names)
}

# Internal function - no documentation needed
extract_transcript_names <- function(transcript_data) {

  # Look for common name columns in transcript data
  name_columns <- c("transcript_name", "name", "speaker_name", "participant_name")
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
  name_columns <- c("preferred_name", "formal_name", "transcript_name", "name")
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

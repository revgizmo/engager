# Internal function - no documentation needed
set_privacy_defaults <- function(privacy_level = c("privacy_strict", "privacy_standard", "mask", "none"),
                                 unmatched_names_action = c("stop", "warn")) {
  privacy_level <- match.arg(privacy_level)
  unmatched_names_action <- match.arg(unmatched_names_action)

  # Validate privacy level
  if (identical(privacy_level, "none")) {
    warning(
      "Privacy disabled globally; outputs may contain identifiable data.",
      call. = FALSE
    )
  } else if (identical(privacy_level, "privacy_strict")) {
    if (getOption("engager.verbose", FALSE)) {
      message("Privacy strict mode enabled; maximum privacy protection applied.")
    }
  } else if (identical(privacy_level, "privacy_standard")) {
    if (getOption("engager.verbose", FALSE)) {
      message("Privacy standard mode enabled; educational privacy defaults applied.")
    }
  }

  # Validate unmatched names action
  if (identical(unmatched_names_action, "stop")) {
    # Unmatched names action set to 'stop' - maximum privacy protection enabled.
  } else if (identical(unmatched_names_action, "warn")) {
    # Unmatched names action set to 'warn' - guided matching enabled.
  }

  # Set global options
  options(
    engager.privacy_level = privacy_level,
    engager.unmatched_names_action = unmatched_names_action
  )

  # Return configuration invisibly
  invisible(list(
    privacy_level = privacy_level,
    unmatched_names_action = unmatched_names_action
  ))
}

#' UX System Integration
#'
#' @description Integrates function audit results with UX system
#' @keywords internal
#' @noRd

#' Update UX categories based on function audit
#'
#' @param function_categories Function categories from audit
#' @param cran_functions Functions selected for CRAN
#' @return Updated UX categories
update_ux_categories <- function(function_categories, cran_functions) {
  cat("🔄 Updating UX categories based on function audit...\n")

  # Define UX levels based on function importance and complexity
  ux_categories <- list(
    essential = character(0), # 5 most critical functions
    common = character(0), # 10 commonly used functions
    advanced = character(0), # 15 advanced functions
    expert = character(0) # Remaining functions
  )

  # Prioritize functions for UX levels
  prioritized_functions <- prioritize_functions_for_ux(function_categories, cran_functions)

  # Allocate functions to UX levels
  ux_categories$essential <- prioritized_functions[1:min(5, length(prioritized_functions))]
  ux_categories$common <- prioritized_functions[6:min(15, length(prioritized_functions))]
  ux_categories$advanced <- prioritized_functions[16:min(30, length(prioritized_functions))]
  ux_categories$expert <- prioritized_functions[31:length(prioritized_functions)]

  # Remove empty categories
  ux_categories <- lapply(ux_categories, function(x) x[!is.na(x) & x != ""])

  cat("✅ UX categories updated successfully\n")
  print_ux_category_summary(ux_categories)

  ux_categories
}

#' Prioritize functions for UX levels
#'
#' @param function_categories Function categories from audit
#' @param cran_functions Functions selected for CRAN
#' @return Prioritized function list
prioritize_functions_for_ux <- function(function_categories, cran_functions) {
  # Priority order for UX (based on user workflow importance)
  priority_order <- c(
    "core_workflow", # Most important for users
    "privacy_compliance", # Critical for compliance
    "data_processing", # Core functionality
    "analysis", # Analysis capabilities
    "visualization", # Output functions
    "utility" # Helper functions
  )

  prioritized <- character(0)

  # Add functions in priority order
  for (category in priority_order) {
    if (category %in% names(function_categories)) {
      category_functions <- function_categories[[category]]
      # Only include functions that are in CRAN selection
      cran_category_functions <- intersect(category_functions, cran_functions)
      prioritized <- c(prioritized, cran_category_functions)
    }
  }

  # Add any remaining CRAN functions
  remaining_functions <- setdiff(cran_functions, prioritized)
  prioritized <- c(prioritized, remaining_functions)

  prioritized
}

#' Print UX category summary
#'
#' @param ux_categories UX categories
print_ux_category_summary <- function(ux_categories) {
  cat("\n📱 UX CATEGORY SUMMARY\n")
  cat(paste(rep("=", 25), collapse = ""), "\n")

  for (level in names(ux_categories)) {
    count <- length(ux_categories[[level]])
    cat(sprintf("%-10s: %2d functions\n", level, count))
  }
  cat("\n")
}

#' Update help system with new categories
#'
#' @param function_categories Function categories from audit
#' @param ux_categories UX categories
#' @return Updated help system
update_help_system <- function(function_categories, ux_categories) {
  cat("📚 Updating help system with new categories...\n")

  help_system <- list(
    getting_started = list(
      functions = ux_categories$essential,
      description = "Essential functions for getting started with transcript analysis"
    ),
    common_workflows = list(
      functions = ux_categories$common,
      description = "Commonly used functions for typical analysis workflows"
    ),
    advanced_features = list(
      functions = ux_categories$advanced,
      description = "Advanced functions for specialized analysis needs"
    ),
    expert_tools = list(
      functions = ux_categories$expert,
      description = "Expert-level functions for complex analysis scenarios"
    )
  )

  cat("✅ Help system updated successfully\n")

  help_system
}

#' Generate progressive disclosure configuration
#'
#' @param ux_categories UX categories
#' @return Progressive disclosure configuration
generate_progressive_disclosure_config <- function(ux_categories) {
  cat("🎛️  Generating progressive disclosure configuration...\n")

  disclosure_config <- list(
    levels = list(
      beginner = list(
        functions = ux_categories$essential,
        description = "Start here - essential functions for basic analysis",
        show_advanced = FALSE
      ),
      intermediate = list(
        functions = c(ux_categories$essential, ux_categories$common),
        description = "Common workflows - essential + commonly used functions",
        show_advanced = FALSE
      ),
      advanced = list(
        functions = c(ux_categories$essential, ux_categories$common, ux_categories$advanced),
        description = "Advanced analysis - includes specialized functions",
        show_advanced = TRUE
      ),
      expert = list(
        functions = c(
          ux_categories$essential, ux_categories$common,
          ux_categories$advanced, ux_categories$expert
        ),
        description = "Expert mode - all functions available",
        show_advanced = TRUE
      )
    ),
    default_level = "beginner",
    auto_progression = TRUE
  )

  cat("✅ Progressive disclosure configuration generated\n")

  disclosure_config
}

#' Update function help descriptions
#'
#' @param function_categories Function categories from audit
#' @param ux_categories UX categories
#' @return Updated function descriptions
update_function_descriptions <- function(function_categories, ux_categories) {
  cat("📝 Updating function help descriptions...\n")

  descriptions <- list()

  for (level in names(ux_categories)) {
    for (func_name in ux_categories[[level]]) {
      descriptions[[func_name]] <- list(
        level = level,
        category = get_function_category_by_name(func_name, function_categories),
        description = generate_function_description(func_name, level)
      )
    }
  }

  cat("✅ Function descriptions updated\n")

  descriptions
}

#' Get function category by name
#'
#' @param func_name Function name
#' @param function_categories Function categories
#' @return Category name
get_function_category_by_name <- function(func_name, function_categories) {
  for (category in names(function_categories)) {
    if (func_name %in% function_categories[[category]]) {
      return(category)
    }
  }
  "unknown"
}

#' Generate function description based on UX level
#'
#' @param func_name Function name
#' @param ux_level UX level
#' @return Function description
generate_function_description <- function(func_name, ux_level) {
  base_descriptions <- list(
    analyze_transcripts = "Main function for analyzing Zoom transcripts",
    load_zoom_transcript = "Load and parse Zoom transcript files",
    privacy_audit = "Audit transcript data for privacy compliance",
    plot_users = "Create visualizations of user engagement",
    write_metrics = "Export analysis results to files"
  )

  if (func_name %in% names(base_descriptions)) {
    base_desc <- base_descriptions[[func_name]]
  } else {
    base_desc <- paste("Function:", func_name)
  }

  level_prefixes <- list(
    essential = "⭐ Essential: ",
    common = "📊 Common: ",
    advanced = "🔧 Advanced: ",
    expert = "⚡ Expert: "
  )

  if (ux_level %in% names(level_prefixes)) {
    paste0(level_prefixes[[ux_level]], base_desc
  } else {
    base_desc
  }
}

#' Create UX integration report
#'
#' @param function_categories Function categories from audit
#' @param cran_functions Functions selected for CRAN
#' @param ux_categories UX categories
#' @param help_system Help system
#' @return UX integration report
create_ux_integration_report <- function(function_categories, cran_functions, ux_categories, help_system) {
  cat("📊 Creating UX integration report...\n")

  report <- list(
    summary = list(
      total_functions = length(cran_functions),
      essential_functions = length(ux_categories$essential),
      common_functions = length(ux_categories$common),
      advanced_functions = length(ux_categories$advanced),
      expert_functions = length(ux_categories$expert)
    ),
    ux_categories = ux_categories,
    help_system = help_system,
    progressive_disclosure = generate_progressive_disclosure_config(ux_categories),
    generated_at = Sys.time()
  )

  cat("✅ UX integration report created\n")

  report
}

#' Test UX integration system
#'
#' @return Test results
test_ux_integration <- function() {
  cat("🧪 Testing UX integration system...\n")

  # Test with sample data
  sample_categories <- list(
    core_workflow = c("analyze_transcripts", "load_zoom_transcript"),
    privacy_compliance = c("privacy_audit", "ensure_privacy"),
    data_processing = c("consolidate_transcript"),
    analysis = c("summarize_transcript_metrics"),
    visualization = c("plot_users", "write_metrics"),
    utility = c("get_essential_functions")
  )

  sample_cran_functions <- c(
    "analyze_transcripts", "load_zoom_transcript", "privacy_audit",
    "ensure_privacy", "consolidate_transcript", "summarize_transcript_metrics",
    "plot_users", "write_metrics", "get_essential_functions"
  )

  ux_categories <- update_ux_categories(sample_categories, sample_cran_functions)
  help_system <- update_help_system(sample_categories, ux_categories)

  cat("✅ UX integration test completed\n")

  return(list(
    ux_categories = ux_categories,
    help_system = help_system
  ))
}

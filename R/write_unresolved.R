# Safe writer for unresolved names (scaffold)

#' Write unresolved matches to disk with privacy guardrails
#'
#' @param unresolved_tbl Tibble returned by detect_unmatched_names()
#' @param path Output file path
#' @param include_raw Logical; include raw names if TRUE and allowed
#' @param overwrite Logical; overwrite existing file if TRUE
#' @return Invisibly, the path written
#' @export
#' @family name-matching
write_unresolved <- function(unresolved_tbl,
                             path,
                             include_raw = FALSE,
                             overwrite = FALSE) {
  rlang::abort("write_unresolved() not yet implemented in MVP scaffolding.",
               class = "engager_not_implemented_error")
}



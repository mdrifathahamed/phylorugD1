#' Check Taxa Consistency Across Multiple Phylogenetic Trees
#'
#' Compares a list of phylogenetic trees against a reference tree
#' (the first tree in the list) to ensure that all trees contain the exact same
#' set of taxa (tip labels). If discrepancies are found, detailed diagnostic
#' reports listing missing and extra taxa are provided.
#'
#' @param tree_list A list of phylogenetic tree objects of class \code{"phylo"},
#'  or a multiPhylo object containing the trees to be compared.
#'
#' @param verbose Logical. If \code{TRUE} (default), detailed status messages
#' and diagnostic reports for mismatched trees are printed to the console using
#'  \code{\link[base]{message}}.
#'
#'
#' @return A single logical value. \code{TRUE} if all trees contain
#'   identical taxa. \code{FALSE} if any tree differs, in which case
#'   the pipeline should not proceed.
#'
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Assuming 'my_trees' is a named list of phylo objects loaded into R:
#' trees <- read_trees_from_dir("path/to/your/trees")
#' result <- check_same_taxa(trees)
#'
#' # Check if it's safe to proceed:
#' if (result) {
#'   message("Safe to proceed.")
#' }
#' }
check_same_taxa <- function(tree_list, verbose = TRUE) {

  # Validate input
  if (!inherits(tree_list, "list")) {
    stop(
      "`tree_list` must be a list of phylo objects.",
      call. = FALSE
    )
  }

  if (length(tree_list) == 0) {
    stop(
      "`tree_list` is empty. Supply at least two trees.",
      call. = FALSE
    )
  }

  if (any(vapply(tree_list, is.null, logical(1)))) {
    stop(
      "`tree_list` contains NULL elements. ",
      "Check that all files were read successfully.",
      call. = FALSE
    )
  }

  # Extract and sort tip labels from each tree
  taxa_list <- lapply(tree_list, function(tr) sort(tr$tip.label))

  # Use first tree as reference
  ref  <- taxa_list[[1]]

  # Compare all trees to reference
  same <- vapply(taxa_list, function(x) identical(x, ref), logical(1))

  # Report results if verbose
  if (verbose) {
    if (all(same)) {
      message("\u2705 All trees contain the same set of taxa.")
    } else {
      message("\u274c Some trees differ in their taxa.")
      bad <- which(!same)
      for (i in bad) {
        diff1 <- setdiff(ref, taxa_list[[i]])
        diff2 <- setdiff(taxa_list[[i]], ref)
        message(
          " - Tree ", i, ": missing {",
          paste(diff1, collapse = ", "),
          "} extra {",
          paste(diff2, collapse = ", "), "}"
        )
      }
    }
  }

  # Return single logical
  all(same)
}

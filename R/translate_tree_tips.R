#' Translate tip labels of a phylogenetic tree
#'
#' Renames the terminal tip labels of a phylogenetic tree using a lookup table
#' supplied as a data frame. Only tips matching entries in `from_col` are
#' renamed , unmatched tips are left unchanged. Both `from_col` and `to_col`
#' must be character columns not factors, and a summary message reports how many
#' tips were translated.
#'
#' @param phy A phylogenetic tree object of class `phylo`.
#'
#' @param data A data frame containing the label translation lookup table. Can
#'   be a standard `data.frame` or a `tibble`.
#'
#' @param from_col A character string specifying the column name in `data` that
#'   holds the current tip labels of the tree. Defaults to `from`.
#'
#' @param to_col A character string specifying the column name in `data` that
#'   holds the new desired replacement labels. Defaults to `to`.
#'
#' @return An updated phylogenetic tree object of class `phylo` with matching
#'   tip labels translated. The tree topology and edge lengths remain unchanged.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'
#' # Mock a small tree
#' tree <- ape::rtree(3, tip.label = c("t1", "t2", "t3"))
#'
#' # Translation map
#' dict <- data.frame(
#'   from = c("t1", "t2"),
#'   to   = c("Homo_sapiens", "Mus_musculus")
#' )
#'
#' # Translate tips
#' clean_tree <- translate_tree_tips(tree,
#'                                   dict,
#'                                   from_col = "from",
#'                                   to_col   = "to")
#' }

translate_tree_tips <- function(phy,
                                data,
                                from_col = "from",
                                to_col   = "to") {
  # Validate inputs
  if (!inherits(phy, "phylo")) {
    stop(
      "`phy` must be a phylogenetic tree of class \"phylo\".",
      call. = FALSE
    )
  }

  if (!inherits(data, "data.frame")) {
    stop(
      "`data` must be a data frame.",
      call. = FALSE
    )
  }

  if (!all(c(from_col, to_col) %in% colnames(data))) {
    stop(
      "Columns \"", from_col, "\" and \"", to_col,
      "\" not found in `data`.",
      call. = FALSE
    )
  }

  # Build translation dictionary
  # as.character() protects against factor columns
  trans_dict <- stats::setNames(
    as.character(data[[to_col]]),
    as.character(data[[from_col]])
  )

  # Find which tips need translating
  tips_to_translate <- phy$tip.label %in% names(trans_dict)

  # Translate matched tips
  phy$tip.label[tips_to_translate] <-
    trans_dict[phy$tip.label[tips_to_translate]]
  # Report summary
  message("Tips translated : ", sum(tips_to_translate))
  message("Tips unchanged  : ", sum(!tips_to_translate))

  phy
}

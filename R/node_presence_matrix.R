#' Construct Node Presence and Support Value Matrix Across Multiple Phylogenies
#'
#' Evaluates a collection of alternative phylogenetic trees against a designated reference
#' backbone topology. For each internal node in the backbone tree, the function determines
#' whether a matching monophyletic clade exists in each comparison tree, populating a coordinate
#' data framework matrix with binary occupancy flags or quantitative branch support scores.
#'
#' @param backbone A phylogenetic tree object of class \code{"phylo"}. This tree serves
#'   as the structural reference template, where each of its internal nodes establishes a
#'   mapping row coordinate in the final output matrix.
#'
#' @param trees A named list of alternative phylogenetic tree objects of class \code{"phylo"},
#'   or an object of class \code{"multiPhylo"}. Each tree in this list corresponds to a single
#'   independent data partition, inference method, or bootstrap replicate, defining a unique data
#'   mapping column in the output matrix.
#'
#' @param use_support Logical. If \code{FALSE} (default), the function operates in binary
#'   presence/absence mode, returning a \code{1} if a backbone clade is congruent with a
#'   comparison tree and \code{0} otherwise. If \code{TRUE}, the function operates in quantitative
#'   mode, returning the literal branch support score extracted from matching clades, or \code{0}
#'   if the clade is completely absent or structurally discordant.
#'
#' @param support_col Integer. Specifies which target column data to extract from the internal
#'   node indexing tables (typically column \code{1} or \code{2}, mapping onto distinct bootstrap or
#'   posterior probability metrics). Assessed only when \code{use_support = TRUE}. Defaults to \code{1}.
#'
#' @param round_support Integer or \code{NULL}. If an integer is supplied, numerical support values
#'   are rounded to the specified number of decimal places before matrix insertion. Defaults to \code{NULL}.
#'
#'
#' @return A numeric matrix where:
#' \itemize{
#'   \item \strong{Rows:} Represent the internal nodes of the \code{backbone} tree, with the absolute backbone node index stored in the first column labeled \code{"node_id"}.
#'   \item \strong{Columns:} Represent each target tree supplied inside \code{tree_list}. Column names are automatically mapped onto the names of the list elements, or padded sequentially to \code{"tree_1"}, \code{"tree_2"} if names are absent.
#'   \item \strong{Cells:} Contain numeric scalar values indicating binary clade presence (\code{0} or \code{1}) or quantitative statistical confidence values (e.g., bootstrap percentages or Bayesian posterior values) depending on \code{use_support}.
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#'
#' # Generate a shared backbone tree and several alternative trees
#' shared_backbone <- ape::rtree(5, tip.label = c("A", "B", "C", "D", "E"))
#' alternative_trees <- list(
#'   UCE_partition = ape::rtree(5, tip.label = c("A", "B", "C", "D", "E")),
#'   Mito_partition = ape::rtree(5, tip.label = c("A", "B", "C", "D", "E"))
#' )
#'
#' # 1. Calculate binary presence/absence matrix
#' topo_matrix <- node_presence_matrix(
#'   backbone    = shared_backbone,
#'   trees   = alternative_trees,
#'   use_support = FALSE
#' )
#'
#' # 2. Calculate continuous support value intensity matrix
#' support_matrix <- node_presence_matrix(
#'   backbone    = shared_backbone,
#'   trees   = alternative_trees,
#'   use_support = TRUE,
#'   support_col = 1
#' )
#' }
node_presence_matrix <- function(backbone,
                                 trees,
                                 use_support = FALSE,
                                 support_col = 1,
                                 round_support = NULL) {

  if (!inherits(backbone, "phylo")) {
    stop("`backbone` must be a phylogenetic tree of class \"phylo\".",
      call. = FALSE
    )
  }

  if (!is.list(trees)) {
    stop("`trees` must be a named list of phylo objects.",
      call. = FALSE
    )
  }

  if (!support_col %in% c(1, 2)) {
    stop("`support_col` must be 1 or 2.", call. = FALSE)
  }
  # helper: get clade (tip labels) for a given node
  get_clade <- function(tree, node) {
    tips <- phangorn::Descendants(tree, node, type = "tips")[[1]]
    sort(tree$tip.label[tips])
  }
  ntip <- ape::Ntip(backbone)
  nnodes <- backbone$Nnode
  bb_nodes <- (ntip + 1):(ntip + nnodes)

  # clades for each backbone node
  bb_clades <- lapply(bb_nodes, get_clade, tree = backbone)

  # For each tree, compute values per backbone node
  M <- sapply(seq_along(trees), function(i) {
    tr <- trees[[i]]

    # internal nodes of this tree
    tr_nodes <- (ape::Ntip(tr) + 1):(ape::Ntip(tr) + tr$Nnode)
    tr_clades <- lapply(tr_nodes, get_clade, tree = tr)

    # if using support, parse support for this tree
    if (use_support) {
      supp <- get_node_support(tr, round = round_support)
      if (nrow(supp) != length(tr_nodes)) {
        stop(
          "Number of node labels in tree ", i,
          " does not match Nnode(tree)."
        )
      }
      support_vec <- as.numeric(supp[[support_col]])
    }

    # For each backbone clade: either 0/1 or that tree's support
    sapply(bb_clades, function(cl) {
      idx <- which(vapply(
        tr_clades,
        function(cl2) identical(cl2, cl),
        logical(1)
      ))
      if (length(idx) == 0) {
        # backbone node absent in this tree
        return(0)
      } else {
        # present: either 1 or that tree's node support
        idx <- idx[1] # unique match assumed
        if (!use_support) {
          return(1)
        } else {
          val <- support_vec[idx]
          ifelse(is.na(val), 0, val) # NA support → treat as 0
        }
      }
    })
  })

  # At this point, M has rows = backbone nodes, cols = trees
  M <- as.matrix(M)
  colnames(M) <- if (!is.null(names(trees))) names(trees) else paste0("tree_", seq_along(trees))

  # Add backbone node IDs as first column
  M <- cbind(node_id = bb_nodes, M)

  M
}

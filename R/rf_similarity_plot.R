#' Map and Plot Multidimensional Tree Similarity from Robinson-Foulds Distances
#'
#' Calculates the symmetric topological Robinson-Foulds (RF) distance between
#' pairs of input trees, projects their structural proximity patterns onto a
#' lower-dimensional continuous plane using Classical Multidimensional Scaling
#' (MDS), and renders a labeled ordination scatter plot on the current graphics
#' device.
#'
#' @param trees An object of class \code{"multiPhylo"} containing a list of
#'   independent phylogenetic trees sharing an identical terminal leaf-set.
#' @param method Character string. The distance method passed to
#'   \code{ape::dist.topo()}. Use \code{"PH85"} for the Robinson-Foulds
#'   symmetric difference (default).
#'
#' @param k Integer. Number of dimensions for the MDS projection.
#'   Default is \code{2} for a standard 2D scatter plot.
#'
#' @return The MDS coordinate matrix invisibly. A scatter plot is drawn
#'   on the current graphics device as a side effect.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'
#' # Generate a list of 5 mock random trees with identical tip labels
#' set.seed(42)
#'
#' mock_trees <- replicate(
#'   5,
#'   ape::rtree(10, tip.label = paste0("Taxon_", 1:10)),
#'   simplify = FALSE
#' )
#'
#' class(mock_trees) <- "multiPhylo"
#' names(mock_trees) <- paste0("Analysis_", 1:5)
#'
#' # Create the plots/ directory if missing and run the visualization pipeline
#' rf_similarity_plot(mock_trees)
#' }
rf_similarity_plot <- function(trees,
                               method = "PH85",
                               k      = 2) {
  # Validate input
  if (!inherits(trees, "multiPhylo")) {
    stop(
      "`trees` must be an object of class \"multiPhylo\".",
      call. = FALSE
    )
  }

  # Compute pairwise RF distances
  rf <- ape::dist.topo(trees, method = method)
  rf_mt <- as.matrix(rf)

  # Project onto k dimensions using MDS
  mds <- stats::cmdscale(stats::as.dist(rf_mt), k = k)

  # Plot
  graphics::plot(
    mds[, 1], mds[, 2],
    xlab = "MDS1",
    ylab = "MDS2",
    main = "Tree similarity based on RF distances",
    pch = 19
  )

  graphics::text(
    mds[, 1], mds[, 2],
    labels = rownames(mds),
    pos = 3,
    cex = 0.7
  )

  invisible(mds)
}

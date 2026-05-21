#' Plot Node Rug Grids Over a Phylogenetic Canvas
#'
#' Superimposes compact color-coded grid sub-cells ("rug plots") onto the internal
#' branching nodes of a previously plotted phylogenetic tree. This provides a clear,
#' multi-analysis visual representation of statistical node support values.
#'
#' @param tree An object of class \code{"phylo"} representing the reference topology
#'   rendered on the active graphics device.
#'
#' @param rug_mt A matrix or data frame where the first column corresponds to the
#'   backbone \code{node_id} sequence, and subsequent columns contain numeric support
#'   values for each comparison tree.
#'
#' @param cell_h A numeric value specifying the geometric height of each individual
#'   grid sub-cell in plotting coordinate space.
#'
#' @param cell_w A numeric value specifying the geometric width of each individual
#'   grid sub-cell in plotting coordinate space.
#'
#' @param x_offset A numeric scalar multiplier used to shift the grid horizontally
#'   away from the node vertex. Expressed relative to the tree's maximum horizontal width.
#'   Default is \code{0.02}.
#'
#' @param y_offset A numeric scalar multiplier used to shift the grid vertically
#'   away from the node vertex. Expressed relative to the tree's maximum vertical height.
#'   Default is \code{0}.
#'
#' @param map_to_color A function that accepts a numeric support value alongside a
#'   palette details object and outputs a valid character color string.
#'
#' @param pal_info A configuration object (such as a list) storing custom color keys,
#'   value breaks, or mapping criteria requested by \code{map_to_color}.
#'
#' @param n_cols An integer specifying the number of horizontal columns inside the
#'   individual rug plot grid layout. Default is \code{3}.
#'
#' @return Invoked exclusively for its side-effect of rendering geometric shapes onto
#'   the active plot window. Returns \code{NULL} invisibly.
#'
#'
#' @export
#'
#' @examples
#' \dontrun{
#'
#' set.seed(42)
#' my_tree <- ape::rtree(6)
#' ape::plot.phylo(my_tree)
#'
#' # Mock matrix for 5 internal nodes and 3 comparison trees
#' support_mat <- data.frame(
#'   node_id = 7:11,
#'   Analysis1 = c(1, 0.9, 1, 0.5, 0.8),
#'   Analysis2 = c(0.95, 0.85, 1, 0.3, 0.9),
#'   Analysis3 = c(1, 0.8, 0.9, 0.4, 1)
#' )
#'
#' # Simple dummy mapping function
#' custom_mapper <- function(val, pal) {
#'   if (val >= 0.9) {
#'     return("darkgreen")
#'   }
#'   if (val >= 0.7) {
#'     return("chartreuse3")
#'   }
#'   return("firebrick1")
#' }
#'
#' plot_node_rug(
#'   tree = my_tree, rug_mt = support_mat,
#'   cell_h = 0.2, cell_w = 0.05,
#'   x_offset = 0.03, y_offset = 0.1,
#'   map_to_color = custom_mapper, pal_info = list(),
#'   n_cols = 3
#' )
#' }
plot_node_rug <- function(tree, rug_mt,
                          cell_h, cell_w,
                          x_offset = 0.02,
                          y_offset = 0,
                          map_to_color,
                          pal_info,
                          n_cols = 3) {

  if (!inherits(tree, "phylo")) {
    stop("`tree` must be a phylogenetic tree of class \"phylo\".",
      call. = FALSE
    )
  }


  if (!is.matrix(rug_mt) && !is.data.frame(rug_mt)) {
    stop("`rug_mt` must be a matrix or data frame.", call. = FALSE)
  }

  lastPP <- get("last_plot.phylo", envir = ape::.PlotPhyloEnv)

  dx_offset <- max(lastPP$xx) * x_offset
  dy_offset <- max(lastPP$yy) * y_offset

  n_nodes <- nrow(rug_mt)
  n_cells <- ncol(rug_mt) - 1

  # Dynamically calculate the matching rows layout to fix the bug
  n_rows <- ceiling(n_cells / n_cols)
  total_w <- n_cols * cell_w
  total_h <- n_rows * cell_h

  for (i in seq_len(n_nodes)) {
    node_id <- rug_mt[i, 1]
    vals <- as.numeric(rug_mt[i, -1])

    x_center <- lastPP$xx[node_id] + dx_offset
    y_center <- lastPP$yy[node_id] + dy_offset

    x0 <- x_center - total_w / 2
    y0 <- y_center + total_h / 2

    for (k in seq_along(vals)) {
      val <- vals[k]
      row_idx <- ceiling(k / n_cols)
      col_idx <- ((k - 1) %% n_cols) + 1

      xleft <- x0 + (col_idx - 1) * cell_w
      xright <- xleft + cell_w
      ytop <- y0 - (row_idx - 1) * cell_h
      ybottom <- ytop - cell_h

      col <- map_to_color(val, pal_info)

      graphics::rect(xleft, ybottom, xright, ytop,
        col    = col,
        border = "black",
        lwd    = 0.4
      )
    }
  }
  invisible(NULL)
}

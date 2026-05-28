# Internal helper functions for phylorugD1
# Not exported -- called internally by exported functions

get_node_support <- function(tree, round = NULL) {

  # Validate tree input
  if (!inherits(tree, "phylo")) {
    stop(
      "`tree` must be a phylogenetic tree of class \"phylo\".",
      call. = FALSE
    )
  }

  # Validate round argument
  if (!is.null(round) && (!is.numeric(round) || length(round) != 1)) {
    stop(
      "`round` must be a single integer or NULL.",
      call. = FALSE
    )
  }

  # Extract node labels
  lbl <- tree$node.label

  # No labels -- return a data frame of NAs, one row per internal node
  if (is.null(lbl)) {
    return(data.frame(
      support_1 = rep(NA_real_, ape::Nnode(tree)),
      support_2 = rep(NA_real_, ape::Nnode(tree))
    ))
  }

  # Pad with NA if label vector is shorter than number of internal nodes
  # (can happen when the root label is omitted)
  if (length(lbl) < ape::Nnode(tree)) {
    lbl <- c(lbl, rep(NA_character_, ape::Nnode(tree) - length(lbl)))
  }

  # Split each label on "/" -- "95" stays as list("95"),
  # "0.98/95" becomes list("0.98", "95")
  spl <- strsplit(lbl, "/", fixed = TRUE)

  supp_mat <- t(
    vapply(
      spl,
      function(x) {
        # Remove empty strings from NA or "" labels
        x <- x[nzchar(x) & !is.na(x)]

        if (length(x) == 0) {
          c(NA_real_, NA_real_)
        } else if (length(x) == 1) {
          c(suppressWarnings(as.numeric(x[[1]])), NA_real_)
        } else {
          suppressWarnings(as.numeric(x[1:2]))
        }
      },
      numeric(2)
    )
  )

  # Build output data frame
  result <- data.frame(
    support_1 = supp_mat[, 1],
    support_2 = supp_mat[, 2]
  )

  # Round support values if requested
  if (!is.null(round)) {
    result$support_1 <- round(result$support_1, round)
    result$support_2 <- round(result$support_2, round)
  }

  result
}
# Internal helper functions for phylorugD1
# Not exported -- called internally by exported functions

get_node_support <- function(tree, round = NULL) {
  # ... existing code ...
}

# ------------------------------------------------------------------------------
# compute_adaptive_cell_size()
# Computes per-node cell height based on local tip spacing
# Called internally by plot_node_rug() when adaptive = TRUE
# ------------------------------------------------------------------------------

compute_adaptive_cell_size <- function(backbone,
                                       last_pp,
                                       fill_fraction = 0.4) {
  n_tip   <- ape::Ntip(backbone)
  n_node  <- ape::Nnode(backbone)
  tip_yy  <- last_pp$yy[seq_len(n_tip)]
  node_yy <- last_pp$yy[(n_tip + 1):(n_tip + n_node)]

  cell_sizes <- vapply(
    seq_len(n_node),
    function(i) {
      node_y        <- node_yy[i]
      above         <- tip_yy[tip_yy > node_y]
      below         <- tip_yy[tip_yy < node_y]

      if (length(above) == 0 || length(below) == 0) {
        return(NA_real_)
      }

      local_gap <- min(above) - max(below)
      local_gap * fill_fraction
    },
    numeric(1)
  )

  global_median <- stats::median(cell_sizes, na.rm = TRUE)
  cell_sizes[is.na(cell_sizes)] <- global_median
  cell_sizes
}

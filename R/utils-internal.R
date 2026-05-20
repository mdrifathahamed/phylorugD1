# Internal helper functions for phylorugD1
# These functions are not exported and are not user-facing
# They are called internally by the exported package functions

# ------------------------------------------------------------------------------
# get_node_support()
# Parses node label strings into a two-column data frame
# Called internally by node_presence_matrix()
# ------------------------------------------------------------------------------
get_node_support <- function(tree, round = NULL) {
  # ---- Input validation -------------------------------------------------------
  # Check 1: is tree actually a tree?
  if (!inherits(tree, "phylo")) {
    stop(
      "`tree` must be a phylogenetic tree of class \"phylo\".",
      call. = FALSE
    )
  }
  # Check 2: is round a valid number?
  if (!is.null(round) && (!is.numeric(round) || length(round) != 1)) {
    stop(
      "`round` must be a single integer or NULL.",
      call. = FALSE
    )
  }

  # ---- Extract labels ---------------------------------------------------------

  lbl <- tree$node.label

  # No labels at all — return a data frame of NAs, one row per internal node
  if (is.null(lbl)) {
    return(
      data.frame(
        support_1 = rep(NA_real_, ape::Nnode(tree)),
        support_2 = rep(NA_real_, ape::Nnode(tree))
      )
    )
  }

  # Pad with NA if the label vector is shorter than the number of internal nodes
  # (can happen when the root label is omitted)
  if (length(lbl) < ape::Nnode(tree)) {
    lbl <- c(lbl, rep(NA_character_, ape::Nnode(tree) - length(lbl)))
  }

  # ---- Parse labels -----------------------------------------------------------

  # Split each label on "/" — "95" stays as list("95"), "0.98/95" becomes list("0.98", "95")
  spl <- strsplit(lbl, "/", fixed = TRUE)

  # vapply is used instead of sapply for type safety — it always returns numeric(2)
  supp_mat <- t(
    vapply(
      spl, function(x) {
        # Remove empty strings that result from NA or "" labels
        x <- x[nzchar(x) & !is.na(x)]

        if (length(x) == 0) {
          return(c(NA_real_, NA_real_)) # empty or NA label
        }
        if (length(x) == 1) {
          return(c(suppressWarnings(as.numeric(x[[1]])), NA_real_))
        }
        suppressWarnings(as.numeric(x[1:2]))
      },
      numeric(2)
    )
  )

  # ---- Build output data frame ------------------------------------------------

  result <- data.frame(
    support_1 = supp_mat[, 1],
    support_2 = supp_mat[, 2]
  )

  # ---- Optional rounding ------------------------------------------------------

  if (!is.null(round)) {
    result$support_1 <- round(result$support_1, round)
    result$support_2 <- round(result$support_2, round)
  }

  result
}

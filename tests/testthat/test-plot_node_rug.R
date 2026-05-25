# Tests for plot_node_rug()

# ---- helper -----------------------------------------------------------------
make_test_tree <- function() {
  set.seed(1)
  ape::rtree(5)
}

make_test_rug_mt <- function(tree) {
  n_tip   <- ape::Ntip(tree)
  n_node  <- ape::Nnode(tree)
  node_ids <- (n_tip + 1):(n_tip + n_node)
  matrix(
    c(node_ids,
      rep(1, n_node),
      rep(0, n_node)),
    nrow  = n_node,
    ncol  = 3,
    dimnames = list(NULL, c("node_id", "TreeA", "TreeB"))
  )
}

dummy_map <- function(val, pal_info) {
  if (val == 1) "black" else "white"
}

# ---- input validation -------------------------------------------------------

test_that("stops when tree is not a phylo object", {
  expect_error(
    plot_node_rug("not_a_tree",
                  make_test_rug_mt(make_test_tree()),
                  cell_h       = 0.1,
                  cell_w       = 0.1,
                  map_to_color = dummy_map,
                  pal_info     = list()),
    "must be a phylogenetic tree"
  )
})

test_that("stops when rug_mt is not a matrix or data frame", {
  tree <- make_test_tree()
  expect_error(
    plot_node_rug(tree,
                  "not_a_matrix",
                  cell_h       = 0.1,
                  cell_w       = 0.1,
                  map_to_color = dummy_map,
                  pal_info     = list()),
    "must be a matrix or data frame"
  )
})

# ---- return value -----------------------------------------------------------

test_that("returns invisible NULL", {
  tree   <- make_test_tree()
  rug_mt <- make_test_rug_mt(tree)
  # Must plot first to populate ape::.PlotPhyloEnv with node coordinates
  ape::plot.phylo(tree)
  result <- plot_node_rug(
    tree         = tree,
    rug_mt       = rug_mt,
    cell_h       = 0.1,
    cell_w       = 0.1,
    map_to_color = dummy_map,
    pal_info     = list()
  )
  expect_null(result)
})

test_that("runs without error on valid inputs", {
  tree   <- make_test_tree()
  rug_mt <- make_test_rug_mt(tree)
  ape::plot.phylo(tree)
  expect_no_error(
    plot_node_rug(
      tree         = tree,
      rug_mt       = rug_mt,
      cell_h       = 0.1,
      cell_w       = 0.1,
      map_to_color = dummy_map,
      pal_info     = list()
    )
  )
})

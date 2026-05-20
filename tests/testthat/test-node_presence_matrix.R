# tests/testthat/test-node_presence_matrix.R
# Tests for node_presence_matrix()

# ---- helper -----------------------------------------------------------------

make_shared_tree <- function() {
  tree <- ape::read.tree(
    text = "(((A,B),C),(D,E));"
  )
  tree
}

make_tree_list <- function() {
  list(
    tree1 = ape::read.tree(text = "(((A,B),C),(D,E));"),
    tree2 = ape::read.tree(text = "((A,(B,C)),(D,E));")
  )
}

# ---- input validation -------------------------------------------------------

test_that("stops when backbone is not a phylo object", {
  expect_error(
    node_presence_matrix("not_a_tree", make_tree_list()),
    "must be a phylogenetic tree"
  )
})

test_that("stops when trees is not a list", {
  expect_error(
    node_presence_matrix(make_shared_tree(), "not_a_list"),
    "must be a named list"
  )
})

test_that("stops when support_col is not 1 or 2", {
  expect_error(
    node_presence_matrix(make_shared_tree(), make_tree_list(),
                         support_col = 3),
    "`support_col` must be 1 or 2"
  )
})

# ---- output structure -------------------------------------------------------

test_that("returns matrix with correct dimensions", {
  result <- node_presence_matrix(make_shared_tree(), make_tree_list())
  expect_true(is.matrix(result))
  expect_equal(ncol(result), 3 )   # node_id + 2 trees
  expect_equal(nrow(result), 4)   # internal nodes of a 5-tip tree
})

# ---- correct values ---------------------------------------------------------

test_that("returns 1 for matching clades and 0 for absent clades", {
  backbone  <- make_shared_tree()
  tree_list <- make_tree_list()
  result    <- node_presence_matrix(backbone, tree_list)

  # tree1 is identical to backbone — all clades should be present
  expect_true(all(result[, "tree1"] %in% c(0, 1)))

  # node_id column should contain integers
  expect_true(all(result[, "node_id"] > 0))
})

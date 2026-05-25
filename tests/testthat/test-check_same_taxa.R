# Tests for check_same_taxa()

# helpers

make_tree_list <- function(n_trees = 3, n_tips = 5) {
  tips <- paste0("Sp_", seq_len(n_tips))
  trees <- replicate(
    n_trees,
    ape::rtree(n_tips, tip.label = tips),
    simplify = FALSE
  )
  names(trees) <- paste0("tree_", seq_len(n_trees))
  trees
}

# input validation

test_that("stops when tree_list is not a list", {
  mock_tree <- list(tip.label = c("A", "B", "C"))
  class(mock_tree) <- "phylo"
  expect_error(
    check_same_taxa(mock_tree),
    "must be a list"
  )
})

test_that("stops when tree_list is empty", {
  expect_error(
    check_same_taxa(list()),
    "is empty"
  )
})

test_that("stops when tree_list contains NULL elements", {
  trees    <- make_tree_list()
  bad_list <- list(
    tree1 = trees[[1]],
    tree2 = NULL,
    tree3 = trees[[3]]
  )
  expect_error(
    check_same_taxa(bad_list),
    "NULL elements"
  )
})

# correct behaviour

test_that("returns TRUE when all trees have identical taxa", {
  trees  <- make_tree_list()
  result <- check_same_taxa(trees, verbose = FALSE)
  expect_true(result)
})

test_that("returns FALSE when trees have different taxa", {
  trees    <- make_tree_list()
  bad_tree <- trees[[1]]
  bad_tree$tip.label <- bad_tree$tip.label[-1]
  bad_list <- list(tree1 = trees[[1]], tree2 = bad_tree)
  result   <- check_same_taxa(bad_list, verbose = FALSE)
  expect_false(result)
})

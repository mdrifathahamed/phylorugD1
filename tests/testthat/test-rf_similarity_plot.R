# Tests for rf_similarity_plot()

# ---- helper -----------------------------------------------------------------

make_multi_phylo <- function(n_trees = 3, n_tips = 6, seed = 1) {
  set.seed(seed)
  tips  <- paste0("Taxon_", seq_len(n_tips))
  trees <- replicate(
    n_trees,
    ape::unroot(ape::rtree(n_tips, tip.label = tips)),
    simplify = FALSE
  )
  names(trees) <- paste0("Tree_", seq_len(n_trees))
  class(trees) <- "multiPhylo"
  trees
}

# ---- input validation -------------------------------------------------------

test_that("stops when trees is not a multiPhylo object", {
  expect_error(
    rf_similarity_plot(list()),
    "must be an object of class"
  )
})

# ---- return value -----------------------------------------------------------

test_that("returns a matrix invisibly", {
  trees  <- make_multi_phylo()
  result <- rf_similarity_plot(trees)
  expect_true(is.matrix(result))
})

test_that("returned matrix has correct dimensions", {
  trees  <- make_multi_phylo(n_trees = 3)
  result <- rf_similarity_plot(trees)
  expect_equal(nrow(result), 3)
  expect_equal(ncol(result), 2)
})

test_that("runs without error on valid multiPhylo input", {
  trees <- make_multi_phylo()
  expect_no_error(rf_similarity_plot(trees))
})

# tests/testthat/test-translate_tree_tips.R
# Tests for translate_tree_tips()

# ---- helper -----------------------------------------------------------------

make_test_tree <- function() {
  tree <- ape::rtree(3)
  tree$tip.label <- c("sp1", "sp2", "sp3")
  tree
}

make_test_dict <- function() {
  data.frame(
    from = c("sp1", "sp2"),
    to = c("Species_one", "Species_two"),
    stringsAsFactors = FALSE
  )
}

#  input validation

test_that("stops when phy is not a phylo object", {
  expect_error(
    translate_tree_tips("not_a_tree", make_test_dict()),
    "must be a phylogenetic tree"
  )
})

test_that("stops when data is not a data frame", {
  expect_error(
    translate_tree_tips(make_test_tree(), list(from = "sp1", to = "Species_one")),
    "must be a data frame"
  )
})

test_that("stops when column names not found in data", {
  expect_error(
    translate_tree_tips(make_test_tree(), make_test_dict(),
      from_col = "wrong_col"
    ),
    "not found in"
  )
})

# correct translation

test_that("translates matched tips correctly", {
  tree <- make_test_tree()
  result <- translate_tree_tips(tree, make_test_dict())

  expect_equal(result$tip.label[1], "Species_one")
  expect_equal(result$tip.label[2], "Species_two")
  expect_equal(result$tip.label[3], "sp3")
})

test_that("returns a phylo object", {
  tree <- make_test_tree()
  result <- translate_tree_tips(tree, make_test_dict())
  expect_s3_class(result, "phylo")
})

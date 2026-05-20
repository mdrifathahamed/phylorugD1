# tests/testthat/test-check_same_taxa.R
# Tests for check_same_taxa()

# not a list

test_that("stops when tree_list is not a list", {
  mock_tree <- list(tip.label = c("A", "B", "C"))
  class(mock_tree) <- "phylo"
  expect_error(
    check_same_taxa(mock_tree),
    "must be a list"
  )
})

# empty list

test_that("stops when tree_list is empty", {
  expect_error(
    check_same_taxa(list()),
    "is empty"
  )
})

# NULL element

test_that("stops when tree_list contains NULL elements", {
  folder <- "C:/Users/1/OneDrive - University of Helsinki/EEB/research Groups/Masters thesis/Data/phylo-rug-plot-main/trees_processed/316-tips"
  skip_if_not(dir.exists(folder))
  trees <- read_trees_from_dir(folder)
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

# all trees match

test_that("returns TRUE when all trees have identical taxa", {
  folder <- "C:/Users/1/OneDrive - University of Helsinki/EEB/research Groups/Masters thesis/Data/phylo-rug-plot-main/trees_processed/316-tips"
  skip_if_not(dir.exists(folder))
  trees <- read_trees_from_dir(folder)
  result <- check_same_taxa(trees, verbose = FALSE) # suppress messages in tests
  expect_true(result)
})

# trees differ

test_that("returns FALSE when trees have different taxa", {
  folder <- "C:/Users/1/OneDrive - University of Helsinki/EEB/research Groups/Masters thesis/Data/phylo-rug-plot-main/trees_processed/316-tips"
  skip_if_not(dir.exists(folder))
  trees <- read_trees_from_dir(folder)
  bad_tree <- trees[[1]]
  bad_tree$tip.label <- bad_tree$tip.label[-1]
  bad_list <- list(tree1 = trees[[1]], tree2 = bad_tree)
  result <- check_same_taxa(bad_list, verbose = FALSE)
  expect_false(result)
})

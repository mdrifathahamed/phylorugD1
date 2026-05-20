# tests/testthat/test-read_trees_from_dir.R
# Tests for read_trees_from_dir()


test_that("stops when directory does not exist", {
  expect_error(
    read_trees_from_dir("path/that/does/not/exist"),
    "does not exist"
  )
})


test_that("stops when no .tre files found in directory", {
  tmp <- tempdir()    # which R function creates a temporary folder?
  expect_error(
    read_trees_from_dir(tmp, ext = "tre"),
    "No .tre files found"
  )
})

test_that("stops when format is not newick or nexus", {
  expect_error(
    read_trees_from_dir(tempdir(), format = "format is not newick or nexus"),
    "should be one of"
  )
})

test_that("returns a named list of phylo objects", {
  folder <- "C:/Users/1/OneDrive - University of Helsinki/EEB/research Groups/Masters thesis/Data/phylo-rug-plot-main/trees_processed/316-tips"

    # skip if folder not found
  skip_if_not(dir.exists(folder))

  trees <- read_trees_from_dir(folder)

  expect_type(trees, "list")                              # what type is a list?
  expect_true(all(sapply(trees, inherits, "phylo")))       # what class is each tree?
  expect_equal(length(trees), 10)                           # how many trees in the folder?
  expect_equal(names(trees), basename(list.files(folder,   # what should the names be?
                                                      pattern = "\\.tre$")))
})

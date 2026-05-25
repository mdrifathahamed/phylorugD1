# Tests for read_trees_from_dir()

# ---- helper -----------------------------------------------------------------

make_temp_trees <- function(n = 2, n_tips = 5) {
  tmp   <- tempdir()
  tips  <- paste0("Sp_", seq_len(n_tips))
  files <- character(n)
  for (i in seq_len(n)) {
    path <- file.path(tmp, paste0("tree_", i, ".tre"))
    ape::write.tree(
      ape::rtree(n_tips, tip.label = tips),
      path
    )
    files[i] <- path
  }
  list(dir = tmp, files = files)
}

# ---- input validation -------------------------------------------------------

test_that("stops when directory does not exist", {
  expect_error(
    read_trees_from_dir("path/that/does/not/exist"),
    "does not exist"
  )
})

test_that("stops when no matching files found in directory", {
  tmp <- tempdir()
  expect_error(
    read_trees_from_dir(tmp, ext = "xyz"),
    "No .xyz files found"
  )
})

test_that("stops when format is not newick or nexus", {
  expect_error(
    read_trees_from_dir(tempdir(), format = "invalid_format"),
    "should be one of"
  )
})

# ---- output structure -------------------------------------------------------

test_that("returns a named list of phylo objects", {
  setup  <- make_temp_trees(n = 2)
  result <- read_trees_from_dir(setup$dir, ext = "tre")

  expect_type(result, "list")
  expect_true(all(sapply(result, inherits, "phylo")))
  expect_equal(length(result), 2)
  expect_equal(
    names(result),
    basename(list.files(setup$dir, pattern = "\\.tre$"))
  )

  file.remove(setup$files)
})

# ---- error handling ---------------------------------------------------------

test_that("warns when a file cannot be read", {
  tmp <- tempdir()

  # Create one valid tree file and one corrupt file
  writeLines("(A,B);", file.path(tmp, "good.tre"))
  writeLines("THIS IS NOT A TREE", file.path(tmp, "bad.tre"))

  expect_warning(
    result <- read_trees_from_dir(tmp, ext = "tre"),
    "file\\(s\\) could not be read"
  )

  # Result still has both elements -- bad one is NULL
  expect_equal(length(result), 2)
  expect_null(result$bad.tre)
  expect_s3_class(result$good.tre, "phylo")

  file.remove(file.path(tmp, "good.tre"))
  file.remove(file.path(tmp, "bad.tre"))
})

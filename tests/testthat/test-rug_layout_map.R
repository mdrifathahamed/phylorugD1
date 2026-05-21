# tests/testthat/test-rug_layout_map.R
# Tests for rug_layout_map()

# ---- helper -----------------------------------------------------------------

make_test_matrix <- function() {
  m <- matrix(
    c(290, 1, 0, 1,
      291, 1, 1, 1),
    nrow = 2, byrow = TRUE
  )
  colnames(m) <- c("node_id", "TreeA", "TreeB", "TreeC")
  m
}

# ---- input validation -------------------------------------------------------

test_that("stops when rug_mt is not a matrix or data frame", {
  # testing non-matrix inputs behaves implicitly via dimension or subsetting errors
  expect_error(
    rug_layout_map("not_a_matrix"),
    "must be a matrix or data frame"
  )
})

test_that("stops when rug_mt has fewer than two columns", {
  # safe checking structure when names cannot be extracted via colnames()[-1]
  expect_error(
    rug_layout_map(matrix(1:2, nrow = 2)),
    "at least two columns"
  )
})

test_that("stops when more trees than grid cells", {
  expect_error(
    rug_layout_map(make_test_matrix(), n_rows = 1, n_cols = 1),
    "More trees than available cells in the rug grid."
  )
})

# ---- output structure -------------------------------------------------------

test_that("returns a data frame", {
  result <- rug_layout_map(make_test_matrix())
  expect_s3_class(result, "data.frame")
})

test_that("returns correct number of rows", {
  result <- rug_layout_map(make_test_matrix())
  expect_equal(nrow(result), 6)   # 2 nodes × 3 trees = 6 rows
})

test_that("returns correct column names", {
  result <- rug_layout_map(make_test_matrix())
  expect_named(result, c("node_id", "tree_name", "row", "col", "cell_index"))
})

# ---- correct grid positions -------------------------------------------------

test_that("assigns correct row and col positions", {
  result <- rug_layout_map(make_test_matrix(), n_rows = 2, n_cols = 2)

  # TreeA is k=1 — should be row 1, col 1
  expect_equal(result$row[result$tree_name == "TreeA"][1], 1)
  expect_equal(result$col[result$tree_name == "TreeA"][1], 1)

  # TreeB is k=2 — should be row 1, col 2
  expect_equal(result$row[result$tree_name == "TreeB"][1], 1)
  expect_equal(result$col[result$tree_name == "TreeB"][1], 2)
})

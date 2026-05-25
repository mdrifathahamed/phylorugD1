# Map phylogenetic trees to grid cell coordinates for rug plots

Transforms a wide node-support matrix into a long-format data frame
containing the specific row, column, and sequential index positions for
each comparison tree within a compact color-coded rug plot grid. This
function is essential for mapping multiple tree analyses to individual
sub-cells at each backbone node.

## Usage

``` r
rug_layout_map(rug_mt, n_rows = 2, n_cols = 3)
```

## Arguments

- rug_mt:

  A matrix or data frame where the first column contains the reference
  `node_id` values (numeric or character), and the subsequent columns
  contain the names or labels of the phylogenetic comparison trees.

- n_rows:

  An integer specifying the maximum number of grid rows to arrange the
  tree cells vertically. Default is `2`.

- n_cols:

  An integer specifying the maximum number of grid columns to arrange
  the tree cells horizontally. Default is `3`.

## Value

A long-format data frame with one row per node per analysis and five
columns:

- `node_id`:

  Internal node identifier from the backbone tree.

- `tree_name`:

  Name of the comparison tree.

- `row`:

  Row position in the rug grid (1 = top).

- `col`:

  Column position in the rug grid (1 = left).

- `cell_index`:

  Sequential index of the analysis.

## Examples

``` r
if (FALSE) { # \dontrun{
# Example support matrix for 3 nodes across 5 alternative analyses

mock_matrix <- matrix(
  c(
    10, 1, 0.95, 0.80, 1, 0,
    11, 0, 1.00, 1.00, 0, 1,
    12, 1, 0.50, 0.00, 1, 1
  ),
  nrow = 3, byrow = TRUE
)
colnames(mock_matrix) <- c(
  "node_id", "TreeA", "TreeB", "TreeC", "TreeD", "TreeE"
)

# Map the positions onto a 2x3 grid layout
grid_layout <- rug_layout_map(mock_matrix, n_rows = 2, n_cols = 3)
head(grid_layout)
} # }
```

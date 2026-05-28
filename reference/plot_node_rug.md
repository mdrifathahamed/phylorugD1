# Plot Node Rug Grids Over a Phylogenetic Canvas

Superimposes compact color-coded grid sub-cells ("rug plots") onto the
internal branching nodes of a previously plotted phylogenetic tree. This
provides a clear, multi-analysis visual representation of statistical
node support values.

## Usage

``` r
plot_node_rug(
  tree,
  rug_mt,
  cell_h,
  cell_w,
  x_offset = -0.0095,
  y_offset = 0.0023,
  map_to_color,
  pal_info,
  n_cols = 2,
  adaptive = TRUE,
  fill_fraction = 0.4
)
```

## Arguments

- tree:

  An object of class `"phylo"` representing the reference topology
  rendered on the active graphics device.

- rug_mt:

  A matrix or data frame where the first column corresponds to the
  backbone `node_id` sequence, and subsequent columns contain numeric
  support values for each comparison tree.

- cell_h:

  A numeric value specifying the geometric height of each individual
  grid sub-cell in plotting coordinate space.

- cell_w:

  A numeric value specifying the geometric width of each individual grid
  sub-cell in plotting coordinate space.

- x_offset:

  A numeric scalar multiplier used to shift the grid horizontally away
  from the node vertex. Expressed relative to the tree's maximum
  horizontal width. Default is `0.02`.

- y_offset:

  A numeric scalar multiplier used to shift the grid vertically away
  from the node vertex. Expressed relative to the tree's maximum
  vertical height. Default is `0`.

- map_to_color:

  A function that accepts a numeric support value alongside a palette
  details object and outputs a valid character color string.

- pal_info:

  A configuration object (such as a list) storing custom color keys,
  value breaks, or mapping criteria requested by `map_to_color`.

- n_cols:

  An integer specifying the number of horizontal columns inside the
  individual rug plot grid layout. Default is `3`.

## Value

Invoked exclusively for its side-effect of rendering geometric shapes
onto the active plot window. Returns `NULL` invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{

set.seed(42)
my_tree <- ape::rtree(6)
ape::plot.phylo(my_tree)

# Mock matrix for 5 internal nodes and 3 comparison trees
support_mat <- data.frame(
  node_id = 7:11,
  Analysis1 = c(1, 0.9, 1, 0.5, 0.8),
  Analysis2 = c(0.95, 0.85, 1, 0.3, 0.9),
  Analysis3 = c(1, 0.8, 0.9, 0.4, 1)
)

# Simple dummy mapping function
custom_mapper <- function(val, pal) {
  if (val >= 0.9) {
    return("darkgreen")
  }
  if (val >= 0.7) {
    return("chartreuse3")
  }
  return("firebrick1")
}

plot_node_rug(
  tree = my_tree, rug_mt = support_mat,
  cell_h = 0.2, cell_w = 0.05,
  x_offset = 0.03, y_offset = 0.1,
  map_to_color = custom_mapper, pal_info = list(),
  n_cols = 3
)
} # }
```

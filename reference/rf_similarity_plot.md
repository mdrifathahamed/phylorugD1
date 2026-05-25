# Map and Plot Multidimensional Tree Similarity from Robinson-Foulds Distances

Calculates the symmetric topological Robinson-Foulds (RF) distance
between pairs of input trees, projects their structural proximity
patterns onto a lower-dimensional continuous plane using Classical
Multidimensional Scaling (MDS), and renders a labeled ordination scatter
plot on the current graphics device.

## Usage

``` r
rf_similarity_plot(trees, method = "PH85", k = 2)
```

## Arguments

- trees:

  An object of class `"multiPhylo"` containing a list of independent
  phylogenetic trees sharing an identical terminal leaf-set.

- method:

  Character string. The distance method passed to
  [`ape::dist.topo()`](https://rdrr.io/pkg/ape/man/dist.topo.html). Use
  `"PH85"` for the Robinson-Foulds symmetric difference (default).

- k:

  Integer. Number of dimensions for the MDS projection. Default is `2`
  for a standard 2D scatter plot.

## Value

The MDS coordinate matrix invisibly. A scatter plot is drawn on the
current graphics device as a side effect.

## Examples

``` r
if (FALSE) { # \dontrun{

# Generate a list of 5 mock random trees with identical tip labels
set.seed(42)
mock_trees <- replicate(5, ape::rtree(10, tip.label = paste0("Taxon_", 1:10)),
  simplify = FALSE
)
class(mock_trees) <- "multiPhylo"
names(mock_trees) <- paste0("Analysis_", 1:5)

# Create the plots/ directory if missing and run the visualization pipeline
rf_similarity_plot(mock_trees)
} # }
```

# Construct Node Presence and Support Value Matrix Across Multiple Phylogenies

Evaluates a collection of alternative phylogenetic trees against a
designated reference backbone topology. For each internal node in the
backbone tree, the function determines whether a matching monophyletic
clade exists in each comparison tree, populating a coordinate data
framework matrix with binary occupancy flags or quantitative branch
support scores.

## Usage

``` r
node_presence_matrix(
  backbone,
  trees,
  use_support = FALSE,
  support_col = 1,
  round_support = NULL
)
```

## Arguments

- backbone:

  A phylogenetic tree object of class `"phylo"`. This tree serves as the
  structural reference template, where each of its internal nodes
  establishes a mapping row coordinate in the final output matrix.

- trees:

  A named list of alternative phylogenetic tree objects of class
  `"phylo"`, or an object of class `"multiPhylo"`. Each tree in this
  list corresponds to a single independent data partition, inference
  method, or bootstrap replicate, defining a unique data mapping column
  in the output matrix.

- use_support:

  Logical. If `FALSE` (default), the function operates in binary
  presence/absence mode, returning a `1` if a backbone clade is
  congruent with a comparison tree and `0` otherwise. If `TRUE`, the
  function operates in quantitative mode, returning the literal branch
  support score extracted from matching clades, or `0` if the clade is
  completely absent or structurally discordant.

- support_col:

  Integer. Specifies which target column data to extract from the
  internal node indexing tables (typically column `1` or `2`, mapping
  onto distinct bootstrap or posterior probability metrics). Assessed
  only when `use_support = TRUE`. Defaults to `1`.

- round_support:

  Integer or `NULL`. If an integer is supplied, numerical support values
  are rounded to the specified number of decimal places before matrix
  insertion. Defaults to `NULL`.

## Value

A numeric matrix where:

- **Rows:** Represent the internal nodes of the `backbone` tree, with
  the absolute backbone node index stored in the first column labeled
  `"node_id"`.

- **Columns:** Represent each target tree supplied inside `tree_list`.
  Column names are automatically mapped onto the names of the list
  elements, or padded sequentially to `"tree_1"`, `"tree_2"` if names
  are absent.

- **Cells:** Contain numeric scalar values indicating binary clade
  presence (`0` or `1`) or quantitative statistical confidence values
  (e.g., bootstrap percentages or Bayesian posterior values) depending
  on `use_support`.

## Examples

``` r
if (FALSE) { # \dontrun{

# Generate a shared backbone tree and several alternative trees
shared_backbone <- ape::rtree(5, tip.label = c("A", "B", "C", "D", "E"))
alternative_trees <- list(
  UCE_partition = ape::rtree(5, tip.label = c("A", "B", "C", "D", "E")),
  Mito_partition = ape::rtree(5, tip.label = c("A", "B", "C", "D", "E"))
)

# 1. Calculate binary presence/absence matrix
topo_matrix <- node_presence_matrix(
  backbone    = shared_backbone,
  trees   = alternative_trees,
  use_support = FALSE
)

# 2. Calculate continuous support value intensity matrix
support_matrix <- node_presence_matrix(
  backbone    = shared_backbone,
  trees   = alternative_trees,
  use_support = TRUE,
  support_col = 1
)
} # }
```

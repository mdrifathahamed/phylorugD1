# Check Taxa Consistency Across Multiple Phylogenetic Trees

Compares a list of phylogenetic trees against a reference tree (the
first tree in the list) to ensure that all trees contain the exact same
set of taxa (tip labels). If discrepancies are found, detailed
diagnostic reports listing missing and extra taxa are provided.

## Usage

``` r
check_same_taxa(tree_list, verbose = TRUE)
```

## Arguments

- tree_list:

  A list of phylogenetic tree objects of class `"phylo"`, or a
  multiPhylo object containing the trees to be compared.

- verbose:

  Logical. If `TRUE` (default), detailed status messages and diagnostic
  reports for mismatched trees are printed to the console using
  [`message`](https://rdrr.io/r/base/message.html).

## Value

A single logical value. `TRUE` if all trees contain identical taxa.
`FALSE` if any tree differs, in which case the pipeline should not
proceed.

## Examples

``` r
if (FALSE) { # \dontrun{
# Assuming 'my_trees' is a named list of phylo objects loaded into R:
trees <- read_trees_from_dir("path/to/your/trees")
result <- check_same_taxa(trees)

# Check if it's safe to proceed:
if (result) {
  message("Safe to proceed.")
}
} # }
```

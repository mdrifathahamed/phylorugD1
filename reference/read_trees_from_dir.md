# Reads Multiple Phylogenetic Trees from a Directory

Searches a specified directory for phylogenetic tree files with a
matching file extension and imports them into R as a list of tree
objects. It supports both Newick and NEXUS formats by wrapping the
corresponding ape package functions. The resulting list elements are
automatically named using the base names of their respective files for
easy tracking.

## Usage

``` r
read_trees_from_dir(dir, ext = "tre", format = c("newick", "nexus"))
```

## Arguments

- dir:

  Character string. The path to the directory containing the tree files.

- ext:

  Character string. The file extension to search for (without the
  leading dot). Defaults to `"tre"`.

- format:

  Character string. The file format of the trees, either `"newick"` or
  `"nexus"`. Defaults to `"newick"`.

## Value

A named list of objects of class `"phylo"`. Each element is one tree.
List names are the filenames the trees were read from.

## Examples

``` r
if (FALSE) { # \dontrun{
trees <- read_trees_from_dir(
  dir    = "path/to/your/trees",
  ext    = "tre",
  format = "newick"
)
} # }
```

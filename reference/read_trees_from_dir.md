# Read multiple phylogenetic trees from a directory

Searches a specified directory for phylogenetic tree files with a
matching file extension and imports them into R as a named list of tree
objects. Supports both Newick and NEXUS formats.

## Usage

``` r
read_trees_from_dir(dir, ext = "tre", format = c("newick", "nexus"))
```

## Arguments

- dir:

  Character string. Path to the directory containing the tree files.

- ext:

  Character string. File extension to search for, without the leading
  dot. Defaults to `"tre"`.

- format:

  Character string. File format of the trees, either`"newick"` or
  `"nexus"`. Defaults to `"newick"`.

## Value

A named list of objects of class `"phylo"`. List names are the filenames
the trees were read from. Elements for files that could not be read are
set to `NULL`.

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

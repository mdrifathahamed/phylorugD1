# Translate Tip Labels of a Phylogenetic Tree

Renames the terminal tip labels of a phylogenetic tree using a lookup
table supplied as a data frame. Only tips matching entries in `from_col`
are renamed — unmatched tips are left unchanged. Both `from_col` and
`to_col` must be character columns not factors, and a summary message
reports how many tips were translated.

## Usage

``` r
translate_tree_tips(phy, data, from_col = "from", to_col = "to")
```

## Arguments

- phy:

  A phylogenetic tree object of class `"phylo"`.

- data:

  A data frame containing the label translation lookup table. Can be a
  standard `data.frame` or a `tibble`.

- from_col:

  A character string specifying the column name in `data` that holds the
  current tip labels of the tree. Defaults to `"from"`.

- to_col:

  A character string specifying the column name in `data` that holds the
  new desired replacement labels. Defaults to `"to"`.

## Value

An updated phylogenetic tree object of class `"phylo"` with matching tip
labels translated. The tree topology and edge lengths remain unchanged.

## Examples

``` r
if (FALSE) { # \dontrun{

# Mock a small tree
tree <- ape::rtree(3, tip.label = c("t1", "t2", "t3"))

# Translation map
dict <- data.frame(
  from = c("t1", "t2"),
  to   = c("Homo_sapiens", "Mus_musculus")
)

# Translate tips
clean_tree <- translate_tree_tips(tree, dict, from_col = "from", to_col = "to")
} # }
```

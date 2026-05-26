# Getting started with phylorugD1

## The biological problem

Phylogenomic studies routinely produce multiple trees from different
methods and datasets. When researchers analyse the same set of taxa
using IQ-TREE, GHOST, and ASTRAL – or using different data types such as
Ultraconserved Elements (UCEs) and partitioned sequence data – they
often obtain slightly different topologies or different levels of node
support. This disagreement between analyses is called **incongruence**
(Steenwyk et al. 2023).

The problem is not that incongruence exists. The problem is
communicating it honestly. Current practice is to publish one tree –
usually the maximum likelihood tree – and move everything else to
supplementary materials. A reader looking at the published figure cannot
tell which nodes are robust across all five analyses and which nodes are
contested. This is a transparency problem.

## The rug plot method

The rug plot method addresses this by drawing a compact colour-coded
grid at each internal node of a backbone tree. Each cell in the grid
represents one alternative analysis, shaded from white (clade absent) to
black (clade present). Nodes supported unanimously by all analyses are
shown as a solid black dot – maximally clean. Nodes where analyses
disagree show a mixed grid that a reader can interpret at a glance.

The method was first introduced by Wheeler (1995) under the name *space
plots*, later called *Navajo rugs* (Giribet 2003) and *topological
congruence plots* (Wheeler & Hayashi 1998). Despite thirty years of use
in the literature, no automated R tool existed to produce these
visualizations. **phylorugD1** is the first implementation.

## Who should use this package

Any researcher who:

- runs more than one phylogenomic analysis on the same dataset
- uses IQ-TREE, ASTRAL, GHOST, RAxML, MrBayes, or BEAST
- wants to show node support from multiple analyses in a single figure
- works in R and needs a reproducible, scriptable workflow

The package is organism-agnostic. It was developed and demonstrated on
dung beetles but works on any phylogenomic dataset.

------------------------------------------------------------------------

## Installation

``` r

pak::pak("mdrifathahamed/phylorugD1")
```

------------------------------------------------------------------------

## The demonstration dataset

This vignette uses a phylogenomic dataset of 289 dung beetle taxa
(*Coleoptera: Scarabaeinae* and *Aphodiinae*) assembled by the Tarasov
Lab at the Finnish Museum of Natural History (LUOMUS), University of
Helsinki. Five analyses were performed:

| Analysis            | Method             | Data type   |
|---------------------|--------------------|-------------|
| IQ-TREE UCE         | Maximum likelihood | UCE         |
| IQ-TREE partitioned | Maximum likelihood | Partitioned |
| GHOST partitioned   | Heterotachous ML   | Partitioned |
| ASTRAL UCE          | Coalescent         | UCE         |
| ASTRAL partitioned  | Coalescent         | Partitioned |

The IQ-TREE UCE tree is used as the backbone – the most data-rich, most
methodologically standard analysis. The other four are comparison trees.

------------------------------------------------------------------------

## Step-by-step pipeline

### Step 1 – Read raw trees

[`read_trees_from_dir()`](https://mdrifathahamed.github.io/phylorugD1/reference/read_trees_from_dir.md)
reads all tree files from a folder into a named list of `phylo` objects.
It supports Newick and NEXUS formats.

``` r

library(phylorugD1)
library(readxl)
library(phytools)

raw_trees <- read_trees_from_dir(
  dir    = "data/raw_trees/70p",
  ext    = "tre",
  format = "newick"
)

names(raw_trees)
# [1] "70p_ASTRAL_partition_entropy.tre" "70p_ASTRAL_uce.tre"
# [3] "70p_ghost.tre"                    "70p_partition_entropy.tre"
# [5] "70p_uce.tre"
```

### Step 2 – Root before translating

The outgroup must be rooted using raw specimen codes before translation.
After translation the raw codes no longer exist and
[`root()`](https://rdrr.io/pkg/ape/man/root.html) cannot find them.

``` r

rooted_trees <- lapply(raw_trees, function(tr) {
  root(
    tr,
    outgroup     = c("NicorbUCE", "NicvesUCE"),
    resolve.root = TRUE
  )
})
```

### Step 3 – Translate tip labels

[`translate_tree_tips()`](https://mdrifathahamed.github.io/phylorugD1/reference/translate_tree_tips.md)
renames tip labels from museum specimen codes to full species names
using a lookup table stored in `biogeo.xlsx`. The lookup table has two
columns: `from` (original code) and `to` (species name).

``` r

biogeo <- read_excel("data/biogeo.xlsx", sheet = "BioGeo")

translated_trees <- lapply(rooted_trees, function(tr) {
  translate_tree_tips(
    phy      = tr,
    data     = biogeo,
    from_col = "from",
    to_col   = "to"
  )
})

head(translated_trees[[1]]$tip.label)
# [1] "Amphistomus_primonactus_Amppri_UCE"
# [2] "Coptodactyla_brooksi_CopbroUCE"
```

### Step 4 – Extract the ingroup

The outgroup is removed using `phytools::findMRCA()` to locate the most
recent common ancestor of the ingroup, then
[`extract.clade()`](https://rdrr.io/pkg/ape/man/drop.tip.html) to keep
only the ingroup taxa. This reduces the dataset from 316 to 289 taxa.

``` r

processed_trees <- lapply(translated_trees, function(tr) {
  tr   <- ladderize(tr)
  node <- phytools::findMRCA(
    tr,
    c("Heteronitis_ragazzii_STL10032",
      "Aphodius_immundus_ST003")
  )
  extract.clade(tr, node)
})
names(processed_trees) <- names(raw_trees)

Ntip(processed_trees[[1]])
# [1] 289
```

### Step 5 – Validate taxa

[`check_same_taxa()`](https://mdrifathahamed.github.io/phylorugD1/reference/check_same_taxa.md)
confirms that all five trees share exactly the same 289 taxa before any
downstream analysis. This must return `TRUE` before continuing.

``` r

check_same_taxa(processed_trees)
# All trees contain the same set of taxa.
# [1] TRUE
```

### Step 6 – Define backbone and comparison trees

``` r

backbone  <- processed_trees$`70p_uce.tre`

tree_list <- processed_trees[c(
  "70p_partition_entropy.tre",
  "70p_ghost.tre",
  "70p_ASTRAL_uce.tre",
  "70p_ASTRAL_partition_entropy.tre"
)]
```

### Step 7 – Build the node presence matrix

[`node_presence_matrix()`](https://mdrifathahamed.github.io/phylorugD1/reference/node_presence_matrix.md)
is the core function. For each of the 288 internal nodes in the backbone
tree, it searches each comparison tree for the same clade and records
whether it is present.

With `use_support = FALSE`, it returns a binary matrix where `1` means
the clade exists in that analysis and `0` means it does not.

``` r

rug_mt <- node_presence_matrix(
  backbone    = backbone,
  trees       = tree_list,
  use_support = FALSE
)

dim(rug_mt)
# [1] 288   5

head(rug_mt)
#      node_id  70p_partition  70p_ghost  70p_ASTRAL_uce  70p_ASTRAL_part
# [1,]     290            1          1               1               1
# [2,]     291            1          1               1               1
# [3,]     292            1          0               1               1
```

Node 292 shows a real biological result. The clade exists in IQ-TREE
partitioned and both ASTRAL analyses but not in GHOST. This is
topological incongruence – a genuine disagreement between methods.

### Step 8 – Build the grid layout

[`rug_layout_map()`](https://mdrifathahamed.github.io/phylorugD1/reference/rug_layout_map.md)
assigns each analysis to a fixed position in the 2x2 grid. The layout is
the same at every node across the entire tree, so a reader can learn it
once and interpret the whole figure.

``` r

layout_df <- rug_layout_map(rug_mt, n_rows = 2, n_cols = 2)

nrow(layout_df)
# [1] 1152  (288 nodes x 4 analyses)
```

The grid positions are:

    IQ-TREE partitioned | GHOST partitioned
    ASTRAL UCE          | ASTRAL partitioned

### Step 9 – RF similarity plot

[`rf_similarity_plot()`](https://mdrifathahamed.github.io/phylorugD1/reference/rf_similarity_plot.md)
computes the Robinson-Foulds distance between every pair of trees and
projects the result into 2D using Multidimensional Scaling (MDS). Trees
close together have similar topologies. Trees far apart disagree
substantially.

``` r

all_trees        <- processed_trees
names(all_trees) <- c(
  "ASTRAL_part",
  "ASTRAL_uce",
  "GHOST",
  "IQTREE_part",
  "IQTREE_uce"
)
class(all_trees) <- "multiPhylo"

rf_mt <- as.matrix(dist.topo(all_trees, method = "PH85"))
print(rf_mt)

rf_similarity_plot(all_trees)
```

### Step 10 – Draw the rug plot

[`plot_node_rug()`](https://mdrifathahamed.github.io/phylorugD1/reference/plot_node_rug.md)
must be called after
[`plot.phylo()`](https://rdrr.io/pkg/ape/man/plot.phylo.html). It reads
node coordinates from the active plot environment and draws a 2x2 rug
grid at each uncertain node. Nodes where all four analyses agree are
shown as a solid black dot.

The key parameter is `n_cols = 2` which produces a clean 2x2 grid
exactly matching the four comparison analyses.

``` r

# Colour palette: white = absent, black = present
pal_info        <- list()
pal_info$pal    <- gray.colors(64, start = 0.95, end = 0.00)
pal_info$breaks <- seq(0, 1, length.out = 64)

map_to_color <- function(val, pal_info) {
  if (val == 0) {
    "white"
  } else {
    pal_info$pal[cut(
      val,
      breaks         = pal_info$breaks,
      include.lowest = TRUE
    )]
  }
}

# Split nodes into unanimous and variable
rug_mt_unanimous <- rug_mt[
  apply(rug_mt[, -1, drop = FALSE], 1, function(x) all(x == 1)),
  , drop = FALSE
]

rug_mt_variable <- rug_mt[
  !apply(rug_mt[, -1, drop = FALSE], 1, function(x) all(x == 1)),
  , drop = FALSE
]

# Save to PDF
pdf("output/rug_plot_70p.pdf", width = 8.27 * 2, height = 11.69 * 5)

# 1. Plot backbone tree
plot.phylo(
  backbone,
  show.tip.label = TRUE,
  cex            = 0.8,
  label.offset   = 0.001,
  no.margin      = TRUE,
  edge.width     = 2
)

# 2. Solid dots at unanimous nodes
last_pp  <- get("last_plot.phylo", envir = ape::.PlotPhyloEnv)
node_ids <- rug_mt_unanimous[, 1]

points(
  last_pp$xx[node_ids],
  last_pp$yy[node_ids],
  pch = 16,
  cex = 1.2,
  col = "black"
)

# 3. Compute cell dimensions
pin        <- par("pin")
dy         <- median(diff(sort(last_pp$yy[1:Ntip(backbone)])))
x_per_inch <- diff(last_pp$x.lim) / pin[1]
y_per_inch <- diff(last_pp$y.lim) / pin[2]
cell_h     <- dy * 0.5
cell_w     <- cell_h * (x_per_inch / y_per_inch)

# 4. Draw rug grid -- n_cols = 2 for clean 2x2 layout
plot_node_rug(
  tree         = backbone,
  rug_mt       = rug_mt_variable,
  cell_h       = cell_h,
  cell_w       = cell_w,
  x_offset     = -0.0095,
  y_offset     = 0.0023,
  map_to_color = map_to_color,
  pal_info     = pal_info,
  n_cols       = 2
)

dev.off()
```

------------------------------------------------------------------------

## Reading the output

**Solid black dot** – all four comparison analyses support this node.
The node is robust across all methods.

**2x2 coloured grid** – at least one analysis differs. Read the grid:

    IQ-TREE partitioned | GHOST partitioned
    ASTRAL UCE          | ASTRAL partitioned

- **Black cell** – clade present in this analysis
- **White cell** – clade absent from this analysis entirely

A node where IQ-TREE cells are black but ASTRAL cells are white means
the maximum likelihood and coalescent methods disagree. This may
indicate incomplete lineage sorting or rapid diversification at that
node.

------------------------------------------------------------------------

## Tuning the figure

Four parameters control the visual appearance:

``` r

cell_h   <- dy * 0.5    # increase for bigger cells, decrease for smaller
x_offset <- -0.0095     # more negative = further left into branch
y_offset <- 0.0023      # increase to shift grids up
n_cols   <- 2           # always 2 for 4 analyses (2x2 grid)
```

For large trees (200+ taxa) save to PDF with `width = 8.27 * 2` and
`height = 11.69 * 5` to give each node enough space.

------------------------------------------------------------------------

## References

Giribet, G. (2003). Stability in phylogenetic formulations and its
relationship to nodal support. *Systematic Biology*, 52(4), 554–564.

Steenwyk, J. L., Li, Y., Zhou, X., Shen, X. X., & Rokas, A. (2023).
Incongruence in the phylogenomics era. *Nature Reviews Genetics*,
24(12), 834–850.

Wheeler, W. C. (1995). Sequence alignment, parameter sensitivity, and
the phylogenetic analysis of molecular data. *Systematic Biology*,
44(3), 321–331.

Wheeler, W. C., & Hayashi, C. Y. (1998). The phylogeny of the extant
chelicerate orders. *Cladistics*, 14, 173–192.

## Acknowledgements

Prototype R script by Dr. Sergei Tarasov, Tarasov Lab, LUOMUS,
University of Helsinki. MSc project supervised by Dr. Sergei Tarasov and
co-supervised by Salvador Arias Becerra, University of Helsinki.


<!-- README.md is generated from README.Rmd. Please edit that file -->

# phylorugD1

<!-- badges: start -->

<!-- badges: end -->

Phylogenomic studies routinely produce multiple trees from different
methods and datasets — yet no dedicated R tool existed to visualize node
support across all of them simultaneously on a single reference
topology. **phylorugD1** fills this gap by implementing the rug plot
method: a compact colour-coded grid drawn at each internal node of a
backbone tree, where each cell represents one analysis shaded from white
(absent or no support) to black (full support). Any researcher working
with IQ-TREE, GHOST, ASTRAL, MrBayes, or any combination of phylogenomic
methods can use phylorugD1 to communicate their results more honestly
and completely.

## Installation

``` r
# install.packages("pak")
pak::pak("mdrifathahamed/phylorugD1")
```

## The Seven Functions

| Function | What it does |
|----|----|
| `read_trees_from_dir()` | Reads all tree files from a directory into a named list of phylo objects |
| `check_same_taxa()` | Checks whether all trees share the same set of taxa — returns a green signal if they match |
| `translate_tree_tips()` | Translates tip labels from museum specimen codes to full species names using a lookup table |
| `node_presence_matrix()` | For each node in the backbone tree, records whether that clade is present in each comparison tree, returning a 0/1 or support-value matrix |
| `rug_layout_map()` | Transforms the node support matrix into a long-format data frame mapping each analysis to a specific row and column position in the rug grid |
| `plot_node_rug()` | Superimposes compact colour-coded grid cells onto the internal nodes of a plotted phylogenetic tree |
| `rf_similarity_plot()` | Computes Robinson-Foulds distances between all trees and renders a 2D MDS scatter plot showing pairwise topological similarity |

## Basic Usage

``` r
library(phylorugD1)
library(readxl)
library(phytools)

# Step 1 — Read raw trees
raw_trees <- read_trees_from_dir("data/raw_trees/70p", ext = "tre")

# Step 2 — Root before translating (use raw tip labels for outgroup)
rooted_trees <- lapply(raw_trees, function(tr) {
  root(tr, outgroup = c("NicorbUCE", "NicvesUCE"), resolve.root = TRUE)
})

# Step 3 — Translate specimen codes to species names
biogeo <- read_excel("data/biogeo.xlsx", sheet = "BioGeo")
translated_trees <- lapply(rooted_trees, function(tr) {
  translate_tree_tips(tr, data = biogeo, from_col = "from", to_col = "to")
})

# Step 4 — Extract ingroup
processed_trees <- lapply(translated_trees, function(tr) {
  tr   <- ladderize(tr)
  node <- phytools::findMRCA(
    tr,
    c("Heteronitis_ragazzii_STL10032", "Aphodius_immundus_ST003")
  )
  extract.clade(tr, node)
})
names(processed_trees) <- names(raw_trees)

# Step 5 — Validate taxa
check_same_taxa(processed_trees)

# Step 6 — Define backbone and comparison trees
backbone  <- processed_trees$`70p_uce.tre`
tree_list <- processed_trees[c(
  "70p_partition_entropy.tre",
  "70p_ghost.tre",
  "70p_ASTRAL_uce.tre",
  "70p_ASTRAL_partition_entropy.tre"
)]

# Step 7 — Build node support matrix
rug_mt <- node_presence_matrix(
  backbone    = backbone,
  trees       = tree_list,
  use_support = FALSE
)

# Step 8 — Build grid layout
layout_df <- rug_layout_map(rug_mt, n_rows = 2, n_cols = 2)

# Step 9 — RF similarity plot
all_trees        <- processed_trees
class(all_trees) <- "multiPhylo"
rf_similarity_plot(all_trees)

# Step 10 — Draw the rug plot
pal_info        <- list()
pal_info$pal    <- gray.colors(64, start = 0.95, end = 0.00)
pal_info$breaks <- seq(0, 1, length.out = 64)

map_to_color <- function(val, pal_info) {
  if (val == 0) return("white")
  pal_info$pal[cut(val, breaks = pal_info$breaks, include.lowest = TRUE)]
}

rug_mt_variable <- rug_mt[
  !apply(rug_mt[, -1, drop = FALSE], 1, function(x) all(x == 1)),
  , drop = FALSE
]

plot.phylo(backbone, show.tip.label = TRUE, cex = 0.4,
           label.offset = 0.001, no.margin = TRUE, edge.width = 1.5)

last_pp    <- get("last_plot.phylo", envir = ape::.PlotPhyloEnv)
dy         <- median(diff(sort(last_pp$yy[1:Ntip(backbone)])))
x_per_inch <- diff(last_pp$x.lim) / par("pin")[1]
y_per_inch <- diff(last_pp$y.lim) / par("pin")[2]
cell_h     <- dy * 0.18
cell_w     <- cell_h * (x_per_inch / y_per_inch)

plot_node_rug(
  tree         = backbone,
  rug_mt       = rug_mt_variable,
  cell_h       = cell_h,
  cell_w       = cell_w,
  x_offset     = 0.04,
  y_offset     = 0,
  map_to_color = map_to_color,
  pal_info     = pal_info
)
```

## Study System

The package is demonstrated on a phylogenomic dataset of 289 dung beetle
taxa (*Coleoptera: Scarabaeinae* and *Aphodiinae*) analysed across five
methods — IQ-TREE partitioned, IQ-TREE UCE, GHOST partitioned, ASTRAL
UCE, and ASTRAL partitioned — assembled by the Tarasov Lab at the
Finnish Museum of Natural History (LUOMUS), University of Helsinki.

## Citation

Ahamed, M. R. & Tarasov, S. (2026). *phylorugD1: Visualize Node Support
Across Multiple Phylogenomic Analyses on a Single Reference Tree*. R
package version 0.1.0. <https://github.com/mdrifathahamed/phylorugD1>

## Acknowledgements

Prototype R script by Dr. Sergei Tarasov, Tarasov Lab, LUOMUS,
University of Helsinki. MSc project supervised by Dr. Sergei Tarasov.

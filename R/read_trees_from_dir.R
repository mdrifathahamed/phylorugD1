#' Reads Multiple Phylogenetic Trees from a Directory
#'
#' Searches a specified directory for phylogenetic tree files with a matching
#' file extension and imports them into R as a list of tree objects.
#' It supports both Newick and NEXUS formats by wrapping the corresponding ape package functions.
#' The resulting list elements are automatically named using the base names of their respective
#' files for easy tracking.
#'
#' @param dir Character string. The path to the directory containing the tree files.
#'
#' @param ext Character string. The file extension to search for (without the
#' leading dot). Defaults to \code{"tre"}.
#'
#' @param format Character string. The file format of the trees, either \code{"newick"}
#' or \code{"nexus"}. Defaults to \code{"newick"}.
#'
#' @return A named list of objects of class \code{"phylo"}. Each element
#'   is one tree. List names are the filenames the trees were read from.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   trees <- read_trees_from_dir(
#'     dir    = "path/to/your/trees",
#'     ext    = "tre",
#'     format = "newick"
#'   )
#' }

read_trees_from_dir <- function(dir,
                                ext = "tre",
                                format = c("newick", "nexus")) {
  format <- match.arg(format)

  # Validate directory
  if (!dir.exists(dir)) {
    stop("`dir` does not exist: ", dir, call. = FALSE)
  }

  # List matching files
  files <- list.files(
    dir,
    pattern    = paste0("\\.", ext, "$"),
    full.names = TRUE
  )

  if (length(files) == 0) {
    stop(
      "No .", ext, " files found in: ", dir,
      call. = FALSE
    )
  }

  # Select reader function
  reader <- switch(format,
    newick = ape::read.tree,
    nexus  = ape::read.nexus
  )

  # Read each file, warn and return NULL if a file fails
  trees <- lapply(files, function(f) {
    tryCatch(
      reader(f),
      error = function(e) {
        warning(
          "Could not read file: ", basename(f),
          "\nReason: ", e$message,
          call. = FALSE
        )
        NULL
      }
    )
  })

  # Name list elements and return
  names(trees) <- basename(files)
  trees
}

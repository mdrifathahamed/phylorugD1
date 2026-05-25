#' Read multiple phylogenetic trees from a directory
#'
#' Searches a specified directory for phylogenetic tree files with a matching
#' file extension and imports them into R as a named list of tree objects.
#' Supports both Newick and NEXUS formats.
#'
#' @param dir Character string. Path to the directory containing the tree files.
#'
#' @param ext Character string. File extension to search for, without the
#'  leading dot. Defaults to `"tre"`.
#'
#' @param format Character string. File format of the trees, either`"newick"` or
#'  `"nexus"`. Defaults to `"newick"`.
#'
#' @return A named list of objects of class `"phylo"`. List names are the
#'  filenames the trees were read from. Elements for files that could not be
#'  read are set to `NULL`.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' trees <- read_trees_from_dir(
#'   dir    = "path/to/your/trees",
#'   ext    = "tre",
#'   format = "newick"
#' )
#' }
read_trees_from_dir <- function(dir,
                                ext    = "tre",
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
    stop("No .", ext, " files found in: ", dir, call. = FALSE)
  }

  # Select reader function based on format
  reader <- switch(
    format,
    newick = ape::read.tree,
    nexus  = ape::read.nexus
  )

  # Read each file; warn and return NULL if a file fails
  trees <- lapply(files, function(f) {
    tryCatch(
      suppressWarnings(reader(f)),
      error = function(e) {
        message("Could not read: ", basename(f), " - ", e$message)
        NULL
      }
    )
  })

  # Name list elements by filename
  names(trees) <- basename(files)

  # Report how many files failed to read
  failed <- sum(vapply(trees, is.null, logical(1)))
  if (failed > 0) {
    warning(
      failed, " file(s) could not be read and were set to NULL. ",
      "Run check_same_taxa() before proceeding.",
      call. = FALSE
    )
  }

  trees
}

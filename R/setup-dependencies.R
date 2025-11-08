#' Ensure All Project Dependencies Are Installed
#'
#' @description
#' Checks for and installs all required R packages for the bilingual
#' pathology atlas build system. This eliminates the need for duplicate
#' package installation checks across multiple scripts.
#'
#' @param update_packages Logical: update existing packages (default: FALSE)
#' @param quiet Logical: suppress installation messages (default: TRUE)
#'
#' @return Invisibly returns named list of installed package versions
#' @export
#'
#' @examples
#' # Install missing dependencies
#' ensure_dependencies()
#'
#' # Update all dependencies
#' ensure_dependencies(update_packages = TRUE)
#'
#' # Install with verbose output
#' ensure_dependencies(quiet = FALSE)
ensure_dependencies <- function(update_packages = FALSE, quiet = TRUE) {

  # Core dependencies
  required_packages <- c(
    "xfun",       # Utility functions for Quarto
    "quarto",     # Quarto rendering
    "fs",         # File system operations
    "readxl",     # Excel file reading (mapping file)
    "tinytex"     # LaTeX for PDF output
  )

  # Content processing dependencies
  content_packages <- c(
    "dplyr",      # Data manipulation
    "stringr",    # String operations
    "purrr",      # Functional programming
    "magrittr"    # Pipe operators
  )

  # Output generation dependencies
  output_packages <- c(
    "yaml",       # YAML file generation
    "jsonlite",   # JSON file generation
    "xml2",       # XML/RSS feed generation
    "lubridate",  # Date handling
    "glue"        # String interpolation
  )

  all_packages <- c(required_packages, content_packages, output_packages)

  # Install missing packages
  for (pkg in all_packages) {
    if (!requireNamespace(pkg, quietly = TRUE) || update_packages) {
      if (!quiet) {
        message(sprintf("Installing %s...", pkg))
      }
      install.packages(pkg, dependencies = TRUE, quiet = quiet, verbose = !quiet)
    }
  }

  # Ensure TinyTeX is installed (for PDF generation)
  if (!tinytex::is_tinytex()) {
    if (!quiet) {
      message("Installing TinyTeX...")
    }
    tinytex::install_tinytex()
    Sys.sleep(2)  # Wait for installation to complete

    if (!tinytex::is_tinytex()) {
      stop("Failed to install TinyTeX - PDF rendering will not work")
    }
  }

  # Return installed versions
  versions <- sapply(all_packages, function(pkg) {
    as.character(packageVersion(pkg))
  }, USE.NAMES = TRUE)

  if (!quiet) {
    message(sprintf("✓ All %d dependencies installed", length(all_packages)))
  }

  invisible(versions)
}
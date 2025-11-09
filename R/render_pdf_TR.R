#' Render Turkish PDF Version
#'
#' @description
#' Simple wrapper script to render the Turkish (TR) version of the pathology
#' atlas in PDF format. Called by monthly release GitHub Actions workflow.
#'
#' @details
#' Uses the render_format() utility function from R/utils.R to:
#'   - Generate format-specific chapter list from base chapters
#'   - Render with _quarto_TR_pdf.yml configuration
#'   - Output to _pdf_TR/ directory
#'
#' @seealso
#' - R/utils.R: render_format() function
#' - _quarto_TR_pdf.yml: PDF-specific configuration
#' - .github/workflows/monthly-release.yml: CI/CD usage
#'
#' @examples
#' \dontrun{
#'   # Render Turkish PDF
#'   source("./R/render_pdf_TR.R")
#' }

# Load utilities
source("./R/config.R")
source("./R/utils.R")

# Render Turkish PDF version
render_format(
  language = "TR",
  format = "pdf",
  config_file = "./_quarto_TR_pdf.yml",
  excel_column_suffix = "pdf"
)

# Clean environment
rm(list=ls())

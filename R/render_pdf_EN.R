#' Render English PDF Version
#'
#' @description
#' Simple wrapper script to render the English (EN) version of the pathology
#' atlas in PDF format. Called by monthly release GitHub Actions workflow.
#'
#' @details
#' Uses the render_format() utility function from R/utils.R to:
#'   - Generate format-specific chapter list from base chapters
#'   - Render with _quarto_EN_pdf.yml configuration
#'   - Output to _pdf_EN/ directory
#'
#' @seealso
#' - R/utils.R: render_format() function
#' - _quarto_EN_pdf.yml: PDF-specific configuration
#' - .github/workflows/monthly-release.yml: CI/CD usage
#'
#' @examples
#' \dontrun{
#'   # Render English PDF
#'   source("./R/render_pdf_EN.R")
#' }

# Load utilities
source("./R/config.R")
source("./R/utils.R")

# Render English PDF version
render_format(
  language = "EN",
  format = "pdf",
  config_file = "./_quarto_EN_pdf.yml",
  excel_column_suffix = "pdf"
)

# Clean environment
rm(list=ls())

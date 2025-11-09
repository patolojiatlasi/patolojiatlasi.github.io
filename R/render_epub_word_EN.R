#' Render English EPUB and Word Versions
#'
#' @description
#' Simple wrapper script to render the English (EN) version of the pathology
#' atlas in EPUB and Word (DOCX) formats. Called by monthly release GitHub
#' Actions workflow.
#'
#' @details
#' Uses the render_format() utility function from R/utils.R to:
#'   - Generate format-specific chapter list from base chapters
#'   - Render with _quarto_EN_epub_word.yml configuration
#'   - Output to _epub_word_EN/ directory
#'   - Produces both .epub and .docx files
#'
#' @seealso
#' - R/utils.R: render_format() function
#' - _quarto_EN_epub_word.yml: EPUB/Word-specific configuration
#' - .github/workflows/monthly-release.yml: CI/CD usage
#'
#' @examples
#' \dontrun{
#'   # Render English EPUB and Word formats
#'   source("./R/render_epub_word_EN.R")
#' }

# Load utilities
source("./R/config.R")
source("./R/utils.R")

# Render English EPUB and Word versions
render_format(
  language = "EN",
  format = "epub_word",
  config_file = "./_quarto_EN_epub_word.yml",
  excel_column_suffix = "epub_word"
)

# Clean environment
rm(list=ls())

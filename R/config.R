#' Project Configuration
#' Centralized configuration for bilingual book build
#'
#' @description
#' This file provides centralized configuration for the pathology atlas
#' bilingual book build system. All paths, directories, and project settings
#' are defined here to avoid hardcoded values scattered across scripts.
#'
#' @return Named list with project configuration
#' @export
get_project_config <- function() {
  list(
    languages = c("TR", "EN"),

    quarto = list(
      TR = list(
        config = "./_quarto_TR.yml",
        output_dir = "_docs",
        deploy_dir = "docs",          # Final deployment directory
        freeze_dir = "./_freeze_TR"
      ),
      EN = list(
        config = "./_quarto_EN.yml",
        output_dir = "_EN",
        deploy_dir = "EN",             # Final deployment directory
        freeze_dir = "./_freeze_EN"
      )
    ),

    r_scripts = list(
      TR = "./R/languageTR.R",
      EN = "./R/languageEN.R"
    ),

    mapping_file = "./config/chapter-mapping.xlsx",

    cleanup_patterns = c(
      "_files$", "_pdf_", "_epub_", "_freeze$"
    ),

    repos = list(
      EN_mirror = "patolojiatlasi/EN",
      histopathology = "histopathologyatlas/histopathologyatlas.github.io",
      gitlab = "sbalci/atlas"
    )
  )
}

#' Get Language-Specific Configuration
#'
#' @description
#' Returns configuration settings for a specific language (TR or EN).
#' This includes paths to Quarto config files, output directories,
#' freeze directories, and language-specific R scripts.
#'
#' @param language Character: "TR" or "EN"
#'
#' @return Named list with language-specific configuration
#' @export
#'
#' @examples
#' config <- get_language_config("EN")
#' config$quarto_file  # "./_quarto_EN.yml"
get_language_config <- function(language) {
  config <- get_project_config()

  if (!language %in% config$languages) {
    stop(sprintf("Unknown language: %s. Available: %s",
                 language, paste(config$languages, collapse=", ")))
  }

  list(
    language = language,
    quarto_file = config$quarto[[language]]$config,
    output_dir = config$quarto[[language]]$output_dir,
    deploy_dir = config$quarto[[language]]$deploy_dir,
    freeze_dir = config$quarto[[language]]$freeze_dir,
    language_file = config$r_scripts[[language]]
  )
}

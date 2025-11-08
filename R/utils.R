#' Utility Functions for Bilingual Book Build
#'
#' @description
#' This file provides reusable utility functions for the pathology atlas
#' bilingual book build system. These functions eliminate code duplication
#' across build scripts.

# Ensure config.R is loaded
if (!exists("get_language_config")) {
  source("./R/config.R")
}

#' Read Chapter Mappings
#'
#' @description
#' Reads chapter mappings from YAML configuration file. This replaces the
#' Excel-based mapping system with a git-friendly, text-based alternative.
#'
#' @param mapping_file Path to YAML mapping file. Defaults to "chapter-mappings.yml"
#'
#' @return Data frame with columns: TR_chapter_qmd, EN_chapter_qmd, TR_pdf_chapter_qmd,
#'   EN_pdf_chapter_qmd, TR_epub_word_chapter_qmd, EN_epub_word_chapter_qmd
#' @export
#'
#' @examples
#' mappings <- read_chapter_mappings()
#' head(mappings)
read_chapter_mappings <- function(mapping_file = "chapter-mappings.yml") {

  # Check if YAML file exists
  if (!file.exists(mapping_file)) {
    stop("Chapter mappings file not found: ", mapping_file)
  }

  # Read YAML
  yaml_data <- yaml::read_yaml(mapping_file)

  # Convert to data frame
  chapters_df <- do.call(rbind, lapply(yaml_data$chapters, function(ch) {
    data.frame(
      TR_chapter_qmd = ch$tr,
      EN_chapter_qmd = ch$en,
      TR_pdf_chapter_qmd = ch$tr_pdf,
      EN_pdf_chapter_qmd = ch$en_pdf,
      TR_epub_word_chapter_qmd = ch$tr_epub_word,
      EN_epub_word_chapter_qmd = ch$en_epub_word,
      stringsAsFactors = FALSE
    )
  }))

  rownames(chapters_df) <- NULL
  return(chapters_df)
}

#' Setup Language-Specific Build Environment
#'
#' @description
#' Prepares the build environment for rendering a specific language version.
#' This function:
#' 1. Copies the language-specific Quarto config to ./_quarto.yml
#' 2. Copies the language-specific R script to ./R/language.R
#' 3. Optionally restores the freeze directory from a backup
#'
#' @param language Character: "TR" or "EN"
#' @param source_freeze_dir Optional path to freeze directory to restore.
#'   If NULL, no freeze directory is restored.
#'
#' @return Invisibly returns TRUE on success
#' @export
#'
#' @examples
#' # Setup for Turkish build
#' setup_language_build("TR")
#'
#' # Setup for English build with freeze directory
#' setup_language_build("EN", source_freeze_dir = "./_freeze_EN")
setup_language_build <- function(language, source_freeze_dir = NULL) {
  config <- get_language_config(language)

  # Copy language configuration
  fs::file_copy(
    path = config$quarto_file,
    new_path = "./_quarto.yml",
    overwrite = TRUE
  )

  # Copy language script
  fs::file_copy(
    path = config$language_file,
    new_path = "./R/language.R",
    overwrite = TRUE
  )

  # Handle freeze directory
  if (!is.null(source_freeze_dir) && dir.exists(source_freeze_dir)) {
    # Clean existing freeze directory first
    if (dir.exists("./_freeze")) {
      fs::dir_delete(path = "./_freeze")
    }

    # Copy freeze directory
    fs::dir_copy(
      path = source_freeze_dir,
      new_path = "./_freeze",
      overwrite = TRUE
    )
  }

  invisible(TRUE)
}

#' Clean Up Build Artifacts
#'
#' @description
#' Deletes build artifacts and temporary directories. If no paths are
#' specified, deletes common build artifacts based on default patterns.
#'
#' @param paths Character vector of specific paths to delete. If NULL,
#'   uses default cleanup paths and patterns.
#'
#' @return Invisibly returns TRUE on success
#' @export
#'
#' @examples
#' # Clean up specific directories
#' cleanup_build_artifacts(c("./docs", "./public"))
#'
#' # Clean up all default artifacts
#' cleanup_build_artifacts()
cleanup_build_artifacts <- function(paths = NULL) {
  if (is.null(paths)) {
    # Default cleanup paths
    paths <- c(
      "./_freeze",
      "./_EN",
      "./_docs",
      "./public",
      "./gitlab_atlas/gitlab_atlas"
    )

    # Add glob patterns for generated directories
    if (dir.exists(".")) {
      patterns <- c("_files$", "_pdf_", "_epub_")
      for (pattern in patterns) {
        matched <- fs::dir_ls(".", recurse = FALSE, regexp = pattern, type = "directory")
        if (length(matched) > 0) {
          paths <- c(paths, matched)
        }
      }
    }
  }

  # Delete each path if it exists
  for (path in paths) {
    if (dir.exists(path)) {
      fs::dir_delete(path)
    }
  }

  invisible(TRUE)
}

#' Save Freeze Directory
#'
#' @description
#' Backs up the freeze directory to a language-specific location.
#' This preserves computed results between builds.
#'
#' @param language Character: "TR" or "EN"
#'
#' @return Invisibly returns TRUE on success
#' @export
#'
#' @examples
#' # After rendering, save freeze directory
#' save_freeze_directory("TR")
save_freeze_directory <- function(language) {
  config <- get_language_config(language)

  if (dir.exists("./_freeze")) {
    fs::dir_copy(
      path = "./_freeze",
      new_path = config$freeze_dir,
      overwrite = TRUE
    )
  }

  invisible(TRUE)
}

#' Render Specific Output Format
#'
#' @description
#' Generic function to render PDF or EPUB/Word formats for either language.
#' Handles the complete workflow:
#' 1. Setup config and language files
#' 2. Restore freeze directory
#' 3. Copy and transform chapter files
#' 4. Apply format-specific text replacements
#' 5. Render
#' 6. Save freeze directory
#' 7. Clean up temporary files
#'
#' @param language Character: "TR" or "EN"
#' @param format Character: "pdf" or "epub_word"
#' @param config_file Path to Quarto config file (e.g., "_quarto_TR_pdf.yml")
#' @param excel_column_suffix Column suffix in Excel mapping (e.g., "pdf", "epub_word")
#'
#' @return Invisibly returns TRUE on success
#' @export
#'
#' @examples
#' # Render Turkish PDF
#' render_format(language = "TR", format = "pdf",
#'               config_file = "_quarto_TR_pdf.yml",
#'               excel_column_suffix = "pdf")
#'
#' # Render English EPUB/Word
#' render_format(language = "EN", format = "epub_word",
#'               config_file = "_quarto_EN_epub_word.yml",
#'               excel_column_suffix = "epub_word")
render_format <- function(language, format, config_file, excel_column_suffix) {

  # Validate inputs
  if (!language %in% c("TR", "EN")) {
    stop("language must be 'TR' or 'EN'")
  }
  if (!format %in% c("pdf", "epub_word")) {
    stop("format must be 'pdf' or 'epub_word'")
  }

  # Setup language file
  language_file <- ifelse(language == "TR", "./R/languageTR.R", "./R/languageEN.R")
  fs::file_copy(language_file, "./R/language.R", overwrite = TRUE)

  # Setup config file
  fs::file_copy(config_file, "./_quarto.yml", overwrite = TRUE)

  # Handle freeze directory
  freeze_dir_name <- paste0("./_freeze_", language, "_", format)
  if (dir.exists("./_freeze")) fs::dir_delete("./_freeze")
  if (dir.exists(freeze_dir_name)) {
    fs::dir_copy(freeze_dir_name, "./_freeze", overwrite = TRUE)
  }

  # Read chapter mappings from YAML (replaces Excel dependency)
  patolojiatlasi_histopathologyatlas <- read_chapter_mappings()

  # Determine column names based on language and format
  tr_col <- "TR_chapter_qmd"
  target_col <- paste0(language, "_", excel_column_suffix, "_chapter_qmd")

  patolojiatlasi_histopathologyatlas <-
    patolojiatlasi_histopathologyatlas[, c(tr_col, target_col)]

  TR_chapter_qmd <- paste0("./", patolojiatlasi_histopathologyatlas[[tr_col]], ".qmd")
  target_chapter_qmd <- paste0("./", patolojiatlasi_histopathologyatlas[[target_col]], ".qmd")

  # Handle subchapter files
  subchapter_files <- list.files("_subchapters", pattern = "*.qmd", recursive = FALSE)
  subchapter_files <- paste0("./_subchapters/", subchapter_files)

  # Generate target subchapter names
  suffix <- paste0("_", format, "_", language, ".qmd")
  subchapter_files_target <- gsub(".qmd", suffix, subchapter_files)

  # Combine main chapters and subchapters
  TR_chapter_qmd <- c(TR_chapter_qmd, subchapter_files)
  all_target_qmd <- c(target_chapter_qmd, subchapter_files_target)

  # Copy files
  fs::file_copy(TR_chapter_qmd, all_target_qmd, overwrite = TRUE)

  # Apply text replacements for PDF/EPUB format
  # Remove panel-tabset (doesn't work in PDF/EPUB)
  xfun::gsub_files(all_target_qmd, pattern = "panel-tabset", replacement = "")
  xfun::gsub_files(all_target_qmd, pattern = ":::::", replacement = "")

  # Remove WSI sections (not useful in PDF/EPUB)
  xfun::gsub_files(all_target_qmd, pattern = "#+\\s*WSI - Link", replacement = "")
  xfun::gsub_files(all_target_qmd, pattern = "#+\\s*WSI", replacement = "")

  # Handle Diagnosis sections
  xfun::gsub_files(all_target_qmd, pattern = "#+\\s*Diagnosis", replacement = "")
  xfun::gsub_files(all_target_qmd, pattern = "#+\\s*Click for Diagnosis", replacement = "### Diagnosis")

  # Remove QR codes
  xfun::gsub_files(all_target_qmd,
    pattern = '\\!\\[\\]\\(\\.\\/qrcodes\\/\\{\\{template\\}\\}-\\{\\{stain\\}\\}_qrcode.svg\\)\\{width="15%"\\}',
    replacement = "")

  # Update cross-references to point to format-specific files
  xfun::gsub_files(all_target_qmd,
    pattern = ".qmd >}}",
    replacement = paste0(suffix, " >}}"))

  # Render
  quarto::quarto_render(".", as_job = FALSE)

  # Save freeze directory
  if (dir.exists("./_freeze")) {
    fs::dir_copy("./_freeze", freeze_dir_name, overwrite = TRUE)
  }

  # Clean up freeze directory
  if (dir.exists("./_freeze")) fs::dir_delete("./_freeze")

  # Delete temporary chapter files (keep originals)
  temp_files <- all_target_qmd[!(all_target_qmd %in% TR_chapter_qmd)]
  fs::file_delete(temp_files)

  invisible(TRUE)
}

#' Check and Fix Corrupted EN References
#'
#' @description
#' Detects and fixes corrupted _EN_EN_EN... references in QMD files that
#' can occur if a build fails before the reversion step completes.
#'
#' This happens with the 16 shared files that use the same name for both
#' TR and EN versions (e.g., benign.qmd, bs.qmd, crohn.qmd, etc.)
#'
#' @param quiet Logical: suppress informational messages (default: FALSE)
#'
#' @return Invisibly returns the number of corrupted references fixed
#' @export
#'
#' @examples
#' # Check and fix at start of build
#' fix_corrupted_en_references()
#'
#' # Silent mode
#' fix_corrupted_en_references(quiet = TRUE)
fix_corrupted_en_references <- function(quiet = FALSE) {

  # Get all QMD files in root directory
  qmd_files <- list.files(".", pattern = "\\.qmd$", full.names = TRUE, recursive = FALSE)

  # Count corrupted references
  corrupted_count <- 0
  for (file in qmd_files) {
    content <- readLines(file, warn = FALSE)
    corrupted_count <- corrupted_count + sum(grepl("_EN_EN", content))
  }

  if (corrupted_count == 0) {
    if (!quiet) {
      message("✓ No corrupted _EN references found")
    }
    return(invisible(0))
  }

  # Fix corrupted references
  if (!quiet) {
    message(sprintf("⚠ Found %d corrupted _EN_EN references", corrupted_count))
    message("🔧 Auto-fixing...")
  }

  # Multiple passes to handle _EN_EN_EN_EN -> _EN_EN_EN -> _EN_EN -> _EN
  for (pass in 1:5) {
    xfun::gsub_files(
      files = qmd_files,
      pattern = "_EN_EN",
      replacement = "_EN"
    )
  }

  # Verify fix
  final_count <- 0
  for (file in qmd_files) {
    content <- readLines(file, warn = FALSE)
    final_count <- final_count + sum(grepl("_EN_EN", content))
  }

  if (final_count > 0) {
    warning(sprintf("Still found %d corrupted references after cleanup", final_count))
  } else if (!quiet) {
    message(sprintf("✓ Fixed %d corrupted references", corrupted_count))
  }

  invisible(corrupted_count)
}
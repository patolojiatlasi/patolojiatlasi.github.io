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
  chapter_mappings <- read_chapter_mappings()

  # Determine column names based on language and format
  tr_col <- "TR_chapter_qmd"
  target_col <- paste0(language, "_", excel_column_suffix, "_chapter_qmd")

  chapter_mappings <-
    chapter_mappings[, c(tr_col, target_col)]

  tr_chapter_qmd <- paste0("./", chapter_mappings[[tr_col]], ".qmd")
  target_chapter_qmd <- paste0("./", chapter_mappings[[target_col]], ".qmd")

  # Handle subchapter files
  subchapter_files <- list.files("_subchapters", pattern = "*.qmd", recursive = FALSE)
  subchapter_files <- paste0("./_subchapters/", subchapter_files)

  # Generate target subchapter names
  suffix <- paste0("_", format, "_", language, ".qmd")
  subchapter_files_target <- gsub(".qmd", suffix, subchapter_files)

  # Combine main chapters and subchapters
  tr_chapter_qmd <- c(tr_chapter_qmd, subchapter_files)
  all_target_qmd <- c(target_chapter_qmd, subchapter_files_target)

  # Copy files
  fs::file_copy(tr_chapter_qmd, all_target_qmd, overwrite = TRUE)

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
  temp_files <- all_target_qmd[!(all_target_qmd %in% tr_chapter_qmd)]

  # Filter out NA values and non-existent files
  temp_files <- temp_files[!is.na(temp_files)]
  temp_files <- temp_files[!grepl("/NA\\.qmd$", temp_files)]
  temp_files <- temp_files[file.exists(temp_files)]

  if (length(temp_files) > 0) {
    fs::file_delete(temp_files)
  }

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


# ==============================================================================
# ERROR HANDLING AND LOGGING FUNCTIONS
# ==============================================================================

#' Log Error Message
#'
#' @description
#' Logs an error message with timestamp to stderr. Use this for critical
#' failures that should stop execution.
#'
#' @param message Error message to log
#' @param context Optional context string (e.g., function name)
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   log_error("File not found", context = "validate_build_output")
#' }
log_error <- function(message, context = NULL) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  context_str <- if (!is.null(context)) sprintf("[%s] ", context) else ""
  cat(sprintf("[ERROR %s] %s%s\n", timestamp, context_str, message), file = stderr())
}


#' Log Warning Message
#'
#' @description
#' Logs a warning message with timestamp to stderr. Use this for issues
#' that don't stop execution but should be noted.
#'
#' @param message Warning message to log
#' @param context Optional context string (e.g., function name)
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   log_warning("Cache directory not found, skipping optimization", context = "cleanup")
#' }
log_warning <- function(message, context = NULL) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  context_str <- if (!is.null(context)) sprintf("[%s] ", context) else ""
  cat(sprintf("[WARN %s] %s%s\n", timestamp, context_str, message), file = stderr())
}


#' Log Info Message
#'
#' @description
#' Logs an informational message with timestamp. Use this for progress
#' updates and non-critical information.
#'
#' @param message Info message to log
#' @param context Optional context string (e.g., function name)
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   log_info("Starting Turkish build", context = "render_TR")
#' }
log_info <- function(message, context = NULL) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  context_str <- if (!is.null(context)) sprintf("[%s] ", context) else ""
  message(sprintf("[INFO %s] %s%s", timestamp, context_str, message))
}


#' Safe File Copy with Validation
#'
#' @description
#' Copies files with comprehensive error handling and validation.
#' Automatically creates destination directories if needed.
#'
#' @param from Source file path(s)
#' @param to Destination file path(s)
#' @param overwrite Logical: overwrite existing files (default: TRUE)
#' @param verbose Logical: print progress messages (default: TRUE)
#'
#' @return Invisibly returns TRUE on success
#' @export
#'
#' @examples
#' \dontrun{
#'   safe_file_copy("config.yml", "backup/config.yml")
#'   safe_file_copy(c("file1.txt", "file2.txt"), c("dest1.txt", "dest2.txt"))
#' }
safe_file_copy <- function(from, to, overwrite = TRUE, verbose = TRUE) {

  tryCatch({

    # Validate inputs
    if (length(from) != length(to)) {
      stop(sprintf("Length mismatch: from (%d files) vs to (%d files)",
                   length(from), length(to)))
    }

    # Process each file
    for (i in seq_along(from)) {
      src <- from[i]
      dst <- to[i]

      # Check source exists
      if (!file.exists(src)) {
        stop(sprintf("Source file not found: %s", src))
      }

      # Create destination directory if needed
      dest_dir <- dirname(dst)
      if (!dir.exists(dest_dir)) {
        if (verbose) {
          log_info(sprintf("Creating directory: %s", dest_dir), context = "safe_file_copy")
        }
        dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
      }

      # Perform copy
      if (verbose && length(from) <= 10) {  # Don't spam for bulk operations
        log_info(sprintf("Copying: %s → %s", basename(src), basename(dst)),
                context = "safe_file_copy")
      }

      fs::file_copy(src, dst, overwrite = overwrite)

      # Validate copy succeeded
      if (!file.exists(dst)) {
        stop(sprintf("Copy failed - destination not created: %s", dst))
      }
    }

    if (verbose && length(from) > 1) {
      log_info(sprintf("✓ Copied %d file(s) successfully", length(from)),
              context = "safe_file_copy")
    }

    invisible(TRUE)

  }, error = function(e) {
    log_error(sprintf("File copy failed: %s", e$message), context = "safe_file_copy")
    stop(e)
  })
}


#' Safe Directory Delete with Validation
#'
#' @description
#' Deletes directories with error handling. Silently succeeds if directory
#' doesn't exist.
#'
#' @param paths Character vector of directory paths to delete
#' @param verbose Logical: print progress messages (default: TRUE)
#'
#' @return Invisibly returns number of directories deleted
#' @export
#'
#' @examples
#' \dontrun{
#'   safe_dir_delete(c("./_freeze", "./_docs"))
#' }
safe_dir_delete <- function(paths, verbose = TRUE) {

  deleted_count <- 0

  for (path in paths) {
    tryCatch({

      if (dir.exists(path)) {
        if (verbose) {
          file_count <- length(list.files(path, recursive = TRUE, all.files = TRUE))
          log_info(sprintf("Deleting: %s (%d files)", path, file_count),
                  context = "safe_dir_delete")
        }

        fs::dir_delete(path)
        deleted_count <- deleted_count + 1
      }

    }, error = function(e) {
      log_warning(sprintf("Failed to delete %s: %s", path, e$message),
                 context = "safe_dir_delete")
      # Don't stop - continue with other directories
    })
  }

  if (verbose && deleted_count > 0) {
    log_info(sprintf("✓ Deleted %d director%s",
                    deleted_count,
                    if (deleted_count == 1) "y" else "ies"),
            context = "safe_dir_delete")
  }

  invisible(deleted_count)
}


#' Safe Directory Copy with Validation
#'
#' @description
#' Copies directories with error handling and validation.
#'
#' @param from Source directory path
#' @param to Destination directory path
#' @param overwrite Logical: overwrite existing directory (default: TRUE)
#' @param verbose Logical: print progress messages (default: TRUE)
#'
#' @return Invisibly returns TRUE on success
#' @export
#'
#' @examples
#' \dontrun{
#'   safe_dir_copy("./_freeze", "./_freeze_backup")
#' }
safe_dir_copy <- function(from, to, overwrite = TRUE, verbose = TRUE) {

  tryCatch({

    # Validate source exists
    if (!dir.exists(from)) {
      stop(sprintf("Source directory not found: %s", from))
    }

    # Count files for progress message
    if (verbose) {
      file_count <- length(list.files(from, recursive = TRUE, all.files = TRUE))
      log_info(sprintf("Copying directory: %s → %s (%d files)",
                      from, to, file_count),
              context = "safe_dir_copy")
    }

    # Perform copy
    fs::dir_copy(from, to, overwrite = overwrite)

    # Validate copy succeeded
    if (!dir.exists(to)) {
      stop(sprintf("Copy failed - destination not created: %s", to))
    }

    if (verbose) {
      log_info(sprintf("✓ Directory copied successfully"),
              context = "safe_dir_copy")
    }

    invisible(TRUE)

  }, error = function(e) {
    log_error(sprintf("Directory copy failed: %s", e$message),
             context = "safe_dir_copy")
    stop(e)
  })
}


#' Safe Quarto Render with Retry Logic
#'
#' @description
#' Renders Quarto project with error handling and optional retry logic.
#' Captures both success and failure cases with detailed error messages.
#'
#' @param input Quarto file or project directory (default: ".")
#' @param as_job Logical: run as background job (default: FALSE)
#' @param max_retries Integer: maximum retry attempts on failure (default: 1)
#' @param retry_delay Integer: seconds to wait between retries (default: 5)
#' @param verbose Logical: print progress messages (default: TRUE)
#'
#' @return Invisibly returns TRUE on success
#' @export
#'
#' @examples
#' \dontrun{
#'   safe_quarto_render(".", max_retries = 2)
#' }
safe_quarto_render <- function(input = ".",
                                as_job = FALSE,
                                max_retries = 1,
                                retry_delay = 5,
                                verbose = TRUE) {

  attempt <- 1

  while (attempt <= max_retries) {

    if (verbose) {
      if (attempt > 1) {
        log_info(sprintf("Retry attempt %d/%d after %d second delay",
                        attempt, max_retries, retry_delay),
                context = "safe_quarto_render")
        Sys.sleep(retry_delay)
      } else {
        log_info(sprintf("Starting Quarto render: %s", input),
                context = "safe_quarto_render")
      }
    }

    result <- tryCatch({

      # Perform render
      quarto::quarto_render(input, as_job = as_job)

      # Success
      if (verbose) {
        log_info("✓ Quarto render completed successfully",
                context = "safe_quarto_render")
      }

      return(invisible(TRUE))

    }, error = function(e) {

      log_error(sprintf("Quarto render failed (attempt %d/%d): %s",
                       attempt, max_retries, e$message),
               context = "safe_quarto_render")

      # Return error for retry logic
      return(e)
    })

    # If successful, return
    if (isTRUE(result)) {
      return(invisible(TRUE))
    }

    # If this was the last attempt, stop with error
    if (attempt >= max_retries) {
      stop(sprintf("Quarto render failed after %d attempt(s): %s",
                   max_retries, result$message))
    }

    # Otherwise, increment attempt counter
    attempt <- attempt + 1
  }
}


#' Wait for Directory with Timeout
#'
#' @description
#' Waits for a directory to be created/ready, with timeout. Useful for
#' handling race conditions in file system operations.
#'
#' @param path Directory path to wait for
#' @param timeout Maximum seconds to wait (default: 10)
#' @param check_interval Seconds between checks (default: 0.1)
#' @param verbose Logical: print progress messages (default: TRUE)
#'
#' @return Invisibly returns TRUE if directory appears, stops with error on timeout
#' @export
#'
#' @examples
#' \dontrun{
#'   wait_for_directory("./_freeze", timeout = 5)
#' }
wait_for_directory <- function(path,
                               timeout = 10,
                               check_interval = 0.1,
                               verbose = TRUE) {

  start_time <- Sys.time()

  if (verbose) {
    log_info(sprintf("Waiting for directory: %s (timeout: %ds)",
                    path, timeout),
            context = "wait_for_directory")
  }

  while (!dir.exists(path)) {

    # Check timeout
    elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

    if (elapsed > timeout) {
      log_error(sprintf("Timeout waiting for directory: %s (waited %0.1fs)",
                       path, elapsed),
               context = "wait_for_directory")
      stop(sprintf("Timeout waiting for directory: %s", path))
    }

    # Wait before next check
    Sys.sleep(check_interval)
  }

  if (verbose) {
    elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
    log_info(sprintf("✓ Directory ready after %0.1fs: %s", elapsed, path),
            context = "wait_for_directory")
  }

  invisible(TRUE)
}


#' Execute Function with Error Context
#'
#' @description
#' Wrapper function that executes a function with error handling and context.
#' Provides detailed error messages including function name and arguments.
#'
#' @param func Function to execute
#' @param args List of arguments to pass to function
#' @param context Context description for error messages
#' @param on_error Function to call on error (optional)
#'
#' @return Result of function execution
#' @export
#'
#' @examples
#' \dontrun{
#'   with_error_context(
#'     func = fs::file_copy,
#'     args = list(path = "src.txt", new_path = "dst.txt"),
#'     context = "copying config file"
#'   )
#' }
with_error_context <- function(func, args, context, on_error = NULL) {

  tryCatch({

    # Execute function with args
    do.call(func, args)

  }, error = function(e) {

    # Log error with context
    log_error(sprintf("Failed %s: %s", context, e$message),
             context = "with_error_context")

    # Call custom error handler if provided
    if (!is.null(on_error) && is.function(on_error)) {
      on_error(e)
    }

    # Re-throw error
    stop(e)
  })
}
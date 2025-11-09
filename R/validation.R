#' Build Validation Functions
#'
#' @description
#' Validates that Quarto book builds completed successfully and all
#' required files are present.

#' Validate Build Output
#'
#' @description
#' Verifies that all expected output files and directories were created
#' during the build process.
#'
#' @param language Character: "TR" or "EN"
#' @param min_chapters Integer: minimum number of HTML files expected (default: 60)
#' @param check_deploy Logical: check deployment directory instead of build output (default: TRUE)
#' @param verbose Logical: print validation progress (default: TRUE)
#'
#' @return Invisibly returns TRUE if valid, stops with error if validation fails
#' @export
#'
#' @examples
#' \dontrun{
#'   validate_build_output("TR")
#'   validate_build_output("EN", min_chapters = 65)
#'   validate_build_output("TR", check_deploy = FALSE)  # Check _docs instead of docs
#' }
validate_build_output <- function(language, min_chapters = 60,
                                  check_deploy = TRUE, verbose = TRUE) {

  if (!language %in% c("TR", "EN")) {
    stop(sprintf("Invalid language: %s. Must be 'TR' or 'EN'", language))
  }

  if (verbose) {
    message(sprintf("\n=== Validating %s Build Output ===", language))
  }

  # Get language configuration
  source("./R/config.R")
  config <- get_language_config(language)

  # Choose which directory to check
  check_dir <- if (check_deploy) config$deploy_dir else config$output_dir
  dir_type <- if (check_deploy) "deployment" else "build output"

  errors <- character()
  warnings <- character()

  # ============================================
  # 1. Check directory exists
  # ============================================
  if (verbose) message(sprintf("Checking %s directory...", dir_type))

  if (!dir.exists(check_dir)) {
    errors <- c(errors, sprintf("%s directory missing: %s",
                                tools::toTitleCase(dir_type), check_dir))
  } else {
    if (verbose) message(sprintf("  ✓ %s directory exists: %s",
                                tools::toTitleCase(dir_type), check_dir))
  }

  # ============================================
  # 2. Check essential files
  # ============================================
  if (verbose) message("Checking essential files...")

  essential_files <- c(
    file.path(check_dir, "index.html"),
    file.path(check_dir, "search.json"),
    file.path(check_dir, "site_libs")
  )

  for (file in essential_files) {
    if (!file.exists(file)) {
      errors <- c(errors, sprintf("Missing essential file/directory: %s", file))
    } else {
      if (verbose) message(sprintf("  ✓ Found: %s", basename(file)))
    }
  }

  # ============================================
  # 3. Check chapter count
  # ============================================
  if (verbose) message("Checking rendered chapters...")

  if (dir.exists(check_dir)) {
    html_files <- list.files(
      check_dir,
      pattern = "\\.html$",
      recursive = FALSE,
      full.names = FALSE
    )

    chapter_count <- length(html_files)

    if (chapter_count < min_chapters) {
      errors <- c(errors, sprintf(
        "Insufficient chapters rendered: %d found, expected at least %d",
        chapter_count, min_chapters
      ))
    } else {
      if (verbose) {
        message(sprintf("  ✓ %d HTML chapters rendered (expected >= %d)",
                       chapter_count, min_chapters))
      }
    }
  }

  # ============================================
  # 4. Check for broken image references
  # ============================================
  if (verbose) message("Checking image directories...")

  image_dirs <- c("images", "screenshots", "qrcodes")
  for (img_dir in image_dirs) {
    img_path <- file.path(check_dir, img_dir)
    if (!dir.exists(img_path)) {
      warnings <- c(warnings, sprintf("Image directory not copied: %s", img_dir))
    } else {
      img_count <- length(list.files(img_path, recursive = TRUE))
      if (verbose) message(sprintf("  ✓ %s (%d files)", img_dir, img_count))
    }
  }

  # ============================================
  # 5. Check JavaScript resources
  # ============================================
  if (verbose) message("Checking JavaScript resources...")

  js_files <- c(
    file.path(check_dir, "webpages.js"),
    file.path(check_dir, "script.js")
  )

  for (js_file in js_files) {
    if (!file.exists(js_file)) {
      warnings <- c(warnings, sprintf("JavaScript file missing: %s", basename(js_file)))
    } else {
      if (verbose) message(sprintf("  ✓ Found: %s", basename(js_file)))
    }
  }

  # ============================================
  # 6. Check auto-generated chapter YAML files
  # ============================================
  if (verbose) message("Checking auto-generated chapter files...")

  chapter_yaml_files <- c(
    sprintf("_quarto_chapters_%s_pdf.yml", language),
    sprintf("_quarto_chapters_%s_epub_word.yml", language)
  )

  for (yaml_file in chapter_yaml_files) {
    if (!file.exists(yaml_file)) {
      errors <- c(errors, sprintf("Auto-generated chapter file missing: %s", yaml_file))
    } else {
      # Check file has content
      file_size <- file.info(yaml_file)$size
      if (file_size < 100) {
        errors <- c(errors, sprintf("Auto-generated file too small: %s (%d bytes)",
                                    yaml_file, file_size))
      } else {
        if (verbose) message(sprintf("  ✓ %s (%d bytes)", yaml_file, file_size))
      }
    }
  }

  # ============================================
  # 7. Validate search index
  # ============================================
  if (verbose) message("Validating search index...")

  search_json <- file.path(check_dir, "search.json")
  if (file.exists(search_json)) {
    # Check search.json is valid JSON and has content
    tryCatch({
      search_data <- jsonlite::fromJSON(search_json, simplifyVector = FALSE)
      if (length(search_data) > 0) {
        if (verbose) {
          message(sprintf("  ✓ Search index contains %d entries", length(search_data)))
        }
      } else {
        warnings <- c(warnings, "Search index is empty")
      }
    }, error = function(e) {
      errors <- c(errors, sprintf("Search index is invalid JSON: %s", e$message))
    })
  }

  # ============================================
  # Report Results
  # ============================================

  if (length(warnings) > 0) {
    message("\n⚠ Warnings:")
    for (w in warnings) {
      message(sprintf("  - %s", w))
    }
  }

  if (length(errors) > 0) {
    message("\n❌ Validation FAILED:")
    for (err in errors) {
      message(sprintf("  - %s", err))
    }
    stop(sprintf("\nBuild validation failed for %s version with %d error(s)",
                 language, length(errors)))
  }

  if (verbose) {
    message(sprintf("\n✓ Build validation PASSED for %s version", language))
    if (length(warnings) > 0) {
      message(sprintf("  (%d warning(s))", length(warnings)))
    }
  }

  invisible(TRUE)
}


#' Validate Build Prerequisites
#'
#' @description
#' Checks that all required files, directories, and packages are present
#' before attempting to build.
#'
#' @param language Character: "TR" or "EN"
#' @param verbose Logical: print validation progress (default: TRUE)
#'
#' @return Invisibly returns TRUE if valid, stops with error if validation fails
#' @export
#'
#' @examples
#' \dontrun{
#'   validate_build_prerequisites("TR")
#' }
validate_build_prerequisites <- function(language, verbose = TRUE) {

  if (verbose) {
    message(sprintf("\n=== Validating Build Prerequisites for %s ===", language))
  }

  errors <- character()

  # ============================================
  # 1. Check Quarto config exists
  # ============================================
  source("./R/config.R")
  config <- get_language_config(language)

  if (!file.exists(config$quarto_file)) {
    errors <- c(errors, sprintf("Missing Quarto config: %s", config$quarto_file))
  } else {
    if (verbose) message(sprintf("✓ Quarto config: %s", config$quarto_file))
  }

  # ============================================
  # 2. Check base chapter files exist
  # ============================================
  base_chapter_file <- sprintf("_quarto_chapters_%s.yml", language)
  if (!file.exists(base_chapter_file)) {
    errors <- c(errors, sprintf("Missing base chapter file: %s", base_chapter_file))
  } else {
    if (verbose) message(sprintf("✓ Base chapter file: %s", base_chapter_file))
  }

  # ============================================
  # 3. Check required R packages
  # ============================================
  if (verbose) message("Checking R packages...")

  required_pkgs <- c("quarto", "fs", "yaml", "jsonlite", "xfun")
  missing_pkgs <- character()

  for (pkg in required_pkgs) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      missing_pkgs <- c(missing_pkgs, pkg)
    }
  }

  if (length(missing_pkgs) > 0) {
    errors <- c(errors, sprintf("Missing R packages: %s",
                                paste(missing_pkgs, collapse = ", ")))
  } else {
    if (verbose) message(sprintf("✓ All required R packages installed (%d)",
                                length(required_pkgs)))
  }

  # ============================================
  # 4. Check Quarto is installed
  # ============================================
  if (verbose) message("Checking Quarto installation...")

  quarto_version <- tryCatch({
    system2("quarto", args = "--version", stdout = TRUE, stderr = FALSE)
  }, error = function(e) {
    NULL
  })

  if (is.null(quarto_version)) {
    errors <- c(errors, "Quarto CLI not found in PATH")
  } else {
    if (verbose) message(sprintf("✓ Quarto version: %s", quarto_version))
  }

  # ============================================
  # 5. Check critical directories exist
  # ============================================
  if (verbose) message("Checking project directories...")

  critical_dirs <- c("R", "images", "_subchapters")
  for (dir in critical_dirs) {
    if (!dir.exists(dir)) {
      errors <- c(errors, sprintf("Missing critical directory: %s", dir))
    }
  }

  if (length(errors) == 0 && verbose) {
    message(sprintf("✓ All critical directories present (%d)", length(critical_dirs)))
  }

  # ============================================
  # Report Results
  # ============================================

  if (length(errors) > 0) {
    message("\n❌ Prerequisite validation FAILED:")
    for (err in errors) {
      message(sprintf("  - %s", err))
    }
    stop(sprintf("\nBuild prerequisites failed with %d error(s)", length(errors)))
  }

  if (verbose) {
    message(sprintf("\n✓ All build prerequisites validated for %s", language))
  }

  invisible(TRUE)
}


#' Validate Chapter Generation
#'
#' @description
#' Verifies that auto-generated chapter YAML files were created correctly
#' and contain the expected structure.
#'
#' @param language Character: "TR" or "EN"
#' @param verbose Logical: print validation progress (default: TRUE)
#'
#' @return Invisibly returns TRUE if valid, stops with error if validation fails
#' @export
validate_chapter_generation <- function(language, verbose = TRUE) {

  if (verbose) {
    message(sprintf("\n=== Validating Chapter Generation for %s ===", language))
  }

  errors <- character()

  # Check both PDF and EPUB/Word chapter files
  formats <- c("pdf", "epub_word")

  for (format in formats) {
    yaml_file <- sprintf("_quarto_chapters_%s_%s.yml", language, format)

    if (!file.exists(yaml_file)) {
      errors <- c(errors, sprintf("Generated chapter file missing: %s", yaml_file))
      next
    }

    # Read and validate YAML structure
    tryCatch({
      chapter_data <- yaml::read_yaml(yaml_file)

      # Check has book section
      if (!"book" %in% names(chapter_data)) {
        errors <- c(errors, sprintf("%s: Missing 'book' section", yaml_file))
      }

      # Check has chapters
      if ("book" %in% names(chapter_data)) {
        if (!"chapters" %in% names(chapter_data$book)) {
          errors <- c(errors, sprintf("%s: Missing 'chapters' section", yaml_file))
        } else {
          chapter_count <- length(chapter_data$book$chapters)
          if (chapter_count < 10) {
            errors <- c(errors, sprintf("%s: Too few chapters (%d)",
                                        yaml_file, chapter_count))
          } else {
            if (verbose) {
              message(sprintf("✓ %s: %d chapters", yaml_file, chapter_count))
            }
          }
        }
      }

      # Verify suffix was added to hrefs
      suffix <- sprintf("_%s_%s", format, language)

      # Check first few chapters have correct suffix
      if ("book" %in% names(chapter_data) &&
          "chapters" %in% names(chapter_data$book)) {

        sample_chapters <- head(chapter_data$book$chapters, 5)
        suffix_found <- FALSE

        for (ch in sample_chapters) {
          if (is.list(ch) && "href" %in% names(ch)) {
            if (ch$href != "index.qmd" && grepl(suffix, ch$href)) {
              suffix_found <- TRUE
              break
            }
          }
        }

        if (!suffix_found && format == "pdf") {
          # For PDF/EPUB, we expect suffixes (unless all are index.qmd)
          errors <- c(errors, sprintf("%s: Suffixes not found in href fields", yaml_file))
        }
      }

    }, error = function(e) {
      errors <- c(errors, sprintf("%s: Invalid YAML - %s", yaml_file, e$message))
    })
  }

  # ============================================
  # Report Results
  # ============================================

  if (length(errors) > 0) {
    message("\n❌ Chapter generation validation FAILED:")
    for (err in errors) {
      message(sprintf("  - %s", err))
    }
    stop(sprintf("\nChapter generation validation failed with %d error(s)",
                 length(errors)))
  }

  if (verbose) {
    message(sprintf("\n✓ Chapter generation validated for %s", language))
  }

  invisible(TRUE)
}


#' Run All Validations
#'
#' @description
#' Convenience function to run all validation checks in sequence.
#'
#' @param language Character: "TR" or "EN"
#' @param check_prerequisites Logical: validate prerequisites before build (default: TRUE)
#' @param check_chapter_gen Logical: validate chapter generation (default: TRUE)
#' @param check_output Logical: validate build output (default: TRUE)
#' @param verbose Logical: print validation progress (default: TRUE)
#'
#' @return Invisibly returns TRUE if all validations pass
#' @export
#'
#' @examples
#' \dontrun{
#'   # Run all validations for Turkish
#'   validate_all("TR")
#'
#'   # Run only output validation
#'   validate_all("EN", check_prerequisites = FALSE, check_chapter_gen = FALSE)
#' }
validate_all <- function(language,
                        check_prerequisites = TRUE,
                        check_chapter_gen = TRUE,
                        check_output = TRUE,
                        verbose = TRUE) {

  if (verbose) {
    message(sprintf("\n╔════════════════════════════════════════╗"))
    message(sprintf("║  Validation Suite: %s Version         ║", language))
    message(sprintf("╚════════════════════════════════════════╝"))
  }

  if (check_prerequisites) {
    validate_build_prerequisites(language, verbose = verbose)
  }

  if (check_chapter_gen) {
    validate_chapter_generation(language, verbose = verbose)
  }

  if (check_output) {
    validate_build_output(language, verbose = verbose)
  }

  if (verbose) {
    message(sprintf("\n╔════════════════════════════════════════╗"))
    message(sprintf("║  ✓ ALL VALIDATIONS PASSED: %s         ║", language))
    message(sprintf("╚════════════════════════════════════════╝\n"))
  }

  invisible(TRUE)
}

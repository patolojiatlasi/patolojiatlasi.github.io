# Generate format-specific chapter YAML files from base chapter definitions
# This allows maintaining only 2 base chapter files (TR and EN) instead of 6

library(yaml)

#' Add suffix to filename in href field
#' @param href Original href value (e.g., "giris.qmd")
#' @param suffix Suffix to add (e.g., "_pdf_TR")
#' @return Modified href value (e.g., "giris_pdf_TR.qmd")
add_suffix_to_href <- function(href, suffix) {
  if (is.null(href) || is.na(href) || href == "" || href == "index.qmd") {
    return(href)
  }

  # Split into base and extension
  parts <- strsplit(href, "\\.")[[1]]
  if (length(parts) < 2) {
    return(href)
  }

  extension <- parts[length(parts)]
  base <- paste(parts[1:(length(parts)-1)], collapse = ".")

  # Add suffix
  new_href <- paste0(base, suffix, ".", extension)
  return(new_href)
}

#' Recursively process YAML structure and add suffix to all href fields
#' @param obj YAML object (list, vector, or scalar)
#' @param suffix Suffix to add to hrefs
#' @return Modified YAML object
process_yaml_structure <- function(obj, suffix) {
  if (is.list(obj)) {
    # If this is a list with an href field, modify it
    if ("href" %in% names(obj)) {
      obj$href <- add_suffix_to_href(obj$href, suffix)
    }

    # Recursively process all list elements
    obj <- lapply(obj, function(x) process_yaml_structure(x, suffix))
    return(obj)
  } else if (is.vector(obj) && length(obj) > 1) {
    # Process vector elements
    return(lapply(obj, function(x) process_yaml_structure(x, suffix)))
  } else {
    # Return scalars unchanged
    return(obj)
  }
}

#' Generate format-specific chapter YAML file
#' @param base_file Path to base chapter YAML file
#' @param output_file Path to output YAML file
#' @param suffix Suffix to add to chapter hrefs (e.g., "_pdf_TR", "_epub_word_EN")
generate_chapter_yaml <- function(base_file, output_file, suffix) {
  # Read base YAML
  base_content <- yaml::read_yaml(base_file)

  # Process the structure to add suffixes
  modified_content <- process_yaml_structure(base_content, suffix)

  # Add header comment
  header_comment <- paste0(
    "# AUTO-GENERATED FILE - DO NOT EDIT\n",
    "# Generated from ", basename(base_file), "\n",
    "# Suffix: ", suffix, "\n\n"
  )

  # Write modified YAML
  yaml_string <- yaml::as.yaml(modified_content)
  writeLines(c(header_comment, yaml_string), output_file)

  message("Generated: ", output_file)
}

#' Generate all format-specific chapter YAML files for a language
#' @param language Language code ("TR" or "EN")
generate_all_chapter_yamls <- function(language) {
  base_file <- paste0("_quarto_chapters_", language, ".yml")

  if (!file.exists(base_file)) {
    warning("Base chapter file not found: ", base_file)
    return(invisible(NULL))
  }

  # Generate PDF version
  pdf_suffix <- paste0("_pdf_", language)
  pdf_output <- paste0("_quarto_chapters_", language, "_pdf.yml")
  generate_chapter_yaml(base_file, pdf_output, pdf_suffix)

  # Generate EPUB/Word version
  epub_word_suffix <- paste0("_epub_word_", language)
  epub_word_output <- paste0("_quarto_chapters_", language, "_epub_word.yml")
  generate_chapter_yaml(base_file, epub_word_output, epub_word_suffix)

  message("Successfully generated chapter YAMLs for ", language)
}

# Main execution: generate for both languages
if (!interactive()) {
  generate_all_chapter_yamls("TR")
  generate_all_chapter_yamls("EN")
}

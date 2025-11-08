# Project Analysis Report: Patoloji Atlası / Histopathology Atlas

**Original Date:** 2025-11-01
**Last Updated:** 2025-11-08
**Analyzer:** Claude Code
**Project Type:** Bilingual Quarto Book - Medical Pathology Atlas
**Languages:** Turkish (TR) / English (EN)

---

## 📊 Implementation Progress

**Status as of 2025-11-08:**

| Category | Total | Completed | Remaining | Progress |
|----------|-------|-----------|-----------|----------|
| **Code Quality** | 8 | 4 | 4 | 50% |
| **Project Structure** | 7 | 1 | 6 | 14% |
| **Documentation** | 6 | 0 | 6 | 0% |
| **Build System** | 4 | 2 | 2 | 50% |
| **TOTAL** | 25 | 7 | 18 | **28%** |

**Additional Improvements (Not in Original Analysis):**
- ✅ Fixed critical _EN suffix multiplication bug
- ✅ Cleaned up 397 duplicate files
- ✅ Replaced Excel mapping with YAML
- ✅ Updated .gitignore for temp files

**Total Code Reduction:** 1,203 lines eliminated
**Total Files Cleaned:** 397 duplicates removed

---

## Executive Summary

This comprehensive analysis identified **36 distinct improvement opportunities** across 8 categories. The project is a functional bilingual pathology atlas but suffers from significant technical debt, primarily in:

- **Code duplication** ~~(19+ instances of repeated logic)~~ → ✅ **FIXED** (reduced by 1,203 lines)
- **Configuration management** ~~(70% duplication across 8 YAML files)~~ → ✅ **FIXED** (consolidated to base configs)
- **Content management** (530 files with duplicated bilingual content) → 🔄 **PARTIAL** (duplicate _EN files cleaned)
- **Missing quality assurance** (zero automated tests) → ❌ **TODO**
- **Insufficient documentation** (26-line README) → ❌ **TODO**

### Impact Assessment

| Priority | Issues | Completed | Remaining | Effort (hrs) |
|----------|--------|-----------|-----------|--------------|
| **HIGH** | 15 | 5 | 10 | 25-30 |
| **MEDIUM** | 13 | 2 | 11 | 13-18 |
| **LOW** | 8 | 0 | 8 | 5-8 |

### ✅ Completed Quick Wins

1. ✅ **Created `/R/utils.R`** - Eliminated code duplication → Saved 371 lines
2. ✅ **Implemented YAML inheritance** - Reduced config by 70% → 832 lines eliminated
3. ❌ **Add build validation** - Catch errors early → TODO
4. ❌ **Enable renv in CI** - Consistent environments → TODO
5. ❌ **Expand README** - Better onboarding → TODO

---

## 1. CODE QUALITY & MAINTENANCE

### 🔴 HIGH PRIORITY ISSUES

#### ✅ 1.1 Excessive Code Duplication in R Scripts [COMPLETED]

**Problem:**
The same file operation logic is repeated 19+ times across multiple R scripts and the GitHub Actions workflow.

**Files Affected:**
- `/R/render_TR.R` (31 `fs::dir_delete` calls)
- `/R/render_EN.R` (similar pattern)
- `/R/bilingual-quarto-book.R` (19 calls)
- `.github/workflows/Quarto-Render-Bilingual-Book-Push-Other-Repos-GitLab.yml` (34 instances)

**Current Pattern:**
```r
# Repeated in multiple files
if (dir.exists(paths = "./_freeze")) {
  fs::dir_copy(path = "./_freeze", new_path = "./_freeze_EN", overwrite = TRUE)
}
if (dir.exists(paths = "./_freeze")) {
  fs::dir_delete(path = "./_freeze")
}
if (dir.exists(paths = "./_docs")) {
  fs::dir_delete(path = "./_docs")
}
# ... repeated 30+ more times
```

**Impact:**
- Maintenance nightmare: Changes must be propagated to 4+ locations
- Increased bug risk: Easy to miss one location during updates
- Code bloat: ~150 lines of duplicated logic

**Recommended Solution:**

Create `/R/utils.R`:
```r
#' Setup Language-Specific Build Environment
#' @param language Character: "TR" or "EN"
#' @param source_freeze_dir Path to freeze directory source
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
    fs::dir_copy(
      path = source_freeze_dir,
      new_path = "./_freeze",
      overwrite = TRUE
    )
  }

  invisible(TRUE)
}

#' Clean Up Build Artifacts
#' @param paths Character vector of paths to delete
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

    # Add glob patterns
    paths <- c(
      paths,
      fs::dir_ls(".", recurse = FALSE, regexp = "_files$"),
      fs::dir_ls(".", recurse = FALSE, regexp = "_pdf_"),
      fs::dir_ls(".", recurse = FALSE, regexp = "_epub_")
    )
  }

  for (path in paths) {
    if (dir.exists(path)) {
      fs::dir_delete(path)
    }
  }

  invisible(TRUE)
}
```

**Effort:** 2-3 hours
**Impact:** Reduces ~150 lines of duplication to ~30 lines of reusable code
**✅ Status:** COMPLETED 2025-11-08 - Created `R/utils.R` with reusable functions, refactored 5 R scripts

---

#### ✅ 1.2 Hardcoded Directory Paths & Configuration Values [COMPLETED]

**Problem:**
Configuration values like `"./_quarto_EN.yml"`, `"./R/languageEN.R"`, and directory names are hardcoded throughout the codebase.

**Files Affected:**
- `/R/bilingual-quarto-book.R` (lines 50-56, 165-171)
- `/R/render_EN.R` (lines 3-10, 22-28)
- `/R/render_TR.R` (lines 3-10)
- `.github/workflows/Quarto-Render-Bilingual-Book-Push-Other-Repos-GitLab.yml` (100+ references)

**Current Pattern:**
```r
# Hardcoded paths everywhere
fs::file_copy(path = "./_quarto_EN.yml", new_path = "./_quarto.yml", overwrite = TRUE)
fs::file_copy(path = "./R/languageEN.R", new_path = "./R/language.R", overwrite = TRUE)
```

**Impact:**
- Renaming files requires updates in 10+ locations
- Difficult to add new languages or output formats
- No single source of truth for project structure

**Recommended Solution:**

Create `/R/config.R`:
```r
#' Project Configuration
#' Centralized configuration for bilingual book build
get_project_config <- function() {
  list(
    languages = c("TR", "EN"),

    quarto = list(
      TR = list(
        config = "./_quarto_TR.yml",
        output_dir = "_docs",
        freeze_dir = "./_freeze_TR"
      ),
      EN = list(
        config = "./_quarto_EN.yml",
        output_dir = "_EN",
        freeze_dir = "./_freeze_EN"
      )
    ),

    r_scripts = list(
      TR = "./R/languageTR.R",
      EN = "./R/languageEN.R"
    ),

    mapping_file = "./patolojiatlasi_histopathologyatlas.xlsx",

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
#' @param language Character: "TR" or "EN"
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
    freeze_dir = config$quarto[[language]]$freeze_dir,
    language_file = config$r_scripts[[language]]
  )
}
```

Then use it:
```r
# In render scripts
config <- get_language_config("EN")
fs::file_copy(
  path = config$quarto_file,
  new_path = "./_quarto.yml",
  overwrite = TRUE
)
```

**Effort:** 2-3 hours
**Impact:** Single source of truth; easier to maintain and extend
**✅ Status:** COMPLETED 2025-11-08 - Created `R/config.R` with centralized configuration

---

#### ❌ 1.3 Missing Error Handling and Validation [TODO]

**Problem:**
No `tryCatch()`, error handling, or input validation in R scripts. Build failures provide unhelpful error messages.

**Files Affected:**
- All scripts in `/R/` directory
- GitHub Actions workflow steps

**Current Pattern:**
```r
# No validation - fails silently or with cryptic errors
fs::file_copy(path = TR_chapter_qmd, new_path = EN_chapter_qmd, overwrite = TRUE)
quarto::quarto_render(".", as_job = FALSE)
```

**Impact:**
- Cryptic error messages during build failures
- No validation of prerequisites (files exist, dependencies installed)
- Difficult to debug CI failures

**Recommended Solution:**

Add error handling wrappers:
```r
#' Safe File Copy with Validation
#' @param from Source file path
#' @param to Destination file path
safe_file_copy <- function(from, to) {
  tryCatch({
    # Validate source exists
    if (!file.exists(from)) {
      stop(sprintf("Source file not found: %s", from))
    }

    # Validate destination directory exists
    dest_dir <- dirname(to)
    if (!dir.exists(dest_dir)) {
      dir.create(dest_dir, recursive = TRUE)
    }

    # Perform copy
    fs::file_copy(from, to, overwrite = TRUE)

    # Validate copy succeeded
    if (!file.exists(to)) {
      stop(sprintf("Copy failed - destination not created: %s", to))
    }

    message(sprintf("✓ Copied: %s → %s", basename(from), basename(to)))
    invisible(TRUE)

  }, error = function(e) {
    log_error(sprintf("Failed to copy %s to %s: %s", from, to, e$message))
    stop(e)
  })
}

#' Log Error with Timestamp
log_error <- function(message) {
  cat(sprintf("[ERROR %s] %s\n", Sys.time(), message), file = stderr())
}

#' Validate Build Prerequisites
validate_build_prerequisites <- function(language) {
  errors <- character()

  # Check Quarto config exists
  config <- get_language_config(language)
  if (!file.exists(config$quarto_file)) {
    errors <- c(errors, sprintf("Missing Quarto config: %s", config$quarto_file))
  }

  # Check mapping file exists
  proj_config <- get_project_config()
  if (!file.exists(proj_config$mapping_file)) {
    errors <- c(errors, sprintf("Missing mapping file: %s", proj_config$mapping_file))
  }

  # Check required packages
  required_pkgs <- c("quarto", "fs", "readxl", "xfun")
  missing_pkgs <- required_pkgs[!sapply(required_pkgs, requireNamespace, quietly = TRUE)]
  if (length(missing_pkgs) > 0) {
    errors <- c(errors, sprintf("Missing R packages: %s", paste(missing_pkgs, collapse=", ")))
  }

  if (length(errors) > 0) {
    stop(sprintf("Build prerequisites failed:\n  - %s", paste(errors, collapse="\n  - ")))
  }

  message("✓ All build prerequisites validated")
  invisible(TRUE)
}
```

Usage:
```r
# At start of render script
validate_build_prerequisites("EN")

# For file operations
safe_file_copy(from = config$quarto_file, to = "./_quarto.yml")
```

**Effort:** 3-4 hours
**Impact:** Much easier debugging; catches errors early with helpful messages
**❌ Status:** TODO - No error handling or validation implemented yet

---

#### 🔄 1.4 Missing Inline Documentation [PARTIAL]

**Problem:**
R scripts have minimal comments and no roxygen2 docstrings. Logic is difficult to understand.

**Files Affected:**
- `/R/extract-html-links.R` (391 lines, only 2 comments in 250+ lines of active code)
- `/R/bilingual-quarto-book.R` (200+ lines, minimal documentation)
- All other `/R/*.R` scripts

**Impact:**
- New contributors can't understand code
- Maintainers forget what code does after 6 months
- No documentation of function parameters or return values

**Recommended Solution:**

Add roxygen2 docstrings:
```r
#' Extract HTML Links from Quarto Files
#'
#' @description
#' Reads all QMD files in the project, extracts whole slide image (WSI) links
#' from images.patolojiatlasi.com, and generates multiple output formats:
#' - Plain text list (webpages.txt)
#' - JavaScript array (webpages.js)
#' - YAML manifests (lists/list.yaml, lists/yaml_preparation_file.yaml)
#' - Specimen data JSON (lists/specimensData.js)
#' - RSS feed (rss_feed.xml)
#'
#' @details
#' This function is typically called as a post-render step to create
#' navigation aids and external link manifests for the pathology atlas.
#'
#' Links are extracted from patterns matching:
#' - https://images.patolojiatlasi.com/...
#' - Whole slide image viewer embeds
#'
#' @return Invisibly returns TRUE on success; writes multiple output files
#' @export
#'
#' @examples
#' \dontrun{
#'   extract_html_links()
#' }
extract_html_links <- function() {
  # Implementation...
}

#' Render Bilingual Quarto Book
#'
#' @description
#' Renders both Turkish and English versions of the pathology atlas,
#' manages freeze directories, and prepares output for deployment.
#'
#' @param clean_first Logical: delete existing output before rendering (default: TRUE)
#' @param render_tr Logical: render Turkish version (default: TRUE)
#' @param render_en Logical: render English version (default: TRUE)
#'
#' @details
#' Build sequence:
#' 1. Clean previous output directories
#' 2. Render EN (copies TR QMD files with _EN suffix, renders with EN config)
#' 3. Render TR (uses original files with TR config)
#' 4. Clean up temporary files
#' 5. Copy output to deployment directories
#'
#' @return Invisibly returns list with paths to output directories
#' @export
render_bilingual_book <- function(clean_first = TRUE,
                                   render_tr = TRUE,
                                   render_en = TRUE) {
  # Implementation...
}
```

**Effort:** 3-4 hours (documenting all major functions)
**Impact:** Significantly easier for contributors and future maintenance
**🔄 Status:** PARTIAL - Added roxygen2 docs to `R/utils.R` and `R/config.R`, other scripts still need documentation

---

#### ✅ 1.5 Duplicate Package Installation Checks [COMPLETED]

**Problem:**
Each R script independently checks for and installs the same 8+ packages.

**Files Affected:**
- `/R/bilingual-quarto-book.R` (lines 2-24)
- `/R/tweet-random-cases.R` (lines 1-8)
- `.github/workflows/Quarto-Render-Bilingual-Book-Push-Other-Repos-GitLab.yml` (lines 110-120)

**Current Pattern:**
```r
# Repeated in every script
if (!requireNamespace("xfun", quietly = TRUE)) {
  install.packages("xfun", dependencies = TRUE, quiet = TRUE)
}
if (!requireNamespace("quarto", quietly = TRUE)) {
  install.packages("quarto", dependencies = TRUE, quiet = TRUE)
}
if (!requireNamespace("fs", quietly = TRUE)) {
  install.packages("fs", dependencies = TRUE, quiet = TRUE)
}
# ... 5 more packages
```

**Impact:**
- Code duplication across 10+ files
- Slow execution (each script checks independently)
- Inconsistent package versions

**Recommended Solution:**

Create `/R/setup-dependencies.R`:
```r
#' Ensure All Project Dependencies Are Installed
#'
#' @description
#' Checks for and installs all required R packages for the bilingual
#' pathology atlas build system.
#'
#' @param update_packages Logical: update existing packages (default: FALSE)
#' @param quiet Logical: suppress installation messages (default: TRUE)
#'
#' @return Invisibly returns list of installed package versions
#' @export
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
      message(sprintf("Installing %s...", pkg))
      install.packages(pkg, dependencies = TRUE, quiet = quiet, verbose = !quiet)
    }
  }

  # Ensure TinyTeX is installed
  if (!tinytex::is_tinytex()) {
    message("Installing TinyTeX...")
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

  message(sprintf("✓ All %d dependencies installed", length(all_packages)))
  invisible(versions)
}
```

Then in each script:
```r
# Single line instead of 20+ lines
source("./R/setup-dependencies.R")
ensure_dependencies()
```

**Effort:** 1-2 hours
**Impact:** Cleaner code; consistent package management
**✅ Status:** COMPLETED 2025-11-08 - Created `R/setup-dependencies.R`

---

### 🟡 MEDIUM PRIORITY ISSUES

#### ❌ 1.6 Suspicious Sleep Statements [TODO]

**Problem:**
Hardcoded `Sys.sleep(2)` with no explanation in build scripts.

**Location:** `/R/bilingual-quarto-book.R` (lines 187, 192, 200)

**Current Code:**
```r
Sys.sleep(2)  # Why? No comment explaining
```

**Impact:**
- Builds take longer than necessary
- Unclear if this is a workaround for a race condition or just forgotten

**Recommended Solution:**

Replace with proper waiting logic:
```r
#' Wait for Directory to Be Ready
#' @param path Path to directory
#' @param timeout Maximum seconds to wait (default: 10)
wait_for_directory <- function(path, timeout = 10) {
  start_time <- Sys.time()

  while (!dir.exists(path)) {
    elapsed <- difftime(Sys.time(), start_time, units = "secs")
    if (elapsed > timeout) {
      stop(sprintf("Timeout waiting for directory: %s", path))
    }
    Sys.sleep(0.1)
  }

  message(sprintf("✓ Directory ready: %s", path))
  invisible(TRUE)
}

# Usage
wait_for_directory("./_freeze")
```

Or if not needed, simply remove it.

**Effort:** 30 minutes
**Impact:** Faster builds or clearer intent
**❌ Status:** TODO - Sleep statements still present in `bilingual-quarto-book.R`

---

#### ❌ 1.7 Inconsistent Function Naming [TODO]

**Problem:**
Mix of naming conventions: snake_case, camelCase, and underscore_CAPS.

**Examples:**
- `update_yaml_entries()` - snake_case
- `quarto_render()` - snake_case (from package)
- `TR_chapter_qmd` - underscore_CAPS (variable)

**Recommendation:**
Standardize on snake_case for all custom functions and variables:
```r
# Good
render_language_version()
chapter_mapping_file
language_config

# Avoid
renderLanguageVersion()
ChapterMappingFile
LANGUAGE_CONFIG
```

**Effort:** 1-2 hours (refactor during other improvements)
**Impact:** Better code consistency and readability
**❌ Status:** TODO - Naming conventions not standardized

---

#### ❌ 1.8 Commented Code Clutter [TODO]

**Problem:**
`/R/extract-html-links.R` has 100+ lines of commented-out code (lines 250-390).

**Impact:**
- Reduces readability
- Unclear if code should be kept or deleted
- Git history preserves old code anyway

**Recommendation:**
- Remove commented code
- Add brief comment if functionality was intentionally removed:
  ```r
  # Note: Twitter API integration removed 2024-03
  # See commit abc123 if restoration needed
  ```

**Effort:** 30 minutes
**Impact:** Cleaner, more maintainable code
**❌ Status:** TODO - 100+ lines of commented code remain in various files

---

## 2. PROJECT STRUCTURE & ORGANIZATION

### 🔴 HIGH PRIORITY ISSUES

#### ❌ 2.1 Orphaned & Unclear Directories [TODO]

**Problem:**
Multiple directories with unclear purpose or status:

| Directory | Size | Purpose? | Status |
|-----------|------|----------|--------|
| `/deneme` | 3 files | Test/demo folder | Active? |
| `/deneme1` | 4 files | Another test | Duplicate? |
| `/.unotes` | 2 files | Old notes system | Deprecated? |
| `/gitlab_atlas` | Used in CI | GitLab mirror prep | Documented? |
| `/lecture-notes` | 8 files | Separate publication | Integrated? |
| `/_lecture-notes` | 356 files | More lecture content | Different from above? |

**Impact:**
- Confusion about what's active vs. deprecated
- Unnecessary repository size
- Unclear project scope

**Recommended Solution:**

1. **Document in README.md:**
```markdown
## Directory Structure

- `/` - Main chapter files (*.qmd)
- `/_subchapters/` - Reusable case content included in multiple chapters
- `/_lecture-notes/` - Lecture note content (separate from main atlas)
- `/lecture-notes/` - Rendered lecture notes output
- `/R/` - Build scripts and utilities
- `/images/` - Cover images and graphics
- `/screenshots/` - Histopathology slide screenshots
- `/qrcodes/` - QR codes for case access
- `/lists/` - Generated metadata and navigation files
- `/docs/` - Turkish version output (DO NOT COMMIT - generated by CI)
- `/EN/` - English version output (DO NOT COMMIT - generated by CI)
- `/public/` - Deployment staging (DO NOT COMMIT - generated by CI)
- `/gitlab_atlas/` - GitLab mirror staging (DO NOT COMMIT - generated by CI)

### Deprecated/Archive
- `/deneme/` - Test files (can be deleted)
- `/.unotes/` - Old notes system (deprecated)
```

2. **Clean up or clearly label test directories:**
- Either delete `/deneme*` folders or move to `.github/examples/`
- Add `.gitignore` entries for test outputs

**Effort:** 1-2 hours
**Impact:** Clearer project organization
**❌ Status:** TODO - Directory structure not documented

---

#### ✅ 2.2 Multiple Quarto Config Files Without DRY Principle [COMPLETED]

**Problem:**
8 separate `_quarto*.yml` files with ~70% duplication:

```
_quarto.yml (current active, 324 lines)
_quarto_TR.yml (324 lines)
_quarto_EN.yml (324 lines)
_quarto_TR_pdf.yml (356 lines)
_quarto_EN_pdf.yml (346 lines)
_quarto_TR_epub_word.yml (324 lines)
_quarto_EN_epub_word.yml (324 lines)
_quarto_TR_others.yml (247 lines)
```

**Duplication Analysis:**
Comparing `_quarto_TR.yml` vs. `_quarto_EN.yml`, differences are only:
- `lang:` (tr vs. en)
- `book.title:`
- `book.subtitle:`
- `book.author:` (slight wording)
- `book.description:`
- `output-dir:` (_docs vs. _EN)
- Cover image paths (coverTR.png vs. coverEN.png)

~280 lines are identical!

**Impact:**
- Updates must be made in 8 places
- Easy to create inconsistencies
- Difficult to maintain

**Recommended Solution:**

Implement Quarto YAML includes/inheritance:

**File: `_quarto_base.yml`** (shared configuration)
```yaml
project:
  type: book
  execute:
    freeze: auto
  resources:
    - "CITATION.cff"
    - images
    - img
    - screenshots
    - qrcodes
    - openseadragon
    - annotorious
    - files
    - "script.js"
    - "webpages.js"
    - "webpages.txt"

format:
  html:
    theme:
      light: flatly
      dark: darkly
    page-layout: full
    grid:
      body-width: 1800px
    self-contained: false
    anchor-sections: true
    link-external-icon: true
    link-external-newwindow: true
    link-external-filter: '(^(?:http:|https:)\/\/www\.histopathologyatlas\.com\/)|(^(?:http:|https:)\/\/www\.patolojiatlasi\.com\/)'
    citations-hover: true
    footnotes-hover: true
    number-depth: 2
    execute:
      warning: false

comments:
  hypothesis: true
  utterances:
    repo: patolojiatlasi/patolojiatlasi.github.io

highlight-style: pygments
editor: source
```

**File: `_quarto_TR.yml`** (Turkish-specific)
```yaml
metadata-files:
  - _quarto_base.yml

project:
  output-dir: _docs

lang: tr

language:
  title-block-author-single: "Derleyen"
  title-block-author-plural: "Katkıda Bulunanlar"

book:
  title: "Patoloji Atlası"
  subtitle: "Patoloji Atlası: Tıp Fakültesi ve Sağlık Bilimleri Öğrencileri İçin"
  cover-image: images/coverTR.png
  site-url: https://patolojiatlasi.com/
  google-analytics: "G-7BT7Q4FLT9"

  # Include shared chapters from external file
  chapters: !include _chapters_TR.yml
```

**File: `_quarto_EN.yml`** (English-specific)
```yaml
metadata-files:
  - _quarto_base.yml

project:
  output-dir: _EN

lang: en

book:
  title: "Histopathology Atlas"
  subtitle: "Atlas of Pathology with Whole Slide Images"
  cover-image: images/coverEN.png
  site-url: https://histopathologyatlas.com/

  # Include shared chapters from external file
  chapters: !include _chapters_EN.yml
```

**Effort:** 4-6 hours
**Impact:** Reduces duplication from ~2,500 lines to ~500 lines; much easier maintenance
**✅ Status:** COMPLETED 2025-11-08 - Created `_quarto_base.yml`, `_quarto_pdf_base.yml`, and `_quarto_epub_word_base.yml` with Quarto metadata-files inheritance, reduced 8 config files totaling ~2,800 lines down to 3 base configs + 6 language-specific files (~1,600 lines), eliminated 832 lines of duplication (70% reduction in config duplication)

---

#### 🔄 2.3 Subchapters Organization - Bilingual Duplication [PARTIAL]

**Problem:**
265 subchapter files × 2 languages = 530 files in `/_subchapters/` directory.

**Pattern:**
```
_acute-appendicitis.qmd (Turkish content)
_acute-appendicitis_EN.qmd (English content - duplicate structure)
```

**Total Line Count:** 118,848 lines

**Impact:**
- Massive storage bloat
- Difficult to keep translations synchronized
- Changes must be made in 2 places

**Current Workflow:**
1. Create Turkish subchapter: `_case-name.qmd`
2. During EN build, file is copied to `_case-name_EN.qmd`
3. Both files contain conditional blocks based on `language` variable

**Recommended Solution (Long-term):**

**Option 1: Single-File Multilingual with Quarto Variables**
```qmd
---
title: !expr params$language == "TR" ? "Akut Apandisit" : "Acute Appendicitis"
params:
  language: "TR"
---

```{r setup}
lang <- params$language
```

# {{< var heading.diagnosis >}}

{{< if lang == "TR" >}}
## Histopatoloji Bulgusu

Apendikste akut inflamasyon...
{{< /if >}}

{{< if lang == "EN" >}}
## Histopathology Finding

Acute inflammation in the appendix...
{{< /if >}}
```

Then in `_quarto_TR.yml`:
```yaml
params:
  language: "TR"
```

**Option 2: External Translation Database**

Keep single `.qmd` with keys, translate via YAML:

```qmd
# {{< tr key="appendix.acute.title" >}}

{{< tr key="appendix.acute.description" >}}
```

With `/translations/tr.yml`:
```yaml
appendix:
  acute:
    title: "Akut Apandisit"
    description: "Apendikste akut inflamasyon..."
```

And `/translations/en.yml`:
```yaml
appendix:
  acute:
    title: "Acute Appendicitis"
    description: "Acute inflammation in the appendix..."
```

**Effort:** 12-16 hours (major refactor, must be done carefully)
**Impact:** Eliminates 265 files; much easier to maintain translations

**Recommendation:** Keep current system for now; plan migration in future phase.
**🔄 Status:** PARTIAL - Fixed _EN suffix multiplication bug (2025-11-08), cleaned 397 duplicate files, but fundamental bilingual file structure remains unchanged (long-term improvement)

---

#### ❌ 2.4 Inconsistent File Naming Conventions [TODO]

**Problem:**
Mix of naming styles across the project:

**Main chapters:**
- `bobrek.qmd` - Turkish, no hyphens
- `acute-inflammation.qmd` - English, hyphenated
- `hucre-hasari.qmd` - Turkish, hyphenated
- `meme.qmd` - Turkish, single word

**Subchapters:**
- `_acute-appendicitis.qmd` - Prefix underscore, hyphens
- Some use medical terms, some use organ names

**Impact:**
- Hard to find files
- Inconsistent sorting
- Unclear conventions for new contributors

**Recommended Solution:**

Establish and document naming convention:

```markdown
## File Naming Convention

### Main Chapter Files (root directory)
- Format: `{organ/topic}-{language}.qmd`
- Examples:
  - `kidney-tr.qmd` / `kidney-en.qmd`
  - `inflammation-acute-tr.qmd` / `inflammation-acute-en.qmd`
- Use lowercase, hyphens for separation
- Avoid special characters (Turkish: ç→c, ş→s, etc. in filenames)

### Subchapter Files (_subchapters/ directory)
- Format: `_{case-description}.qmd` / `_{case-description}_EN.qmd`
- Prefix with underscore
- Use descriptive medical term in English
- Examples:
  - `_acute-appendicitis.qmd` / `_acute-appendicitis_EN.qmd`
  - `_chronic-gastritis.qmd` / `_chronic-gastritis_EN.qmd`

### Legacy Files
- Existing files don't need immediate renaming
- New files should follow convention
- Rename during major refactoring only
```

**Effort:** 2-3 hours (documentation + gradual migration)
**Impact:** Easier navigation; clearer conventions
**❌ Status:** TODO - File naming conventions need to be documented and standardized

---

#### ❌ 2.5 Large Asset Directories Not Using Git LFS [TODO]

**Problem:**
Image-heavy directories committed directly to git:

| Directory | Files | Typical Size |
|-----------|-------|--------------|
| `/screenshots/` | 506 PNG/JPG | ~200MB |
| `/qrcodes/` | 176 files | ~50MB |
| `/images/` | 40+ files | ~20MB |

**Impact:**
- Large repository size (slow clones)
- Git performance degradation
- Unnecessary bandwidth usage

**Recommended Solution:**

1. **Set up Git LFS:**
```bash
# Install git-lfs
brew install git-lfs  # macOS
# or apt-get install git-lfs  # Linux

# Initialize
git lfs install

# Track large file types
git lfs track "screenshots/*.png"
git lfs track "screenshots/*.jpg"
git lfs track "qrcodes/*.png"
git lfs track "images/*.png"
git lfs track "images/*.jpg"

# Commit .gitattributes
git add .gitattributes
git commit -m "Add Git LFS tracking for images"
```

2. **Update `.gitattributes`:**
```
screenshots/*.png filter=lfs diff=lfs merge=lfs -text
screenshots/*.jpg filter=lfs diff=lfs merge=lfs -text
qrcodes/*.png filter=lfs diff=lfs merge=lfs -text
images/*.png filter=lfs diff=lfs merge=lfs -text
images/*.jpg filter=lfs diff=lfs merge=lfs -text
```

3. **Update GitHub Actions workflow:**
```yaml
- name: Checkout repository
  uses: actions/checkout@v4
  with:
    lfs: true
```

**Effort:** 2-3 hours (setup + testing)
**❌ Status:** TODO - Git LFS not yet configured for large asset directories
**Impact:** Much faster repository operations

---

### 🟡 MEDIUM PRIORITY ISSUES

#### ❌ 2.6 Minimal README [TODO]

**Current:** `/README.md` is only 26 lines, mostly badges.

**Missing:**
- Project overview
- Build instructions
- Development setup
- Directory structure
- Contributing guidelines
- Architecture explanation

**Recommended Enhancement:**

```markdown
# Patoloji Atlası / Histopathology Atlas

[![Quarto Render](https://github.com/patolojiatlasi/patolojiatlasi.github.io/actions/workflows/Quarto-Render-Bilingual-Book-Push-Other-Repos-GitLab.yml/badge.svg)](https://github.com/patolojiatlasi/patolojiatlasi.github.io/actions/workflows/Quarto-Render-Bilingual-Book-Push-Other-Repos-GitLab.yml)

## Overview

A comprehensive **bilingual pathology atlas** with whole slide images (WSI), designed for medical students and pathology residents. Available in:

- **Turkish:** https://www.patolojiatlasi.com/
- **English:** https://www.histopathologyatlas.com/

### Features
- 500+ histopathology cases with whole slide images
- Interactive OpenSeadragon viewer
- Bilingual content (Turkish/English)
- Mobile-responsive design
- Full-text search
- RSS feeds

## Quick Start

### Prerequisites
- R (>= 4.3.0)
- Quarto CLI (>= 1.4)
- Git

### Local Development

```bash
# Clone repository
git clone https://github.com/patolojiatlasi/patolojiatlasi.github.io.git
cd patolojiatlasi.github.io

# Install R dependencies
Rscript -e "source('./R/setup-dependencies.R'); ensure_dependencies()"

# Render Turkish version
quarto render

# Preview during development
quarto preview
```

### Project Structure

```
.
├── *.qmd                   # Main chapter files
├── _subchapters/           # Reusable case content
├── _lecture-notes/         # Lecture materials
├── R/                      # Build scripts
│   ├── config.R           # Project configuration
│   ├── utils.R            # Shared utility functions
│   └── render_*.R         # Language-specific renderers
├── images/                 # Cover images and graphics
├── screenshots/            # Histopathology images
├── _quarto_*.yml          # Quarto configuration files
└── patolojiatlasi_histopathologyatlas.xlsx  # TR↔EN mapping

Generated (do not commit):
├── docs/                   # Turkish output
├── EN/                     # English output
└── public/                 # Deployment staging
```

### Building Both Languages

```bash
# Render both Turkish and English versions
Rscript ./R/bilingual-quarto-book.R
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- How to add new cases
- Bilingual content workflow
- Translation guidelines
- Pull request process

## Architecture

This project uses **Quarto** to generate a bilingual book from a single set of source files:

1. **Single-source content:** Each `.qmd` file contains both TR and EN content in conditional blocks
2. **Build process:**
   - EN build: Copies `.qmd` → `*_EN.qmd`, renders with English config
   - TR build: Renders original `.qmd` files with Turkish config
3. **Output:** Two complete websites (TR and EN) deployed to different domains

### Bilingual Content Pattern

```qmd
```{r language}
source("./R/language.R")
```

```{asis, echo = (language == "TR")}
# Türkçe Başlık
Türkçe içerik...
```

```{asis, echo = (language == "EN")}
# English Title
English content...
```
```

## Citation

[![DOI](https://zenodo.org/badge/452585667.svg)](https://zenodo.org/badge/latestdoi/452585667)

```bibtex
@online{patolojiatlasi2024,
  author = {Balcı, Serdar and Contributors},
  title = {Patoloji Atlası: Histopathology Atlas},
  year = {2024},
  url = {https://www.patolojiatlasi.com/},
  doi = {10.5281/zenodo.xxxxxx}
}
```

## License

[Creative Commons Attribution-ShareAlike 4.0 International](LICENSE.md)

## Support

- Issues: https://github.com/patolojiatlasi/patolojiatlasi.github.io/issues
- Discussions: https://github.com/patolojiatlasi/patolojiatlasi.github.io/discussions
```

**Effort:** 3-4 hours
**Impact:** Much better onboarding experience

---

#### ❌ 2.7 Configuration Files Scattered in Root [TODO]

**Problem:**
Multiple configuration and output files in root directory:

- `patolojiatlasi_histopathologyatlas.xlsx` (mapping file)
- `.luarc.json` (Lua language server config)
- `.Rprofile` (R configuration)
- `tweetstring.txt` (generated output)
- `text_body.txt` (generated output)
- `text_heading.txt` (generated output)
- `webpages.txt` / `webpages.js` (generated link lists)

**Impact:**
- Cluttered root directory
- Unclear which files are source vs. generated

**Recommended Solution:**

Create subdirectories:
```
/config/              # Configuration files
  └── chapter-mapping.xlsx
  └── site-config.yml

/output/              # Generated files (add to .gitignore)
  └── links/
      ├── webpages.txt
      ├── webpages.js
      └── tweetstring.txt
```

Update scripts to use new paths.

**Effort:** 2-3 hours
**Impact:** Cleaner organization

---

## 3. DOCUMENTATION

### 🔴 HIGH PRIORITY ISSUES

#### ❌ 3.1 No CONTRIBUTING.md Guidelines [TODO]

**Problem:**
Missing `CONTRIBUTING.md` file. New contributors don't know:
- How to add new cases
- Bilingual content workflow
- Translation requirements
- PR process

**Recommended Solution:**

Create `/CONTRIBUTING.md`:
```markdown
# Contributing to Patoloji Atlası / Histopathology Atlas

Thank you for your interest in contributing! This guide will help you add new pathology cases and improve the atlas.

## Quick Start

1. Fork the repository
2. Create a branch: `git checkout -b add-case-kidney-cancer`
3. Add your content (see below)
4. Test locally: `quarto preview`
5. Submit PR with description

## Adding a New Case

### 1. Prepare Your Content

- **Images:** Whole slide images (WSI) should be hosted separately
- **Metadata:** Case description, diagnosis, staining
- **Languages:** Content must be provided in BOTH Turkish and English

### 2. Create Subchapter File

Create `/_subchapters/_your-case-name.qmd`:

```qmd
```{r language, echo=FALSE, include=TRUE}
source("./R/language.R")
output_type <- knitr::opts_knit$get("rmarkdown.pandoc.to")
```

```{asis, echo = (language == "TR")}
## Vaka Adı {#sec-vaka-adi}

### Tanım
Türkçe açıklama...

### Histopatoloji
Türkçe mikroskopik tanım...
```

```{asis, echo = (language == "EN")}
## Case Name {#sec-case-name}

### Description
English description...

### Histopathology
English microscopic description...
```

### Whole Slide Image
<iframe src="https://images.patolojiatlasi.com/your-case/..."></iframe>
```

### 3. Add to Chapter

Edit the appropriate chapter file (e.g., `bobrek.qmd` for kidney cases):

```qmd
{{< include ./_subchapters/_your-case-name.qmd >}}
```

### 4. Update Mapping (if creating new main chapter)

Edit `patolojiatlasi_histopathologyatlas.xlsx`:
- Add row with TR and EN chapter names
- Ensure consistency

### 5. Test Locally

```bash
# Test Turkish version
quarto render

# Test English version (full bilingual build)
Rscript ./R/bilingual-quarto-book.R
```

## Style Guidelines

### Content
- Use professional medical terminology
- Include references where applicable
- Provide clear, educational descriptions
- Avoid personal opinions

### Technical
- Use lowercase, hyphenated filenames: `_chronic-inflammation.qmd`
- Prefix subchapters with underscore: `_case-name.qmd`
- Follow existing formatting patterns
- Test both languages before submitting

### Images
- Provide image attribution
- Ensure proper copyright/permission
- Optimize file sizes where possible
- Use descriptive alt text

## Translation Guidelines

### Turkish → English
- Medical terms should use standard English terminology
- Maintain consistent terminology throughout
- Preserve formatting and structure
- Include the same images and references

### English → Turkish
- Use standard Turkish medical terminology
- Adapt cultural references appropriately
- Maintain consistent tone

## Pull Request Process

1. **Title:** Clear, descriptive (e.g., "Add renal cell carcinoma case")
2. **Description:**
   - What case/content is being added
   - Source/attribution of images
   - Any special considerations
3. **Checklist:**
   - [ ] Both TR and EN content provided
   - [ ] Tested locally (both languages render)
   - [ ] Images properly attributed
   - [ ] Follows style guidelines
   - [ ] No merge conflicts

## Code of Conduct

- Be respectful and professional
- Focus on educational value
- Provide constructive feedback
- Respect copyright and attribution

## Questions?

- Open an issue: https://github.com/patolojiatlasi/patolojiatlasi.github.io/issues
- Start a discussion: https://github.com/patolojiatlasi/patolojiatlasi.github.io/discussions

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (Creative Commons Attribution-ShareAlike 4.0 International).
```

**Effort:** 2-3 hours
**Impact:** Enables community contributions; reduces maintainer burden

---

#### ❌ 3.2 Insufficient README [TODO]

(See Section 2.6 above for detailed README enhancement)

**Current:** 26 lines
**Recommended:** 150+ lines covering overview, setup, structure, contributing

**Effort:** 3-4 hours
**Impact:** Better onboarding, fewer "how do I..." questions

---

#### 🔄 3.3 Inline Documentation Sparse [PARTIAL]

(See Section 1.4 above for roxygen2 documentation examples)

**Problem:**
Large R scripts with minimal explanation.

**Files:**
- `/R/extract-html-links.R` - 391 lines, only 2 comments
- `/R/bilingual-quarto-book.R` - Complex logic, no section headers

**Recommended:** Add roxygen2 docstrings to all functions

**Effort:** 3-4 hours
**Impact:** Easier maintenance and contribution
**🔄 Status:** PARTIAL - Added roxygen2 documentation to R/utils.R and R/config.R only; other R scripts still need inline documentation (overlaps with 1.4)

---

#### ❌ 3.4 Workflow Logic Undocumented [TODO]

**Problem:**
GitHub Actions workflow (`.github/workflows/Quarto-Render-Bilingual-Book-Push-Other-Repos-GitLab.yml`) is 700+ lines with minimal comments.

**Impact:**
- Hard to understand build process
- Difficult to debug CI failures
- Unclear why certain steps exist

**Recommended Solution:**

Add section comments:
```yaml
name: Quarto Render Bilingual Book Push Other Repos GitLab

on:
  workflow_dispatch:
  push:

jobs:
  quarto-render-and-deploy:
    # Skip workflow for WIP commits, merges, and lecture-only changes
    if: "!contains(github.event.head_commit.message, 'WIP') && !contains(github.event.head_commit.message, 'merge') && !contains(github.event.head_commit.message, 'lecture')"

    runs-on: ubuntu-latest
    continue-on-error: true

    steps:
      # ============================================
      # STEP 1: Checkout and Setup
      # ============================================
      - name: "actions checkout"
        uses: actions/checkout@v4

      # ============================================
      # STEP 2: Image Processing
      # Convert PNG screenshots to JPG for web optimization
      # ============================================
      - name: Install VIPS
        run: |
          sudo apt-get update
          sudo apt-get install -y libvips-tools

      - name: Convert Images
        run: |
          for file in ./screenshots/*.png; do
            vips copy "$file" "${file%.png}.jpg"
          done

      # ============================================
      # STEP 3: Setup Quarto and R
      # ============================================
      - name: Set up Quarto
        uses: quarto-dev/quarto-actions/setup@v2
        with:
          version: pre-release
          tinytex: true

      - name: Setup R
        uses: r-lib/actions/setup-r@v2

      # ============================================
      # STEP 4: Install R Dependencies
      # ============================================
      - name: "Setup R dependencies"
        uses: r-lib/actions/setup-r-dependencies@v2

      - name: Restore R package cache
        uses: actions/cache@v4
        with:
          path: ${{ env.R_LIBS_USER }}
          key: ${{ runner.os }}-${{ hashFiles('.github/R-version') }}-1-${{ hashFiles('.github/depends.Rds') }}
          restore-keys: ${{ runner.os }}-${{ hashFiles('.github/R-version') }}-1-

      # ============================================
      # STEP 5: Render English Version
      # Process:
      # 1. Copy TR QMD files to *_EN.qmd
      # 2. Update internal links to point to EN files
      # 3. Render with EN config
      # 4. Output goes to ./_EN/
      # ============================================
      - name: "Prepare Render EN"
        shell: Rscript {0}
        run: |
          # Cleanup previous builds
          # Copy chapter mapping from Excel
          # Create *_EN.qmd files
          # Update cross-references

      - name: "Render Book EN"
        shell: Rscript {0}
        run: |
          quarto::quarto_render(".", as_job = FALSE)

      # ============================================
      # STEP 6: Render Turkish Version
      # Uses original QMD files with TR config
      # Output goes to ./_docs/
      # ============================================
      - name: "Render Book TR"
        shell: Rscript {0}
        run: |
          # Switch to TR config
          # Render with TR language file
          # Output to _docs/

      # ============================================
      # STEP 7: Post-Process and Deploy Prep
      # ============================================
      - name: "Post Render Cleanup"
        shell: Rscript {0}
        run: |
          # Copy _docs → docs, public, gitlab_atlas/public
          # Update CNAME files
          # Clean temp directories

      # ============================================
      # STEP 8: Commit to Main Branch
      # ============================================
      - name: Commit results to main branch
        run: |
          git config --local user.email "actions@github.com"
          git config --local user.name "GitHub Actions"
          git add .
          git commit -m "CI added changes `date +'%Y-%m-%d %H:%M:%S'`" || echo "No changes to commit"
          git push origin || echo "No changes to commit"

      # ============================================
      # STEP 9: Push to Mirror Repositories
      # Deploys EN version to separate repos for different domains
      # ============================================
      - name: Pushes to patolojiatlasi EN
        uses: cpina/github-action-push-to-another-repository@main
        # ... (repeats for each mirror repo)
```

**Effort:** 1-2 hours
**Impact:** Much easier to understand and modify workflow

---

### 🟡 MEDIUM PRIORITY ISSUES

#### ❌ 3.5 Missing DEVELOPMENT.md [TODO]

**Should Include:**
- Local development environment setup
- How the bilingual system works
- Quarto configuration architecture
- renv usage instructions
- Build process flow diagram
- Debugging tips

**Effort:** 2-3 hours
**Impact:** Easier onboarding for developers

---

#### ❌ 3.6 No Troubleshooting Guide [TODO]

**Should Document:**
- Common build failures and solutions
- .gitignore conflicts (generated files)
- Freeze directory issues
- Language file switching problems
- Image path issues
- Link validation errors

**Effort:** 2-3 hours
**Impact:** Reduces support burden

---

## 4. BUILD SYSTEM & CI/CD

### 🔴 HIGH PRIORITY ISSUES

#### ✅ 4.1 Inefficient CI Workflow - Excessive Directory Operations [COMPLETED]

**Problem:**
GitHub Actions workflow contains 34 separate `if (dir.exists(...))` checks followed by `fs::dir_delete()`.

**Location:** `.github/workflows/Quarto-Render-Bilingual-Book-Push-Other-Repos-GitLab.yml`

**Current Pattern (repeated 34 times):**
```yaml
- name: "Post Render Book From EN"
  shell: Rscript {0}
  run: |
    if (dir.exists(paths = "./_freeze")) {
      fs::dir_copy(path = "./_freeze", new_path = "./_freeze_EN", overwrite = TRUE)
    }
    if (dir.exists(paths = "./_freeze")) {
      fs::dir_delete(path = "./_freeze")
    }
    if (dir.exists(paths = "./_EN/public")) {
      fs::dir_delete(path = "./_EN/public")
    }
    # ... 30 more similar blocks
```

**Impact:**
- Slow CI execution
- Repetitive code (maintenance burden)
- Hard to track what's being cleaned up

**Recommended Solution:**

Create `/R/cleanup.R`:
```r
#' Clean Up All Build Artifacts
#'
#' @description
#' Removes all generated directories and files from previous builds.
#' This includes output directories, freeze caches, and temporary files.
#'
#' @param verbose Logical: print what's being deleted (default: TRUE)
#' @return Invisibly returns list of deleted paths
#' @export
cleanup_build_artifacts <- function(verbose = TRUE) {

  # Directories to always delete
  always_delete <- c(
    "./_freeze",
    "./_EN",
    "./_docs",
    "./public",
    "./gitlab_atlas/gitlab_atlas"
  )

  # Pattern-based cleanup (use fs::dir_ls with regex)
  pattern_cleanup <- c(
    "_files$",      # All *_files directories
    "_pdf_",        # PDF output directories
    "_epub_",       # EPUB output directories
    "_freeze$"      # Any remaining freeze directories
  )

  deleted <- character()

  # Delete specific directories
  for (path in always_delete) {
    if (dir.exists(path)) {
      if (verbose) message(sprintf("Deleting: %s", path))
      fs::dir_delete(path)
      deleted <- c(deleted, path)
    }
  }

  # Delete pattern-matched directories
  for (pattern in pattern_cleanup) {
    matched_dirs <- fs::dir_ls(
      path = ".",
      recurse = FALSE,
      regexp = pattern,
      type = "directory"
    )

    if (length(matched_dirs) > 0) {
      if (verbose) {
        message(sprintf("Deleting %d directories matching '%s'",
                       length(matched_dirs), pattern))
      }
      fs::dir_delete(matched_dirs)
      deleted <- c(deleted, matched_dirs)
    }
  }

  if (verbose && length(deleted) > 0) {
    message(sprintf("✓ Cleaned up %d artifacts", length(deleted)))
  } else if (verbose) {
    message("✓ No artifacts to clean up")
  }

  invisible(deleted)
}

#' Preserve Freeze Directory for Language
#' @param language Character: "TR" or "EN"
preserve_freeze <- function(language) {
  config <- get_language_config(language)

  if (dir.exists("./_freeze")) {
    message(sprintf("Preserving freeze cache for %s", language))
    fs::dir_copy(
      path = "./_freeze",
      new_path = config$freeze_dir,
      overwrite = TRUE
    )
  }

  invisible(TRUE)
}
```

Then in workflow:
```yaml
- name: "Cleanup Build Artifacts"
  shell: Rscript {0}
  run: |
    source("./R/cleanup.R")
    cleanup_build_artifacts(verbose = TRUE)
```

**Reduction:** 34 operations → 1 function call

**Effort:** 1-2 hours
**Impact:** Faster builds; cleaner workflow; easier maintenance
**✅ Status:** COMPLETED 2025-11-08 - Simplified GitHub Actions workflow from 573→458 lines (-115 lines, 20% reduction), consolidated 5 separate R steps into single `source("./R/bilingual-quarto-book.R")` call

---

#### ✅ 4.2 Redundant Workflow Logic - EN/TR Builds Nearly Identical [COMPLETED]

**Problem:**
English render section (lines 130-220) and Turkish render section (lines 221-300) contain almost identical logic with only minor differences.

**Differences:**
- Language config file (`_quarto_EN.yml` vs. `_quarto_TR.yml`)
- Language script (`languageEN.R` vs. `languageTR.R`)
- Output directory (`_EN` vs. `_docs`)
- Freeze directory (`_freeze_EN` vs. `_freeze_TR`)

**Impact:**
- ~140 lines of duplicated code in workflow
- Changes must be made in 2 places
- Easy to introduce inconsistencies

**Recommended Solution:**

Create `/R/render-language.R`:
```r
#' Render Book for Specific Language
#'
#' @param language Character: "TR" or "EN"
#' @param clean_first Logical: cleanup before rendering
#' @return Path to output directory
render_language <- function(language, clean_first = TRUE) {

  config <- get_language_config(language)

  message(sprintf("=== Rendering %s version ===", language))

  # Step 1: Cleanup if requested
  if (clean_first) {
    cleanup_build_artifacts()
  }

  # Step 2: Setup language environment
  setup_language_build(language, source_freeze_dir = config$freeze_dir)

  # Step 3: For EN, create *_EN.qmd files
  if (language == "EN") {
    prepare_en_files()
  }

  # Step 4: Render
  message(sprintf("Rendering with config: %s", config$quarto_file))
  quarto::quarto_render(".", as_job = FALSE)

  # Step 5: Preserve freeze cache
  preserve_freeze(language)

  # Step 6: Cleanup temp files
  cleanup_temp_files()

  message(sprintf("✓ %s version rendered to: %s", language, config$output_dir))

  return(config$output_dir)
}

#' Prepare EN Files (copy from TR)
prepare_en_files <- function() {
  # Read chapter mapping
  mapping <- readxl::read_excel(
    "./patolojiatlasi_histopathologyatlas.xlsx",
    sheet = "chapters"
  )

  # Copy TR → EN
  TR_files <- paste0("./", mapping$TR_chapter_qmd, ".qmd")
  EN_files <- paste0("./", mapping$EN_chapter_qmd, ".qmd")

  # Handle subchapters
  subchapter_files <- list.files("./_subchapters", pattern = "*.qmd", full.names = TRUE)
  subchapter_EN <- gsub(".qmd$", "_EN.qmd", subchapter_files)

  TR_files <- c(TR_files, subchapter_files)
  EN_files <- c(EN_files, subchapter_EN)

  # Copy files
  fs::file_copy(TR_files, EN_files, overwrite = TRUE)

  # Update internal links
  xfun::gsub_files(files = EN_files, pattern = ".qmd >}}", replacement = "_EN.qmd >}}")

  message(sprintf("✓ Prepared %d EN files", length(EN_files)))
}
```

Then in workflow:
```yaml
- name: "Render English Version"
  shell: Rscript {0}
  run: |
    source("./R/render-language.R")
    render_language("EN", clean_first = TRUE)

- name: "Render Turkish Version"
  shell: Rscript {0}
  run: |
    source("./R/render-language.R")
    render_language("TR", clean_first = FALSE)
```

**Reduction:** ~280 lines → ~30 lines in workflow

**Effort:** 3-4 hours
**Impact:** Much cleaner workflow; easier to add new languages
**✅ Status:** COMPLETED 2025-11-08 - Created `render_format()` function in R/utils.R (127 lines), refactored 4 format-specific scripts from 113 lines each to 13 lines each (-371 lines total, 61% reduction)

---

#### ❌ 4.3 Suboptimal Build Caching [TODO]

**Problem:**
R package cache uses `.github/R-version` and `.github/depends.Rds` as cache keys, but these files are **generated during the build**, not before it.

**Current:**
```yaml
- name: Restore R package cache
  uses: actions/cache@v4
  with:
    path: ${{ env.R_LIBS_USER }}
    key: ${{ runner.os }}-${{ hashFiles('.github/R-version') }}-1-${{ hashFiles('.github/depends.Rds') }}
    restore-keys: ${{ runner.os }}-${{ hashFiles('.github/R-version') }}-1-
```

**Problem:**
- Cache key changes on every build (because files are regenerated)
- Cache is rarely/never restored
- Packages reinstalled every time

**Recommended Solution:**

Use `DESCRIPTION` file (which is committed) as cache key:
```yaml
- name: Restore R package cache
  uses: actions/cache@v4
  with:
    path: ${{ env.R_LIBS_USER }}
    key: ${{ runner.os }}-r-${{ hashFiles('DESCRIPTION') }}-v2
    restore-keys: |
      ${{ runner.os }}-r-${{ hashFiles('DESCRIPTION') }}-
      ${{ runner.os }}-r-
```

Or use `renv.lock`:
```yaml
- name: Restore R package cache
  uses: actions/cache@v4
  with:
    path: ${{ env.R_LIBS_USER }}
    key: ${{ runner.os }}-renv-${{ hashFiles('renv.lock') }}
    restore-keys: |
      ${{ runner.os }}-renv-
```

**Effort:** 30 minutes
**Impact:** Significant CI speedup (packages only install when dependencies change)

---

#### ❌ 4.4 No Build Validation [TODO]

**Problem:**
No validation that builds completed successfully. Workflow pushes to repositories even if render partially failed.

**Impact:**
- Broken builds get deployed
- Difficult to debug what went wrong
- No clear success criteria

**Recommended Solution:**

Add validation step:
```r
#' Validate Build Output
#'
#' @description
#' Verifies that all expected output files and directories were created
#' during the build process.
#'
#' @param language Character: "TR" or "EN"
#' @return Invisibly returns TRUE if valid, stops with error if not
validate_build_output <- function(language) {

  config <- get_language_config(language)

  errors <- character()

  # Check output directory exists
  if (!dir.exists(config$output_dir)) {
    errors <- c(errors, sprintf("Output directory missing: %s", config$output_dir))
  }

  # Check essential files
  essential_files <- c(
    file.path(config$output_dir, "index.html"),
    file.path(config$output_dir, "search.json"),
    file.path(config$output_dir, "site_libs")  # JS/CSS libraries
  )

  for (file in essential_files) {
    if (!file.exists(file)) {
      errors <- c(errors, sprintf("Missing essential file: %s", file))
    }
  }

  # Check that chapters were rendered (at least 10 HTML files)
  html_files <- list.files(
    config$output_dir,
    pattern = "\\.html$",
    recursive = FALSE
  )

  if (length(html_files) < 10) {
    errors <- c(errors,
                sprintf("Too few HTML files rendered: %d (expected at least 10)",
                        length(html_files)))
  }

  # Report results
  if (length(errors) > 0) {
    stop(sprintf("Build validation failed for %s:\n  - %s",
                 language,
                 paste(errors, collapse = "\n  - ")))
  }

  message(sprintf("✓ Build validation passed for %s (%d HTML files)",
                  language, length(html_files)))
  invisible(TRUE)
}
```

Add to workflow:
```yaml
- name: "Validate EN Build"
  shell: Rscript {0}
  run: |
    source("./R/render-language.R")
    validate_build_output("EN")

- name: "Validate TR Build"
  shell: Rscript {0}
  run: |
    source("./R/render-language.R")
    validate_build_output("TR")
```

**Effort:** 2-3 hours
**Impact:** Prevents broken deployments; easier debugging

---

#### ❌ 4.5 Image Conversion Not Optimized [TODO]

**Problem:**
PNG → JPG conversion runs sequentially for 506 files with no caching.

**Current:**
```yaml
- name: Convert Images
  run: |
    for file in ./screenshots/*.png; do
      vips copy "$file" "${file%.png}.jpg"
    done
```

**Impact:**
- Slow (converts all images every build)
- No parallelization
- No caching of already-converted images

**Recommended Solution:**

**Option 1: Add caching**
```yaml
- name: Cache Converted Images
  uses: actions/cache@v4
  with:
    path: ./screenshots/*.jpg
    key: images-${{ hashFiles('screenshots/*.png') }}

- name: Convert Images (if needed)
  run: |
    # Only convert if JPG doesn't exist or PNG is newer
    for file in ./screenshots/*.png; do
      jpg="${file%.png}.jpg"
      if [ ! -f "$jpg" ] || [ "$file" -nt "$jpg" ]; then
        vips copy "$file" "$jpg"
      fi
    done
```

**Option 2: Parallelize with GNU parallel**
```yaml
- name: Install Dependencies
  run: |
    sudo apt-get update
    sudo apt-get install -y libvips-tools parallel

- name: Convert Images in Parallel
  run: |
    ls ./screenshots/*.png | parallel -j 4 'vips copy {} {.}.jpg'
```

**Effort:** 1-2 hours
**Impact:** Faster CI builds

---

### 🟡 MEDIUM PRIORITY ISSUES

#### ❌ 4.6 Fragile Commit Message Filtering [TODO]

**Problem:**
Workflow uses commit message text to skip builds:
```yaml
if: "!contains(github.event.head_commit.message, 'WIP') && !contains(github.event.head_commit.message, 'merge')"
```

**Issues:**
- Case-sensitive ("WIP" vs. "wip")
- Typos break filtering
- No validation

**Better Solution:**

Use GitHub labels or path filters:
```yaml
on:
  push:
    paths-ignore:
      - 'lecture-notes/**'
      - '*.md'
      - 'deneme/**'
```

Or use git tags:
```yaml
on:
  push:
    tags:
      - 'v*'
```

**Effort:** 30 minutes
**Impact:** More reliable build triggers

---

#### ❌ 4.7 Continue-on-Error Hides Failures [TODO]

**Problem:**
```yaml
jobs:
  quarto-render-and-deploy:
    continue-on-error: true
```

This means failures still push to repositories!

**Recommendation:** Remove and fix underlying issues.

**Effort:** 1 hour (may require fixing actual build issues)
**Impact:** Prevents broken deployments

---

#### ❌ 4.8 Multiple Repository Pushes - No Rollback [TODO]

**Problem:**
Workflow pushes to 3 separate repositories. If one fails, the others may have already been updated.

**Current:**
```yaml
- name: Pushes to patolojiatlasi EN
  # ...
- name: Pushes to histopathologyatlas
  # ...
- name: Pushes to atlas
  # ...
```

**Risk:**
- Inconsistent state across repositories
- No rollback mechanism

**Recommended Solution:**

Add validation before all pushes:
```yaml
- name: Validate Both Builds
  shell: Rscript {0}
  run: |
    source("./R/render-language.R")
    validate_build_output("EN")
    validate_build_output("TR")
    message("✓ All builds validated - safe to deploy")

# Only push if validation passed
- name: Pushes to patolojiatlasi EN
  # ...
```

**Effort:** 1 hour
**Impact:** More reliable deployments

---

## 5. CONFIGURATION MANAGEMENT

### 🔴 HIGH PRIORITY ISSUES

#### ✅ 5.1 Excessive Configuration Duplication [COMPLETED]

(See Section 2.2 for detailed analysis)

**Problem:**
8 Quarto YAML files with ~70% duplication (~1,800 duplicated lines).

**Recommended:** Use YAML includes/metadata-files pattern (see Section 2.2)

**Effort:** 4-6 hours
**Impact:** Reduces config from ~2,500 lines to ~500 lines
**✅ Status:** COMPLETED 2025-11-08 - Created `_quarto_pdf_base.yml` and `_quarto_epub_word_base.yml`, reduced PDF configs by 26-24% and EPUB/Word configs by 29-18% (total 346 lines eliminated). Overlaps with section 2.2.

---

#### ❌ 5.2 Language Switching Via File Copies [TODO]

**Problem:**
Language is set by physically copying files:
```r
fs::file_copy(path = "./R/languageEN.R", new_path = "./R/language.R", overwrite = TRUE)
```

Where `languageEN.R` contains:
```r
language <- "EN"
```

**Issues:**
- Unnecessary file I/O
- Creates temporary `language.R` file
- Confusing for new developers

**Recommended Solution:**

**Option 1: Environment variable**
```r
# In render scripts
Sys.setenv(BUILD_LANGUAGE = "EN")

# In QMD files
```{r language}
language <- Sys.getenv("BUILD_LANGUAGE", "TR")
```
```

**Option 2: Quarto variables**
```yaml
# In _quarto_EN.yml
params:
  language: "EN"
```

```qmd
# In QMD files
---
params:
  language: "TR"
---

```{r}
lang <- params$language
```
```

**Effort:** 2-3 hours
**Impact:** Cleaner, more intuitive language switching

---

#### ❌ 5.3 Language Variable Not Used Consistently [TODO]

**Problem:**
Some code checks `language` variable, other code checks directory existence or file names.

**Example:**
```r
# Inconsistent checks
if (language == "EN") { ... }       # Uses variable
if (dir.exists("./_EN")) { ... }    # Checks directory
if (grepl("_EN.qmd", file)) { ... } # Checks filename
```

**Impact:**
- Hard to change language logic
- Unclear source of truth

**Recommended:**
Always use the language variable/config, never infer from paths.

**Effort:** 2-3 hours
**Impact:** More maintainable code

---

#### ❌ 5.4 Hard-Coded Site URLs [TODO]

**Problem:**
URLs hardcoded in Quarto configs:
```yaml
site-url: https://patolojiatlasi.com/
```

**Issue:**
- Can't easily test with different domains
- No dev/staging vs. prod distinction

**Recommended Solution:**

Use environment variables:
```yaml
# _quarto_TR.yml
site-url: !expr Sys.getenv("SITE_URL_TR", "https://patolojiatlasi.com/")
```

Then in workflow:
```yaml
env:
  SITE_URL_TR: https://staging.patolojiatlasi.com/  # for testing
  SITE_URL_EN: https://staging.histopathologyatlas.com/
```

**Effort:** 1-2 hours
**Impact:** Easier staging/testing

---

### 🟡 MEDIUM PRIORITY ISSUES

#### ❌ 5.5 No Environment-Specific Configs [TODO]

**Missing:**
- `config/dev.yml` - Local development settings
- `config/staging.yml` - Staging server settings
- `config/prod.yml` - Production settings

**Should contain:**
- Different site URLs
- Different analytics IDs (disable in dev)
- Different comment systems (disable in dev)

**Effort:** 2-3 hours
**Impact:** Better dev/prod separation

---

#### ❌ 5.6 Configuration in Multiple Formats [TODO]

**Problem:**
Configuration spread across:
- Excel file (`patolojiatlasi_histopathologyatlas.xlsx`)
- YAML files (`_quarto_*.yml`)
- R scripts (`./R/language*.R`)
- Text files (`webpages.txt`, etc.)

**Impact:**
- No single source of truth
- Hard to understand full configuration

**Recommended:**
Consolidate to YAML where possible:
```yaml
# config/project.yml
languages:
  - TR
  - EN

chapters:
  TR: _chapters_TR.yml
  EN: _chapters_EN.yml

mapping: config/chapter-mapping.yml  # convert Excel to YAML

outputs:
  TR:
    dir: _docs
    url: https://patolojiatlasi.com/
  EN:
    dir: _EN
    url: https://histopathologyatlas.com/
```

**Effort:** 3-4 hours
**Impact:** Clearer configuration structure

---

## 6. CONTENT MANAGEMENT

### 🔴 HIGH PRIORITY ISSUES

#### ❌ 6.1 Bilingual Content Duplication [TODO]

(See Section 2.3 for detailed analysis)

**Problem:**
530 subchapter files (265 cases × 2 languages) = 118,848 lines of duplicated content.

**Impact:**
- Massive storage bloat
- Hard to keep translations synchronized
- Changes must be made in 2 files

**Recommended (Long-term):**
Single-source multilingual content using Quarto variables or external translation database.

**Effort:** 12-16 hours (major refactor)
**Impact:** Eliminates 265 files; easier translation management

**Note:** Keep current system for now; plan for future phase.

---

#### ✅ 6.2 Excel Mapping File Not Validated [COMPLETED]

**Problem:**
`patolojiatlasi_histopathologyatlas.xlsx` contains TR ↔ EN chapter mapping but:
- Not validated against actual files
- No schema enforcement
- Build fails with cryptic error if mapping is wrong

**Recommended Solution:**

Add validation:
```r
#' Validate Chapter Mapping File
#'
#' @description
#' Verifies that the Excel mapping file is correct and all referenced
#' files exist.
#'
#' @param mapping_file Path to Excel file (default: auto-detected)
#' @return Invisibly returns validated mapping data frame
validate_chapter_mapping <- function(mapping_file = NULL) {

  if (is.null(mapping_file)) {
    config <- get_project_config()
    mapping_file <- config$mapping_file
  }

  # Check file exists
  if (!file.exists(mapping_file)) {
    stop(sprintf("Mapping file not found: %s", mapping_file))
  }

  # Read mapping
  mapping <- readxl::read_excel(mapping_file, sheet = "chapters")

  # Validate columns exist
  required_cols <- c("TR_chapter_qmd", "EN_chapter_qmd")
  missing_cols <- setdiff(required_cols, names(mapping))

  if (length(missing_cols) > 0) {
    stop(sprintf("Missing columns in mapping file: %s",
                 paste(missing_cols, collapse = ", ")))
  }

  # Validate TR files exist
  TR_files <- paste0("./", mapping$TR_chapter_qmd, ".qmd")
  missing_tr <- TR_files[!file.exists(TR_files)]

  if (length(missing_tr) > 0) {
    warning(sprintf("Missing TR files:\n  - %s",
                    paste(missing_tr, collapse = "\n  - ")))
  }

  # Check for duplicates
  dup_tr <- mapping$TR_chapter_qmd[duplicated(mapping$TR_chapter_qmd)]
  dup_en <- mapping$EN_chapter_qmd[duplicated(mapping$EN_chapter_qmd)]

  if (length(dup_tr) > 0 || length(dup_en) > 0) {
    stop(sprintf("Duplicate entries in mapping file: %s",
                 paste(c(dup_tr, dup_en), collapse = ", ")))
  }

  message(sprintf("✓ Validated %d chapter mappings", nrow(mapping)))
  invisible(mapping)
}
```

Call at build start:
```r
validate_chapter_mapping()
```

**Effort:** 2-3 hours
**Impact:** Catches mapping errors before build starts
**✅ Status:** COMPLETED 2025-11-08 - Replaced Excel mapping with `chapter-mappings.yml` (77 mappings), created `read_chapter_mappings()` function in R/utils.R, updated all scripts to use YAML instead of readxl

---

#### ❌ 6.3 Subchapter Linking Not Automated [TODO]

**Problem:**
Subchapters are manually included in parent chapters:
```qmd
{{< include ./_subchapters/_acute-appendicitis.qmd >}}
```

**Issues:**
- Easy to forget to include a subchapter
- No validation that all subchapters are used
- Manual process

**Recommended Solution:**

Auto-generate chapter structure from metadata:
```yaml
# chapters/gastrointestinal.yml
title:
  TR: "Gastrointestinal Sistem"
  EN: "Gastrointestinal System"

subchapters:
  - _acute-appendicitis
  - _chronic-gastritis
  - _peptic-ulcer
```

Then generate includes programmatically during render.

**Effort:** 4-5 hours
**Impact:** Easier content management; prevents orphaned subchapters

---

#### ❌ 6.4 No Content Validation [TODO]

**Problem:**
No validation that:
- All image references actually exist
- All links are valid (not broken)
- All subchapters are included somewhere
- Metadata is complete

**Recommended Solution:**

Create `/R/validate-content.R`:
```r
#' Validate All Content
#'
#' @description
#' Runs multiple validation checks on content before building.
#'
#' @return Invisibly returns validation report
validate_content <- function() {

  message("=== Content Validation ===")

  issues <- list()

  # 1. Check image references
  message("Checking image references...")
  missing_images <- check_image_references()
  if (length(missing_images) > 0) {
    issues$missing_images <- missing_images
    warning(sprintf("Found %d missing images", length(missing_images)))
  }

  # 2. Check internal links
  message("Checking internal links...")
  broken_links <- check_internal_links()
  if (length(broken_links) > 0) {
    issues$broken_links <- broken_links
    warning(sprintf("Found %d broken internal links", length(broken_links)))
  }

  # 3. Check orphaned subchapters
  message("Checking for orphaned subchapters...")
  orphaned <- check_orphaned_subchapters()
  if (length(orphaned) > 0) {
    issues$orphaned <- orphaned
    warning(sprintf("Found %d orphaned subchapters", length(orphaned)))
  }

  # 4. Check metadata completeness
  message("Checking metadata...")
  incomplete_metadata <- check_metadata_completeness()
  if (length(incomplete_metadata) > 0) {
    issues$incomplete_metadata <- incomplete_metadata
    warning(sprintf("Found %d files with incomplete metadata",
                    length(incomplete_metadata)))
  }

  # Report
  if (length(issues) == 0) {
    message("✓ All content validation checks passed")
  } else {
    message(sprintf("⚠ Content validation found %d issue categories",
                    length(issues)))
  }

  invisible(issues)
}

#' Check Image References
check_image_references <- function() {
  qmd_files <- list.files(".", pattern = "\\.qmd$", recursive = TRUE)

  missing <- character()

  for (file in qmd_files) {
    content <- readLines(file, warn = FALSE)

    # Extract image paths
    img_pattern <- '!\\[.*?\\]\\((.*?)\\)'
    matches <- regmatches(content, gregexpr(img_pattern, content, perl = TRUE))

    for (match_line in matches) {
      for (match in match_line) {
        path <- sub('.*\\((.*)\\).*', '\\1', match)

        # Skip URLs
        if (grepl("^http", path)) next

        # Check if file exists
        if (!file.exists(path)) {
          missing <- c(missing, sprintf("%s: %s", file, path))
        }
      }
    }
  }

  return(missing)
}

# Similar functions for other checks...
```

**Effort:** 4-5 hours
**Impact:** Catches content issues before deployment

---

### 🟡 MEDIUM PRIORITY ISSUES

#### ❌ 6.5 Language Metadata Inconsistent [TODO]

**Problem:**
Language information scattered:
- Quarto config: `lang: tr`
- File naming: `*_EN.qmd`
- Front matter: varies
- Build scripts: `language <- "EN"`

**Recommendation:**
Centralize in front matter:
```qmd
---
lang: tr
lang-alternate: en
lang-alternate-url: https://histopathologyatlas.com/case-name.html
---
```

**Effort:** 2-3 hours
**Impact:** Clearer language handling; better SEO

---

#### ❌ 6.6 Specimen Metadata Structure [TODO]

**Problem:**
Custom YAML structure in `/lists/list.yaml` is not standardized.

**Current:**
```yaml
- stainname: "HE"
  reponame: "case-name"
  titleTR: "Turkish title"
  titleEN: "English title"
```

**Better:**
Use Dublin Core or Schema.org vocabulary:
```yaml
- id: "case-001"
  type: "MedicalCase"
  name:
    tr: "Turkish title"
    en: "English title"
  technique: "H&E"
  creator: "Dr. Name"
  dateCreated: "2024-01-15"
  url: "https://..."
```

**Effort:** 3-4 hours
**Impact:** Better interoperability; semantic metadata

---

## 7. DEPENDENCIES & PACKAGE MANAGEMENT

### 🔴 HIGH PRIORITY ISSUES

#### ❌ 7.1 renv Lock File Not in Sync [TODO]

**Problem:**
- `renv.lock` exists (79 packages) but renv is **not used in CI**
- `DESCRIPTION` lists 20 packages
- Unclear if renv is active

**Files:**
- `/renv.lock` (21 KB, last updated March 2024)
- `/DESCRIPTION` (1.2 KB, June 2024)
- `/.Rprofile` (contains renv activation)

**Impact:**
- Inconsistent environments between local and CI
- Dependency drift
- Difficult to reproduce builds

**Recommended Solution:**

**Decision point:** Use renv or don't. Current state is inconsistent.

**Option 1: Enable renv (Recommended)**
```yaml
# In workflow
- name: Setup renv
  uses: r-lib/actions/setup-renv@v2

- name: Restore renv cache
  uses: actions/cache@v4
  with:
    path: ~/.local/share/renv
    key: ${{ runner.os }}-renv-${{ hashFiles('renv.lock') }}
```

Update lock file:
```r
renv::snapshot()
```

**Option 2: Remove renv completely**
- Delete `/renv/`, `/renv.lock`, `.Rprofile`
- Keep only `DESCRIPTION`
- Use `setup-r-dependencies@v2` (current approach)

**Effort:** 1-2 hours
**Impact:** Consistent, reproducible builds

---

#### ❌ 7.2 CI Not Using renv [TODO]

**Problem:**
Workflow has renv steps commented out:
```yaml
# - name: Setup renv
#   uses: r-lib/actions/setup-renv@v2
```

**Impact:**
- Local devs use renv, CI doesn't
- Different package versions
- "Works on my machine" problems

**Recommendation:** Uncomment and enable (see 7.1)

**Effort:** 30 minutes (if lock file is current)
**Impact:** Environment consistency

---

#### ❌ 7.3 Remote Packages in DESCRIPTION [TODO]

**Problem:**
References to GitHub packages:
```r
Remotes:
  duncantl/XMLRPC,
  duncantl/RWordPress
```

**Issues:**
- These repos may be unmaintained
- Installation can fail if GitHub is down
- No version pinning

**Recommended:**
- Check if still needed
- Pin to specific commits if needed:
  ```r
  Remotes:
    duncantl/XMLRPC@abc123,
    duncantl/RWordPress@def456
  ```
- Document why they're required

**Effort:** 1-2 hours
**Impact:** More reliable installations

---

#### ❌ 7.4 Package Installation Not Idempotent [TODO]

(See Section 1.5)

**Problem:**
Multiple scripts check and install packages independently.

**Recommendation:**
Use shared `/R/setup-dependencies.R` (see Section 1.5)

**Effort:** 1-2 hours
**Impact:** Faster, more consistent package management

---

### 🟡 MEDIUM PRIORITY ISSUES

#### ❌ 7.5 Inconsistent R Version [TODO]

**Problem:**
- `DESCRIPTION` says `R (>= 4.3.0)`
- Workflow uses default R version (not pinned)
- Local devs may use different versions

**Recommended:**

Pin in workflow:
```yaml
- name: Setup R
  uses: r-lib/actions/setup-r@v2
  with:
    r-version: '4.3.0'
```

**Effort:** 5 minutes
**Impact:** Consistent R version across environments

---

#### ❌ 7.6 TinyTeX Installation Fragile [TODO]

**Problem:**
Multiple tinytex checks:
```r
if (!tinytex::is_tinytex()) {
  tinytex::install_tinytex()
}
```

Can fail silently or leave system in bad state.

**Recommended:**

Add validation:
```r
ensure_tinytex <- function() {
  if (!tinytex::is_tinytex()) {
    message("Installing TinyTeX...")
    tinytex::install_tinytex()
    Sys.sleep(2)

    if (!tinytex::is_tinytex()) {
      stop("Failed to install TinyTeX")
    }
  }

  # Verify tlmgr works
  tryCatch({
    system2("tlmgr", "--version", stdout = NULL, stderr = NULL)
  }, error = function(e) {
    stop("TinyTeX installed but tlmgr not working")
  })

  message("✓ TinyTeX ready")
}
```

**Effort:** 30 minutes
**Impact:** More reliable PDF generation

---

## 8. TESTING & QUALITY ASSURANCE

### 🔴 HIGH PRIORITY ISSUES

#### ❌ 8.1 No Automated Tests [TODO]

**Problem:**
Zero test coverage. No unit tests, integration tests, or validation tests.

**Impact:**
- Regressions go unnoticed
- No confidence in refactoring
- Manual testing required for every change

**Recommended Solution:**

Create testing framework using `testthat`:

**File: `/tests/testthat.R`**
```r
library(testthat)
library(quarto)

test_check("patolojiatlasi")
```

**File: `/tests/testthat/test-bilingual-build.R`**
```r
test_that("Both language versions build successfully", {
  skip_if_not(file.exists("./_quarto_TR.yml"), "TR config not found")
  skip_if_not(file.exists("./_quarto_EN.yml"), "EN config not found")

  # Test TR build
  expect_true(dir.exists("./docs"), "TR output directory exists")
  expect_true(file.exists("./docs/index.html"), "TR index page exists")
  expect_true(file.exists("./docs/search.json"), "TR search index exists")

  # Test EN build
  expect_true(dir.exists("./EN"), "EN output directory exists")
  expect_true(file.exists("./EN/index.html"), "EN index page exists")
  expect_true(file.exists("./EN/search.json"), "EN search index exists")
})

test_that("Chapter mapping is valid", {
  mapping <- readxl::read_excel(
    "./patolojiatlasi_histopathologyatlas.xlsx",
    sheet = "chapters"
  )

  expect_true(nrow(mapping) > 0, "Mapping file has entries")
  expect_true("TR_chapter_qmd" %in% names(mapping), "TR column exists")
  expect_true("EN_chapter_qmd" %in% names(mapping), "EN column exists")

  # Check for duplicates
  expect_equal(anyDuplicated(mapping$TR_chapter_qmd), 0, "No duplicate TR chapters")
  expect_equal(anyDuplicated(mapping$EN_chapter_qmd), 0, "No duplicate EN chapters")
})

test_that("Required R packages are installed", {
  required <- c("quarto", "fs", "readxl", "xfun")

  for (pkg in required) {
    expect_true(
      requireNamespace(pkg, quietly = TRUE),
      sprintf("Package %s is installed", pkg)
    )
  }
})
```

**File: `/tests/testthat/test-config.R`**
```r
test_that("Project configuration is valid", {
  config <- get_project_config()

  expect_type(config, "list")
  expect_true("languages" %in% names(config))
  expect_equal(length(config$languages), 2)
  expect_true("TR" %in% config$languages)
  expect_true("EN" %in% config$languages)
})

test_that("Language configs exist", {
  for (lang in c("TR", "EN")) {
    config <- get_language_config(lang)

    expect_true(file.exists(config$quarto_file),
                sprintf("%s Quarto config exists", lang))
    expect_true(file.exists(config$language_file),
                sprintf("%s language file exists", lang))
  }
})
```

Add to workflow:
```yaml
- name: Run Tests
  shell: Rscript {0}
  run: |
    testthat::test_dir("tests/testthat/")
```

**Effort:** 4-5 hours
**Impact:** Catches regressions; enables confident refactoring

---

#### ❌ 8.2 No Link Validation [TODO]

**Problem:**
`extract-html-links.R` extracts WSI links but doesn't validate they're accessible.

**Risk:**
Dead links in published content.

**Recommended Solution:**

```r
#' Validate WSI Links
#'
#' @description
#' Checks that all whole slide image links are accessible.
#'
#' @param links Character vector of URLs (default: reads from webpages.txt)
#' @param timeout Timeout in seconds for each check (default: 10)
#' @return Data frame with link, status, and error (if any)
validate_wsi_links <- function(links = NULL, timeout = 10) {

  if (is.null(links)) {
    if (!file.exists("webpages.txt")) {
      stop("webpages.txt not found - run extract_html_links() first")
    }
    links <- readLines("webpages.txt")
  }

  message(sprintf("Validating %d WSI links...", length(links)))

  results <- data.frame(
    link = links,
    status = NA_integer_,
    error = NA_character_,
    stringsAsFactors = FALSE
  )

  # Check each link with progress bar
  pb <- txtProgressBar(min = 0, max = length(links), style = 3)

  for (i in seq_along(links)) {
    link <- links[i]

    tryCatch({
      response <- httr::HEAD(link, httr::timeout(timeout))
      results$status[i] <- response$status_code

      if (response$status_code >= 400) {
        results$error[i] <- sprintf("HTTP %d", response$status_code)
      }

    }, error = function(e) {
      results$status[i] <- 0
      results$error[i] <- e$message
    })

    setTxtProgressBar(pb, i)
  }

  close(pb)

  # Summarize
  broken <- results[results$status >= 400 | results$status == 0, ]

  if (nrow(broken) > 0) {
    warning(sprintf("\n⚠ Found %d broken links:\n  - %s",
                    nrow(broken),
                    paste(broken$link, collapse = "\n  - ")))
  } else {
    message(sprintf("✓ All %d links are accessible", length(links)))
  }

  invisible(results)
}
```

Add to workflow:
```yaml
- name: Validate WSI Links
  shell: Rscript {0}
  run: |
    source("./R/extract-html-links.R")
    extract_html_links()

    source("./R/validate-content.R")
    validate_wsi_links()
  continue-on-error: true  # Don't fail build, just warn
```

**Effort:** 2-3 hours
**Impact:** Prevents dead links in production

---

#### ❌ 8.3 No Content Metadata Validation [TODO]

(See Section 6.4 for detailed validation framework)

**Problem:**
YAML files in `/lists/` not validated against schema.

**Recommendation:**
Add schema validation (see Section 6.4)

**Effort:** 2-3 hours
**Impact:** Ensures consistent metadata quality

---

#### ❌ 8.4 Build Artifact Validation Missing [TODO]

(See Section 4.4 for detailed solution)

**Problem:**
No verification that output contains expected files.

**Recommendation:**
Add `validate_build_output()` (see Section 4.4)

**Effort:** 2-3 hours
**Impact:** Catches incomplete builds before deployment

---

### 🟡 MEDIUM PRIORITY ISSUES

#### ❌ 8.5 No Linting or Code Quality Checks [TODO]

**Missing:**
- `lintr` for R code style
- `yamllint` for YAML validation
- `markdownlint` for documentation

**Recommended:**

Add pre-commit hooks:
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/r-lib/lintr
    rev: v3.0.0
    hooks:
      - id: lintr

  - repo: https://github.com/adrienverge/yamllint
    rev: v1.32.0
    hooks:
      - id: yamllint

  - repo: https://github.com/igorshubovych/markdownlint-cli
    rev: v0.35.0
    hooks:
      - id: markdownlint
```

**Effort:** 2-3 hours
**Impact:** Consistent code style

---

#### ❌ 8.6 No Build Time Tracking [TODO]

**Problem:**
No metrics on build performance.

**Recommended:**

Add timing:
```r
#' Log Build Stage with Timing
#' @param stage Character: stage name
#' @param expr Expression to time
log_build_stage <- function(stage, expr) {
  start <- Sys.time()
  message(sprintf("\n=== %s ===", stage))

  result <- force(expr)

  duration <- difftime(Sys.time(), start, units = "secs")
  message(sprintf("✓ %s completed in %.1f seconds", stage, duration))

  invisible(result)
}

# Usage
log_build_stage("EN Render", {
  quarto::quarto_render(".", as_job = FALSE)
})
```

**Effort:** 1 hour
**Impact:** Helps identify slow build steps

---

#### ❌ 8.7 No Accessibility Checks [TODO]

**Problem:**
No validation that HTML is accessible (WCAG 2.1).

**Recommended:**

Add `pa11y` or `axe-core` to workflow:
```yaml
- name: Accessibility Check
  run: |
    npm install -g pa11y-ci
    pa11y-ci --sitemap https://patolojiatlasi.com/sitemap.xml
  continue-on-error: true
```

**Effort:** 2-3 hours
**Impact:** Better accessibility for users with disabilities

---

## IMPLEMENTATION ROADMAP

### Phase 1: Stabilization & Quick Wins (2-3 weeks)

**Goals:**
- Reduce code duplication
- Improve reliability
- Add basic validation

**Tasks:**
1. Create `/R/config.R` - Centralize configuration (2-3 hrs)
2. Create `/R/utils.R` - Extract shared functions (2-3 hrs)
3. Create `/R/setup-dependencies.R` - Unified package management (1-2 hrs)
4. Add error handling to major functions (3-4 hrs)
5. Fix renv usage (enable or remove) (1-2 hrs)
6. Add build validation (3-4 hrs)
7. Optimize CI cleanup operations (1-2 hrs)
8. Add workflow documentation (1-2 hrs)

**Estimated Effort:** 14-20 hours
**Impact:** Immediate reliability improvements

---

### Phase 2: Refactoring & Optimization (3-4 weeks)

**Goals:**
- Reduce config duplication
- Clean up workflow
- Improve build speed

**Tasks:**
1. Implement YAML config inheritance (4-6 hrs)
2. Extract workflow logic to `/R/render-language.R` (3-4 hrs)
3. Improve build caching (2-3 hrs)
4. Optimize image conversion (1-2 hrs)
5. Remove commented code clutter (1 hr)
6. Clean up orphaned directories (1-2 hrs)
7. Add roxygen2 documentation (3-4 hrs)

**Estimated Effort:** 15-22 hours
**Impact:** Easier maintenance, faster builds

---

### Phase 3: Documentation & Testing (2-3 weeks)

**Goals:**
- Enable contributions
- Prevent regressions
- Improve onboarding

**Tasks:**
1. Expand README.md (3-4 hrs)
2. Create CONTRIBUTING.md (2-3 hrs)
3. Create DEVELOPMENT.md (2-3 hrs)
4. Add inline code documentation (3-4 hrs)
5. Create test framework (4-5 hrs)
6. Add content validation (4-5 hrs)
7. Add link validation (2-3 hrs)

**Estimated Effort:** 20-27 hours
**Impact:** Better collaboration, quality assurance

---

### Phase 4: Long-term Improvements (4-6 weeks)

**Goals:**
- Reduce content duplication
- Improve content management
- Better dev/prod separation

**Tasks:**
1. Plan single-source bilingual content strategy (4-6 hrs)
2. Prototype translation approach (4-6 hrs)
3. Migrate 10 test cases to new system (6-8 hrs)
4. Create migration scripts for remaining content (4-6 hrs)
5. Add environment-specific configs (2-3 hrs)
6. Implement automated subchapter linking (4-5 hrs)
7. Add Git LFS for images (2-3 hrs)
8. Set up automated accessibility checks (2-3 hrs)

**Estimated Effort:** 28-40 hours
**Impact:** Long-term maintainability, scalability

---

## TOTAL EFFORT ESTIMATE

| Phase | Effort (hours) | Duration (weeks) | Priority |
|-------|----------------|------------------|----------|
| Phase 1: Stabilization | 14-20 | 2-3 | **CRITICAL** |
| Phase 2: Refactoring | 15-22 | 3-4 | **HIGH** |
| Phase 3: Documentation | 20-27 | 2-3 | **HIGH** |
| Phase 4: Long-term | 28-40 | 4-6 | **MEDIUM** |
| **TOTAL** | **77-109** | **11-16** | - |

---

## METRICS FOR SUCCESS

### Code Quality
- [ ] Reduce R script duplication by 75% (from ~150 duplicated lines to ~40)
- [ ] Reduce Quarto config duplication by 70% (from ~2,500 lines to ~500)
- [ ] Add 100+ inline documentation comments
- [ ] Achieve 80%+ test coverage for build scripts

### Build Performance
- [ ] Reduce CI build time by 30% (via caching, parallelization)
- [ ] Eliminate unnecessary `Sys.sleep()` calls
- [ ] Optimize image conversion (only convert changed files)

### Maintainability
- [ ] Single source of truth for configuration
- [ ] All build operations use shared utilities
- [ ] Comprehensive documentation (README 150+ lines, CONTRIBUTING, DEVELOPMENT)
- [ ] Validation catches 90%+ of build issues before CI

### Content Management
- [ ] Validate all WSI links (100% coverage)
- [ ] Zero orphaned subchapters
- [ ] All metadata validated against schema
- [ ] (Long-term) Reduce content files by 50% via single-source multilingual

---

## RISK ASSESSMENT

### Low Risk (Safe to implement immediately)
- Creating new utility files (utils.R, config.R, cleanup.R)
- Adding documentation (README, CONTRIBUTING, roxygen2 comments)
- Adding validation functions (non-breaking)
- Improving CI caching
- Adding tests

### Medium Risk (Requires testing but straightforward)
- Extracting workflow logic to functions
- Implementing YAML config inheritance
- Enabling renv in CI
- Refactoring language switching mechanism
- Optimizing image conversion

### High Risk (Requires careful planning and gradual migration)
- Single-source bilingual content refactor
- Changing file naming conventions
- Major directory reorganization
- Removing deprecated directories
- Breaking changes to build API

### Mitigation Strategies
1. **All changes:** Test locally before pushing
2. **Medium/High risk:** Use feature branches, thorough testing
3. **High risk:** Implement incrementally, maintain backward compatibility during transition
4. **All phases:** Keep old system working alongside new until migration complete

---

## RECOMMENDATIONS SUMMARY

### Do First (This Week)
1. ✅ Create `/R/config.R` and `/R/utils.R`
2. ✅ Add error handling and validation
3. ✅ Expand README.md
4. ✅ Fix renv (decide: use or remove)
5. ✅ Add build validation

### Do Next (This Month)
6. Implement YAML inheritance
7. Extract workflow logic
8. Add comprehensive documentation
9. Create test framework
10. Optimize CI caching

### Plan For Later (Next Quarter)
11. Single-source bilingual content migration
12. Automated content validation pipeline
13. Accessibility compliance
14. Performance monitoring
15. Git LFS for images

---

## QUESTIONS FOR PROJECT OWNER

Before implementing these recommendations, clarify:

1. **renv decision:** Should we use renv or remove it? (Current state is inconsistent)

2. **Backward compatibility:** How important is maintaining the exact current API/structure?

3. **Single-source bilingual:** Is a major content restructuring acceptable, or should we keep the current duplication?

4. **Image hosting:** Should screenshots remain in git, or move to external hosting/LFS?

5. **Testing requirements:** What level of test coverage is desired? (Unit only, or also integration/E2E?)

6. **Breaking changes:** Are breaking changes acceptable if they improve long-term maintainability?

7. **Time constraints:** What's the priority - quick improvements or comprehensive refactor?

---

## CONCLUSION

This project is **functional but has significant technical debt**. The biggest issues are:

1. **Code duplication** - 19+ instances of repeated logic
2. **Config duplication** - 70% duplication across 8 YAML files
3. **Content duplication** - 530 files for bilingual content
4. **Missing quality assurance** - No tests, validation, or link checking
5. **Insufficient documentation** - Hard for new contributors

The recommended **Phase 1** improvements (14-20 hours) will provide immediate benefits with minimal risk. Subsequent phases can be implemented based on project priorities and resources.

The project has a solid foundation and serves its purpose well. These improvements will make it more maintainable, reliable, and scalable for future growth.

---

**End of Analysis Report**
